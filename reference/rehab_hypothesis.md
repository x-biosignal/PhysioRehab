# State a clinical hypothesis about expected change

State a clinical hypothesis about expected change

## Usage

``` r
rehab_hypothesis(statement, expect_speed_mcid = TRUE, expect_icf = c(d450 = 1))
```

## Arguments

- statement:

  free-text clinical hypothesis.

- expect_speed_mcid:

  logical: expect the primary measure to exceed MCID.

- expect_icf:

  named integer vector of ICF codes -\> minimum expected qualifier
  improvement, e.g. \`c(d450 = 1, b735 = 1)\`.

## Value

an object of class \`rehab_hypothesis\`.
