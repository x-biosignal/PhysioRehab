# Single-case trajectory plot -- delegates to PhysioAppKit::phase_plot; the only
# domain differences are the MCID target line and an amber intervention palette.

#' Plot a single-case trajectory with phase line, 2-SD band and MCID target
#' @param ep a `rehab_episode`.
#' @param measure primary measure column.
#' @param mcid MCID (drawn as the target line above baseline mean).
#' @param file optional PNG path; if NULL, draws to the current device.
#' @param ylab y-axis label.
#' @return (invisibly) the file path, or NULL.
#' @export
plot_trajectory <- function(ep, measure = "gait_speed", mcid = 0.16,
                            file = NULL, ylab = NULL) {
  s <- ep$sessions
  y <- s[[measure]]; x <- s$session
  a_idx <- which(s$phase == "baseline"); b_idx <- which(s$phase == "intervention")
  bmean <- mean(y[a_idx], na.rm = TRUE); bsd <- stats::sd(y[a_idx], na.rm = TRUE)
  PhysioAppKit::phase_plot(
    x, y, a_idx, b_idx, center = bmean, lo = bmean - 2 * bsd, hi = bmean + 2 * bsd,
    thr = bmean + mcid, thr_lab = "MCID目標",
    ylab = ylab %||% measure,
    main = sprintf("単一事例トラジェクトリ：%s（%s）", ep$patient_id, ep$condition),
    a_lab = "基準(A)", b_lab = "介入(B)",
    b_col = "#d95f0e", b_bg = "#fec44f", file = file)
}
