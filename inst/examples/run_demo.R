#!/usr/bin/env Rscript
# End-to-end prototype demo: simulate a single stroke-gait case, run the guided
# workflow, and emit the clinician-facing artefacts (progress note + trajectory).
#
# Run from the package root:  Rscript inst/demo/run_demo.R

# Locate R/ whether launched from the package root or from inst/demo.
cand <- c("R", file.path("..", "..", "R"))
rdir <- cand[dir.exists(cand)][1]
if (is.na(rdir)) stop("cannot locate R/ source dir; run from package root")
for (f in list.files(rdir, pattern = "\\.R$", full.names = TRUE)) source(f)

out_dir <- file.path(tempdir(), "physiorehab_demo")

ep <- simulate_stroke_gait_case(seed = 42)
print(ep)

hyp <- rehab_hypothesis(
  statement = "課題指向型歩行練習により、快適歩行速度がMCIDを超えて改善し、ICF d450(歩行)とb735(痙縮)がそれぞれ1段階以上改善する",
  expect_speed_mcid = TRUE,
  expect_icf = c(d450 = 1, b735 = 1))   # b735 is deliberately over-optimistic

res <- rehab_workflow(ep, hypothesis = hyp, mcid = 0.16, out_dir = out_dir)

cat("\n================= 自動下書き経過記録 =================\n\n")
cat(res$report)
cat("\n\n======================================================\n")
cat(sprintf("SCED: NAP=%.2f (%s), Δ=%.2f m/s, MCID超え=%s\n",
            res$sced$nap, res$sced$interpretation, res$sced$delta,
            res$sced$exceeds_mcid))
cat(sprintf("推論総合判定: %s\n", res$reasoning$overall))
cat(sprintf("成果物:\n  - 経過記録: %s\n  - 軌跡図  : %s\n",
            res$report_file, res$plot_file))
