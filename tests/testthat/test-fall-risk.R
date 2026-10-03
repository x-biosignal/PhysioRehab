# Integrated multi-domain fall-risk index.

ref <- data.frame(
  sway = c(5, 6, 4, 5, 6), gait_variability = c(3, 4, 3, 5, 4),
  tug = c(8, 9, 7, 10, 8), strength = c(55, 52, 58, 50, 56))

test_that("zscore composite is high for a worse-than-healthy profile", {
  hi <- fall_risk_index(sway = 12, gait_variability = 10, tug = 18,
                        strength = 38, reference = ref)
  expect_s3_class(hi, "fall_risk_index")
  expect_gt(hi$composite, 1)                       # well above the healthy mean
  expect_gt(hi$percentile, 84)                     # > +1 SD
  # low strength must raise risk: its sign-aligned z is positive
  expect_gt(hi$z[["strength"]], 0)

  lo <- fall_risk_index(sway = 4, gait_variability = 2, tug = 6,
                        strength = 60, reference = ref)
  expect_lt(lo$composite, 0)                       # better than healthy = lower risk
})

test_that("no reference leaves the composite uncalibrated (NA), honestly", {
  nr <- fall_risk_index(sway = 12, tug = 18)
  expect_true(is.na(nr$composite))
  expect_false(nr$calibrated)
  expect_true(is.na(nr$stratum))
  expect_equal(unname(nr$domains[["tug"]]), 18)
})

test_that("validated cutpoints assign a risk stratum", {
  st <- fall_risk_index(sway = 12, gait_variability = 10, tug = 18,
                        strength = 38, reference = ref,
                        cutpoints = c(-1, 0, 1),
                        strata_labels = c("low", "mild", "moderate", "high"))
  expect_true(st$calibrated)
  expect_equal(st$stratum, "high")
})

test_that("the PPA method requires user-supplied coefficients (not fabricated)", {
  expect_error(fall_risk_index(sway = 12, method = "ppa"), "ppa_coef")
  ppa <- fall_risk_index(sway = 12, tug = 18, method = "ppa",
                         ppa_coef = c(intercept = -2, sway = 0.1, tug = 0.05))
  expect_equal(ppa$composite, -2 + 0.1 * 12 + 0.05 * 18)
})

test_that("direction overrides work", {
  # if a domain is coded so higher = better, flip its sign
  x <- fall_risk_index(strength = 38, reference = ref,
                       direction = c(strength = 1))
  # now low strength (38 < mean 54.2) gives a NEGATIVE z under the flipped sign
  expect_lt(x$z[["strength"]], 0)
})

# --- wiring into episodes / progress notes ---

.mk_episode_with_domains <- function() {
  ep <- new_rehab_episode("p1", "stroke", "AB")
  start <- as.Date("2024-01-01")
  gs <- c(0.50, 0.52, 0.51, 0.60, 0.66, 0.72)          # flat baseline, rising B
  ph <- c(rep("baseline", 3), rep("intervention", 3))
  for (i in seq_along(gs)) {
    ep <- add_session(ep, start + (i - 1) * 3, ph[i], gait_speed = gs[i],
                      measures = list(sway = 12, gait_variability = 9,
                                      tug = 16, strength = 40))
  }
  ep
}

test_that("fall_risk_from_episode derives domains from the latest session", {
  ep <- .mk_episode_with_domains()
  fr <- fall_risk_from_episode(ep)
  expect_s3_class(fr, "fall_risk_index")
  expect_equal(unname(fr$domains[["sway"]]), 12)
  expect_equal(unname(fr$domains[["strength"]]), 40)
  ref <- data.frame(sway = c(5, 6, 4, 5), gait_variability = c(3, 4, 3, 5),
                    tug = c(8, 9, 7, 10), strength = c(55, 52, 58, 50))
  expect_true(is.finite(fall_risk_from_episode(ep, reference = ref)$composite))
})

test_that("fall_risk_from_episode returns NULL when the session has no domains", {
  ep <- new_rehab_episode("p2", "stroke", "AB")
  ep <- add_session(ep, as.Date("2024-01-01"), "baseline", gait_speed = 0.6)
  expect_null(fall_risk_from_episode(ep))
})

test_that("rehab_workflow computes fall risk and the note renders the section", {
  ep <- .mk_episode_with_domains()
  res <- rehab_workflow(ep, mcid = 0.16, out_dir = tempdir())
  expect_s3_class(res$fall_risk, "fall_risk_index")
  expect_match(res$report, "転倒リスク")
})
