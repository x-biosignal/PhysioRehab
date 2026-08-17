test_that("icf catalogue and qualifier labels are well-formed", {
  cat <- icf_catalog()
  expect_true(all(c("code", "component", "title_en", "title_ja") %in% names(cat)))
  expect_true("d450" %in% cat$code)
  expect_equal(icf_qualifier_label(0), "問題なし")   # no problem
  expect_equal(icf_qualifier_label(4), "完全")       # complete
  expect_equal(icf_qualifier_label(9), "不明")       # unknown
})

test_that("icf_for_measure resolves gait_speed (hub, or local fallback)", {
  codes <- icf_for_measure("gait_speed")
  expect_true("d450" %in% codes)
})
