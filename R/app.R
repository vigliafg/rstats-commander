# Shiny application ---------------------------------------------------------

app_css <- function() {
  htmltools::HTML(
    "
    body { background: #f6f7f9; }
    .rcmdr-topbar { background: #1f3a5f; color: #fff; }
    .rcmdr-topbar .badge-box { color: #dfe8f3; font-size: .9rem; }
    .rcmdr-topbar .form-select { max-width: 8rem; }
    .rcmdr-sidebar {
      background: #fff; border-right: 1px solid #dde2e8;
      min-height: calc(100vh - 90px); padding: .75rem .65rem;
      max-height: calc(100vh - 90px); overflow-y: auto;
    }
    .rcmdr-menu-group > summary {
      cursor: pointer; font-weight: 600; padding: .25rem 0;
      list-style: none; color: #23384f;
    }
    .rcmdr-menu-group > summary::-webkit-details-marker { display: none; }
    .rcmdr-menu-group > summary:before { content: '\\25B8'; display: inline-block;
      width: 1em; transition: transform .1s; }
    .rcmdr-menu-group[open] > summary:before { transform: rotate(90deg); }
    .rcmdr-menu-children { padding-left: .9rem; }
    .rcmdr-menu-item { display: block; padding: .12rem 0; text-decoration: none;
      color: #2c4a6b; }
    .rcmdr-menu-item:hover { color: #0d6efd; text-decoration: underline; }
    .rcmdr-menu-item.disabled { color: #a7b0b9; cursor: not-allowed; }
    .rcmdr-statusbar { background: #eef1f5; border-top: 1px solid #dde2e8;
      padding: .25rem .75rem; font-size: .85rem; color: #52606d; }
    pre.shiny-text-output { white-space: pre-wrap; background: #fff;
      border: 1px solid #e2e6ea; border-radius: .35rem; padding: .75rem;
      min-height: 120px; max-height: 60vh; overflow-y: auto; }
    .rcmdr-plot img.rcmdr-main-plot { max-width: 100%; border: 1px solid #e2e6ea; }
    .rcmdr-gallery { display: flex; flex-wrap: wrap; gap: .5rem; margin-bottom: .75rem; }
    .rcmdr-gallery img.rcmdr-thumb { width: 110px; height: 82px; object-fit: cover;
      border: 2px solid #dde2e8; border-radius: .3rem; cursor: pointer;
      background: #fff; }
    .rcmdr-gallery img.rcmdr-thumb.active { border-color: #0d6efd; }
    .rcmdr-help-text { white-space: pre-wrap; max-height: 60vh; overflow-y: auto;
      background: #fbfbfc; border: 1px solid #e2e6ea; padding: .75rem; }
    .rcmdr-help-search { margin-bottom: .75rem; }
    .rcmdr-help-sidebar { background: #fff; border: 1px solid #e2e6ea;
      border-radius: .4rem; padding: .75rem; }
    .rcmdr-help-sidebar h6 { text-transform: uppercase; letter-spacing: .04em;
      font-size: .75rem; color: #6b7785; }
    .rcmdr-help-category { display: flex; justify-content: space-between;
      align-items: center; gap: .5rem; padding: .3rem .4rem;
      border-radius: .3rem; color: #2c4a6b; text-decoration: none; }
    .rcmdr-help-category:hover, .rcmdr-help-category.active {
      background: #eaf1fa; color: #0d6efd; }
    .rcmdr-help-result { display: block; padding: .55rem .6rem; margin-bottom: .35rem;
      border: 1px solid #e2e6ea; border-radius: .4rem; background: #fff;
      color: inherit; text-decoration: none; }
    .rcmdr-help-result:hover { border-color: #0d6efd; }
    .rcmdr-help-result-title { font-weight: 600; color: #1f3a5f; }
    .rcmdr-help-result-category { float: right; font-size: .75rem;
      text-transform: uppercase; color: #6b7785; }
    .rcmdr-help-result-snippet { margin: .25rem 0 0; font-size: .88rem;
      color: #52606d; }
    .rcmdr-help-topic { margin-top: 1rem; background: #fff;
      border: 1px solid #e2e6ea; border-radius: .4rem; padding: 1rem 1.25rem; }
    .rcmdr-help-topic:focus-visible { outline: 3px solid #0d6efd; }
    .rcmdr-help-body { max-width: 70ch; }
    .rcmdr-help-body pre { background: #f4f6f8; border: 1px solid #e2e6ea;
      border-radius: .35rem; padding: .6rem .75rem; overflow-x: auto; }
    .rcmdr-help-body table { border-collapse: collapse; margin: .75rem 0; }
    .rcmdr-help-body th, .rcmdr-help-body td {
      border: 1px solid #dde2e8; padding: .3rem .5rem; }
    .rcmdr-help-footer { display: flex; gap: .5rem; flex-wrap: wrap;
      margin-top: 1rem; padding-top: .75rem; border-top: 1px solid #e2e6ea; }
    .rcmdr-help-related ul { padding-left: 1.1rem; }
    .rcmdr-help-inline { margin-top: 1rem; padding-top: .75rem;
      border-top: 2px solid #dde2e8; max-height: 45vh; overflow-y: auto; }
    .rcmdr-help-language { text-transform: uppercase; font-size: .75rem;
      color: #6b7785; }
    .rcmdr-busy { color: #d97706; font-weight: 600; }
    .rcmdr-skip-link { position: absolute; left: .5rem; top: .5rem;
      background: #fff; color: #1f3a5f; padding: .4rem .7rem;
      border-radius: .3rem; z-index: 2000; }
    :focus-visible { outline: 3px solid #0d6efd; outline-offset: 2px; }
    body.rcmdr-dark { background: #151a21; color: #d7dde5; }
    body.rcmdr-dark .rcmdr-sidebar,
    body.rcmdr-dark pre.shiny-text-output,
    body.rcmdr-dark .rcmdr-help-text,
    body.rcmdr-dark .rcmdr-help-sidebar,
    body.rcmdr-dark .rcmdr-help-result,
    body.rcmdr-dark .rcmdr-help-topic,
    body.rcmdr-dark .rcmdr-help-body pre,
    body.rcmdr-dark .rcmdr-gallery img.rcmdr-thumb,
    body.rcmdr-dark .nav-tabs .nav-link.active { background: #1d242d; color: #d7dde5; }
    body.rcmdr-dark .rcmdr-help-result-title { color: #cfe0f3; }
    body.rcmdr-dark .rcmdr-help-category:hover,
    body.rcmdr-dark .rcmdr-help-category.active { background: #24303d; }
    body.rcmdr-dark .rcmdr-menu-group > summary,
    body.rcmdr-dark .rcmdr-menu-item { color: #bfcbd9; }
    body.rcmdr-dark .rcmdr-menu-item.disabled { color: #5d6874; }
    body.rcmdr-dark .rcmdr-statusbar { background: #1d242d; color: #9fb0c2;
      border-color: #2b3540; }
    body.rcmdr-dark .table { color: #d7dde5; }
    body.rcmdr-dark .modal-content { background: #1d242d; color: #d7dde5; }
    "
  )
}

app_js <- function(lang = current_language()) {
  htmltools::HTML(
    paste0(
    "document.documentElement.lang = '", lang, "';\n",
    "Shiny.addCustomMessageHandler('rcmdr-click', function(id) {
      var el = document.getElementById(id);
      if (el) el.click();
    });
    Shiny.addCustomMessageHandler('rcmdr-tab', function(label) {
      var link = Array.from(document.querySelectorAll('.nav-link')).find(function(a) {
        return a.textContent.trim() === label;
      });
      if (link) link.click();
    });
    Shiny.addCustomMessageHandler('rcmdr-focus', function(id) {
      var el = document.getElementById(id);
      if (el) el.focus();
    });
    document.addEventListener('click', function(event) {
      var link = event.target.closest('[data-help-topic]');
      if (!link) return;
      event.preventDefault();
      Shiny.setInputValue('help_open',
        link.getAttribute('data-help-topic'), {priority: 'event'});
      var pane = document.getElementById('help_topic_pane');
      if (pane) pane.focus();
    });
    (function() {
      var stored = window.localStorage.getItem('rcmdr-theme');
      if (stored === 'dark') document.body.classList.add('rcmdr-dark');
    })();
    function rcmdrToggleTheme() {
      var dark = document.body.classList.toggle('rcmdr-dark');
      window.localStorage.setItem('rcmdr-theme', dark ? 'dark' : 'light');
    }
    "
  ))
}

script_pane_ui <- function() {
  htmltools::tagList(
    htmltools::div(
      class = "d-flex gap-2 align-items-center mb-2 flex-wrap",
      actionButton("run_selection", tr("Run selection"), class = "btn-sm btn-primary"),
      actionButton("run_all", tr("Run all"), class = "btn-sm btn-outline-primary"),
      actionButton("clear_script", tr("Clear"), class = "btn-sm btn-outline-secondary"),
      downloadButton("download_script", tr("Download .R"),
                     class = "btn-sm btn-outline-secondary"),
      checkboxInput("auto_append", tr("Append generated commands"), value = TRUE)
    ),
    shinyAce::aceEditor(
      "script", value = "", mode = "r", theme = "textmate",
      height = "460px", fontSize = 13, selectionId = "script_selection",
      autoComplete = "enabled"
    )
  )
}

output_pane_ui <- function() {
  htmltools::tagList(
    htmltools::div(
      class = "d-flex gap-2 mb-2",
      downloadButton("download_output", tr("Download output"),
                     class = "btn-sm btn-outline-secondary"),
      actionButton("clear_output", tr("Clear"), class = "btn-sm btn-outline-secondary")
    ),
    verbatimTextOutput("output_text")
  )
}

messages_pane_ui <- function() {
  htmltools::tagList(
    htmltools::div(
      class = "d-flex gap-2 mb-2",
      actionButton("clear_messages", tr("Clear"), class = "btn-sm btn-outline-secondary")
    ),
    verbatimTextOutput("messages_text")
  )
}

data_pane_ui <- function() {
  htmltools::tagList(
    htmltools::div(
      class = "d-flex gap-2 align-items-center mb-2 flex-wrap",
      radioButtons(
        "data_mode", NULL,
        choices = stats::setNames(c("view", "edit"), c(tr("View"), tr("Edit"))),
        inline = TRUE
      ),
      actionButton("data_refresh", tr("Refresh"), class = "btn-sm btn-outline-secondary"),
      actionButton("data_apply", tr("Apply changes"), class = "btn-sm btn-primary"),
      downloadButton("download_dataset", tr("Download CSV"),
                     class = "btn-sm btn-outline-secondary"),
      downloadButton("download_dataset_rdata", tr("Save .RData"),
                     class = "btn-sm btn-outline-secondary"),
      uiOutput("data_info", inline = TRUE)
    ),
    uiOutput("data_pane")
  )
}

plots_pane_ui <- function() {
  htmltools::tagList(
    htmltools::div(
      class = "d-flex gap-2 mb-2 flex-wrap",
      downloadButton("download_plot_png", tr("Save PNG"),
                     class = "btn-sm btn-outline-secondary"),
      downloadButton("download_plot_pdf", tr("Save PDF"),
                     class = "btn-sm btn-outline-secondary"),
      if (requireNamespace("rgl", quietly = TRUE)) {
        downloadButton("download_rgl", tr("Save 3D PNG"),
                       class = "btn-sm btn-outline-secondary")
      }
    ),
    uiOutput("plotly_pane"),
    uiOutput("plot_gallery"),
    uiOutput("plot_header"),
    htmltools::div(
      class = "rcmdr-plot",
      imageOutput("plot_image", height = "auto")
    ),
    uiOutput("rgl_pane")
  )
}

app_ui <- function() {
  languages <- available_languages()
  current <- current_language()
  if (!current %in% languages) languages <- c(current, languages)

  bslib::page_fluid(
    theme = bslib::bs_theme(version = 5, primary = "#1f3a5f"),
    htmltools::tags$head(
      htmltools::tags$style(app_css()),
      htmltools::tags$script(app_js())
    ),
    htmltools::tags$a(
      class = "visually-hidden-focusable rcmdr-skip-link",
      href = "#main-content", tr("Skip to main content")
    ),
    htmltools::div(
      class = "rcmdr-topbar d-flex justify-content-between align-items-center px-3 py-2",
      role = "banner",
      htmltools::div(
        class = "d-flex align-items-center gap-2",
        htmltools::tags$strong("RcmdrShiny", class = "fs-5"),
        htmltools::tags$small(tr("R Commander for Shiny"), class = "text-white-50")
      ),
      htmltools::div(
        class = "d-flex gap-3 badge-box align-items-center",
        uiOutput("dataset_badge", inline = TRUE),
        uiOutput("model_badge", inline = TRUE),
        selectInput(
          "language", NULL,
          choices = stats::setNames(languages, toupper(languages)),
          selected = current, width = "100px"
        ),
        htmltools::tags$button(
          type = "button", class = "btn btn-sm btn-outline-light",
          title = tr("Toggle dark mode"),
          `aria-label` = tr("Toggle dark mode"),
          onclick = "rcmdrToggleTheme()", "\u25D0"
        )
      )
    ),
    htmltools::div(
      class = "container-fluid",
      htmltools::div(
        class = "row",
        htmltools::div(
          class = "col-lg-3 col-xl-2 rcmdr-sidebar",
          role = "navigation", `aria-label` = tr("Application menus"),
          uiOutput("menus")
        ),
        htmltools::div(
          class = "col-lg-9 col-xl-10 py-3",
          id = "main-content", role = "main", tabindex = "-1",
          tabsetPanel(
            id = "main_tabs",
            tabPanel(tr("Script"), script_pane_ui()),
            tabPanel(tr("Output"), output_pane_ui()),
            tabPanel(tr("Messages"), messages_pane_ui()),
            tabPanel(tr("Plots"), plots_pane_ui()),
            tabPanel(tr("Data"), data_pane_ui()),
            tabPanel(tr("Environment"), uiOutput("environment_pane")),
            tabPanel(tr("Help"), help_center_ui())
          )
        )
      )
    ),
    htmltools::div(
      class = "rcmdr-statusbar", role = "status", `aria-live` = "polite",
      uiOutput("statusbar", inline = TRUE)
    ),
    # Report downloads are triggered from the Export report dialog; the
    # buttons are invisible but must exist for Shiny to bind the outputs.
    htmltools::div(
      class = "visually-hidden",
      downloadButton("download_report_rmd", tr("Download report (.Rmd)")),
      downloadButton("download_report_html", tr("Download report (.html)"))
    )
  )
}

#' Application server
#'
#' @param env Evaluation environment for commands.
#' @return A Shiny server function.
#' @keywords internal
app_server <- function(env = globalenv()) {
  force(env)

  function(input, output, session) {
    state <- AppState(env)
    state$session <- session
    tick <- reactiveVal(0L)
    menu_revision <- reactiveVal(0L)
    dialog_revision <- reactiveVal(0L)
    script_value <- reactiveVal("")
    plot_selected <- reactiveVal(NULL)
    last_plot_count <- reactiveVal(0L)
    state$notify <- function() tick(tick() + 1L)
    state$script_consumed <- 0L
    state$set_script <- function(value) {
      script_value(value)
      shinyAce::updateAceEditor(session, "script", value = value)
    }
    state$show_tab <- function(label) {
      session$sendCustomMessage("rcmdr-tab", label)
    }

    help_server(input, output, session, state)

    # Per-session directory for plot thumbnails and downloads.
    plot_dir <- file.path(tempdir(), paste0("rcmdrshiny-", session$token))
    dir.create(plot_dir, showWarnings = FALSE, recursive = TRUE)
    state$plot_dir <- plot_dir
    state$plot_prefix <- paste0("rcmdr-plots-", session$token)
    try(addResourcePath(state$plot_prefix, plot_dir), silent = TRUE)

    tree <- menu_tree()
    leaves <- menu_leaves(tree)

    # -- menus --------------------------------------------------------------

    output$menus <- renderUI({
      menu_revision()
      menu_ui(tree, function(node) {
        command_status(state, node$command, node$activation, node$install)
      })
    })

    open_dialog <- function(spec) {
      if (!is.null(spec$on_open)) spec$on_open(state)
      state$current_dialog <- spec$id
      if (!is.null(state$help_reset_dialog)) state$help_reset_dialog()
      dialog_revision(dialog_revision() + 1L)
      showModal(dialog_modal(spec))
    }

    launch <- function(command) {
      if (!command_enabled(state, command)) {
        showNotification(
          tr("This command is not available for the current data set."),
          type = "warning", duration = 5
        )
        return(invisible(NULL))
      }

      spec <- get_dialog_spec(command)
      if (!is.null(spec)) {
        open_dialog(spec)
        return(invisible(TRUE))
      }

      action <- direct_commands()[[command]]
      if (!is.null(action)) {
        action(state)
        tick(tick() + 1L)
        menu_revision(menu_revision() + 1L)
        return(invisible(TRUE))
      }

      showNotification(tr("This command has not been ported yet."),
                       type = "message", duration = 5)
      invisible(NULL)
    }

    for (i in seq_len(nrow(leaves))) {
      local({
        key <- leaves$key[[i]]
        command <- leaves$command[[i]]
        observeEvent(input[[key]], launch(command), ignoreInit = TRUE)
      })
    }

    # -- dialogs ------------------------------------------------------------

    output$dialog_body <- renderUI({
      dialog_revision()
      spec <- get_dialog_spec(state$current_dialog %||% "")
      req(spec)
      spec$ui(state, get_dialog_memory(state, spec$id))
    })

    submit_dialog <- function(close = TRUE) {
      id <- state$current_dialog
      req(id)
      spec <- get_dialog_spec(id)
      req(spec)

      result <- tryCatch(
        spec$on_ok(input, state),
        error = function(e) list(error = conditionMessage(e))
      )

      if (!is.null(result$error)) {
        showNotification(result$error, type = "error", duration = 10)
        return(invisible(FALSE))
      }

      if (!is.null(result$memory)) set_dialog_memory(state, id, result$memory)

      state$busy <- TRUE
      ok <- tryCatch(
        apply_dialog_result(state, result),
        error = function(e) {
          state$last_error <- conditionMessage(e)
          state$messages <- c(state$messages, paste0("Error: ", state$last_error))
          FALSE
        }
      )
      state$busy <- FALSE

      if (close) {
        removeModal()
        state$current_dialog <- NULL
        dialog_revision(dialog_revision() + 1L)
      }
      tick(tick() + 1L)
      menu_revision(menu_revision() + 1L)

      if (!ok) {
        state$last_failed_dialog <- list(
          id = id,
          memory = get_dialog_memory(state, id)
        )
        showModal(modalDialog(
          title = tr("Command error"),
          htmltools::tags$pre(state$last_error %||% tr("The command produced an error.")),
          easyClose = TRUE,
          footer = htmltools::tagList(
            modalButton(tr("Close")),
            actionButton("dialog_retry", tr("Retry"), class = "btn-primary")
          )
        ))
      } else if (!close) {
        showNotification(tr("Applied."), type = "message", duration = 2)
      }
      invisible(ok)
    }

    observeEvent(input$dialog_ok, submit_dialog(close = TRUE))
    observeEvent(input$dialog_apply, submit_dialog(close = FALSE))

    observeEvent(input$dialog_cancel, {
      removeModal()
      state$current_dialog <- NULL
      if (!is.null(state$help_reset_dialog)) state$help_reset_dialog()
      dialog_revision(dialog_revision() + 1L)
    })

    observeEvent(input$dialog_reset, {
      id <- state$current_dialog
      req(id)
      spec <- get_dialog_spec(id)
      req(spec)
      clear_dialog_memory(state, id)
      if (!is.null(state$help_reset_dialog)) state$help_reset_dialog()
      if (!is.null(spec$on_open)) spec$on_open(state)
      dialog_revision(dialog_revision() + 1L)
      showModal(dialog_modal(spec))
    })

    observeEvent(input$dialog_retry, {
      failed <- state$last_failed_dialog
      req(failed)
      removeModal()
      spec <- get_dialog_spec(failed$id)
      req(spec)
      state$current_dialog <- failed$id
      if (!is.null(state$help_reset_dialog)) state$help_reset_dialog()
      if (!is.null(failed$memory)) {
        set_dialog_memory(state, failed$id, failed$memory)
      }
      if (!is.null(spec$on_open)) spec$on_open(state)
      dialog_revision(dialog_revision() + 1L)
      showModal(dialog_modal(spec))
    })

    for (spec in dialog_catalog()) {
      if (!is.null(spec$observers)) {
        spec$observers(input, output, session, state, tick)
      }
    }

    # -- output panes -------------------------------------------------------

    output$output_text <- renderText({
      tick()
      paste(state$output, collapse = "\n")
    })

    output$messages_text <- renderText({
      tick()
      paste(state$messages, collapse = "\n")
    })

    outputOptions(output, "output_text", suspendWhenHidden = FALSE)
    outputOptions(output, "messages_text", suspendWhenHidden = FALSE)

    observeEvent(input$clear_output, {
      state$output <- character()
      tick(tick() + 1L)
    }, ignoreInit = TRUE)

    observeEvent(input$clear_messages, {
      state$messages <- character()
      state$warnings <- character()
      state$last_error <- NULL
      tick(tick() + 1L)
    }, ignoreInit = TRUE)

    # -- data pane ----------------------------------------------------------

    output$data_info <- renderUI({
      tick()
      df <- dataset(state)
      if (is.null(df)) return(NULL)
      htmltools::tags$span(
        class = "text-muted",
        sprintf(tr("%d rows x %d columns, %d cells"),
                nrow(df), ncol(df), nrow(df) * ncol(df)),
        if (!editable_dataset(state)) {
          htmltools::tags$span(
            class = "text-warning",
            tr(" (editing disabled: threshold exceeded)")
          )
        }
      )
    })

    output$data_pane <- renderUI({
      tick()
      df <- dataset(state)
      if (is.null(df)) {
        return(htmltools::tags$p(class = "text-muted",
                                 tr("No active data set.")))
      }
      if (identical(input$data_mode %||% "view", "edit")) {
        if (!editable_dataset(state)) {
          return(htmltools::tags$div(
            class = "alert alert-warning",
            tr("This data set exceeds the interactive editing threshold.")
          ))
        }
        return(rhandsontable::rHandsontableOutput("data_editor"))
      }
      DT::dataTableOutput("data_table")
    })

    output$data_table <- DT::renderDataTable({
      tick()
      df <- dataset(state)
      req(df)
      DT::datatable(
        df,
        options = list(pageLength = 10, scrollX = TRUE, dom = "ftip"),
        rownames = FALSE,
        server = nrow(df) > (state$options$dt_server_threshold %||% 5000L)
      )
    })

    output$data_editor <- rhandsontable::renderRHandsontable({
      tick()
      df <- dataset(state)
      req(df, editable_dataset(state))
      rhandsontable::rhandsontable(
        df, height = 480, stretchH = "all", useTypes = TRUE
      )
    })

    observeEvent(input$data_apply, {
      req(input$data_editor)
      df <- tryCatch(
        rhandsontable::hot_to_r(input$data_editor),
        error = function(e) NULL
      )
      if (is.null(df) || !is.data.frame(df)) {
        showNotification(tr("The edited data are not valid."),
                         type = "error", duration = 6)
        return()
      }
      update_dataset(state, df)
      showNotification(tr("Data set updated."), type = "message", duration = 3)
      tick(tick() + 1L)
      menu_revision(menu_revision() + 1L)
    }, ignoreInit = TRUE)

    observeEvent(input$data_refresh, {
      tick(tick() + 1L)
    }, ignoreInit = TRUE)

    output$environment_pane <- renderUI({
      tick()
      objects <- ls(envir = state$env)
      if (length(objects) == 0L) {
        return(htmltools::tags$p(class = "text-muted",
                                 tr("The environment is empty.")))
      }
      info <- data.frame(
        name = objects,
        class = vapply(objects, function(x) {
          paste(class(get(x, envir = state$env)), collapse = ", ")
        }, character(1)),
        size = vapply(objects, function(x) {
          object <- get(x, envir = state$env)
          if (is.data.frame(object)) {
            sprintf("%d x %d", nrow(object), ncol(object))
          } else {
            as.character(utils::object.size(object))
          }
        }, character(1)),
        stringsAsFactors = FALSE
      )
      DT::datatable(info, rownames = FALSE, options = list(dom = "t"))
    })

    # -- plots --------------------------------------------------------------

    current_plot <- reactive({
      tick()
      n <- length(state$plots)
      if (n == 0L) return(NULL)
      index <- plot_selected()
      if (is.null(index) || index < 1L || index > n) index <- n
      state$plots[[index]]
    })

    observeEvent(input$plot_selected, {
      plot_selected(input$plot_selected)
    }, ignoreInit = TRUE)

    observeEvent(tick(), {
      n <- length(state$plots)
      if (n > last_plot_count()) {
        plot_selected(NULL)
        last_plot_count(n)
      }
    }, ignoreInit = TRUE)

    output$plot_gallery <- renderUI({
      tick()
      n <- length(state$plots)
      if (n == 0L) return(NULL)
      active <- plot_selected()
      if (is.null(active) || active < 1L || active > n) active <- n
      htmltools::div(
        class = "rcmdr-gallery",
        lapply(seq_len(n), function(index) {
          plot <- state$plots[[index]]
          htmltools::tags$img(
            src = plot$url %||% "",
            class = paste("rcmdr-thumb", if (index == active) "active"),
            title = plot$code, alt = plot$code,
            onclick = sprintf(
              "Shiny.setInputValue('plot_selected', %d, {priority: 'event'})",
              index
            )
          )
        })
      )
    })

    output$plotly_pane <- renderUI({
      tick()
      if (!plotly_available() || is.null(state$plotly_widget)) return(NULL)
      htmltools::tagList(
        htmltools::tags$h6(state$plotly_title %||% tr("Interactive plot")),
        plotly::plotlyOutput("plotly_plot", height = "480px")
      )
    })

    if (plotly_available()) {
      output$plotly_plot <- plotly::renderPlotly({
        tick()
        req(state$plotly_widget)
        state$plotly_widget
      })
    }

    output$plot_image <- renderImage({
      plot <- current_plot()
      req(plot)
      list(src = plot$file, contentType = "image/png", alt = plot$code)
    }, deleteFile = FALSE)

    output$plot_header <- renderUI({
      tick()
      if (length(state$plots) == 0L) {
        return(htmltools::tags$p(class = "text-muted", tr("No plot yet.")))
      }
      plot <- current_plot()
      req(plot)
      htmltools::tags$div(
        class = "mb-2",
        htmltools::tags$strong(sprintf(
          tr("Plot %d of %d"),
          plot_selected() %||% length(state$plots), length(state$plots)
        )),
        htmltools::tags$pre(class = "small text-muted mb-1", plot$code)
      )
    })

    output$rgl_pane <- renderUI({
      tick()
      if (is.null(state$rgl_widget)) return(NULL)
      htmltools::tagList(
        htmltools::tags$h6(tr("3D plot")),
        if (requireNamespace("rgl", quietly = TRUE)) {
          rgl::rglwidgetOutput("rgl_plot", height = "420px")
        }
      )
    })

    if (requireNamespace("rgl", quietly = TRUE)) {
      output$rgl_plot <- rgl::renderRglwidget({
        tick()
        req(state$rgl_widget)
        state$rgl_widget
      })
    }

    # -- downloads ----------------------------------------------------------

    output$download_report_rmd <- downloadHandler(
      filename = function() {
        paste0("rcmdrshiny-report-", Sys.Date(), ".Rmd")
      },
      content = function(file) {
        write_report_rmd(state, file,
                         title = state$report_title %||% "RcmdrShiny report")
      }
    )

    output$download_report_html <- downloadHandler(
      filename = function() {
        paste0("rcmdrshiny-report-", Sys.Date(), ".html")
      },
      content = function(file) {
        write_report_html(state, file,
                          title = state$report_title %||% "RcmdrShiny report")
      }
    )

    output$download_script <- downloadHandler(
      filename = function() "RcmdrShiny-script.R",
      content = function(file) {
        writeLines(isolate(script_value()), file)
      }
    )

    output$download_output <- downloadHandler(
      filename = function() "RcmdrShiny-output.txt",
      content = function(file) {
        writeLines(isolate(paste(state$output, collapse = "\n")), file)
      }
    )

    output$download_dataset <- downloadHandler(
      filename = function() {
        name <- active_dataset(state) %||% "dataset"
        paste0(name, ".csv")
      },
      content = function(file) {
        df <- isolate(dataset(state))
        req(df)
        utils::write.csv(df, file, row.names = FALSE)
      }
    )

    output$download_dataset_rdata <- downloadHandler(
      filename = function() {
        name <- active_dataset(state) %||% "dataset"
        paste0(name, ".RData")
      },
      content = function(file) {
        name <- isolate(active_dataset(state))
        req(name)
        save(list = name, file = file, envir = state$env)
      }
    )

    output$download_workspace <- downloadHandler(
      filename = function() "RcmdrShiny-workspace.RData",
      content = function(file) {
        objects <- isolate(ls(envir = state$env))
        req(length(objects) > 0L)
        save(list = objects, file = file, envir = state$env)
      }
    )

    output$download_plot_png <- downloadHandler(
      filename = function() "RcmdrShiny-plot.png",
      content = function(file) {
        plot <- isolate(current_plot())
        req(plot)
        file.copy(plot$file, file, overwrite = TRUE)
      }
    )

    output$download_rgl <- downloadHandler(
      filename = function() "RcmdrShiny-3D.png",
      content = function(file) {
        req(state$rgl_widget)
        rgl::rgl.snapshot(file)
      }
    )

    output$download_plot_pdf <- downloadHandler(
      filename = function() "RcmdrShiny-plot.pdf",
      content = function(file) {
        plot <- isolate(current_plot())
        req(plot, plot$recorded)
        grDevices::pdf(file)
        on.exit(grDevices::dev.off(), add = TRUE)
        grDevices::replayPlot(plot$recorded)
      }
    )

    # -- language -----------------------------------------------------------

    observeEvent(input$language, {
      language <- input$language %||% "en"
      state$options$language <- language
      Sys.setenv(LANGUAGE = language)
      showNotification(
        tr("The language change takes effect after restarting RcmdrShiny."),
        type = "message", duration = 8
      )
      tick(tick() + 1L)
    }, ignoreInit = TRUE)

    # -- status bar and badges ---------------------------------------------

    output$dataset_badge <- renderUI({
      tick()
      name <- active_dataset(state)
      htmltools::tags$span(
        if (is.null(name)) tr("No active data set") else name,
        class = if (is.null(name)) "text-warning" else "text-white"
      )
    })

    output$model_badge <- renderUI({
      tick()
      name <- active_model(state)
      htmltools::tags$span(
        if (is.null(name)) tr("No active model") else name,
        class = if (is.null(name)) "text-white-50" else "text-white"
      )
    })

    output$statusbar <- renderUI({
      tick()
      version <- tryCatch(
        as.character(utils::packageVersion("RcmdrShiny")),
        error = function(e) "0.1.0"
      )
      df <- dataset(state)
      dimensions <- if (is.null(df)) {
        tr("no data")
      } else {
        sprintf("%d x %d", nrow(df), ncol(df))
      }
      htmltools::tagList(
        htmltools::tags$span(sprintf(tr("RcmdrShiny %s"), version)),
        htmltools::tags$span(" | "),
        htmltools::tags$span(dimensions),
        htmltools::tags$span(" | "),
        htmltools::tags$span(sprintf(tr("%d command(s)"), length(state$log))),
        htmltools::tags$span(" | "),
        htmltools::tags$span(sprintf(tr("%d plot(s)"), length(state$plots))),
        if (isTRUE(state$busy)) {
          htmltools::tags$span(class = "rcmdr-busy", tr(" | busy"))
        },
        if (!is.null(state$last_error)) {
          htmltools::tags$span(
            class = "text-danger",
            sprintf(tr(" | last error: %s"), state$last_error)
          )
        }
      )
    })

    # -- script pane --------------------------------------------------------

    observeEvent(input$script, {
      if (!identical(isolate(script_value()), input$script)) {
        script_value(input$script %||% "")
      }
    }, ignoreInit = TRUE)

    append_log_to_script <- function() {
      if (!isTRUE(input$auto_append)) return(invisible(NULL))
      if (length(state$log) <= state$script_consumed) return(invisible(NULL))
      new_commands <- state$log[seq.int(state$script_consumed + 1L, length(state$log))]
      state$script_consumed <- length(state$log)
      value <- paste(c(isolate(script_value()), new_commands), collapse = "\n")
      script_value(value)
      shinyAce::updateAceEditor(session, "script", value = value)
      invisible(NULL)
    }

    observeEvent(tick(), append_log_to_script(), ignoreInit = TRUE)

    run_script <- function(code) {
      if (is.null(code) || !nzchar(trimws(code))) return(invisible(NULL))
      state$busy <- TRUE
      result <- tryCatch(
        run_command(state, code, log = FALSE),
        error = function(e) list(status = "error", error = conditionMessage(e))
      )
      state$busy <- FALSE
      tick(tick() + 1L)
      menu_revision(menu_revision() + 1L)
      if (identical(result$status, "error")) {
        showNotification(
          result$error %||% tr("The script produced an error."),
          type = "error", duration = 8
        )
      }
      invisible(NULL)
    }

    observeEvent(input$run_all, run_script(script_value()), ignoreInit = TRUE)

    observeEvent(input$run_selection, {
      selection <- input$script_selection %||% ""
      run_script(if (nzchar(trimws(selection))) selection else script_value())
    }, ignoreInit = TRUE)

    observeEvent(input$clear_script, {
      script_value("")
      shinyAce::updateAceEditor(session, "script", value = "")
    }, ignoreInit = TRUE)
  }
}

#' Create the RcmdrShiny application
#'
#' @param env Evaluation environment for user commands.  Defaults to the
#'   global environment.
#' @return A `shiny.appobj`.
#' @export
app <- function(env = globalenv(), plugins = NULL) {
  load_plugins(plugins)
  shinyApp(ui = app_ui(), server = app_server(env))
}

#' Run RcmdrShiny
#'
#' Starts the local Shiny application in the browser.
#'
#' @param env Evaluation environment for user commands.
#' @param language Language code for the session (for example `"en"` or
#'   `"it"`).  Defaults to the current language.
#' @param ... Further arguments passed to [shiny::runApp()].
#' @return The value returned by [shiny::runApp()], invisibly.
#' @examples
#' \dontrun{
#' RcmdrShiny::run()
#' }
#' @export
run_app <- function(env = globalenv(), language = NULL, plugins = NULL, ...) {
  if (!is.null(language)) Sys.setenv(LANGUAGE = language)
  shiny::runApp(app(env = env, plugins = plugins), ...)
}

#' @rdname run_app
#' @export
run <- run_app
