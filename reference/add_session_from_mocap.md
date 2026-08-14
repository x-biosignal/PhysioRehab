# Append a rehab session whose measures come from a real OpenPose recording

Append a rehab session whose measures come from a real OpenPose
recording

## Usage

``` r
add_session_from_mocap(
  ep,
  date,
  phase,
  openpose_dir,
  side = "R",
  observation = ""
)
```

## Arguments

- ep:

  a \`rehab_episode\`.

- date, phase:

  session date and phase.

- openpose_dir:

  directory of OpenPose JSON frames for this visit.

- side:

  "R"/"L".

- observation:

  optional clinician note (auto-filled if empty).

## Value

the updated \`rehab_episode\`, with real \`knee_rom\` /
\`knee_smoothness\`.
