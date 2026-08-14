# Create an empty rehabilitation episode (single-case)

Create an empty rehabilitation episode (single-case)

## Usage

``` r
new_rehab_episode(patient_id, condition, design = "AB", goals = list())
```

## Arguments

- patient_id:

  de-identified patient id.

- condition:

  free-text condition, e.g. "stroke, left hemiplegia".

- design:

  single-case design label, e.g. "AB".

- goals:

  list of \[rehab_goal\] objects.

## Value

an object of class \`rehab_episode\`.
