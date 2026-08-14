# Evaluate a hypothesis against the episode's evidence

Evaluate a hypothesis against the episode's evidence

## Usage

``` r
evaluate_hypothesis(ep, hyp, sced)
```

## Arguments

- ep:

  a \`rehab_episode\`.

- hyp:

  a \`rehab_hypothesis\`.

- sced:

  the result of \[sced_analyze\] on the primary measure.

## Value

list(verdict, overall, items) where each item is one checked expectation
with its supported/refuted status and the evidence used.
