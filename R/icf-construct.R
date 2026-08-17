# ---------------------------------------------------------------------------
# Cross-modal ICF construct: capacity vs performance for one d-code.
#
# The ICF codes a single Activity & Participation category with TWO qualifiers:
# performance (what the person actually does in their real environment) and
# capacity (what they can do in a standardised / clinic setting). Rehabilitation
# lives in the gap between them -- the stroke survivor who *can* walk in the gym
# (capacity) but *doesn't* at home (performance). This layer unifies the
# ecosystem's heterogeneous measures under one ICF domain: ordinal clinical
# scales and their Rasch interval measures (PhysioClinical) supply capacity;
# free-living accelerometry (PhysioWearable) supplies performance. Each measure
# is mapped to the ICF 0-4 qualifier so they become comparable, the
# capacity-performance gap is quantified, and either qualifier stream can be
# tracked over an episode with the existing single-case machinery.
# ---------------------------------------------------------------------------

# Map a measure value to the ICF 0-4 qualifier via 4 ascending cut-points.
# `cutpoints` are boundaries on the raw measure; findInterval gives 0..4 rising
# with the value. For a higher-is-better measure the qualifier (a PROBLEM scale,
# 0 none .. 4 complete) is the reflection 4 - interval.
.to_qualifier <- function(value, cutpoints, direction) {
  q <- findInterval(value, sort(as.numeric(cutpoints)))
  if (direction == "higher_better") q <- 4L - q
  as.integer(q)
}

#' Create a cross-modal ICF construct for one Activity/Participation domain
#'
#' @param code an ICF code, e.g. `"d450"` (walking) or `"d550"` (eating).
#' @param title optional human title; resolved from the ontology
#'   (PhysioAnnotationHub, else the local catalogue) when omitted.
#' @return an empty object of class `icf_construct`.
#' @seealso [add_icf_measure()], [capacity_performance_gap()]
#' @export
#' @examples
#' new_icf_construct("d450")
new_icf_construct <- function(code, title = NULL) {
  if (is.null(title)) title <- .icf_title(code, lang = "en")
  structure(
    list(code = code, title = title,
         observations = data.frame(
           date = as.Date(character(0)), source = character(0),
           modality = character(0), qualifier_type = character(0),
           value = numeric(0), unit = character(0), direction = character(0),
           qualifier = integer(0), stringsAsFactors = FALSE)),
    class = "icf_construct")
}

#' Add a measure observation to an ICF construct
#'
#' Records one modality's view of the domain, tagged as `capacity` (a
#' standardised/clinic measure -- an ordinal scale total, a Rasch person measure,
#' a performance test) or `performance` (a free-living / real-world measure). The
#' value is mapped to the ICF 0-4 qualifier either directly (`qualifier`) or from
#' `cutpoints` (direction-aware), so heterogeneous measures become comparable.
#' `value` and `date` may be vectors to add a whole longitudinal stream at once.
#'
#' @param construct an `icf_construct`.
#' @param source short measure id, e.g. `"barthel"`, `"steps_per_day"`.
#' @param value numeric measure value(s).
#' @param qualifier_type `"capacity"` or `"performance"`.
#' @param modality `"scale"`, `"rasch"`, `"performance_test"`, `"sensor"` or
#'   `"self_report"`.
#' @param date measurement date(s) (Date or coercible); recycled to `value`.
#' @param unit optional measure unit.
#' @param direction `"higher_better"` (default) or `"higher_worse"`.
#' @param qualifier optional explicit ICF qualifier(s) 0-4 (overrides
#'   `cutpoints`).
#' @param cutpoints optional length-4 ascending cut-points mapping `value` to the
#'   0-4 qualifier.
#' @return the updated `icf_construct`.
#' @seealso [capacity_performance_gap()], [icf_construct_trajectory()]
#' @export
add_icf_measure <- function(construct, source, value,
                            qualifier_type = c("capacity", "performance"),
                            modality = c("scale", "rasch", "performance_test",
                                         "sensor", "self_report"),
                            date = NA, unit = NA_character_,
                            direction = c("higher_better", "higher_worse"),
                            qualifier = NULL, cutpoints = NULL) {
  stopifnot(inherits(construct, "icf_construct"))
  qualifier_type <- match.arg(qualifier_type)
  modality <- match.arg(modality)
  direction <- match.arg(direction)
  value <- as.numeric(value)
  n <- length(value)
  date <- if (length(date) == 1L) rep(date, n) else date
  if (length(date) != n) stop("`date` must be length 1 or length(value).",
                              call. = FALSE)

  q <- if (!is.null(qualifier)) {
    as.integer(rep(qualifier, length.out = n))
  } else if (!is.null(cutpoints)) {
    if (length(cutpoints) != 4L) stop("`cutpoints` must have length 4.",
                                      call. = FALSE)
    .to_qualifier(value, cutpoints, direction)
  } else {
    rep(NA_integer_, n)
  }

  row <- data.frame(
    date = as.Date(date), source = source, modality = modality,
    qualifier_type = qualifier_type, value = value, unit = unit,
    direction = direction, qualifier = q, stringsAsFactors = FALSE)
  construct$observations <- rbind(construct$observations, row)
  construct
}

# latest (by date) or mean qualifier for one qualifier_type.
.pick_qualifier <- function(obs, type, when) {
  df <- obs[obs$qualifier_type == type & !is.na(obs$qualifier), , drop = FALSE]
  if (!nrow(df)) return(NA_real_)
  if (when == "mean") return(mean(df$qualifier))
  df <- df[order(df$date, na.last = FALSE), , drop = FALSE]
  df$qualifier[nrow(df)]
}

#' Capacity-performance gap for an ICF construct
#'
#' The signature rehabilitation discrepancy: how much a person's real-world
#' doing (performance) falls short of what they can do in a standardised setting
#' (capacity), both on the ICF 0-4 qualifier. A positive gap means performance
#' is worse than capacity -- the person does less than they are able, pointing to
#' environmental or behavioural barriers rather than impairment.
#'
#' @param construct an `icf_construct` carrying both a capacity and a performance
#'   qualifier.
#' @param when `"latest"` (default, most recent of each) or `"mean"`.
#' @return a list: `code`, `title`, `capacity`, `performance`, `gap`
#'   (performance - capacity) and a text `interpretation`.
#' @seealso [add_icf_measure()]
#' @export
capacity_performance_gap <- function(construct, when = c("latest", "mean")) {
  stopifnot(inherits(construct, "icf_construct"))
  when <- match.arg(when)
  cq <- .pick_qualifier(construct$observations, "capacity", when)
  pq <- .pick_qualifier(construct$observations, "performance", when)
  gap <- pq - cq
  interp <- if (is.na(gap)) {
    "能力または実行の qualifier が不足（両方の測定が必要）"
  } else if (gap > 0) {
    "実行が能力を下回る（できるのにしていない＝環境・行動要因の可能性）"
  } else if (gap < 0) {
    "実行が能力を上回る（代償・測定条件の相違の可能性）"
  } else {
    "能力と実行が一致"
  }
  list(code = construct$code, title = construct$title,
       capacity = cq, performance = pq, gap = gap, interpretation = interp)
}

#' Time-ordered trajectory of one qualifier stream (feeds single-case analysis)
#'
#' @param construct an `icf_construct`.
#' @param qualifier_type `"capacity"` or `"performance"`.
#' @return a data.frame(`date`, `value`, `qualifier`) ordered by date, ready to
#'   pass to [PhysioAppKit::nonoverlap_analyze()] or the rehab SCED tools.
#' @seealso [capacity_performance_gap()]
#' @export
icf_construct_trajectory <- function(construct,
                                     qualifier_type = c("capacity",
                                                        "performance")) {
  stopifnot(inherits(construct, "icf_construct"))
  qualifier_type <- match.arg(qualifier_type)
  df <- construct$observations[
    construct$observations$qualifier_type == qualifier_type, , drop = FALSE]
  df <- df[order(df$date, na.last = FALSE), c("date", "value", "qualifier")]
  rownames(df) <- NULL
  df
}

#' Add a free-living performance metric from a summary to an ICF construct
#'
#' Convenience adapter: pulls one aggregate metric from a
#' `PhysioWearable::summarizeFreeLiving()` result and records it as the
#' `performance` qualifier of the construct. Works structurally, so PhysioWearable
#' need not be attached.
#'
#' @param construct an `icf_construct`.
#' @param fl a `freeliving_summary` (or any list with an `aggregate` element).
#' @param metric aggregate field name, e.g. `"mvpa_min"` or `"steps"`.
#' @param cutpoints length-4 ascending cut-points mapping the metric to the 0-4
#'   qualifier (higher metric = better performance).
#' @param date measurement date.
#' @param source measure id recorded (defaults to `metric`).
#' @return the updated `icf_construct`.
#' @seealso [add_icf_measure()]
#' @export
add_performance_from_freeliving <- function(construct, fl, metric, cutpoints,
                                            date = NA, source = metric) {
  agg <- fl$aggregate %||% NULL
  if (is.null(agg) || is.null(agg[[metric]])) {
    stop("metric '", metric, "' not found in the free-living summary.",
         call. = FALSE)
  }
  add_icf_measure(construct, source = source, value = as.numeric(agg[[metric]]),
                  qualifier_type = "performance", modality = "sensor",
                  date = date, direction = "higher_better", cutpoints = cutpoints)
}

#' @export
print.icf_construct <- function(x, ...) {
  cat(sprintf("<icf_construct> %s | %d observation(s)\n",
              x$title, nrow(x$observations)))
  g <- capacity_performance_gap(x)
  if (!is.na(g$gap)) {
    cat(sprintf("  capacity=%d  performance=%d  gap=%+d  (%s)\n",
                as.integer(g$capacity), as.integer(g$performance),
                as.integer(g$gap), g$interpretation))
  } else {
    ct <- table(x$observations$qualifier_type)
    cat(sprintf("  capacity obs: %d  performance obs: %d\n",
                sum(x$observations$qualifier_type == "capacity"),
                sum(x$observations$qualifier_type == "performance")))
  }
  invisible(x)
}
