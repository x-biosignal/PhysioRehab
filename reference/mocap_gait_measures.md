# Real gait/kinematic measures from an OpenPose recording (via PhysioMoCap)

Reads the COCO-18 OpenPose JSON frames, builds a PhysioExperiment, runs
\[PhysioMoCap::poseFix\], and derives real knee-kinematic measures for
one side.

## Usage

``` r
mocap_gait_measures(openpose_dir, side = c("R", "L"), fps = 30)
```

## Arguments

- openpose_dir:

  directory of \`openpose_data\<N\>.json\` frames (COCO-18 flat).

- side:

  "R" or "L".

- fps:

  frame rate (Hz).

## Value

a list of real measures: knee_rom (deg), knee_smoothness_fixed and \_raw
(mean \|2nd diff\| of the knee angle, after / before poseFix), frames,
flagged_fraction, leg_swaps.
