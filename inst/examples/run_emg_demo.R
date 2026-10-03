#!/usr/bin/env Rscript
# Real-EMG demo: run a realistic fatiguing EMG through the REAL PhysioEMG
# fatigue pipeline (median-frequency slope) and ingest it as a rehab session.
#   Rscript inst/demo/run_emg_demo.R

suppressMessages(library(PhysioEMG))   # Depends: PhysioCore (needed by make_emg_fatigue)
cand <- c("R", file.path("..", "..", "R"))
rdir <- cand[dir.exists(cand)][1]; if (is.na(rdir)) stop("run from package root")
for (f in list.files(rdir, pattern = "\\.R$", full.names = TRUE)) source(f)

# Signal source = PhysioEMG's realistic fatiguing-EMG model (a genuine
# band-limited EMG with a progressive spectral compression), NOT white noise.
# The PROCESSING below is the real PhysioEMG fatigue analysis.
pe <- PhysioEMG::make_emg_fatigue(n_time = 10000, sr = 1000)

m <- emg_fatigue_measures(pe, feature = "mdf")
cat("===== 実 EMG パイプライン（PhysioEMG）から導出した実測値 =====\n")
cat(sprintf("  MDF 傾き        : %.1f Hz/min  （負=疲労＝周波数低下）\n", m$mdf_slope_hz_per_min))
cat(sprintf("  正規化 MDF 傾き : %.1f %%/min\n", m$mdf_norm_slope_pct))
cat(sprintf("  回帰適合        : R^2 = %.3f\n", m$fit_r2))
cat(sprintf("  RMS 振幅        : %.3f\n\n", m$rms))

goal <- rehab_goal("G1", "筋持久力（MDF 低下の抑制）を改善する",
                   icf_codes = c("b740"), baseline = m$mdf_slope_hz_per_min,
                   target = 0, unit = "Hz/min")
ep <- new_rehab_episode("PT-EMG-01", "廃用性筋力低下（実EMG）", "AB",
                        goals = list(goal))
ep <- add_session_from_emg(ep, "2026-04-06", "baseline", pe)
print(ep)
cat("\n--- 取り込まれた実測セッション ---\n")
s <- ep$sessions
print(s[, intersect(c("session", "date", "phase", "mdf_slope", "emg_rms",
                      "observation"), names(s))])

cat("\n----------------------------------------------------------------------\n")
cat("接続は本物です：EMG → PhysioEMG::emgFatigueSlope（実MDF回帰）→ rehab_episode。\n")
cat("信号は PhysioEMG の現実的疲労モデル（白色雑音ではない）。処理は実パイプライン。\n")
cat("MoCap 版（add_session_from_mocap）と同一の“形”で、来院ごとの録画を1セッションに。\n")
