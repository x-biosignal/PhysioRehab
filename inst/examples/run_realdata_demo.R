#!/usr/bin/env Rscript
# Real-signal demo: run a real OpenPose gait recording through the REAL
# PhysioMoCap pipeline (readOpenPose-equivalent -> poseFix -> knee kinematics)
# and ingest the derived measures as a rehab session. No synthetic numbers here.
#
#   Rscript inst/demo/run_realdata_demo.R  [openpose_dir]

cand <- c("R", file.path("..", "..", "R"))
rdir <- cand[dir.exists(cand)][1]
if (is.na(rdir)) stop("run from the package root")
for (f in list.files(rdir, pattern = "\\.R$", full.names = TRUE)) source(f)

# Locate the authentic OpenPose clip bundled with PoseFixeR.
opdir <- commandArgs(TRUE)[1]
if (is.na(opdir) || !dir.exists(opdir)) {
  guesses <- c(system.file("extdata", package = "PoseFixeR"),
               "../PoseFixeR/inst/extdata",
               "../../PoseFixeR/inst/extdata")
  opdir <- guesses[nzchar(guesses) & dir.exists(guesses)][1]
}
if (is.na(opdir)) stop("OpenPose data dir not found; pass it as an argument")
cat(sprintf("Real recording: %s\n\n", normalizePath(opdir)))

## 1) Real signal -> real measures (through the real PhysioMoCap pipeline) -----
m <- mocap_gait_measures(opdir, side = "R")
cat("===== 実信号から導出した実測値（PhysioMoCap poseFix 経由）=====\n")
cat(sprintf("  フレーム数        : %d\n", m$frames))
cat(sprintf("  膝ROM (deg)       : %.1f\n", m$knee_rom))
cat(sprintf("  膝角の平滑度      : raw %.2f -> poseFix %.2f  （%.0f%% 平滑化）\n",
            m$knee_smoothness_raw, m$knee_smoothness_fixed,
            100 * (1 - m$knee_smoothness_fixed / m$knee_smoothness_raw)))
cat(sprintf("  検出異常フラグ    : %.1f%%,  左右脚swap補正 %d\n\n",
            100 * m$flagged_fraction, m$leg_swaps))

## 2) Ingest the real recording as a rehab session ---------------------------
goal <- rehab_goal("G1", "歩行の質（膝運動の滑らかさ）を改善する",
                   icf_codes = c("b770", "d450"),
                   baseline = m$knee_smoothness_fixed, target = 3.0, unit = "index")
ep <- new_rehab_episode("PT-REAL-01", "脳卒中・片麻痺（実OpenPose）", "AB",
                        goals = list(goal))
ep <- add_session_from_mocap(ep, "2026-04-06", "baseline", opdir, side = "R")
print(ep)
cat("\n--- 取り込まれた実測セッション ---\n")
s <- ep$sessions
print(s[, intersect(c("session", "date", "phase", "knee_rom",
                      "knee_smoothness", "observation"), names(s))])

cat("\n----------------------------------------------------------------------\n")
cat("接続は本物です：実 OpenPose → poseFix → 膝キネマティクス → rehab_episode。\n")
cat("`add_session_from_mocap()` が、来院ごとの録画を1セッションに変換します。\n")
cat("完全な単一事例トラジェクトリ（基準相＋介入相の SCED）には反復録画が必要で、\n")
cat("公開データに縦断単一症例が無いため、多相ワークフロー実演は合成症例\n")
cat("（simulate_stroke_gait_case）を用います。測定の“形”は本デモと同一です。\n")
