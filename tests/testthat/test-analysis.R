test_that("sced_analyze detects an MCID-exceeding improvement", {
  ep <- simulate_stroke_gait_case(42)
  s <- sced_analyze(ep, "gait_speed", mcid = 0.16)
  expect_true(s$exceeds_mcid)
  expect_gt(s$nap, 0.9)
  expect_equal(s$measure, "gait_speed")
  expect_equal(s$mcid, 0.16)
})

test_that("evaluate_hypothesis is honest about unsupported items", {
  ep <- simulate_stroke_gait_case(42)
  s <- sced_analyze(ep, "gait_speed", mcid = 0.16)
  # b735 (spasticity) does not improve in the simulated case -> partial
  hyp <- rehab_hypothesis("test", expect_speed_mcid = TRUE,
                          expect_icf = c(d450 = 1, b735 = 1))
  r <- evaluate_hypothesis(ep, hyp, s)
  expect_match(r$overall, "partial")
  supported <- vapply(r$items, function(i) isTRUE(i$supported), logical(1))
  expect_true(any(supported))
  expect_true(any(!supported))
})

test_that("rehab_workflow returns a report, sced and reasoning", {
  ep <- simulate_stroke_gait_case(42)
  hyp <- rehab_hypothesis("test", expect_icf = c(d450 = 1))
  res <- rehab_workflow(ep, hyp, mcid = 0.16, out_dir = tempdir())
  expect_type(res$report, "character")
  expect_match(res$report, "経過記録")   # 経過記録
  expect_true(res$sced$exceeds_mcid)
  expect_true(file.exists(res$report_file))
})
