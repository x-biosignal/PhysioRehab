# PhysioRehab (prototype)

**An ICF-native clinical-reasoning layer that re-centres physiological
measurement around how rehabilitation actually reasons.**

Rehabilitation is different from disease medicine: it targets
*disability* and *life-reconstruction*, evaluates the *individual* (not
a randomised group), fuses *qualitative* judgement with quantitative
signals, and is delivered by allied-health staff (PT/OT/ST) whose
coding/statistics background is diverse. A tool that wants to penetrate
rehab has to speak that language. This prototype is a runnable,
end-to-end vertical slice that does.

> Status: **concept demonstrator**, not a released package. The engine
> it sits on already exists in the ecosystem; the novelty here is the
> rehab-facing semantic / qualitative / reasoning / documentation layer.

## The one-path workflow

    個別患者を目標参照で経時測定
      → SCED で変化を defensible に検出（NAP + MCID + 2SD帯）
      → ICF + 軌跡で可視化
      → ICF 構造の経過記録を自動下書き

Run it:

``` r
# from the package root
Rscript inst/examples/run_demo.R
```

It simulates a chronic stroke, left-hemiplegia single case (AB design,
12 sessions), runs the guided workflow, and emits two clinician-facing
artefacts: `progress_note.md` (auto-drafted, ICF-structured) and
`trajectory.png` (a SCED single-case plot). Sample output is in
`inst/examples/out/`.

## Design: the three pillars (and what is deliberately honest)

| Pillar | What it is | Where in the code |
|----|----|----|
| **A. ICF-native semantics** | The shared language of rehab (WHO ICF): every measure, goal and observation is anchored to ICF codes + 0–4 qualifiers. The domain data model. | `R/icf.R`, `R/goals.R` (GAS) |
| **B. Quant × qual fusion + reasoning scaffold** | Single-case change detection (`R/sced.R`) fuses gait speed with ICF qualifiers; a hypothesis→evidence check (`R/reasoning.R`) keeps the clinician in the loop and **honestly flags what is not supported** (in the demo, spasticity b735 does not improve → “partial”). | `R/sced.R`, `R/reasoning.R` |
| **C. Low floor / high ceiling** | One guided call ([`rehab_workflow()`](https://x-biosignal.github.io/PhysioRehab/reference/rehab_workflow.md)) is what a GUI button runs; experts call the pieces directly. Every run leaves a readable record, so the GUI doubles as an R on-ramp — the Rcmdr/jamovi adoption mechanism. | `R/workflow.R` |

The clinician-facing payoff (`R/report.R`) is the **adoption hook**: it
drafts the progress note the therapist already has to write, so
measurement and analysis ride along for free.

## Sits on the existing ecosystem (does not reinvent)

- **SCED** → `PhysioClinStats` (`scedNAP`/`scedTau`/`scedTauU` already
  shipped; the local `nap()` here is a self-contained prototype
  stand-in).
- **Ontologies / ICF catalogue** → `PhysioAnnotationHub`.
- **Individual trajectories** →
  [`PhysioCore::PhysioLongitudinal`](https://x-biosignal.github.io/PhysioCore//reference/PhysioLongitudinal.html).
- **Quantitative measures** (gait speed, symmetry, EMG, synergies) →
  `PhysioMoCap`, `PhysioEMG`, gait pipelines.
- **Report rendering** → `PhysioReport`.
- **Consent / governance / role scope** → `PhysioCompliance`.

## Not yet (deliberate scope)

- A clinician GUI (Pillar C proper) — this prototype is the R core a GUI
  drives.
- Rasch/IRT ordinal→interval measurement.
- Real-signal ingestion wired to the ecosystem packages (here:
  synthetic).
- Regulatory framing (kept to *measurement + documentation + reasoning
  support*, clinician-in-the-loop; not diagnostic autonomy).
