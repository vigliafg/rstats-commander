# Help server ----------------------------------------------------------------
#
# One function wires the Help tab and the inline dialog help.  Both share the
# registry and the language fallback implemented in R/help.R.

#' Help tab server
#'
#' @param input,output,session Shiny objects.
#' @param state Application state.
#' @return `NULL`, invisibly.
#' @export
help_server <- function(input, output, session, state) {
  selected <- shiny::reactiveVal(NULL)
  recent <- shiny::reactiveVal(character())
  filter <- shiny::reactiveVal(NULL)
  current_topic <- shiny::reactiveVal(NULL)
  dialog_help <- shiny::reactiveVal(NULL)

  remember <- function(id) {
    ids <- unique(c(id, recent()))
    recent(utils::head(ids, 5L))
  }

  state$help_show <- function(id, switch_tab = TRUE) {
    topic <- help_topic(id, help_language())
    if (is.null(topic)) return(invisible(FALSE))
    selected(topic$id)
    current_topic(topic)
    filter(NULL)
    remember(topic$id)
    if (isTRUE(switch_tab)) state$show_tab(tr("Help"))
    invisible(TRUE)
  }

  state$help_show_dialog <- function(spec) {
    topic <- help_topic_for_dialog(spec, help_language())
    if (is.null(topic)) return(invisible(FALSE))
    dialog_help(topic)
    invisible(TRUE)
  }

  state$help_reset_dialog <- function() {
    dialog_help(NULL)
    invisible(NULL)
  }

  state$help_topic_open <- function() {
    topic <- current_topic()
    if (is.null(topic)) NULL else topic$id
  }

  output$help_context <- shiny::renderUI({
    if (is.null(state$current_dialog)) return(NULL)
    spec <- get_dialog_spec(state$current_dialog)
    if (is.null(spec)) return(NULL)
    topic <- help_topic_for_dialog(spec, help_language())
    if (is.null(topic)) return(NULL)
    shiny::actionButton(
      "help_current_dialog",
      sprintf(tr("Help on this window: %s"), spec$title),
      class = "btn-sm btn-outline-secondary"
    )
  })

  output$help_categories <- shiny::renderUI({
    index <- help_index()
    latest <- filter()
    htmltools::tagList(
      lapply(seq_len(nrow(index)), function(i) {
        category <- index[i, , drop = FALSE]
        htmltools::tags$div(
          class = if (identical(category$id, latest)) {
            "rcmdr-help-category active"
          } else {
            "rcmdr-help-category"
          },
          help_category_ui(category)
        )
      })
    )
  })

  output$help_recent <- shiny::renderUI({
    ids <- recent()
    if (length(ids) == 0L) return(NULL)
    htmltools::tagList(
      htmltools::tags$h6(tr("Recent")),
      htmltools::tags$ul(
        lapply(ids, function(id) help_topic_link_ui(id))
      )
    )
  })

  output$help_results <- shiny::renderUI({
    category <- filter()
    query <- input$help_query %||% ""

    if (!is.null(category)) {
      catalog <- help_catalog(category = category, language = help_language())
      if (nrow(catalog) == 0L) return(help_welcome_ui(state))
      return(htmltools::tagList(
        htmltools::tags$h5(help_title_case(category)),
        htmltools::tags$ul(
          class = "rcmdr-help-list",
          lapply(seq_len(nrow(catalog)), function(i) {
            htmltools::tags$li(help_topic_link(catalog$id[[i]],
                                               catalog$title[[i]]))
          })
        )
      ))
    }

    if (!nzchar(trimws(query))) return(help_welcome_ui(state))

    results <- help_search(query, limit = 20L, language = help_language())
    if (nrow(results) == 0L) {
      return(htmltools::tags$p(
        class = "text-muted",
        tr("No help topic matches the search.")
      ))
    }
    htmltools::tagList(
      htmltools::tags$p(
        class = "text-muted small",
        sprintf(tr("%d topic(s) found"), nrow(results))
      ),
      lapply(seq_len(nrow(results)), function(i) {
        help_result_ui(results[i, , drop = FALSE])
      })
    )
  })

  output$help_topic <- shiny::renderUI({
    topic <- current_topic()
    if (is.null(topic)) return(help_welcome_ui(state))
    help_topic_panel_ui(topic)
  })

  shiny::observeEvent(input$help_open, {
    state$help_show(input$help_open, switch_tab = FALSE)
  }, ignoreInit = TRUE)

  shiny::observeEvent(input$help_category, {
    filter(input$help_category)
    selected(NULL)
    current_topic(NULL)
  }, ignoreInit = TRUE)

  shiny::observeEvent(input$help_current_dialog, {
    spec <- get_dialog_spec(state$current_dialog %||% "")
    if (!is.null(spec)) state$help_show_dialog(spec)
  }, ignoreInit = TRUE)

  shiny::observeEvent(input$help_r_reference, {
    topic <- current_topic()
    if (is.null(topic) || length(topic$commands) == 0L) return()
    package <- if (length(topic$packages) > 0L) topic$packages[[1L]] else NULL
    if (is.null(help_topic_text(topic$commands[[1L]], package_name = package))) {
      shiny::showNotification(
        sprintf(tr("No R reference found for '%s'."), topic$commands[[1L]]),
        type = "message", duration = 5
      )
    } else {
      show_help_modal(topic$commands[[1L]], package)
    }
  }, ignoreInit = TRUE)

  shiny::observeEvent(input$help_open_center, {
    topic <- current_topic()
    if (!is.null(topic)) state$help_show(topic$id)
  }, ignoreInit = TRUE)

  # -- inline help inside dialogs -------------------------------------------

  output$dialog_help_panel <- shiny::renderUI({
    topic <- dialog_help()
    if (is.null(topic)) return(NULL)
    help_dialog_panel_ui(topic)
  })

  shiny::observeEvent(input$dialog_help, {
    spec <- get_dialog_spec(state$current_dialog %||% "")
    if (is.null(spec)) return()
    if (!isTRUE(state$help_show_dialog(spec))) {
      shiny::showNotification(
        sprintf(tr("No help topic for '%s'."), spec$title),
        type = "warning", duration = 5
      )
    }
  }, ignoreInit = TRUE)

  shiny::observeEvent(input$dialog_help_close, {
    dialog_help(NULL)
  }, ignoreInit = TRUE)

  shiny::observeEvent(input$dialog_help_center, {
    topic <- dialog_help()
    if (is.null(topic)) return()
    dialog_help(NULL)
    shiny::removeModal()
    state$current_dialog <- NULL
    state$help_show(topic$id)
  }, ignoreInit = TRUE)

  shiny::observeEvent(input$dialog_help_reference, {
    topic <- dialog_help()
    if (is.null(topic) || length(topic$commands) == 0L) return()
    package <- if (length(topic$packages) > 0L) topic$packages[[1L]] else NULL
    help_text <- help_topic_text(topic$commands[[1L]], package_name = package)
    if (is.null(help_text)) {
      shiny::showNotification(
        sprintf(tr("No R reference found for '%s'."), topic$commands[[1L]]),
        type = "message", duration = 5
      )
    } else {
      shiny::showModal(shiny::modalDialog(
        title = sprintf(tr("Help: %s"), topic$commands[[1L]]),
        htmltools::tags$pre(class = "rcmdr-help-text", help_text),
        size = "l", easyClose = TRUE,
        footer = shiny::modalButton(tr("Close"))
      ))
    }
  }, ignoreInit = TRUE)

  invisible(NULL)
}
