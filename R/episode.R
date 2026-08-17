# ---------------------------------------------------------------------------
# The rehab_episode: one patient's individualised trajectory.
#
# A single-case container of repeated measures over therapy sessions, tagged
# by phase (baseline / intervention), fusing QUANTITATIVE signals (gait speed,
# cadence, symmetry -- from the ecosystem's signal packages) with QUALITATIVE
# ICF qualifiers and GAS goal ratings, plus the clinician's free-text
# observation. This is the object a clinician-facing GUI drives session by
# session. In production it wraps PhysioCore::PhysioLongitudinal.
# ---------------------------------------------------------------------------

#' Create an empty rehabilitation episode (single-case)
#'
#' @param patient_id de-identified patient id.
#' @param condition free-text condition, e.g. "stroke, left hemiplegia".
#' @param design single-case design label, e.g. "AB".
#' @param goals list of [rehab_goal] objects.
#' @return an object of class `rehab_episode`.
#' @export
new_rehab_episode <- function(patient_id, condition, design = "AB",
                              goals = list()) {
  structure(
    list(patient_id = patient_id, condition = condition, design = design,
         goals = goals, sessions = data.frame()),
    class = "rehab_episode"
  )
}

#' Record one therapy session
#'
#' @param ep a `rehab_episode`.
#' @param date session date (Date or string).
#' @param phase "baseline" or "intervention".
#' @param gait_speed comfortable gait speed (m/s), the primary measure.
#' @param cadence,symmetry secondary quantitative measures (optional).
#' @param icf named list of ICF qualifiers, e.g. `list(b770 = 3, d450 = 3)`.
#' @param gas named list of GAS ratings keyed by goal id, e.g. `list(G1 = -1)`.
#' @param observation clinician's free-text qualitative note.
#' @return the updated `rehab_episode`.
#' @export
#' @param measures named list of additional quantitative measures (arbitrary
#'   columns), e.g. `list(knee_rom = 47.2)` for signal-derived measures.
add_session <- function(ep, date, phase, gait_speed = NA, cadence = NA,
                        symmetry = NA, measures = list(), icf = list(),
                        gas = list(), observation = "") {
  stopifnot(inherits(ep, "rehab_episode"))
  phase <- match.arg(phase, c("baseline", "intervention"))
  row <- data.frame(
    session = nrow(ep$sessions) + 1L,
    date = as.Date(date),
    phase = phase,
    gait_speed = as.numeric(gait_speed),
    cadence = as.numeric(cadence),
    symmetry = as.numeric(symmetry),
    observation = as.character(observation),
    stringsAsFactors = FALSE
  )
  for (m in names(measures)) row[[m]]              <- as.numeric(measures[[m]])
  for (code in names(icf))   row[[paste0("icf_", code)]] <- icf[[code]]
  for (g in names(gas))      row[[paste0("gas_", g)]]    <- gas[[g]]
  ep$sessions <- PhysioAppKit::rbind_fill(ep$sessions, row)
  ep
}

#' ICF qualifier change across an episode (improvement = qualifier decreases)
#'
#' @param ep a `rehab_episode`.
#' @param code ICF code, e.g. "d450".
#' @return list(code, from, to, improved) where `improved` > 0 means the
#'   qualifier fell (clinical improvement). NULL if the code was never recorded.
#' @export
icf_change <- function(ep, code) {
  col <- paste0("icf_", code)
  if (!col %in% names(ep$sessions)) return(NULL)
  fl <- PhysioAppKit::first_last(ep$sessions[[col]])
  if (any(is.na(fl))) return(NULL)
  list(code = code, from = fl[1], to = fl[2], improved = fl[1] - fl[2])
}

#' @export
print.rehab_episode <- function(x, ...) {
  cat(sprintf("<rehab_episode> patient=%s | %s | design=%s\n",
              x$patient_id, x$condition, x$design))
  cat(sprintf("  sessions: %d (%s baseline / %s intervention)\n",
              nrow(x$sessions),
              sum(x$sessions$phase == "baseline"),
              sum(x$sessions$phase == "intervention")))
  cat(sprintf("  goals: %d\n", length(x$goals)))
  invisible(x)
}
