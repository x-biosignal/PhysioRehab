#!/usr/bin/env Rscript
# Rasch (ordinal -> interval) for a rehab ADL/mobility instrument. A raw sum of
# pass/fail items is NOT linear: the same +2-item gain means a different real
# gain at the floor than in the middle. Tracking raw score misleads; the Rasch
# interval measure is the honest one for single-case change.
#   Rscript inst/demo/run_rasch_demo.R
suppressMessages(library(PhysioAppKit))

# 1) Calibrate a 12-item pass/fail mobility checklist on a reference sample.
set.seed(1)
I <- 12; N <- 150
tasks <- sprintf("m%02d", 1:I)
delta_true <- sort(seq(-2.2, 2.2, length.out = I))
theta <- stats::rnorm(N, 0, 1.4)
x <- outer(theta, delta_true, function(t, d) stats::rbinom(length(t), 1, stats::plogis(t - d)))
colnames(x) <- tasks
fit <- rasch_measure(x)
cat(sprintf("Rasch calibration: %d items, %d persons | 収束=%s, 難易度回復 r=%.3f\n\n",
            I, N, fit$converged, cor(delta_true, fit$delta, use = "complete")))

tab <- raw_score_measure(fit$delta)

# 2) One patient across 4 sessions from the floor up: equal RAW gains (+2 each).
patient_raw <- c(1, 3, 5, 7)
measure <- tab$measure[match(patient_raw, tab$raw)]
d_raw <- c(NA, diff(patient_raw))
d_int <- c(NA, round(diff(measure), 3))

cat("===== 患者の経過（同じ生スコア +2 でも、区間尺度の変化量は異なる）=====\n")
df <- data.frame(session = 1:4, raw_score = patient_raw,
                 rasch_measure = round(measure, 3),
                 raw_change = d_raw, interval_change = d_int)
print(df, row.names = FALSE)

cat(sprintf("\n生スコアは各回 +2 で一定に見えるが、実際の改善（logit）は %.2f→%.2f と%s。\n",
            d_int[2], d_int[4], if (d_int[4] > d_int[2]) "後半ほど大きい" else "前半ほど大きい"))
cat("＝ 生スコアで「一定の改善」と読むと臨床判断を誤る。区間尺度（Rasch）で追うべき。\n")
cat("（本来は施設校正済みの項目難易度を用いる。ICF 連携項目にも同じ較正が可能。）\n")
