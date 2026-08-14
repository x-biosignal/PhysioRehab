# Record one therapy session

Record one therapy session

## Usage

``` r
add_session(
  ep,
  date,
  phase,
  gait_speed = NA,
  cadence = NA,
  symmetry = NA,
  measures = list(),
  icf = list(),
  gas = list(),
  observation = ""
)
```

## Arguments

- ep:

  a \`rehab_episode\`.

- date:

  session date (Date or string).

- phase:

  "baseline" or "intervention".

- gait_speed:

  comfortable gait speed (m/s), the primary measure.

- cadence, symmetry:

  secondary quantitative measures (optional).

- measures:

  named list of additional quantitative measures (arbitrary columns),
  e.g. \`list(knee_rom = 47.2)\` for signal-derived measures.

- icf:

  named list of ICF qualifiers, e.g. \`list(b770 = 3, d450 = 3)\`.

- gas:

  named list of GAS ratings keyed by goal id, e.g. \`list(G1 = -1)\`.

- observation:

  clinician's free-text qualitative note.

## Value

the updated \`rehab_episode\`.
