# ---------------------------------------------------------------------------
# The clinician-facing payoff: an auto-drafted, ICF-structured progress note.
#
# The adoption hook is workflow: allied-health staff already have to write a
# progress note every session. If the tool DRAFTS that note -- ICF-structured,
# with the SCED result, MCID verdict, GAS and an honest reasoning summary, all
# traceable -- the measurement and analysis ride along for free. This returns
# Markdown; PhysioReport renders it to the clinic's template.
# ---------------------------------------------------------------------------

#' Draft an ICF-structured progress note from an analysed episode
#'
#' @param ep a `rehab_episode`.
#' @param sced result of [sced_analyze].
#' @param reasoning optional result of [evaluate_hypothesis].
#' @param mcid MCID used (for the record).
#' @param constructs optional list of [new_icf_construct] objects; when supplied,
#'   a cross-modal capacity-vs-performance section is added.
#' @return a single Markdown string (also the object printed in the demo).
#' @export
draft_progress_note <- function(ep, sced, reasoning = NULL, mcid = sced$mcid,
                                constructs = NULL) {
  s <- ep$sessions
  period <- sprintf("%s 〜 %s", min(s$date), max(s$date))
  L <- c()
  add <- function(...) L[[length(L) + 1]] <<- paste0(...)

  add("# リハビリテーション経過記録（自動下書き）")
  add("")
  add(sprintf("- **患者**: %s　**病態**: %s　**単一事例計画**: %s",
              ep$patient_id, ep$condition, ep$design))
  add(sprintf("- **評価期間**: %s（全%d回：基準%d／介入%d）", period,
              nrow(s), sum(s$phase == "baseline"),
              sum(s$phase == "intervention")))
  add("")

  # --- Activity (d): the primary, life-level outcome ---
  add("## 活動（ICF d：生活レベルの主要アウトカム）")
  verdict <- if (isTRUE(sced$exceeds_mcid)) "**MCIDを超える臨床的に意味のある改善**"
             else "MCID未満（統計的変化はあっても臨床的意義は限定的）"
  add(sprintf("- **快適歩行速度**：基準平均 %.2f → 最新 %.2f m/s（Δ%.2f）。%s。",
              sced$baseline_mean, sced$latest, sced$delta, verdict))
  add(sprintf("- 単一事例効果量 **NAP=%.2f（%s）**、Tau=%.2f。2SD帯超えの介入点 %d/%d。",
              sced$nap, sced$interpretation, sced$tau,
              sced$band_beyond, sced$n_intervention))
  add(sprintf("  （MCID=%.2f m/s を判定基準に使用）", mcid))
  for (code in c("d450", "d4500")) {
    ch <- icf_change(ep, code)
    if (!is.null(ch))
      add(sprintf("- %s：%s → %s（qualifier %d→%d）", .icf_title(code),
                  icf_qualifier_label(ch$from), icf_qualifier_label(ch$to),
                  ch$from, ch$to))
  }
  add("")

  # --- Cross-modal capacity vs performance (ICF d, two qualifiers) ---
  if (length(constructs)) {
    add("## 能力↔実行の統合（ICF d：クロスモーダル）")
    for (cn in constructs) {
      g <- capacity_performance_gap(cn)
      if (is.na(g$gap)) {
        add(sprintf("- %s：能力または実行の測定が不足。", .icf_title(g$code)))
        next
      }
      add(sprintf(
        "- %s：能力(clinic) qualifier %d ／ 実行(free-living) qualifier %d → **ギャップ %+d**。%s",
        .icf_title(g$code), as.integer(g$capacity),
        as.integer(g$performance), as.integer(g$gap), g$interpretation))
    }
    add("")
  }

  # --- Body functions (b): the impairment level ---
  add("## 心身機能（ICF b：機能障害レベル）")
  for (code in c("b730", "b735", "b770")) {
    ch <- icf_change(ep, code)
    if (is.null(ch)) next
    tag <- if (ch$improved > 0) "改善" else if (ch$improved < 0) "悪化" else "不変"
    add(sprintf("- %s：%s → %s（%s）", .icf_title(code),
                icf_qualifier_label(ch$from), icf_qualifier_label(ch$to), tag))
  }
  add("")

  # --- Goal attainment ---
  if (length(ep$goals)) {
    add("## 目標達成（GAS）")
    for (g in ep$goals) {
      col <- paste0("gas_", g$id)
      if (col %in% names(s)) {
        fl <- PhysioAppKit::first_last(s[[col]])
        add(sprintf("- 「%s」：GAS %+d（%s）→ %+d（%s）",
                    g$statement, fl[1], .gas_label(fl[1]),
                    fl[2], .gas_label(fl[2])))
      } else {
        add(sprintf("- 「%s」", g$statement))
      }
    }
    add("")
  }

  # --- Clinical reasoning (honest, in-the-loop) ---
  if (!is.null(reasoning)) {
    add("## 臨床推論（仮説→根拠）")
    add(sprintf("- **仮説**：%s", reasoning$statement))
    add(sprintf("- **総合判定**：%s", reasoning$overall))
    for (it in reasoning$items) {
      mark <- if (is.na(it$supported)) "－" else if (it$supported) "○" else "×"
      add(sprintf("  - [%s] %s — %s", mark, it$claim, it$evidence))
    }
    add("")
  }

  # --- Provenance / defensibility ---
  add("## 根拠・追跡可能性")
  add(sprintf("- 手法：NAP（Parker & Vannest 2009, 分布によらない単一事例効果量）、2SD帯、MCID判定。"))
  add(sprintf("- データ：%d セッションの実測値に基づく。全数値は各セッション記録に追跡可能。",
              nrow(s)))
  add("- ※ 本記録は下書きです。最終判断はセラピストが行い、必要に応じて修正してください。")

  paste(unlist(L), collapse = "\n")
}
