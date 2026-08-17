# PhysioRehab

**ICF-native, single-case clinical-reasoning tools for rehabilitation.**

Rehabilitation reasons differently from disease medicine: it targets disability
and life reconstruction, evaluates the individual rather than a randomised
group, combines qualitative judgement with quantitative signals, and is
delivered by allied-health professionals (PT / OT / ST) with varied statistical
backgrounds. PhysioRehab re-centres physiological measurement around that way of
reasoning: it anchors measures and goals to the International Classification of
Functioning (ICF), detects change with single-case methods, keeps the clinician
in the loop, and drafts an ICF-structured progress note.

## Installation

```r
install.packages("PhysioRehab", repos = "https://x-biosignal.r-universe.dev")
```

## Quick start

The core is a single guided workflow:

```
measure the individual over time against personal goals
  -> detect change defensibly with single-case methods (NAP + MCID + 2-SD band)
  -> visualise against ICF and the trajectory
  -> auto-draft an ICF-structured progress note
```

```r
library(PhysioRehab)

ep  <- simulate_stroke_gait_case()          # a synthetic single case
hyp <- rehab_hypothesis("task-oriented training improves gait",
                        expect_speed_mcid = TRUE, expect_icf = c(d450 = 1))
res <- rehab_workflow(ep, hyp)              # analyse -> reason -> plot -> draft

cat(res$report)                             # the ICF-structured progress note
res$plot_file                               # the single-case trajectory plot
```

A runnable end-to-end example is included:

```r
Rscript inst/examples/run_demo.R
```

It simulates a chronic-stroke, left-hemiplegia single case (AB design, 12
sessions), runs the workflow, and writes two clinician-facing artefacts — an
auto-drafted, ICF-structured progress note and a single-case trajectory plot.

## Design

| Component | Description | Code |
|---|---|---|
| **ICF-native semantics** | Measures, goals and observations are anchored to WHO ICF codes with 0–4 qualifiers — the domain data model of rehabilitation. | `R/icf.R`, `R/goals.R` |
| **Quantitative–qualitative fusion with an honest reasoning scaffold** | Single-case change detection fuses signals with ICF qualifiers; a hypothesis-to-evidence check keeps the clinician in the loop and explicitly reports what the evidence does *not* support. | `R/sced.R`, `R/reasoning.R` |
| **Guided workflow and clinician GUI** | One call, `rehab_workflow()`, runs the whole path; a Shiny interface, `rehab_app()`, exposes it to non-programmers, while experts call the components directly. | `R/workflow.R`, `R/app.R` |

The clinician-facing output (`R/report.R`) drafts the progress note the
therapist already has to write, so measurement and analysis accompany routine
documentation.

## Ecosystem integration

PhysioRehab builds on the x-biosignal ecosystem rather than reimplementing it:

- **Single-case statistics** — `PhysioAppKit` (NAP effect size, threshold-and-band
  analysis; reconciled with `PhysioClinStats::scedNAP`).
- **ICF ontology** — `PhysioAnnotationHub` (`icf_for_measure()` resolves a measure
  to ICF codes from the maintained ontology).
- **Real signals** — `PhysioMoCap` (markerless gait via `add_session_from_mocap()`)
  and `PhysioEMG` (muscle fatigue via `add_session_from_emg()`).
- **Ordinal-to-interval measurement** — Rasch calibration via `PhysioAppKit`.
- **Reporting** — `PhysioReport`.

## Scope and limitations

- Early-stage (0.1.0). The bundled examples use synthetic data; the worked
  instance is stroke hemiplegic gait, and the framework is condition-agnostic.
- PhysioRehab is a **research tool for measurement, documentation, and
  clinician-in-the-loop reasoning support. It is not a medical device and is not
  intended for diagnosis**; final clinical judgement rests with the clinician.

## Citation

See `CITATION.cff`. Licensed under the MIT License.
