test_that("MoCap adapter ingests a real OpenPose recording and poseFix smooths", {
  skip_if_not_installed("PhysioMoCap")
  skip_if_not_installed("PhysioCore")
  skip_if_not_installed("PoseFixeR")
  skip_if_not_installed("jsonlite")
  dir <- system.file("extdata", package = "PoseFixeR")
  skip_if(!length(list.files(dir, pattern = "openpose_data[0-9]+\\.json$")),
          "no bundled OpenPose demo data")
  m <- mocap_gait_measures(dir, side = "R")
  expect_true(is.finite(m$knee_rom))
  expect_gt(m$frames, 1)
  # poseFix reduces frame-to-frame jerk of the knee angle
  expect_lt(m$knee_smoothness_fixed, m$knee_smoothness_raw)

  ep <- add_session_from_mocap(new_rehab_episode("P", "stroke"),
                               "2026-01-01", "baseline", dir, side = "R")
  expect_equal(nrow(ep$sessions), 1L)
  expect_true(is.finite(ep$sessions$knee_rom))
})

test_that("EMG adapter runs the real PhysioEMG fatigue pipeline", {
  skip_if_not_installed("PhysioEMG")
  skip_if_not_installed("PhysioCore")
  suppressMessages(require(PhysioEMG))   # Depends: PhysioCore (make_emg_fatigue)
  pe <- PhysioEMG::make_emg_fatigue(n_time = 4000, sr = 1000)
  m <- emg_fatigue_measures(pe)
  expect_true(is.finite(m$mdf_slope_hz_per_min))
  expect_lt(m$mdf_slope_hz_per_min, 0)   # median frequency falls with fatigue
})
