# ---------------------------------------------------------------------------
# Pillar C, made real: a clinician-facing GUI (Shiny prototype).
#
# The adoption "仕掛け" that R Commander / jamovi proved: allied-health staff
# who cannot code still get a full workflow from a few clicks -- and every click
# is mirrored as readable R code (the "生成されたRコード" tab), so the GUI
# doubles as an on-ramp into R. Progressive disclosure: load a case, tweak MCID
# and the clinical hypothesis, record a session, "解析実行" -> trajectory,
# SCED value boxes, honest reasoning, and the auto-drafted progress note.
# ---------------------------------------------------------------------------

#' Build the PhysioRehab clinician prototype GUI
#'
#' @return a Shiny app object (pass to [shiny::runApp] or print to launch).
#' @export
rehab_app <- function() {
  for (p in c("shiny", "bslib"))
    if (!requireNamespace(p, quietly = TRUE))
      stop("package '", p, "' is required for the GUI", call. = FALSE)

  icf_choices <- c("d450 歩行" = "d450", "b770 歩行パターン" = "b770",
                   "b730 筋力" = "b730", "b735 痙縮" = "b735")

  ui <- bslib::page_sidebar(
    title = "PhysioRehab — 単一事例リハ評価（応用レイヤー#1: リハビリテーション）",
    sidebar = bslib::sidebar(
      width = 330,
      shiny::helpText("患者の経時評価を目標参照で行います。"),
      shiny::sliderInput("mcid", "MCID（m/s）", min = 0.05, max = 0.30,
                         value = 0.16, step = 0.01),
      shiny::tags$hr(),
      shiny::strong("臨床仮説"),
      shiny::checkboxInput("h_speed", "歩行速度がMCIDを超えて改善", TRUE),
      shiny::checkboxGroupInput("h_icf", "以下のICFが1段階以上改善",
                                choices = icf_choices, selected = c("d450", "b735")),
      shiny::actionButton("run", "解析実行", class = "btn-primary",
                          width = "100%"),
      shiny::tags$hr(),
      shiny::strong("新規セッションを記録"),
      shiny::selectInput("s_phase", "フェーズ",
                         c("baseline", "intervention"), "intervention"),
      shiny::numericInput("s_speed", "歩行速度 m/s", 0.68, 0.1, 1.5, 0.01),
      shiny::selectInput("s_d450", "ICF d450 歩行", 0:4, 2),
      shiny::selectInput("s_b770", "ICF b770 歩行パターン", 0:4, 2),
      shiny::numericInput("s_gas", "GAS", 1, -2, 2, 1),
      shiny::actionButton("add", "セッション追加", width = "100%")
    ),
    bslib::navset_card_tab(
      bslib::nav_panel(
        "結果",
        bslib::layout_columns(
          fill = FALSE,
          bslib::value_box("NAP（効果量）", shiny::textOutput("vb_nap"),
                           theme = "primary"),
          bslib::value_box("Δ 歩行速度", shiny::textOutput("vb_delta"),
                           theme = "secondary"),
          bslib::value_box("MCID判定", shiny::textOutput("vb_mcid"))
        ),
        bslib::card(bslib::card_header("単一事例トラジェクトリ"),
                    shiny::plotOutput("plot", height = "380px")),
        bslib::card(bslib::card_header("臨床推論（仮説→根拠）"),
                    shiny::uiOutput("reason")),
        bslib::card(bslib::card_header("自動下書き経過記録"),
                    shiny::uiOutput("note"))
      ),
      bslib::nav_panel(
        "生成されたRコード",
        shiny::helpText("クリック操作は下のRコードと等価です（GUIはRへの入口）。"),
        shiny::verbatimTextOutput("code")
      ),
      bslib::nav_panel("セッション一覧", shiny::tableOutput("sessions"))
    )
  )

  server <- function(input, output, session) {
    ep <- shiny::reactiveVal(simulate_stroke_gait_case())

    shiny::observeEvent(input$add, {
      e <- ep()
      nextdate <- max(e$sessions$date) + 3
      gid <- if (length(e$goals)) e$goals[[1]]$id else "G1"
      e <- add_session(
        e, nextdate, input$s_phase, gait_speed = input$s_speed,
        icf = list(d450 = as.integer(input$s_d450),
                   b770 = as.integer(input$s_b770)),
        gas = stats::setNames(list(as.integer(input$s_gas)), gid))
      ep(e)
    })

    hyp <- shiny::reactive({
      icf <- stats::setNames(rep(1L, length(input$h_icf)), input$h_icf)
      rehab_hypothesis("GUI入力による仮説",
                       expect_speed_mcid = isTRUE(input$h_speed),
                       expect_icf = icf)
    })

    # Fires once at startup (ignoreNULL=FALSE) and on every "解析実行" click.
    analysis <- shiny::eventReactive(input$run, {
      rehab_workflow(ep(), hyp(), mcid = input$mcid, out_dir = tempdir())
    }, ignoreNULL = FALSE)

    output$vb_nap <- shiny::renderText({
      r <- analysis(); sprintf("%.2f（%s）", r$sced$nap, r$sced$interpretation)
    })
    output$vb_delta <- shiny::renderText({
      sprintf("%.2f m/s", analysis()$sced$delta)
    })
    output$vb_mcid <- shiny::renderText({
      if (isTRUE(analysis()$sced$exceeds_mcid)) "MCID超え" else "MCID未満"
    })
    output$plot <- shiny::renderPlot({
      plot_trajectory(ep(), mcid = input$mcid, ylab = "快適歩行速度 (m/s)")
    })
    output$reason <- shiny::renderUI({
      r <- analysis(); shiny::req(r$reasoning)
      items <- lapply(r$reasoning$items, function(it) {
        mark <- if (is.na(it$supported)) "—" else if (it$supported) "○" else "×"
        col <- if (isTRUE(it$supported)) "#1a7f37"
               else if (is.na(it$supported)) "#777" else "#cf222e"
        shiny::tags$li(shiny::HTML(sprintf(
          "<b style='color:%s'>[%s]</b> %s — <span style='color:#555'>%s</span>",
          col, mark, it$claim, it$evidence)))
      })
      shiny::tagList(
        shiny::tags$p(shiny::tags$b("総合判定："), r$reasoning$overall),
        shiny::tags$ul(items))
    })
    output$note <- shiny::renderUI(shiny::markdown(analysis()$report))
    output$code <- shiny::renderText({
      icfstr <- paste(sprintf("%s = 1", input$h_icf), collapse = ", ")
      paste0(
        "library(PhysioRehab)\n",
        "ep  <- simulate_stroke_gait_case()\n",
        "hyp <- rehab_hypothesis(\n",
        "  \"課題指向型歩行練習の効果仮説\",\n",
        "  expect_speed_mcid = ", isTRUE(input$h_speed), ",\n",
        "  expect_icf = c(", icfstr, "))\n",
        "res <- rehab_workflow(ep, hyp, mcid = ", input$mcid, ")\n",
        "res$report      # 経過記録（自動下書き）\n",
        "res$plot_file   # 軌跡図\n")
    })
    output$sessions <- shiny::renderTable({
      s <- ep()$sessions
      keep <- intersect(c("session", "phase", "gait_speed", "icf_d450",
                          "icf_b770", "gas_G1"), names(s))
      s[keep]
    }, digits = 2)
  }

  shiny::shinyApp(ui, server)
}

#' Launch the PhysioRehab GUI in a browser
#' @param ... passed to [shiny::runApp].
#' @export
launch_rehab_app <- function(...) {
  shiny::runApp(rehab_app(), ...)
}
