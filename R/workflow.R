# ---------------------------------------------------------------------------
# Pillar C, the "low floor": one guided call a GUI button would run.
#
# A therapist who cannot (yet) code clicks "Analyse this episode"; the GUI calls
# rehab_workflow(), which runs the SCED, evaluates the stated hypothesis, draws
# the trajectory, and drafts the progress note -- returning everything as a
# tidy object. Experts can still call the pieces directly (the "high ceiling"),
# and every run leaves a readable record, so the GUI doubles as an R on-ramp.
# ---------------------------------------------------------------------------

#' Run the full single-case rehab workflow (guided, one call)
#'
#' @param ep a `rehab_episode`.
#' @param hypothesis optional `rehab_hypothesis`.
#' @param measure primary measure column.
#' @param mcid MCID for the primary measure.
#' @param direction improvement direction.
#' @param out_dir directory for the trajectory PNG and progress-note Markdown.
#' @return (invisibly) list(sced, reasoning, report, plot_file, report_file).
#' @export
rehab_workflow <- function(ep, hypothesis = NULL, measure = "gait_speed",
                           mcid = 0.16, direction = "increase",
                           out_dir = tempdir()) {
  sced <- sced_analyze(ep, measure = measure, mcid = mcid, direction = direction)
  reasoning <- if (!is.null(hypothesis))
    evaluate_hypothesis(ep, hypothesis, sced) else NULL

  if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)
  plot_file <- file.path(out_dir, "trajectory.png")
  ok <- tryCatch({
    plot_trajectory(ep, measure = measure, mcid = mcid, file = plot_file,
                    ylab = "快適歩行速度 (m/s)")
    TRUE
  }, error = function(e) { message("plot skipped: ", conditionMessage(e)); FALSE })

  report <- draft_progress_note(ep, sced, reasoning, mcid = mcid)
  report_file <- file.path(out_dir, "progress_note.md")
  writeLines(report, report_file, useBytes = TRUE)

  invisible(list(sced = sced, reasoning = reasoning, report = report,
                 plot_file = if (ok) plot_file else NA_character_,
                 report_file = report_file))
}
