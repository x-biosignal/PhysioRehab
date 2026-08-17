# ---------------------------------------------------------------------------
# Pillar A: ICF-native semantic layer.
#
# The ICF (International Classification of Functioning, Disability and Health,
# WHO) is the shared language of rehabilitation -- taught to every PT/OT/ST.
# Any tool that wants to "speak rehab" must anchor its measures, goals and
# observations to ICF codes. This is the domain data model, the rehab analogue
# of what SummarizedExperiment is for genomics.
#
# Prototype scope: a curated core-set subset relevant to stroke hemiplegic gait.
# In production this catalogue is served by PhysioAnnotationHub.
# ---------------------------------------------------------------------------

#' ICF catalogue (stroke gait core-set subset)
#'
#' @return A data.frame of ICF codes: `code`, `component`, `title_en`, `title_ja`.
#' @export
icf_catalog <- function() {
  data.frame(
    code = c("b730", "b735", "b770", "d450", "d4500", "d4501", "e1201"),
    component = c("BodyFunction", "BodyFunction", "BodyFunction",
                  "Activity", "Activity", "Activity", "Environmental"),
    title_en = c("Muscle power functions",
                 "Muscle tone functions",
                 "Gait pattern functions",
                 "Walking",
                 "Walking short distances",
                 "Walking long distances",
                 "Assistive products for personal indoor/outdoor mobility"),
    title_ja = c("筋力の機能",
                 "筋緊張（痙縮）の機能",
                 "歩行パターンの機能",
                 "歩行",
                 "短距離歩行",
                 "長距離歩行",
                 "移動のための補助製品（杖等）"),
    stringsAsFactors = FALSE
  )
}

#' Label an ICF qualifier (0-4 severity)
#'
#' ICF body-function / activity qualifiers: 0 no problem .. 4 complete problem.
#' Lower is better; improvement means the qualifier decreases.
#'
#' @param q integer qualifier 0..4 (vectorised).
#' @return character labels.
#' @export
icf_qualifier_label <- function(q) {
  labs <- c("0" = "問題なし",       # no problem
            "1" = "軽度",                    # mild
            "2" = "中等度",              # moderate
            "3" = "重度",                    # severe
            "4" = "完全")                    # complete
  out <- labs[as.character(q)]
  out[is.na(out)] <- "不明"                 # unknown
  unname(out)
}

# Canonical English ICF title from the real ontology (PhysioAnnotationHub),
# falling back to the local table when the hub is unavailable.
.icf_hub_title <- function(code) {
  if (!requireNamespace("PhysioAnnotationHub", quietly = TRUE)) return(NA_character_)
  tt <- tryCatch(PhysioAnnotationHub::icfCategories(code), error = function(e) NULL)
  if (is.null(tt) || !nrow(tt)) return(NA_character_)
  t <- tt$title[tt$icf_code == code]
  if (!length(t) || is.na(t[1])) NA_character_ else t[1]
}

.icf_title <- function(code, lang = c("ja", "en")) {
  lang <- match.arg(lang)
  cat_df <- icf_catalog()
  hit <- cat_df[cat_df$code == code, , drop = FALSE]
  if (lang == "en") {
    hub <- .icf_hub_title(code)                      # real ontology first
    if (!is.na(hub)) return(paste0(code, " ", hub))
  }
  if (!nrow(hit)) return(code)
  paste0(code, " ", hit[[paste0("title_", lang)]][1])
}

#' Map a measure to ICF codes via the real ontology (PhysioAnnotationHub)
#'
#' Uses PhysioAnnotationHub's ICF-linking rules (Cieza 2005) so a measure such as
#' `"gait_speed"` resolves to `"d450"` from the maintained ontology, not a
#' hard-coded table. Signal-derived measures that are not yet in the ontology
#' (e.g. `"knee_rom"`) return `character(0)`; the fix is to register the mapping
#' in PhysioAnnotationHub, not to hard-code it here.
#'
#' @param measure a measure / instrument id, e.g. "gait_speed".
#' @return character vector of ICF codes (possibly empty).
#' @export
icf_for_measure <- function(measure) {
  if (!requireNamespace("PhysioAnnotationHub", quietly = TRUE)) {
    fallback <- c(gait_speed = "d450", cadence = "b770")
    return(unname(fallback[measure][!is.na(fallback[measure])]))
  }
  suppressWarnings(tryCatch(PhysioAnnotationHub::tagICF(measure),
                            error = function(e) character(0)))
}
