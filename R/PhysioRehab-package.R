#' PhysioRehab: ICF-native single-case clinical-reasoning tools for rehabilitation
#'
#' Rehabilitation evaluates the individual over time against personal goals, not
#' a randomised group. PhysioRehab anchors measures, goals and observations to
#' the WHO International Classification of Functioning (ICF), detects change with
#' single-case methods, keeps the clinician in the loop with a
#' hypothesis-to-evidence check, and auto-drafts an ICF-structured progress note.
#' It is a research tool for measurement, documentation and
#' clinician-in-the-loop reasoning support on synthetic or real signals; it is
#' not a medical device and is not intended for diagnosis.
#'
#' @section Guided workflow (start here):
#' \code{\link{simulate_stroke_gait_case}} builds a synthetic single case;
#' \code{\link{rehab_workflow}} runs the whole path (single-case analysis,
#' hypothesis evaluation, trajectory plot and a drafted note) in one call;
#' \code{\link{rehab_app}} / \code{\link{launch_rehab_app}} expose it as a Shiny
#' GUI.
#'
#' @section Single-case episodes and goals:
#' \code{\link{new_rehab_episode}}, \code{\link{add_session}},
#' \code{\link{rehab_goal}} and \code{\link{icf_change}} build and query a
#' single patient's repeated-measures episode.
#'
#' @section ICF semantics:
#' \code{\link{icf_catalog}}, \code{\link{icf_qualifier_label}} and
#' \code{\link{icf_for_measure}}.
#'
#' @section Change detection and reasoning:
#' \code{\link{sced_analyze}} (single-case non-overlap + MCID),
#' \code{\link{rehab_hypothesis}} and \code{\link{evaluate_hypothesis}}
#' (hypothesis-to-evidence check), \code{\link{plot_trajectory}} and
#' \code{\link{draft_progress_note}}.
#'
#' @section Cross-modal capacity vs performance (ICF constructs):
#' \code{\link{new_icf_construct}}, \code{\link{add_icf_measure}},
#' \code{\link{capacity_performance_gap}},
#' \code{\link{icf_construct_trajectory}} and
#' \code{\link{add_performance_from_freeliving}}.
#'
#' @section ADL measurement coverage:
#' \code{\link{adl_coverage}}, \code{\link{adl_coverage_summary}} and
#' \code{\link{construct_coverage}}.
#'
#' @section Fall risk:
#' \code{\link{fall_risk_index}} and \code{\link{fall_risk_from_episode}}.
#'
#' @section Real-signal adapters (ecosystem):
#' \code{\link{mocap_gait_measures}} and \code{\link{add_session_from_mocap}}
#' (markerless gait via PhysioMoCap); \code{\link{emg_fatigue_measures}} and
#' \code{\link{add_session_from_emg}} (muscle fatigue via PhysioEMG).
#'
#' @section Where to go next:
#' Single-case statistics come from PhysioAppKit, the ICF ontology from
#' PhysioAnnotationHub, and real signals from PhysioMoCap and PhysioEMG. See
#' \code{vignette("PhysioRehab")} for a worked end-to-end example.
#'
#' @keywords internal
"_PACKAGE"
