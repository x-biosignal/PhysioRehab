# ---------------------------------------------------------------------------
# ADL coverage registry: which ADL can be measured, by which modality, on which
# ICF qualifier.
#
# A comprehensive ADL system is not just a pile of measures -- it is knowing,
# for every activity of daily living, whether it can be measured at all, by how
# many modalities, and on both the capacity (clinic / standardised) and the
# performance (real-world) qualifier. This registry encodes what the ecosystem
# can actually measure today, so the system can report its own coverage and a
# single patient's icf_construct can be checked for gaps ("d550 eating: capacity
# covered by the Barthel item; performance not yet measured"). Convention:
# standardised / clinic measures are capacity, free-living measures are
# performance.
# ---------------------------------------------------------------------------

# code, title, modality, qualifier, method, package
.adl_registry <- function() {
  # status: "validated" = proven on real data or a verified/established measure;
  #         "supported" = pipeline + ICF mapping ready, but no task-specific model
  #         / dataset validated yet (honest distinction, not over-claimed).
  r <- function(code, title, modality, qualifier, method, package, status)
    data.frame(code = code, title = title, modality = modality,
               qualifier = qualifier, method = method, package = package,
               status = status, stringsAsFactors = FALSE)
  do.call(rbind, list(
    # --- Mobility (d4) ---
    r("d410", "Changing basic body position", "kinematics", "capacity", "instrumentedTUG", "PhysioMoCap", "validated"),
    r("d410", "Changing basic body position", "sensor_har", "performance", "recognizeADL", "PhysioWearable", "supported"),
    r("d415", "Maintaining a body position", "kinematics", "capacity", "balance/COP", "PhysioMoCap", "validated"),
    r("d415", "Maintaining a body position", "sensor_har", "performance", "recognizeADL", "PhysioWearable", "validated"),
    r("d420", "Transferring oneself", "scale", "capacity", "scoreFIM", "PhysioClinical", "validated"),
    r("d440", "Fine hand use", "dexterity", "capacity", "nhptDexterity", "PhysioMoCap", "validated"),
    r("d445", "Hand and arm use", "scale", "capacity", "scoreARAT/scoreWMFT/scoreFMAUE", "PhysioClinical", "validated"),
    r("d445", "Hand and arm use", "kinematics", "capacity", "adlReachTask/reachingKinematics", "PhysioMoCap", "validated"),
    r("d445", "Hand and arm use", "emg", "capacity", "emgADLActivation", "PhysioEMG", "validated"),
    r("d445", "Hand and arm use", "sensor_freeliving", "performance", "upperLimbUse", "PhysioWearable", "validated"),
    r("d450", "Walking", "scale", "capacity", "scoreBarthel/score10MWT/score6MWT", "PhysioClinical", "validated"),
    r("d450", "Walking", "performance_test", "capacity", "scoreTUG", "PhysioClinical", "validated"),
    r("d450", "Walking", "kinematics", "capacity", "gaitDeviationIndex/gaitProfileScore", "PhysioMoCap", "validated"),
    r("d450", "Walking", "sensor_freeliving", "performance", "summarizeFreeLiving", "PhysioWearable", "validated"),
    r("d450", "Walking", "sensor_har", "performance", "recognizeADL", "PhysioWearable", "validated"),
    r("d455", "Moving around", "scale", "capacity", "scoreBarthel(stairs)", "PhysioClinical", "validated"),
    r("d455", "Moving around", "sensor_har", "performance", "recognizeADL", "PhysioWearable", "validated"),
    # --- Self-care (d5) ---
    r("d510", "Washing oneself", "scale", "capacity", "scoreBarthel/scoreKatz/scoreFIM", "PhysioClinical", "validated"),
    r("d510", "Washing oneself", "sensor_har", "performance", "recognizeADL(wash-hands; HTAD N=3, recall 0.53)", "PhysioWearable", "validated"),
    r("d520", "Caring for body parts", "scale", "capacity", "scoreBarthel/scoreFIM", "PhysioClinical", "validated"),
    r("d520", "Caring for body parts", "kinematics", "capacity", "adlReachTask(grooming)", "PhysioMoCap", "validated"),
    r("d520", "Caring for body parts", "sensor_har", "performance", "recognizeADL(grooming; HMP-validated)", "PhysioWearable", "validated"),
    r("d530", "Toileting", "scale", "capacity", "scoreBarthel/scoreKatz/scoreFIM", "PhysioClinical", "validated"),
    r("d530", "Toileting", "sensor_har", "performance", "recognizeADL(toileting gesture)", "PhysioWearable", "supported"),
    r("d540", "Dressing", "scale", "capacity", "scoreBarthel/scoreKatz/scoreFIM", "PhysioClinical", "validated"),
    r("d540", "Dressing", "kinematics", "capacity", "adlReachTask(dressing)", "PhysioMoCap", "validated"),
    r("d540", "Dressing", "sensor_har", "performance", "recognizeADL(dressing gesture)", "PhysioWearable", "supported"),
    r("d550", "Eating", "scale", "capacity", "scoreBarthel/scoreKatz/scoreFIM", "PhysioClinical", "validated"),
    r("d550", "Eating", "kinematics", "capacity", "adlReachTask(feeding)", "PhysioMoCap", "validated"),
    r("d550", "Eating", "emg", "capacity", "emgADLActivation(feeding)", "PhysioEMG", "validated"),
    r("d550", "Eating", "sensor_har", "performance", "recognizeADL(eating; HMP leave-one-subject-out recall 0.00 -- not distinguished from other hand-to-face gestures)", "PhysioWearable", "supported"),
    r("d560", "Drinking", "kinematics", "capacity", "adlReachTask(drinking)", "PhysioMoCap", "validated"),
    r("d560", "Drinking", "emg", "capacity", "emgADLActivation(drinking)", "PhysioEMG", "validated"),
    r("d560", "Drinking", "sensor_har", "performance", "recognizeADL(drinking; HMP-validated)", "PhysioWearable", "validated"),
    r("d570", "Looking after one's health", "sensor_freeliving", "performance", "summarizeFreeLiving", "PhysioWearable", "validated"),
    # --- Domestic life / IADL (d6) ---
    r("d620", "Acquisition of goods and services", "scale", "capacity", "scoreLawton(shopping)", "PhysioClinical", "validated"),
    r("d630", "Preparing meals", "scale", "capacity", "scoreLawton(food_preparation)", "PhysioClinical", "validated"),
    r("d630", "Preparing meals", "sensor_har", "performance", "recognizeADL(cooking)", "PhysioWearable", "supported"),
    r("d640", "Doing housework", "scale", "capacity", "scoreLawton(housekeeping/laundry)", "PhysioClinical", "validated"),
    r("d640", "Doing housework", "sensor_har", "performance", "recognizeADL(vacuuming/ironing)", "PhysioWearable", "validated"),
    r("d470", "Using transportation", "scale", "capacity", "scoreLawton(transportation)", "PhysioClinical", "validated")
  ))
}

#' ADL measurement-coverage registry
#'
#' What the ecosystem can measure for each ADL: the ICF Activities & Participation
#' code, the measurement modality (`scale`, `performance_test`, `kinematics`,
#' `emg`, `dexterity`, `sensor_freeliving`, `sensor_har`), the ICF qualifier it
#' informs (`capacity` for standardised/clinic measures, `performance` for
#' real-world ones), and the function that provides it.
#'
#' @param code Optional ICF code(s) to filter to.
#' @param qualifier Optional `"capacity"`/`"performance"` filter.
#' @return a data.frame with `code`, `title`, `modality`, `qualifier`, `method`,
#'   `package` and `status` (`"validated"` = proven on real data or an
#'   established/verified measure; `"supported"` = pipeline + ICF mapping ready
#'   but not yet validated on a task-specific dataset).
#' @seealso [adl_coverage_summary()], [construct_coverage()]
#' @export
#' @examples
#' adl_coverage("d640")
adl_coverage <- function(code = NULL, qualifier = NULL) {
  reg <- .adl_registry()
  if (!is.null(code)) reg <- reg[reg$code %in% code, , drop = FALSE]
  if (!is.null(qualifier)) reg <- reg[reg$qualifier %in% qualifier, , drop = FALSE]
  rownames(reg) <- NULL
  reg
}

#' Per-ADL coverage completeness
#'
#' Summarises, for each ADL code in the registry, how many modalities measure it
#' and whether it is covered on the capacity and the performance qualifier -- and
#' hence whether it is genuinely multi-modal.
#'
#' @return a data.frame `code`, `title`, `n_modalities`, `has_capacity`,
#'   `has_performance`, `validated_performance` (at least one performance method
#'   proven on real data, not merely pipeline-ready) and `multimodal` (both
#'   qualifiers), with an attribute `overall` giving ecosystem-level percentages
#'   including `pct_validated_performance`.
#' @seealso [adl_coverage()]
#' @export
#' @examples
#' adl_coverage_summary()
adl_coverage_summary <- function() {
  reg <- .adl_registry()
  codes <- unique(reg$code)
  out <- do.call(rbind, lapply(codes, function(cc) {
    s <- reg[reg$code == cc, , drop = FALSE]
    perf <- s[s$qualifier == "performance", , drop = FALSE]
    data.frame(code = cc, title = s$title[1],
               n_modalities = length(unique(s$modality)),
               has_capacity = "capacity" %in% s$qualifier,
               has_performance = nrow(perf) > 0,
               validated_performance = any(perf$status == "validated"),
               stringsAsFactors = FALSE)
  }))
  out$multimodal <- out$has_capacity & out$has_performance
  out <- out[order(-out$n_modalities, out$code), ]
  rownames(out) <- NULL
  attr(out, "overall") <- c(
    n_adl = nrow(out),
    pct_capacity = round(100 * mean(out$has_capacity)),
    pct_performance = round(100 * mean(out$has_performance)),
    pct_validated_performance = round(100 * mean(out$validated_performance)),
    pct_multimodal = round(100 * mean(out$multimodal)))
  out
}

#' Coverage of a patient's ICF construct against the registry
#'
#' For the domain of one [new_icf_construct], reports which measurement
#' modalities the ecosystem offers (from [adl_coverage()]) and which qualifiers
#' the construct has actually populated, flagging the gaps -- the modalities that
#' are available but not yet used for this individual.
#'
#' @param construct an `icf_construct`.
#' @return a list: `code`, `title`, `has_capacity`/`has_performance` (in the
#'   construct), `available` (registry rows for the code) and `missing_qualifiers`
#'   (registry qualifiers with an available method but no observation yet).
#' @seealso [adl_coverage()], [capacity_performance_gap()]
#' @export
construct_coverage <- function(construct) {
  stopifnot(inherits(construct, "icf_construct"))
  avail <- adl_coverage(code = construct$code)
  obs <- construct$observations
  has_cap <- any(obs$qualifier_type == "capacity")
  has_perf <- any(obs$qualifier_type == "performance")
  present <- c(if (has_cap) "capacity", if (has_perf) "performance")
  missing_q <- setdiff(unique(avail$qualifier), present)
  list(code = construct$code, title = construct$title,
       has_capacity = has_cap, has_performance = has_perf,
       available = avail, missing_qualifiers = missing_q)
}
