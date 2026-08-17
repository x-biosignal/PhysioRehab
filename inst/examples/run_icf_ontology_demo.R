#!/usr/bin/env Rscript
# ICF is now backed by the real ontology (PhysioAnnotationHub), not a hard-coded
# table: measure->ICF links come from the maintained ICF-linking rules, and
# canonical (English) titles are read from the hub.
#   Rscript inst/demo/run_icf_ontology_demo.R
cand <- c("R", file.path("..", "..", "R"))
rdir <- cand[dir.exists(cand)][1]; if (is.na(rdir)) stop("run from package root")
for (f in list.files(rdir, pattern = "\\.R$", full.names = TRUE)) source(f)

cat("===== 測定 -> ICF（実オントロジ PhysioAnnotationHub 経由）=====\n")
for (m in c("gait_speed", "cadence", "knee_rom")) {
  codes <- icf_for_measure(m)
  cat(sprintf("  %-11s -> %s\n", m,
              if (length(codes)) paste(codes, collapse = ", ")
              else "（未登録：ハブに mapping を登録すべき）"))
}
cat("\n===== ICF タイトル（EN=ハブ由来 / JA=ローカル）=====\n")
for (code in c("b730", "b770", "d450")) {
  cat(sprintf("  %-6s EN: %-28s JA: %s\n", code,
              sub(paste0(code, " "), "", .icf_title(code, "en")),
              sub(paste0(code, " "), "", .icf_title(code, "ja"))))
}
cat("\n注：gait_speed->d450 はハブの ICF リンク規則（Cieza 2005）に基づく実マッピング。\n")
cat("信号由来の独自指標（knee_rom 等）は honest な未登録＝ハブ側に登録して拡張する。\n")
