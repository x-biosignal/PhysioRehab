# Define a rehabilitation goal (ICF-linked, GAS-scaled)

Define a rehabilitation goal (ICF-linked, GAS-scaled)

## Usage

``` r
rehab_goal(id, statement, icf_codes, baseline, target, unit, gas = NULL)
```

## Arguments

- id:

  short identifier, e.g. "G1".

- statement:

  free-text clinical goal (the patient's own words are ideal).

- icf_codes:

  character vector of ICF codes this goal maps to.

- baseline, target:

  numeric baseline and target on the primary measure.

- unit:

  measurement unit, e.g. "m/s".

- gas:

  optional named character vector describing GAS levels
  "-2","-1","0","+1","+2".

## Value

an object of class \`rehab_goal\`.
