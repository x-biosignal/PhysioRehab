# Append a rehab session whose measures come from a real EMG recording

Append a rehab session whose measures come from a real EMG recording

## Usage

``` r
add_session_from_emg(ep, date, phase, emg_pe, observation = "")
```

## Arguments

- ep:

  a \`rehab_episode\`.

- date:

  session date (Date or string).

- phase:

  "baseline" or "intervention".

- emg_pe:

  a PhysioExperiment of raw EMG.

- observation:

  optional clinician note (auto-filled if empty).

## Value

the updated \`rehab_episode\`, with real \`mdf_slope\` / \`emg_rms\`.
