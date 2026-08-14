# Package index

## ICF semantics & goals

- [`icf_catalog()`](https://x-biosignal.github.io/PhysioRehab/reference/icf_catalog.md)
  : ICF catalogue (stroke gait core-set subset)
- [`icf_qualifier_label()`](https://x-biosignal.github.io/PhysioRehab/reference/icf_qualifier_label.md)
  : Label an ICF qualifier (0-4 severity)
- [`icf_change()`](https://x-biosignal.github.io/PhysioRehab/reference/icf_change.md)
  : ICF qualifier change across an episode (improvement = qualifier
  decreases)
- [`icf_for_measure()`](https://x-biosignal.github.io/PhysioRehab/reference/icf_for_measure.md)
  : Map a measure to ICF codes via the real ontology
  (PhysioAnnotationHub)
- [`rehab_goal()`](https://x-biosignal.github.io/PhysioRehab/reference/rehab_goal.md)
  : Define a rehabilitation goal (ICF-linked, GAS-scaled)

## Single-case episode & analysis

- [`new_rehab_episode()`](https://x-biosignal.github.io/PhysioRehab/reference/new_rehab_episode.md)
  : Create an empty rehabilitation episode (single-case)
- [`add_session()`](https://x-biosignal.github.io/PhysioRehab/reference/add_session.md)
  : Record one therapy session
- [`sced_analyze()`](https://x-biosignal.github.io/PhysioRehab/reference/sced_analyze.md)
  : Analyse an episode's primary measure with SCED + MCID (via
  PhysioAppKit)

## Reasoning, report & plot

- [`rehab_hypothesis()`](https://x-biosignal.github.io/PhysioRehab/reference/rehab_hypothesis.md)
  : State a clinical hypothesis about expected change
- [`evaluate_hypothesis()`](https://x-biosignal.github.io/PhysioRehab/reference/evaluate_hypothesis.md)
  : Evaluate a hypothesis against the episode's evidence
- [`draft_progress_note()`](https://x-biosignal.github.io/PhysioRehab/reference/draft_progress_note.md)
  : Draft an ICF-structured progress note from an analysed episode
- [`plot_trajectory()`](https://x-biosignal.github.io/PhysioRehab/reference/plot_trajectory.md)
  : Plot a single-case trajectory with phase line, 2-SD band and MCID
  target

## Guided workflow & GUI

- [`rehab_workflow()`](https://x-biosignal.github.io/PhysioRehab/reference/rehab_workflow.md)
  : Run the full single-case rehab workflow (guided, one call)
- [`rehab_app()`](https://x-biosignal.github.io/PhysioRehab/reference/rehab_app.md)
  : Build the PhysioRehab clinician prototype GUI
- [`launch_rehab_app()`](https://x-biosignal.github.io/PhysioRehab/reference/launch_rehab_app.md)
  : Launch the PhysioRehab GUI in a browser

## Real-signal adapters

- [`mocap_gait_measures()`](https://x-biosignal.github.io/PhysioRehab/reference/mocap_gait_measures.md)
  : Real gait/kinematic measures from an OpenPose recording (via
  PhysioMoCap)
- [`add_session_from_mocap()`](https://x-biosignal.github.io/PhysioRehab/reference/add_session_from_mocap.md)
  : Append a rehab session whose measures come from a real OpenPose
  recording
- [`emg_fatigue_measures()`](https://x-biosignal.github.io/PhysioRehab/reference/emg_fatigue_measures.md)
  : Real muscle-fatigue / amplitude measures from an EMG recording (via
  PhysioEMG)
- [`add_session_from_emg()`](https://x-biosignal.github.io/PhysioRehab/reference/add_session_from_emg.md)
  : Append a rehab session whose measures come from a real EMG recording

## Example data

- [`simulate_stroke_gait_case()`](https://x-biosignal.github.io/PhysioRehab/reference/simulate_stroke_gait_case.md)
  : Simulate a stroke hemiplegic-gait single-case episode
