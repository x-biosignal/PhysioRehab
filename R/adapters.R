# ---------------------------------------------------------------------------
# Real-signal adapters: turn ecosystem signal output into rehab measures.
#
# The synthetic simulate_stroke_gait_case() is only for demos. In the clinic a
# session's measures come from real recordings. This adapter runs the REAL
# PhysioMoCap pipeline -- OpenPose keypoints -> poseFix (anomaly clean) -> knee
# kinematics -- and returns real, calibration-free measures a rehab_episode can
# carry. (Metric gait speed in m/s needs camera calibration; smoothness and
# range-of-motion are honest, unit-defined measures available from 2D pose.)
# ---------------------------------------------------------------------------

.angle3 <- function(ax, ay, bx, by, cx, cy) {
  # angle (deg) at vertex b formed by a-b-c, per frame (vectorised)
  v1x <- ax - bx; v1y <- ay - by
  v2x <- cx - bx; v2y <- cy - by
  dot <- v1x * v2x + v1y * v2y
  n <- sqrt(v1x^2 + v1y^2) * sqrt(v2x^2 + v2y^2)
  acos(pmax(-1, pmin(1, dot / n))) * 180 / pi
}

.smoothness <- function(x) mean(abs(diff(diff(x))), na.rm = TRUE)  # mean |2nd diff|

#' Real gait/kinematic measures from an OpenPose recording (via PhysioMoCap)
#'
#' Reads the COCO-18 OpenPose JSON frames, builds a PhysioExperiment, runs
#' [PhysioMoCap::poseFix], and derives real knee-kinematic measures for one side.
#'
#' @param openpose_dir directory of `openpose_data<N>.json` frames (COCO-18 flat).
#' @param side "R" or "L".
#' @param fps frame rate (Hz).
#' @return a list of real measures: knee_rom (deg), knee_smoothness_fixed and
#'   _raw (mean |2nd diff| of the knee angle, after / before poseFix), frames,
#'   flagged_fraction, leg_swaps.
#' @export
mocap_gait_measures <- function(openpose_dir, side = c("R", "L"), fps = 30) {
  side <- match.arg(side)
  for (p in c("PhysioMoCap", "PhysioCore", "S4Vectors",
              "SummarizedExperiment", "jsonlite"))
    if (!requireNamespace(p, quietly = TRUE))
      stop("package '", p, "' is required for the MoCap adapter", call. = FALSE)

  files <- list.files(openpose_dir, pattern = "openpose_data[0-9]+\\.json$",
                      full.names = TRUE)
  if (!length(files)) stop("no openpose_data*.json in ", openpose_dir)
  files <- files[order(as.integer(gsub("\\D", "", basename(files))))]

  coco <- c("nose", "neck", "Rshoulder", "Relbow", "Rwrist", "Lshoulder",
            "Lelbow", "Lwrist", "Rhip", "Rknee", "Rankle", "Lhip", "Lknee",
            "Lankle", "Reye", "Leye", "Rear", "Lear")
  mats <- lapply(files, function(f)
    matrix(jsonlite::fromJSON(readLines(f, warn = FALSE)), nrow = 18,
           byrow = TRUE))
  X <- t(vapply(mats, function(m) m[, 1], numeric(18)))
  Y <- t(vapply(mats, function(m) m[, 2], numeric(18)))
  P <- t(vapply(mats, function(m) m[, 3], numeric(18)))
  map <- c(neck = "Neck", Rshoulder = "RShoulder", Lshoulder = "LShoulder",
           Rhip = "RHip", Rknee = "RKnee", Rankle = "RAnkle",
           Lhip = "LHip", Lknee = "LKnee", Lankle = "LAnkle")
  labels <- ifelse(coco %in% names(map), map[coco], coco)
  colnames(X) <- colnames(Y) <- colnames(P) <- labels

  hip <- paste0(side, "Hip"); knee <- paste0(side, "Knee")
  ankle <- paste0(side, "Ankle")
  raw_angle <- .angle3(X[, hip], Y[, hip], X[, knee], Y[, knee],
                       X[, ankle], Y[, ankle])

  pe <- PhysioCore::PhysioExperiment(
    assays = S4Vectors::SimpleList(keypoint_x = X, keypoint_y = Y,
                                   confidence = P),
    colData = S4Vectors::DataFrame(label = labels, type = "keypoint",
                                   model = "COCO"),
    samplingRate = fps)
  fx <- poseFix_call(pe)
  rep <- S4Vectors::metadata(fx)$poseFix
  Xc <- as.matrix(SummarizedExperiment::assay(fx, "keypoint_x"))
  Yc <- as.matrix(SummarizedExperiment::assay(fx, "keypoint_y"))
  fixed_angle <- .angle3(Xc[, hip], Yc[, hip], Xc[, knee], Yc[, knee],
                         Xc[, ankle], Yc[, ankle])

  list(
    knee_rom = as.numeric(diff(range(fixed_angle, na.rm = TRUE))),
    knee_smoothness_fixed = .smoothness(fixed_angle),
    knee_smoothness_raw = .smoothness(raw_angle),
    frames = nrow(X),
    flagged_fraction = as.numeric(rep$fraction %||% NA),
    leg_swaps = as.integer(rep$leg_swaps %||% NA),
    side = side
  )
}

# poseFix lives in PhysioMoCap; call without attaching the whole namespace.
poseFix_call <- function(pe) PhysioMoCap::poseFix(pe, conf_threshold = 0.2)

#' Append a rehab session whose measures come from a real OpenPose recording
#'
#' @param ep a `rehab_episode`.
#' @param date,phase session date and phase.
#' @param openpose_dir directory of OpenPose JSON frames for this visit.
#' @param side "R"/"L".
#' @param observation optional clinician note (auto-filled if empty).
#' @return the updated `rehab_episode`, with real `knee_rom` / `knee_smoothness`.
#' @export
add_session_from_mocap <- function(ep, date, phase, openpose_dir,
                                   side = "R", observation = "") {
  m <- mocap_gait_measures(openpose_dir, side = side)
  if (!nzchar(observation))
    observation <- sprintf(
      "OpenPose実測（%dフレーム, poseFix適用, flagged %.0f%%, leg-swap %d）",
      m$frames, 100 * m$flagged_fraction, m$leg_swaps)
  add_session(ep, date, phase, gait_speed = NA,
              measures = list(knee_rom = m$knee_rom,
                              knee_smoothness = m$knee_smoothness_fixed),
              observation = observation)
}

# --- EMG adapter (PhysioEMG): muscle endurance / fatigue -------------------
# Runs the real PhysioEMG fatigue pipeline (median-frequency slope over the
# contraction) -> a muscle-endurance measure (ICF b740). A negative MDF slope
# means the frequency spectrum compresses = fatigue; less-negative over an
# episode = improved endurance.

#' Real muscle-fatigue / amplitude measures from an EMG recording (via PhysioEMG)
#'
#' @param emg_pe a PhysioExperiment holding raw EMG (e.g. from PhysioIO, or the
#'   realistic `PhysioEMG::make_emg_fatigue()` model).
#' @param feature "mdf" (median) or "mnf" (mean) frequency.
#' @return list: mdf_slope_hz_per_min, mdf_norm_slope_pct, fit_r2, rms.
#' @export
emg_fatigue_measures <- function(emg_pe, feature = c("mdf", "mnf")) {
  feature <- match.arg(feature)
  if (!requireNamespace("PhysioEMG", quietly = TRUE))
    stop("package 'PhysioEMG' is required for the EMG adapter", call. = FALSE)
  fs <- PhysioEMG::emgFatigueSlope(emg_pe, feature = feature, normalize = TRUE)
  rms <- tryCatch({
    af <- PhysioEMG::emgAmplitudeFeatures(emg_pe, features = "rms")
    mean(af[["rms"]], na.rm = TRUE)
  }, error = function(e) NA_real_)
  list(mdf_slope_hz_per_min = mean(fs$slope_hz_per_min, na.rm = TRUE),
       mdf_norm_slope_pct = mean(fs$norm_slope_pct_per_min, na.rm = TRUE),
       fit_r2 = mean(fs$r_squared, na.rm = TRUE), rms = rms)
}

#' Append a rehab session whose measures come from a real EMG recording
#'
#' @param ep a `rehab_episode`.
#' @param date session date (Date or string).
#' @param phase "baseline" or "intervention".
#' @param emg_pe a PhysioExperiment of raw EMG.
#' @param observation optional clinician note (auto-filled if empty).
#' @return the updated `rehab_episode`, with real `mdf_slope` / `emg_rms`.
#' @export
add_session_from_emg <- function(ep, date, phase, emg_pe, observation = "") {
  m <- emg_fatigue_measures(emg_pe)
  if (!nzchar(observation))
    observation <- sprintf("EMG実測（MDF傾き %.1f Hz/min, 適合 R^2 %.2f）",
                           m$mdf_slope_hz_per_min, m$fit_r2)
  add_session(ep, date, phase, gait_speed = NA,
              measures = list(mdf_slope = m$mdf_slope_hz_per_min,
                              emg_rms = m$rms),
              observation = observation)
}
