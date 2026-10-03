test_that("episode records sessions, phases and list-columns", {
  ep <- new_rehab_episode("P1", "stroke", "AB")
  ep <- add_session(ep, "2026-01-01", "baseline", gait_speed = 0.40,
                    icf = list(d450 = 3), gas = list(G1 = -1))
  ep <- add_session(ep, "2026-02-01", "intervention", gait_speed = 0.60,
                    icf = list(d450 = 2), gas = list(G1 = 1))
  expect_s3_class(ep, "rehab_episode")
  expect_equal(nrow(ep$sessions), 2L)
  expect_equal(ep$sessions$phase, c("baseline", "intervention"))
  expect_true(all(c("icf_d450", "gas_G1") %in% names(ep$sessions)))
})

test_that("add_session carries arbitrary signal-derived measures", {
  ep <- new_rehab_episode("P1", "stroke")
  ep <- add_session(ep, "2026-01-01", "baseline",
                    measures = list(knee_rom = 47.2, mdf_slope = -12))
  expect_equal(ep$sessions$knee_rom, 47.2)
  expect_equal(ep$sessions$mdf_slope, -12)
})

test_that("icf_change reports improvement as positive; NULL when unrecorded", {
  ep <- new_rehab_episode("P1", "stroke")
  ep <- add_session(ep, "2026-01-01", "baseline", gait_speed = 0.4, icf = list(d450 = 3))
  ep <- add_session(ep, "2026-02-01", "intervention", gait_speed = 0.6, icf = list(d450 = 2))
  ch <- icf_change(ep, "d450")
  expect_equal(ch$improved, 1)          # qualifier 3 -> 2 = one grade better
  expect_null(icf_change(ep, "b999"))
})

test_that("simulate_stroke_gait_case is well-formed and reproducible", {
  ep <- simulate_stroke_gait_case(seed = 42)
  expect_s3_class(ep, "rehab_episode")
  expect_equal(sum(ep$sessions$phase == "baseline"), 3L)
  expect_equal(sum(ep$sessions$phase == "intervention"), 9L)
  expect_identical(simulate_stroke_gait_case(42)$sessions$gait_speed,
                   simulate_stroke_gait_case(42)$sessions$gait_speed)
})
