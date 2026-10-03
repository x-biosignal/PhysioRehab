# PhysioRehab 0.5.2

## Documentation

* `?PhysioRehab` now answers: a package help page gives one paragraph on what the
  package is for, the main entry points grouped by task, and where to go next.
* A vignette carries one task end to end on synthetic or bundled data, offline,
  and is built and run by `R CMD check`.
* Runnable `@examples` added or corrected across 27 help pages. Each runs
  offline in seconds, writes nothing outside `tempdir()`, and is executed by
  `R CMD check`; anything needing a device, a download or an optional backend is
  fenced with the reason stated.
* The README's quick start runs as written: it attaches the package, builds its
  own inputs, and uses only hard dependencies.

# PhysioRehab 0.5.1

* Wired `fall_risk_index()` into the reporting pipeline: `fall_risk_from_episode()`
  derives the fall-risk domains from a `rehab_episode`'s latest session `measures`
  columns; `draft_progress_note()` gains a `fall_risk` argument and renders a
  "転倒リスク（統合指標）" section (domains, z, composite/percentile, stratum or the
  uncalibrated caveat); `rehab_workflow()` computes it and passes it into the note.

# PhysioRehab 0.5.0

* `fall_risk_index()`: an integrated multi-domain fall-risk index that combines
  per-domain summaries (postural sway, gait variability, TUG, lower-limb
  strength, and optionally reaction time / vision / proprioception) following the
  Physiological Profile Assessment framework. Honest scope: the default
  z-score-composite method standardises each domain against a user-supplied
  healthy reference (sign-aligned, equal weights by default) and stays
  uncalibrated (no risk stratum) unless validated `cutpoints` are supplied; the
  PPA method requires the caller's published discriminant weights (`ppa_coef`) —
  no weights or cut-offs are fabricated.

# PhysioRehab 0.4.3

* Honest-scope correction: eating (d550) sensor_har performance is moved back
  from `validated` to `supported`. A strict leave-one-subject-out re-analysis on
  the HMP wrist dataset shows eating recall 0.00 -- eating collapses into the
  other hand-to-face gestures and is NOT distinguished cross-subject; the earlier
  every-other-subject split had no eating in its test set. Grooming (d520) and
  drinking (d560) remain `validated`. Validated performance coverage 56% -> 50%.


# PhysioRehab 0.4.2

* Washing (d510) moved from `supported` to `validated` after cross-subject
  recognition on the HTAD wrist-accelerometer dataset (washing-hands recall 0.53,
  ~3.7x chance). The method note records the weak evidence (`HTAD N=3`).
  Validated performance coverage rises 50% -> 56%. Dressing (d540) and toileting
  (d530) stay `supported` -- still no public wrist-IMU labels.


# PhysioRehab 0.4.1

* Self-care recognition validated on real data: brushing/combing (d520), eating
  (d550) and drinking (d560) are moved from `supported` to `validated` in the
  coverage registry after cross-subject validation on the UCI wrist-worn
  accelerometer ADL dataset (self-care detected-as-self-care 1.00). Validated
  performance coverage rises 33% -> 50%. Washing/dressing/toileting stay
  `supported` (no public wrist-IMU labels for those tasks).


# PhysioRehab 0.4.0

* The ADL coverage registry gains a `status` column distinguishing `validated`
  (proven on real data or an established measure) from `supported` (pipeline +
  ICF mapping ready, but not yet validated on a task-specific dataset).
  `adl_coverage_summary()` reports `validated_performance` per ADL and
  `pct_validated_performance` overall -- an honest split of real vs potential
  coverage. Registers the remaining self-care activities (washing/toileting/
  dressing) as `supported` performance via wrist-gesture `recognizeADL`.


# PhysioRehab 0.3.1

* Register real-world upper-limb use (`PhysioWearable::upperLimbUse` -> d445) and
  wrist-gesture eating/drinking recognition (`recognizeADL` -> d550/d560) as
  performance modalities in the ADL coverage registry, filling the self-care
  performance gap (ecosystem performance coverage 39% -> 56%, multi-modal
  33% -> 50%).


# PhysioRehab 0.3.0

ADL measurement-coverage registry.

* `adl_coverage()`: what the ecosystem can measure for each ADL -- the ICF code,
  the modality (scale / performance_test / kinematics / emg / dexterity /
  sensor_freeliving / sensor_har), the qualifier it informs (capacity vs
  performance) and the function that provides it.
* `adl_coverage_summary()`: per-ADL completeness -- how many modalities, and
  whether covered on both qualifiers (genuinely multi-modal) -- with
  ecosystem-level percentages.
* `construct_coverage()`: for one patient's `icf_construct`, the modalities the
  ecosystem offers versus the qualifiers actually populated, flagging the gaps.


# PhysioRehab 0.2.0

Cross-modal ICF construct: capacity vs performance.

* `new_icf_construct()` / `add_icf_measure()`: bind heterogeneous measures of one
  ICF Activity/Participation domain under its capacity (clinic scale / Rasch) and
  performance (free-living sensor) qualifiers on the ICF 0-4 scale.
* `capacity_performance_gap()`: the performance-minus-capacity discrepancy -- what
  a person does versus what they can do.
* `icf_construct_trajectory()`: a time-ordered qualifier stream for single-case
  analysis.
* `add_performance_from_freeliving()`: ingest a `PhysioWearable::summarizeFreeLiving()`
  metric as the performance qualifier.
* `draft_progress_note()` gains an optional cross-modal capacity-vs-performance
  section.


# PhysioRehab 0.1.0

First public release.

* ICF-native semantic layer: `icf_catalog()`, `icf_qualifier_label()`,
  `icf_change()`, and `icf_for_measure()` resolving measures to ICF codes via
  the `PhysioAnnotationHub` ontology (with a local fallback).
* Individualised single-case container: `new_rehab_episode()`, `add_session()`,
  with Goal Attainment Scaling goals (`rehab_goal()`).
* Single-case change detection over `PhysioAppKit`: `sced_analyze()` (NAP + MCID
  + 2-SD band) and a clinician-in-the-loop reasoning scaffold
  (`rehab_hypothesis()`, `evaluate_hypothesis()`) that honestly flags
  unsupported claims.
* Auto-drafted, ICF-structured progress note: `draft_progress_note()`; a guided
  one-call `rehab_workflow()`; a trajectory plot (`plot_trajectory()`).
* Real-signal adapters: `mocap_gait_measures()` / `add_session_from_mocap()`
  (markerless gait via `PhysioMoCap`) and `emg_fatigue_measures()` /
  `add_session_from_emg()` (muscle fatigue via `PhysioEMG`).
* A clinician GUI (`rehab_app()` / `launch_rehab_app()`, Shiny) whose actions
  mirror the equivalent R code.
* Worked instance: stroke hemiplegic gait (`simulate_stroke_gait_case()`).
