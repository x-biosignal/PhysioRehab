# PhysioRehab clinician prototype GUI.
# Run with:  shiny::runApp(system.file("shiny", package = "PhysioRehab"))
# or during development from the package root:  shiny::runApp("inst/shiny")
if (requireNamespace("pkgload", quietly = TRUE) &&
    file.exists("../../DESCRIPTION")) {
  pkgload::load_all("../..", quiet = TRUE)
} else {
  library(PhysioRehab)
}
rehab_app()
