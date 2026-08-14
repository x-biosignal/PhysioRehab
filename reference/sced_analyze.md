# Analyse an episode's primary measure with SCED + MCID (via PhysioAppKit)

Analyse an episode's primary measure with SCED + MCID (via PhysioAppKit)

## Usage

``` r
sced_analyze(
  ep,
  measure = "gait_speed",
  mcid = 0.16,
  direction = c("increase", "decrease")
)
```

## Arguments

- ep:

  a \`rehab_episode\`.

- measure:

  column name of the primary quantitative measure.

- mcid:

  minimal clinically important difference on that measure.

- direction:

  improvement direction.

## Value

a list with NAP, Tau, baseline mean, latest, MCID verdict, 2-SD band.
