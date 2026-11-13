# Shiny application ---------------------------------------------------------

app_css <- function() {
  htmltools::HTML(
    "
    body { background: #f6f7f9; }
    .rcmdr-topbar { background: #1f3a5f; color: #fff; }
    .rcmdr-topbar .badge-box { color: #dfe8f3; font-size: .9rem; }
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
      min-height: 120px; }
    .rcmdr-plot img { max-width: 100%; border: 1px solid #e2e6ea; }
    "
  )
}

script_pane_ui <- function() {
  htmltools::tagList(
    htmltools::div(
      class = "d-flex gap-2 align-items-center mb-2 flex-wrap",
      actionButton("run_selection", tr("Run selection"), class = "btn-sm btn-primary"),
      actionButton("run_all", tr("Run all"), class = "btn-sm btn-outline-primary"),
      actionButton("clear_script", tr("Clear"), class = "btn-sm btn-outline-secondary"),
      checkboxInput("auto_append", tr("Append generated commands"), value = TRUE)
    ),
    shinyAce::aceEditor(
      "script", value = "", mode = "r", theme = "textmate",
      height = "460px", fontSize = 13, selectionId = "script_selection",
      autoComplete = "enabled"
    )
  )
}

plot_pane_ui <- function() {
  htmltools::div(
    class = "rcmdr-plot",
    uiOutput("plot_header"),
    imageOutput("plot_image", height = "auto")
  )
}

app_ui <- function() {
  bslib::page_fluid(
    theme = bslib::bs_theme(version = 5, primary = "#1f3a5f"),
    htmltools::tags$head(htmltools::tags$style(app_css())),
    htmltools::div(
      class = "rcmdr-topbar d-flex justify-content-between align-items-center px-3 py-2",
      htmltools::div(
        class = "d-flex align-items-center gap-2",
        htmltools::tags$strong("RcmdrShiny", class = "fs-5"),
        htmltools::tags$small(tr("R Commander for Shiny"), class = "text-white-50")
      ),
      htmltools::div(
        class = "d-flex gap-3 badge-box",
        uiOutput("dataset_badge", inline = TRUE),
        uiOutput("model_badge", inline = TRUE),
        uiOutput("language_badge", inline = TRUE)
      )
    ),
    htmltools::div(
      class = "container-fluid",
      htmltools::div(
        class = "row",
        htmltools::div(class = "col-lg-3 col-xl-2 rcmdr-sidebar", uiOutput("menus")),
        htmltools::div(
          class = "col-lg-9 col-xl-10 py-3",
          tabsetPanel(
            id = "main_tabs",
            tabPanel(tr("Script"), script_pane_ui()),
            tabPanel(tr("Output"), verbatimTextOutput("output_text")),
            tabPanel(tr("Messages"), verbatimTextOutput("messages_text")),
            tabPanel(tr("Plots"), plot_pane_ui()),
            tabPanel(tr("Data"), uiOutput("data_pane")),
            tabPanel(tr("Environment"), uiOutput("environment_pane"))
          )
        )
      )
    ),
    htmltools::div(class = "rcmdr-statusbar", uiOutput("statusbar", inline = TRUE))
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
    tick <- reactiveVal(0L)
    dialog_revision <- reactiveVal(0L)
    script_value <- reactiveVal("")
    state$notify <- function() tick(tick() + 1L)
    state$script_consumed <- 0L

    tree <- menu_tree()
    leaves <- menu_leaves(tree)

    # -- menus --------------------------------------------------------------

    output$menus <- renderUI({
      tick()
      menu_ui(tree, function(command) command_enabled(state, command))
    })

    open_dialog <- function(spec) {
      if (!is.null(spec$on_open)) spec$on_open(state)
      state$current_dialog <- spec$id
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

    observeEvent(input$dialog_ok, {
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
        return()
      }

      if (!is.null(result$memory)) set_dialog_memory(state, id, result$memory)
      ok <- apply_dialog_result(state, result)

      removeModal()
      state$current_dialog <- NULL
      dialog_revision(dialog_revision() + 1L)
      tick(tick() + 1L)

      if (!ok) {
        showNotification(
          state$last_error %||% tr("The command produced an error."),
          type = "error", duration = 10
        )
      }
    })

    observeEvent(input$dialog_cancel, {
      removeModal()
      state$current_dialog <- NULL
      dialog_revision(dialog_revision() + 1L)
    })

    observeEvent(input$dialog_reset, {
      id <- state$current_dialog
      req(id)
      spec <- get_dialog_spec(id)
      req(spec)
      clear_dialog_memory(state, id)
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

    # Keep the log panes current even while their tab is hidden, so that
    # switching tabs never shows stale content.
    outputOptions(output, "output_text", suspendWhenHidden = FALSE)
    outputOptions(output, "messages_text", suspendWhenHidden = FALSE)

    output$data_pane <- renderUI({
      tick()
      df <- dataset(state)
      if (is.null(df)) {
        return(htmltools::tags$p(class = "text-muted",
                                 tr("No active data set.")))
      }
      DT::datatable(
        df,
        options = list(pageLength = 10, scrollX = TRUE, dom = "ftip"),
        rownames = FALSE
      )
    })

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

    output$plot_image <- renderImage({
      tick()
      req(length(state$plots) > 0L)
      plot <- state$plots[[length(state$plots)]]
      list(src = plot$file, contentType = "image/png", alt = plot$code)
    }, deleteFile = FALSE)

    output$plot_header <- renderUI({
      tick()
      if (length(state$plots) == 0L) {
        return(htmltools::tags$p(class = "text-muted", tr("No plot yet.")))
      }
      plot <- state$plots[[length(state$plots)]]
      htmltools::tags$div(
        class = "mb-2",
        htmltools::tags$strong(sprintf(
          tr("Plot %d of %d"), length(state$plots), length(state$plots)
        )),
        htmltools::tags$pre(class = "small text-muted mb-1", plot$code)
      )
    })

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

    output$language_badge <- renderUI({
      htmltools::tags$span(toupper(current_language()))
    })

    output$statusbar <- renderUI({
      tick()
      version <- tryCatch(
        as.character(utils::packageVersion("RcmdrShiny")),
        error = function(e) "0.1.0"
      )
      htmltools::tagList(
        htmltools::tags$span(sprintf(tr("RcmdrShiny %s"), version)),
        htmltools::tags$span(" | "),
        htmltools::tags$span(sprintf(tr("%d command(s) in the log"), length(state$log))),
        htmltools::tags$span(" | "),
        htmltools::tags$span(sprintf(
          tr("output lines: %d"), length(state$output)
        ))
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
      run_command(state, code, log = FALSE)
      tick(tick() + 1L)
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
app <- function(env = globalenv()) {
  shinyApp(ui = app_ui(), server = app_server(env))
}

#' Run RcmdrShiny
#'
#' Starts the local Shiny application in the browser.
#'
#' @param env Evaluation environment for user commands.
#' @param ... Further arguments passed to [shiny::runApp()].
#' @return The value returned by [shiny::runApp()], invisibly.
#' @examples
#' \dontrun{
#' RcmdrShiny::run()
#' }
#' @export
run_app <- function(env = globalenv(), ...) {
  shiny::runApp(app(env = env), ...)
}

#' @rdname run_app
#' @export
run <- run_app
