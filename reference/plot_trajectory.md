# Plot a single-case trajectory with phase line, 2-SD band and MCID target

Plot a single-case trajectory with phase line, 2-SD band and MCID target

## Usage

``` r
plot_trajectory(
  ep,
  measure = "gait_speed",
  mcid = 0.16,
  file = NULL,
  ylab = NULL
)
```

## Arguments

- ep:

  a \`rehab_episode\`.

- measure:

  primary measure column.

- mcid:

  MCID (drawn as the target line above baseline mean).

- file:

  optional PNG path; if NULL, draws to the current device.

- ylab:

  y-axis label.

## Value

(invisibly) the file path, or NULL.
