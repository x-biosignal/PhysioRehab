# Single-case (SCED) change detection -- the native paradigm of rehab.
# The neutral machinery now lives in PhysioAppKit; this file supplies only the
# rehab threshold (MCID) and remaps the engine's generic fields to the clinical
# vocabulary (beyond_threshold -> exceeds_mcid).

#' Analyse an episode's primary measure with SCED + MCID (via PhysioAppKit)
#'
#' @param ep a `rehab_episode`.
#' @param measure column name of the primary quantitative measure.
#' @param mcid minimal clinically important difference on that measure.
#' @param direction improvement direction.
#' @return a list with NAP, Tau, baseline mean, latest, MCID verdict, 2-SD band.
#' @export
sced_analyze <- function(ep, measure = "gait_speed", mcid = 0.16,
                         direction = c("increase", "decrease")) {
  direction <- match.arg(direction)
  s <- ep$sessions
  a <- s[[measure]][s$phase == "baseline"]
  b <- s[[measure]][s$phase == "intervention"]
  r <- PhysioAppKit::nonoverlap_analyze(a, b, threshold = mcid,
                                        direction = direction)  # band = 2*sd(a)
  c(r, list(measure = measure, direction = direction, mcid = mcid,
            exceeds_mcid = r$beyond_threshold, n_intervention = r$n_b))
}
