# ADL measurement-coverage registry (adl_coverage / summary / construct_coverage).

test_that("adl_coverage returns and filters the registry with status", {
  all <- adl_coverage()
  expect_true(all(c("code", "modality", "qualifier", "method", "package",
                    "status") %in% names(all)))
  expect_true(all(all$status %in% c("validated", "supported")))
  d640 <- adl_coverage("d640")
  expect_setequal(d640$qualifier, c("capacity", "performance"))  # scale + HAR
  expect_true(any(grepl("recognizeADL", d640$method)))           # domestic HAR
  expect_true(all(adl_coverage(qualifier = "performance")$qualifier ==
                    "performance"))
})

test_that("coverage summary distinguishes validated vs supported performance", {
  s <- adl_coverage_summary()
  walking <- s[s$code == "d450", ]
  expect_true(walking$multimodal)                    # capacity AND performance
  expect_gt(walking$n_modalities, 2)
  # housework & eating: performance validated on real data (PAMAP2 / HMP)
  expect_true(s$validated_performance[s$code == "d640"])
  # grooming & drinking: validated on real wrist-IMU data (HMP); eating is NOT
  # (HMP leave-one-subject-out recall 0.00 -- collapses into the other gestures)
  expect_true(s$validated_performance[s$code == "d520"])
  eating <- s[s$code == "d550", ]
  expect_true(eating$has_capacity && eating$has_performance)
  expect_false(eating$validated_performance)         # honest: eating not distinguished
  # washing: validated on real wrist-IMU data (HTAD)
  expect_true(s$validated_performance[s$code == "d510"])
  # dressing: performance pipeline-ready (supported) but NOT yet validated
  expect_true(s$has_performance[s$code == "d540"])
  expect_false(s$validated_performance[s$code == "d540"])
  # transportation stays genuinely capacity-only (no sensor performance)
  expect_false(s$has_performance[s$code == "d470"])
  ov <- attr(s, "overall")
  expect_true(all(c("pct_capacity", "pct_performance",
                    "pct_validated_performance", "pct_multimodal") %in% names(ov)))
  # validated performance must not exceed (mapping-ready) performance
  expect_lte(ov[["pct_validated_performance"]], ov[["pct_performance"]])
})

test_that("construct_coverage reports the gaps for one patient", {
  cn <- new_icf_construct("d640")
  cn <- add_icf_measure(cn, "lawton_housekeeping", 1, qualifier_type = "capacity",
                        modality = "scale", date = "2026-01-01", qualifier = 2)
  cov <- construct_coverage(cn)
  expect_true(cov$has_capacity)
  expect_false(cov$has_performance)
  expect_true("performance" %in% cov$missing_qualifiers)   # HAR available, unused
  expect_true(any(grepl("recognizeADL", cov$available$method)))

  # add the performance side -> gap closed
  cn <- add_icf_measure(cn, "vacuuming", 40, qualifier_type = "performance",
                        modality = "sensor", date = "2026-01-15", qualifier = 1)
  expect_length(construct_coverage(cn)$missing_qualifiers, 0)
})
