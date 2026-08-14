# ICF qualifier change across an episode (improvement = qualifier decreases)

ICF qualifier change across an episode (improvement = qualifier
decreases)

## Usage

``` r
icf_change(ep, code)
```

## Arguments

- ep:

  a \`rehab_episode\`.

- code:

  ICF code, e.g. "d450".

## Value

list(code, from, to, improved) where \`improved\` \> 0 means the
qualifier fell (clinical improvement). NULL if the code was never
recorded.
