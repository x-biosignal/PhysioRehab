# Run the full single-case rehab workflow (guided, one call)

Run the full single-case rehab workflow (guided, one call)

## Usage

``` r
rehab_workflow(
  ep,
  hypothesis = NULL,
  measure = "gait_speed",
  mcid = 0.16,
  direction = "increase",
  out_dir = tempdir()
)
```

## Arguments

- ep:

  a \`rehab_episode\`.

- hypothesis:

  optional \`rehab_hypothesis\`.

- measure:

  primary measure column.

- mcid:

  MCID for the primary measure.

- direction:

  improvement direction.

- out_dir:

  directory for the trajectory PNG and progress-note Markdown.

## Value

(invisibly) list(sced, reasoning, report, plot_file, report_file).
