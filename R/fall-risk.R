# Integrated (multi-domain) fall-risk index. Fall risk is multifactorial: no
# single measure captures it, so this combines domain summaries already produced
# elsewhere in the ecosystem -- postural sway (PhysioMoCap swayMetrics), gait
# variability (summarizeGaitParameters CVs), functional mobility (scoreTUG),
# lower-limb strength (scoreMRCSum / peakTorque), and optionally reaction time,
# vision and proprioception -- into one score, following the Physiological
# Profile Assessment (PPA; Lord et al. 2003) framework.
#
# HONEST SCOPE: the PPA discriminant weights and the composite-to-probability
# calibration are empirically derived from Lord et al.'s prospective cohorts and
# are NOT reconstructable here, so none are hard-coded. The default
# "zscore_composite" method standardises each domain against a user-supplied
# healthy `reference` (equal weights unless given) and leaves the composite
# UNCALIBRATED (no risk stratum) unless the caller passes validated `cutpoints`.
# The "ppa" method requires the caller to supply the published `ppa_coef`.

# Domain orientation: +1 if a higher value means more fall risk, -1 if less.
.fri_direction <- c(sway = 1, gait_variability = 1, tug = 1, strength = -1,
                    reaction_time = 1, vision = -1, proprioception = 1)

#' Integrated multi-domain fall-risk index
#'
#' Combines per-domain fall-risk summaries into a single index. Each argument is
#' a scalar summary from the corresponding validated measure (e.g. `sway` from
#' [PhysioMoCap::swayMetrics()] path length, `gait_variability` from a
#' [PhysioMoCap::summarizeGaitParameters()] CV, `tug` from
#' [PhysioClinical::scoreTUG()], `strength` from [PhysioClinical::scoreMRCSum()]).
#' Omit a domain by leaving it `NA`.
#'
#' @param sway,gait_variability,tug,strength,reaction_time,vision,proprioception
#'   Per-domain scalar summaries (any may be `NA` to omit).
#' @param reference A `data.frame` of the same-named domain columns measured in a
#'   healthy reference sample; required for the `"zscore_composite"` method (each
#'   domain is z-standardised against it, sign-aligned so higher = more risk).
#'   Without it the composite is `NA`.
#' @param weights Optional named per-domain weights for the composite (default
#'   equal).
#' @param direction Optional named `+1`/`-1` overrides of the default domain
#'   orientation (`+1` = higher is riskier).
#' @param cutpoints Optional ascending composite cut-points defining risk strata;
#'   supply only from validated fall-outcome data. Default `NULL` = uncalibrated
#'   (no stratum).
#' @param strata_labels Optional labels for the `length(cutpoints) + 1` strata.
#' @param method `"zscore_composite"` (default) or `"ppa"` (needs `ppa_coef`).
#' @param ppa_coef For `method = "ppa"`, a named numeric vector of the published
#'   PPA discriminant weights per domain (plus optional `intercept`); not bundled.
#' @return An S3 `fall_risk_index`: `domains`, sign-aligned `z`, `composite`,
#'   `percentile` (normal, when calibrated by a reference), `stratum`,
#'   `method` and `calibrated`.
#' @references Lord SR, Menz HB, Tiedemann A (2003). A physiological profile
#'   approach to falls risk assessment and prevention. *Phys Ther* 83:237-252.
#' @seealso [PhysioClinical::scoreTUG()], [PhysioClinical::scoreBerg()]
#' @export
#' @examples
#' ref <- data.frame(sway = c(5, 6, 4, 5, 6), gait_variability = c(3, 4, 3, 5, 4),
#'                   tug = c(8, 9, 7, 10, 8), strength = c(55, 52, 58, 50, 56))
#' fall_risk_index(sway = 12, gait_variability = 10, tug = 18, strength = 38,
#'                 reference = ref)
fall_risk_index <- function(sway = NA_real_, gait_variability = NA_real_,
                            tug = NA_real_, strength = NA_real_,
                            reaction_time = NA_real_, vision = NA_real_,
                            proprioception = NA_real_,
                            reference = NULL, weights = NULL, direction = NULL,
                            cutpoints = NULL, strata_labels = NULL,
                            method = c("zscore_composite", "ppa"),
                            ppa_coef = NULL) {
  method <- match.arg(method)
  domains <- c(sway = sway, gait_variability = gait_variability, tug = tug,
               strength = strength, reaction_time = reaction_time,
               vision = vision, proprioception = proprioception)
  domains <- domains[is.finite(domains)]
  if (!length(domains)) stop("supply at least one domain summary.", call. = FALSE)

  dvec <- .fri_direction[names(domains)]
  dvec[is.na(dvec)] <- 1
  if (!is.null(direction)) {
    for (k in names(direction)) if (k %in% names(domains)) dvec[k] <- direction[[k]]
  }

  if (method == "ppa") {
    if (is.null(ppa_coef)) {
      stop("method = 'ppa' requires 'ppa_coef' (the published Lord et al. ",
           "discriminant weights); these are not bundled - supply them.",
           call. = FALSE)
    }
    inter <- if ("intercept" %in% names(ppa_coef)) ppa_coef[["intercept"]] else 0
    used <- intersect(names(domains), names(ppa_coef))
    composite <- inter + sum(domains[used] * ppa_coef[used])
    z <- stats::setNames(rep(NA_real_, length(domains)), names(domains))
  } else {
    z <- stats::setNames(rep(NA_real_, length(domains)), names(domains))
    composite <- NA_real_
    if (!is.null(reference)) {
      ref <- as.data.frame(reference)
      for (k in names(domains)) {
        if (!k %in% names(ref)) next
        col <- as.numeric(ref[[k]])
        mu <- mean(col, na.rm = TRUE); s <- stats::sd(col, na.rm = TRUE)
        if (is.finite(s) && s > 0) z[k] <- dvec[k] * (domains[k] - mu) / s
      }
      zz <- z[is.finite(z)]
      if (length(zz)) {
        w <- if (is.null(weights)) rep(1, length(zz)) else {
          ww <- weights[names(zz)]; ww[is.na(ww)] <- 0; ww
        }
        if (sum(w) > 0) composite <- sum(zz * (w / sum(w)))
      }
    }
  }

  percentile <- if (is.finite(composite) && method == "zscore_composite") {
    stats::pnorm(composite) * 100
  } else NA_real_
  stratum <- NA_character_
  if (is.finite(composite) && !is.null(cutpoints)) {
    band <- findInterval(composite, sort(as.numeric(cutpoints))) + 1L
    stratum <- if (!is.null(strata_labels) &&
                   length(strata_labels) == length(cutpoints) + 1L) {
      strata_labels[band]
    } else paste0("band_", band)
  }

  structure(list(domains = domains, direction = dvec, z = z,
                 composite = composite, percentile = percentile,
                 stratum = stratum, method = method,
                 calibrated = !is.null(cutpoints)), class = "fall_risk_index")
}

#' @export
print.fall_risk_index <- function(x, ...) {
  cat(sprintf("Fall-risk index (%s)\n", x$method))
  for (nm in names(x$domains)) {
    cat(sprintf("  %-16s %.4g%s\n", nm, x$domains[[nm]],
                if (is.finite(x$z[nm])) sprintf("  (z %+.2f)", x$z[nm]) else ""))
  }
  cat(sprintf("  composite       : %s\n",
              if (is.na(x$composite)) "NA (needs a reference)" else
                sprintf("%.3f%s", x$composite,
                        if (is.finite(x$percentile))
                          sprintf(" (%.0fth pct)", x$percentile) else "")))
  cat(sprintf("  risk stratum    : %s\n",
              if (is.na(x$stratum)) "NA (uncalibrated - supply validated cutpoints)"
              else x$stratum))
  invisible(x)
}

#' Derive a fall-risk index from a rehab episode
#'
#' Builds [fall_risk_index()] domain inputs from a `rehab_episode`'s latest (or a
#' chosen) session, mapping the standard domain names out of the session's
#' quantitative `measures` columns (as stored by [add_session()]). Returns `NULL`
#' if the session holds none of the fall-risk domains, so it composes cleanly
#' into [draft_progress_note()] / [rehab_workflow()].
#'
#' @param ep A `rehab_episode` (see [new_rehab_episode()]).
#' @param session Session number to use (default: the latest session).
#' @param reference,weights,cutpoints,strata_labels Passed to [fall_risk_index()].
#' @param domain_map Named character vector mapping fall-risk domains to session
#'   column names (default: identity for `sway`, `gait_variability`, `tug`,
#'   `strength`, `reaction_time`, `vision`, `proprioception`).
#' @return A `fall_risk_index`, or `NULL` if no domain columns are present.
#' @seealso [fall_risk_index()], [draft_progress_note()]
#' @export
#' @examples
#' # Synthetic domain summaries recorded on one session (not clinical advice).
#' ep <- new_rehab_episode("PT-01", "stroke, left hemiplegia")
#' ep <- add_session(ep, "2026-04-06", "baseline",
#'                   measures = list(sway = 12, tug = 18, strength = 38))
#' fall_risk_from_episode(ep)
fall_risk_from_episode <- function(ep, session = NULL, reference = NULL,
                                   weights = NULL, cutpoints = NULL,
                                   strata_labels = NULL,
                                   domain_map = c(sway = "sway",
                                     gait_variability = "gait_variability",
                                     tug = "tug", strength = "strength",
                                     reaction_time = "reaction_time",
                                     vision = "vision",
                                     proprioception = "proprioception")) {
  if (!is.list(ep) || is.null(ep$sessions) || !nrow(ep$sessions)) {
    stop("'ep' must be a rehab_episode with at least one session.", call. = FALSE)
  }
  s <- ep$sessions
  row <- if (is.null(session)) s[nrow(s), , drop = FALSE] else
    s[s$session == session, , drop = FALSE]
  if (!nrow(row)) stop("session not found in the episode.", call. = FALSE)
  args <- list(reference = reference, weights = weights, cutpoints = cutpoints,
               strata_labels = strata_labels)
  found <- FALSE
  for (dom in names(domain_map)) {
    col <- domain_map[[dom]]
    if (col %in% names(row)) {
      v <- suppressWarnings(as.numeric(row[[col]])[1])
      if (is.finite(v)) { args[[dom]] <- v; found <- TRUE }
    }
  }
  if (!found) return(NULL)
  do.call(fall_risk_index, args)
}
