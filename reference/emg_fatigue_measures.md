# Real muscle-fatigue / amplitude measures from an EMG recording (via PhysioEMG)

Real muscle-fatigue / amplitude measures from an EMG recording (via
PhysioEMG)

## Usage

``` r
emg_fatigue_measures(emg_pe, feature = c("mdf", "mnf"))
```

## Arguments

- emg_pe:

  a PhysioExperiment holding raw EMG (e.g. from PhysioIO, or the
  realistic \`PhysioEMG::make_emg_fatigue()\` model).

- feature:

  "mdf" (median) or "mnf" (mean) frequency.

## Value

list: mdf_slope_hz_per_min, mdf_norm_slope_pct, fit_r2, rms.
