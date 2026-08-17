# ---------------------------------------------------------------------------
# Pillar B: hypothesis -> evidence reasoning scaffold.
#
# Rehab reasoning is qualitative and hypothesis-driven. The tool does not
# replace the clinician's judgement; it SCAFFOLDS it: the clinician states an
# expectation ("intervention will push gait speed past MCID and improve ICF
# d450 by >=1"), and the tool reports, item by item, whether the data support
# it -- and, crucially, honestly flags what is NOT supported. This is the same
# discipline as the ecosystem's provenance substrate (grounding claims, catching
# over-claiming / HARKing), turned toward clinical inference.
# ---------------------------------------------------------------------------

#' State a clinical hypothesis about expected change
#'
#' @param statement free-text clinical hypothesis.
#' @param expect_speed_mcid logical: expect the primary measure to exceed MCID.
#' @param expect_icf named integer vector of ICF codes -> minimum expected
#'   qualifier improvement, e.g. `c(d450 = 1, b735 = 1)`.
#' @return an object of class `rehab_hypothesis`.
#' @export
rehab_hypothesis <- function(statement, expect_speed_mcid = TRUE,
                             expect_icf = c(d450 = 1)) {
  structure(list(statement = statement,
                 expect_speed_mcid = expect_speed_mcid,
                 expect_icf = expect_icf),
            class = "rehab_hypothesis")
}

#' Evaluate a hypothesis against the episode's evidence
#'
#' @param ep a `rehab_episode`.
#' @param hyp a `rehab_hypothesis`.
#' @param sced the result of [sced_analyze] on the primary measure.
#' @return list(verdict, overall, items) where each item is one checked
#'   expectation with its supported/refuted status and the evidence used.
#' @export
evaluate_hypothesis <- function(ep, hyp, sced) {
  items <- list()

  if (isTRUE(hyp$expect_speed_mcid)) {
    supported <- isTRUE(sced$exceeds_mcid)
    items[[length(items) + 1]] <- list(
      claim = sprintf("%s がMCID(%.2f)を超えて改善", sced$measure, sced$mcid),
      supported = supported,
      evidence = sprintf("Δ=%.2f %s（基準平均%.2f→最新%.2f）, NAP=%.2f（%s）",
                         sced$delta, if (supported) "≥MCID" else "<MCID",
                         sced$baseline_mean, sced$latest,
                         sced$nap, sced$interpretation)
    )
  }

  for (code in names(hyp$expect_icf)) {
    need <- hyp$expect_icf[[code]]
    ch <- icf_change(ep, code)
    if (is.null(ch)) {
      items[[length(items) + 1]] <- list(
        claim = sprintf("ICF %s が%d段階以上改善", code, need),
        supported = NA, evidence = "該当ICFの記録なし（判定不能）")
    } else {
      supported <- ch$improved >= need
      items[[length(items) + 1]] <- list(
        claim = sprintf("ICF %s が%d段階以上改善", code, need),
        supported = supported,
        evidence = sprintf("qualifier %d→%d（%d段階改善）",
                           ch$from, ch$to, ch$improved))
    }
  }

  structure(list(statement = hyp$statement,
                 overall = PhysioAppKit::combine_verdicts(items), items = items),
            class = "rehab_reasoning")
}
