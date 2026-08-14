# Map a measure to ICF codes via the real ontology (PhysioAnnotationHub)

Uses PhysioAnnotationHub's ICF-linking rules (Cieza 2005) so a measure
such as \`"gait_speed"\` resolves to \`"d450"\` from the maintained
ontology, not a hard-coded table. Signal-derived measures that are not
yet in the ontology (e.g. \`"knee_rom"\`) return \`character(0)\`; the
fix is to register the mapping in PhysioAnnotationHub, not to hard-code
it here.

## Usage

``` r
icf_for_measure(measure)
```

## Arguments

- measure:

  a measure / instrument id, e.g. "gait_speed".

## Value

character vector of ICF codes (possibly empty).
