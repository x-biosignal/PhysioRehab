# ---------------------------------------------------------------------------
# Goal-referenced, individualised outcomes.
#
# Rehab targets disability and life-reconstruction, not disease: the unit of
# success is the individual's trajectory toward a PERSONAL goal, not a group
# effect. Goal Attainment Scaling (GAS) encodes that: each goal has a 5-point
# scale from -2 (much less than expected) to +2 (much more than expected),
# with 0 = the expected outcome. GAS makes a personalised goal quantitatively
# trackable without pretending it is a population biomarker.
# ---------------------------------------------------------------------------

#' Define a rehabilitation goal (ICF-linked, GAS-scaled)
#'
#' @param id short identifier, e.g. "G1".
#' @param statement free-text clinical goal (the patient's own words are ideal).
#' @param icf_codes character vector of ICF codes this goal maps to.
#' @param baseline,target numeric baseline and target on the primary measure.
#' @param unit measurement unit, e.g. "m/s".
#' @param gas optional named character vector describing GAS levels
#'   "-2","-1","0","+1","+2".
#' @return an object of class `rehab_goal`.
#' @export
rehab_goal <- function(id, statement, icf_codes, baseline, target, unit,
                       gas = NULL) {
  structure(
    list(id = id, statement = statement, icf_codes = icf_codes,
         baseline = baseline, target = target, unit = unit, gas = gas),
    class = "rehab_goal"
  )
}

.gas_label <- function(level) {
  labs <- c("-2" = "予想を大きく下回る",
            "-1" = "予想をやや下回る",
            "0"  = "予想どおり達成",
            "1"  = "予想をやや上回る",
            "2"  = "予想を大きく上回る")
  out <- labs[as.character(level)]
  out[is.na(out)] <- "未評価"
  unname(out)
}
