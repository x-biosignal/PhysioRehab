# Cross-modal ICF construct: capacity vs performance unification (phase 3).

test_that("value -> ICF 0-4 qualifier is direction-aware", {
  cn <- new_icf_construct("d450")
  # higher-is-better steps/day: few steps -> severe problem (4)
  cn <- add_icf_measure(cn, "steps_per_day", c(1000, 5000, 9000),
                        qualifier_type = "performance", modality = "sensor",
                        date = as.Date("2026-01-01") + 0:2,
                        direction = "higher_better",
                        cutpoints = c(2000, 4000, 6000, 8000))
  q <- cn$observations$qualifier
  expect_equal(q, c(4L, 2L, 0L))

  # higher-is-worse (e.g. a symptom count): low -> no problem
  cn2 <- add_icf_measure(new_icf_construct("d530"), "symptom", c(0, 10),
                         qualifier_type = "capacity", modality = "scale",
                         date = as.Date("2026-01-01"),
                         direction = "higher_worse",
                         cutpoints = c(1, 3, 6, 9))
  expect_equal(cn2$observations$qualifier, c(0L, 4L))
})

test_that("capacity-performance gap sign and interpretation are correct", {
  cn <- new_icf_construct("d450")
  cn <- add_icf_measure(cn, "10mwt", 1.2, qualifier_type = "capacity",
                        modality = "performance_test", date = "2026-02-01",
                        qualifier = 1)                       # mild in clinic
  cn <- add_icf_measure(cn, "steps_per_day", 2500,
                        qualifier_type = "performance", modality = "sensor",
                        date = "2026-02-01", qualifier = 3)  # severe at home
  g <- capacity_performance_gap(cn)
  expect_equal(g$capacity, 1)
  expect_equal(g$performance, 3)
  expect_equal(g$gap, 2)                                     # does less than able
  expect_match(g$interpretation, "実行が能力を下回る")
})

test_that("gap is NA when a qualifier stream is missing", {
  cn <- new_icf_construct("d550")
  cn <- add_icf_measure(cn, "barthel_feeding", 10, qualifier_type = "capacity",
                        modality = "scale", date = "2026-01-01", qualifier = 0)
  expect_true(is.na(capacity_performance_gap(cn)$gap))
})

test_that("latest vs mean selection uses the most recent capacity/performance", {
  cn <- new_icf_construct("d450")
  cn <- add_icf_measure(cn, "s", c(4, 2), qualifier_type = "performance",
                        modality = "sensor",
                        date = c("2026-01-01", "2026-03-01"), qualifier = c(4, 2))
  cn <- add_icf_measure(cn, "c", 1, qualifier_type = "capacity",
                        modality = "scale", date = "2026-03-01", qualifier = 1)
  expect_equal(capacity_performance_gap(cn, "latest")$performance, 2)  # newest
  expect_equal(capacity_performance_gap(cn, "mean")$performance, 3)    # (4+2)/2
})

test_that("trajectory is time-ordered and feeds single-case analysis", {
  cn <- new_icf_construct("d450")
  cn <- add_icf_measure(cn, "steps", c(1500, 1800, 4000, 5200, 6100),
                        qualifier_type = "performance", modality = "sensor",
                        date = as.Date("2026-01-01") + c(2, 0, 10, 12, 14),
                        direction = "higher_better",
                        cutpoints = c(2000, 4000, 6000, 8000))
  tr <- icf_construct_trajectory(cn, "performance")
  expect_equal(tr$value, c(1800, 1500, 4000, 5200, 6100))   # sorted by date
  # baseline (first two) vs intervention (rest) NAP on the raw performance value
  nap <- PhysioAppKit::nonoverlap_analyze(tr$value[1:2], tr$value[3:5],
                                          threshold = 2000, direction = "increase")
  expect_equal(nap$nap, 1)                                   # all pairs improved
})

test_that("free-living summary ingests as the performance qualifier", {
  fl <- structure(list(aggregate = list(mvpa_min = 12, steps = 5200)),
                  class = "freeliving_summary")
  cn <- new_icf_construct("d450")
  cn <- add_performance_from_freeliving(cn, fl, "steps",
                                        cutpoints = c(2000, 4000, 6000, 8000),
                                        date = "2026-04-01")
  expect_equal(cn$observations$qualifier, 2L)               # 5200 -> q2
  expect_equal(cn$observations$modality, "sensor")
  expect_error(add_performance_from_freeliving(cn, fl, "nope", c(1, 2, 3, 4)),
               "not found")
})

test_that("progress note gains a cross-modal capacity-performance section", {
  ep <- new_rehab_episode("P01", "stroke", design = "AB")
  ep <- add_session(ep, "2026-01-01", "baseline", gait_speed = 0.6)
  ep <- add_session(ep, "2026-01-08", "baseline", gait_speed = 0.62)
  ep <- add_session(ep, "2026-01-15", "intervention", gait_speed = 0.8)
  ep <- add_session(ep, "2026-01-22", "intervention", gait_speed = 0.85)
  sced <- sced_analyze(ep, measure = "gait_speed", mcid = 0.16)

  cn <- new_icf_construct("d450")
  cn <- add_icf_measure(cn, "10mwt", 1.1, qualifier_type = "capacity",
                        modality = "performance_test", date = "2026-01-22",
                        qualifier = 1)
  cn <- add_icf_measure(cn, "steps_per_day", 2800,
                        qualifier_type = "performance", modality = "sensor",
                        date = "2026-01-22", qualifier = 3)

  note <- draft_progress_note(ep, sced, constructs = list(cn))
  expect_match(note, "能力↔実行の統合")
  expect_match(note, "ギャップ \\+2")
  # without constructs the section is absent (back-compatible)
  expect_false(grepl("能力↔実行", draft_progress_note(ep, sced)))
})
