# Draft an ICF-structured progress note from an analysed episode

Draft an ICF-structured progress note from an analysed episode

## Usage

``` r
draft_progress_note(ep, sced, reasoning = NULL, mcid = sced$mcid)
```

## Arguments

- ep:

  a \`rehab_episode\`.

- sced:

  result of \[sced_analyze\].

- reasoning:

  optional result of \[evaluate_hypothesis\].

- mcid:

  MCID used (for the record).

## Value

a single Markdown string (also the object printed in the demo).
