# Changelog

## PhysioRehab 0.1.0

First public release.

- ICF-native semantic layer:
  [`icf_catalog()`](https://x-biosignal.github.io/PhysioRehab/reference/icf_catalog.md),
  [`icf_qualifier_label()`](https://x-biosignal.github.io/PhysioRehab/reference/icf_qualifier_label.md),
  [`icf_change()`](https://x-biosignal.github.io/PhysioRehab/reference/icf_change.md),
  and
  [`icf_for_measure()`](https://x-biosignal.github.io/PhysioRehab/reference/icf_for_measure.md)
  resolving measures to ICF codes via the `PhysioAnnotationHub` ontology
  (with a local fallback).
- Individualised single-case container:
  [`new_rehab_episode()`](https://x-biosignal.github.io/PhysioRehab/reference/new_rehab_episode.md),
  [`add_session()`](https://x-biosignal.github.io/PhysioRehab/reference/add_session.md),
  with Goal Attainment Scaling goals
  ([`rehab_goal()`](https://x-biosignal.github.io/PhysioRehab/reference/rehab_goal.md)).
- Single-case change detection over `PhysioAppKit`:
  [`sced_analyze()`](https://x-biosignal.github.io/PhysioRehab/reference/sced_analyze.md)
  (NAP + MCID
  - 2-SD band) and a clinician-in-the-loop reasoning scaffold
    ([`rehab_hypothesis()`](https://x-biosignal.github.io/PhysioRehab/reference/rehab_hypothesis.md),
    [`evaluate_hypothesis()`](https://x-biosignal.github.io/PhysioRehab/reference/evaluate_hypothesis.md))
    that honestly flags unsupported claims.
- Auto-drafted, ICF-structured progress note:
  [`draft_progress_note()`](https://x-biosignal.github.io/PhysioRehab/reference/draft_progress_note.md);
  a guided one-call
  [`rehab_workflow()`](https://x-biosignal.github.io/PhysioRehab/reference/rehab_workflow.md);
  a trajectory plot
  ([`plot_trajectory()`](https://x-biosignal.github.io/PhysioRehab/reference/plot_trajectory.md)).
- Real-signal adapters:
  [`mocap_gait_measures()`](https://x-biosignal.github.io/PhysioRehab/reference/mocap_gait_measures.md)
  /
  [`add_session_from_mocap()`](https://x-biosignal.github.io/PhysioRehab/reference/add_session_from_mocap.md)
  (markerless gait via `PhysioMoCap`) and
  [`emg_fatigue_measures()`](https://x-biosignal.github.io/PhysioRehab/reference/emg_fatigue_measures.md)
  /
  [`add_session_from_emg()`](https://x-biosignal.github.io/PhysioRehab/reference/add_session_from_emg.md)
  (muscle fatigue via `PhysioEMG`).
- A clinician GUI
  ([`rehab_app()`](https://x-biosignal.github.io/PhysioRehab/reference/rehab_app.md)
  /
  [`launch_rehab_app()`](https://x-biosignal.github.io/PhysioRehab/reference/launch_rehab_app.md),
  Shiny) whose actions mirror the equivalent R code.
- Worked instance: stroke hemiplegic gait
  ([`simulate_stroke_gait_case()`](https://x-biosignal.github.io/PhysioRehab/reference/simulate_stroke_gait_case.md)).
