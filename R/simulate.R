# ---------------------------------------------------------------------------
# A synthetic-but-realistic single-case: chronic stroke, left hemiplegia.
#
# AB design: 3 baseline sessions, then 9 intervention sessions over ~5 weeks.
# Comfortable gait speed rises from ~0.41 to ~0.69 m/s (crossing the ~0.16 m/s
# MCID). ICF qualifiers improve where expected -- gait pattern (b770), walking
# (d450), muscle power (b730) each fall one grade -- but muscle tone / spasticity
# (b735) stays put, an honest "not everything improves". GAS moves -1 -> +1.
# Numbers are illustrative; the point is the end-to-end shape.
# ---------------------------------------------------------------------------

#' Simulate a stroke hemiplegic-gait single-case episode
#'
#' @param seed RNG seed for reproducibility.
#' @return a populated `rehab_episode`.
#' @export
simulate_stroke_gait_case <- function(seed = 42) {
  if (!is.null(seed)) set.seed(seed)

  goal <- rehab_goal(
    id = "G1",
    statement = "6週間で屋内10mを杖なしで自立歩行する",
    icf_codes = c("d450", "d4500"),
    baseline = 0.40, target = 0.70, unit = "m/s")

  ep <- new_rehab_episode("PT-0007", "脳卒中・左片麻痺（慢性期）", "AB",
                          goals = list(goal))

  start <- as.Date("2026-04-06")

  # --- baseline (A): 3 sessions ---
  base_speed <- round(c(0.41, 0.39, 0.43) + stats::rnorm(3, 0, 0.008), 2)
  for (i in 1:3) {
    ep <- add_session(
      ep, start + (i - 1) * 2, "baseline",
      gait_speed = base_speed[i],
      cadence = round(78 + stats::rnorm(1, 0, 2)),
      symmetry = round(0.70 + stats::rnorm(1, 0, 0.02), 2),
      icf = list(b730 = 3, b735 = 3, b770 = 3, d450 = 3, d4500 = 3),
      gas = list(G1 = -1),
      observation = "杖使用、屋内短距離で監視レベル。麻痺側立脚期短縮。")
  }

  # --- intervention (B): 9 sessions over ~5 weeks ---
  b_true <- seq(0.46, 0.69, length.out = 9)
  b_speed <- round(b_true + stats::rnorm(9, 0, 0.012), 2)
  # qualifier schedules (lower = better); b735 spasticity unchanged (honest)
  sched <- list(
    b730 = c(3, 3, 3, 2, 2, 2, 2, 2, 2),
    b735 = c(3, 3, 3, 3, 3, 3, 3, 3, 3),
    b770 = c(3, 3, 2, 2, 2, 2, 2, 2, 2),
    d450 = c(3, 3, 3, 2, 2, 2, 2, 2, 2),
    d4500 = c(3, 3, 2, 2, 2, 2, 2, 2, 2))
  gas_sched <- c(-1, -1, 0, 0, 0, 0, 1, 1, 1)
  sym <- round(seq(0.74, 0.90, length.out = 9) + stats::rnorm(9, 0, 0.015), 2)

  for (j in 1:9) {
    ep <- add_session(
      ep, start + 6 + (j - 1) * 3, "intervention",
      gait_speed = b_speed[j],
      cadence = round(seq(82, 98, length.out = 9)[j] + stats::rnorm(1, 0, 2)),
      symmetry = sym[j],
      icf = list(b730 = sched$b730[j], b735 = sched$b735[j],
                 b770 = sched$b770[j], d450 = sched$d450[j],
                 d4500 = sched$d4500[j]),
      gas = list(G1 = gas_sched[j]),
      observation = if (j >= 7)
        "杖なしで屋内10m自立歩行可能。麻痺側立脚安定。" else
        "課題指向型歩行練習＋部分免荷。麻痺側荷重量増加。")
  }

  ep
}
