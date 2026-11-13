# Dialog runtime ------------------------------------------------------------
#
# A dialog is a small spec: a title, a UI builder, an on_ok callback and,
# optionally, an on_open hook and observers that need the Shiny session.
# The runtime renders the spec inside a modal and turns the returned commands
# into run_command() calls.

#' @keywords internal
dialog_spec <- function(id, title, ui, on_ok, on_open = NULL,
                        observers = NULL, size = "l",
                        help = NULL, help_package = NULL,
                        help_topic = NULL) {
  structure(
    list(
      id = id,
      title = title,
      ui = ui,
      on_ok = on_ok,
      on_open = on_open,
      observers = observers,
      size = size,
      help = help,
      help_package = help_package,
      help_topic = help_topic
    ),
    class = "RcmdrShinyDialog"
  )
}

#' Available dialog specifications
#' @keywords internal
base_dialog_catalog <- function() {
  c(
    list(
      loadPlugins = load_plugins_dialog(),
      readDataSet = import_text_dialog(),
      numericalSummaries = numerical_summaries_dialog(),
      linearModel = linear_model_dialog(),
      Options = options_dialog(),
      Setwd = setwd_dialog(),
      loadDataSet = load_dataset_dialog(),
      loadLog = load_script_dialog(),
      exportReport = export_report_dialog()
    ),
    document_dialogs(),
    phase2_dialogs(), phase3_dialogs(), phase4_dialogs(), phase5_dialogs()
  )
}

#' @keywords internal
dialog_catalog <- function() {
  c(base_dialog_catalog(), plugin_dialogs())
}

#' @keywords internal
get_dialog_spec <- function(id) get_dialog(id)

#' Retrieve a dialog specification
#'
#' Exposes the dialog registry to plugin packages so their tests can call
#' `on_ok()` with a synthetic input.  Plugin aliases resolve to the core
#' dialog, with the alias command id preserved.
#'
#' @param id Command name used in the menu file.
#' @return A dialog specification, or `NULL`.
#' @export
get_dialog <- function(id) {
  catalog <- dialog_catalog()
  spec <- catalog[[id]]
  if (!is.null(spec)) return(spec)

  target <- plugin_aliases()[id]
  if (is.na(target) || !nzchar(target)) return(NULL)
  spec <- catalog[[target]]
  if (is.null(spec)) return(NULL)
  spec$id <- id
  spec
}

.implemented_commands_cache <- new.env(parent = emptyenv())

#' @keywords internal
implemented_commands <- function() {
  if (is.null(.implemented_commands_cache$names)) {
    .implemented_commands_cache$names <- unique(c(
      names(dialog_catalog()),
      names(direct_commands()),
      names(plugin_aliases())
    ))
  }
  .implemented_commands_cache$names
}

#' @keywords internal
is_implemented_command <- function(command) {
  command %in% implemented_commands()
}

# Commands that do not need a dialog.  They are the first entries of the
# "porting registry": each one is a function of the application state.
base_direct_commands <- function() {
  list(
    summarizeDataSet = function(state) {
      ds <- active_dataset(state)
      if (is.null(ds)) return(NULL)
      run_command(state, paste0("summary(", ds, ")"))
    },
    viewData = function(state) {
      if (!is.null(state$show_tab)) state$show_tab("Data")
      invisible(NULL)
    },
    variablesDataSet = function(state) {
      ds <- active_dataset(state)
      if (is.null(ds)) return(NULL)
      run_command(state, paste0("names(", ds, ")"))
    },
    refreshActiveDataSet = function(state) {
      ds <- active_dataset(state)
      if (!is.null(ds)) active_dataset(state, ds)
      invisible(NULL)
    },
    addObsNumbers = function(state) {
      ds <- active_dataset(state)
      if (is.null(ds)) return(NULL)
      run_command(state, cmd_add_obs_numbers(ds, nrow(dataset(state))))
    },
    listDataSetsInPackages = function(state) {
      run_command(state, "data()")
    },
    countMissing = function(state) {
      ds <- active_dataset(state)
      if (is.null(ds)) return(NULL)
      run_command(state, cmd_count_missing(ds))
    },
    saveRmd = function(state) document_save_current(state, "rmd"),
    saveRnw = function(state) document_save_current(state, "rnw"),
    editMarkdown = function(state) {
      document_switch_mode(state, "rmd")
      invisible(NULL)
    },
    editKnitr = function(state) {
      document_switch_mode(state, "rnw")
      invisible(NULL)
    },
    removeLastRmdBlock = function(state) {
      removed <- document_remove_current_chunk(state)
      if (is.function(state$sync_document)) state$sync_document()
      invisible(removed)
    },
    removeLastRmdSection = function(state) {
      removed <- document_remove_current_section(state)
      if (is.function(state$sync_document)) state$sync_document()
      invisible(removed)
    },
    removeLastRnwBlock = function(state) {
      removed <- document_remove_current_chunk(state)
      if (is.function(state$sync_document)) state$sync_document()
      invisible(removed)
    },
    convertStrings2Factors = function(state) {
      df <- dataset(state)
      if (is.null(df)) return(NULL)
      variables <- names(df)[vapply(df, is.character, logical(1))]
      if (length(variables) == 0L) {
        if (!is.null(state$session)) {
          showNotification(
            tr("The active data set has no character variables."),
            type = "message", duration = 5
          )
        }
        return(invisible(NULL))
      }
      for (command in cmd_convert_strings_to_factors(active_dataset(state),
                                                     variables)) {
        run_command(state, command, plot = FALSE)
      }
      invisible(NULL)
    },
    saveDataSet = function(state) request_download(state, "download_dataset_rdata"),
    saveLog = function(state) request_download(state, "download_script"),
    saveLogAs = function(state) request_download(state, "download_script"),
    saveOutput = function(state) request_download(state, "download_output"),
    saveOutputAs = function(state) request_download(state, "download_output"),
    saveWorkspace = function(state) request_download(state, "download_workspace"),
    saveWorkspaceAs = function(state) request_download(state, "download_workspace"),
    saveBitmap = function(state) request_download(state, "download_plot_png"),
    savePDF = function(state) request_download(state, "download_plot_pdf"),
    saveRglGraph = function(state) request_download(state, "download_rgl"),
    summarizeModel = function(state) {
      model <- active_model(state)
      if (is.null(model)) return(NULL)
      run_command(state, cmd_summarize_model(model))
    },
    aic = function(state) {
      model <- active_model(state)
      if (is.null(model)) return(NULL)
      run_command(state, cmd_aic(model))
    },
    bic = function(state) {
      model <- active_model(state)
      if (is.null(model)) return(NULL)
      run_command(state, cmd_bic(model))
    },
    VIF = function(state) {
      model <- active_model(state)
      if (is.null(model)) return(NULL)
      for (command in cmd_vif(model)) run_command(state, command)
    },
    OutlierTest = function(state) {
      model <- active_model(state)
      if (is.null(model)) return(NULL)
      run_command(state, cmd_outlier_test(model))
    },
    plotModel = function(state) {
      model <- active_model(state)
      if (is.null(model)) return(NULL)
      for (command in cmd_plot_model(model)) run_command(state, command)
    },
    appNap = function(state) {
      showNotification(tr("App Nap management is only relevant on macOS."),
                       type = "message", duration = 5)
    },
    installSoftware = function(state) {
      showNotification(
        tr("Auxiliary software must be installed with your system package manager."),
        type = "message", duration = 8
      )
    },
    browseManual = function(state) {
      utils::browseURL("https://www.r-commander.com/")
    },
    browseEnglishManual = function(state) {
      utils::browseURL("https://www.r-commander.com/")
    },
    browseRcmdrHexSticker = function(state) {
      utils::browseURL("https://www.r-commander.com/")
    },
    browseRMarkdown = function(state) {
      utils::browseURL("https://rmarkdown.rstudio.com/")
    },
    saveOptions = function(state) {
      path <- file.path(path.expand("~"), ".RcmdrShiny-options.rds")
      saveRDS(state$options, path)
      showNotification(
        sprintf(tr("Options saved to %s"), path),
        type = "message", duration = 5
      )
      invisible(path)
    },
    helpCommander = function(state) {
      showModal(modalDialog(
        title = tr("RcmdrShiny help"),
        htmltools::tagList(
          htmltools::tags$p(tr(
            "RcmdrShiny is a Shiny version of the R Commander. Use the sidebar to run commands and dialogs; the generated R code appears in the Script tab."
          )),
          htmltools::tags$ul(
            htmltools::tags$li(tr("Data: import and manage data sets.")),
            htmltools::tags$li(tr("Statistics: summaries, tests and models.")),
            htmltools::tags$li(tr("Graphs: base, lattice and ggplot2 graphics.")),
            htmltools::tags$li(tr("Options: output digits, width and editing threshold."))
          )
        ),
        easyClose = TRUE,
        footer = modalButton(tr("Close"))
      ))
    },
    helpCenter = function(state) {
      if (!is.null(state$show_tab)) state$show_tab(tr("Help"))
      invisible(NULL)
    },
    helpSearch = function(state) {
      if (!is.null(state$show_tab)) state$show_tab(tr("Help"))
      if (!is.null(state$session)) {
        state$session$sendCustomMessage("rcmdr-focus", "help_query")
      }
      invisible(NULL)
    },
    helpTutorials = function(state) {
      open_help_topic(state, "getting-started")
    },
    helpShortcuts = function(state) {
      open_help_topic(state, "keyboard-shortcuts")
    },
    helpPluginsTopic = function(state) {
      open_help_topic(state, "plugins")
    },
    helpDiagnostics = function(state) {
      report <- tryCatch(format_diagnostics(), error = function(e) {
        paste("Diagnostics unavailable:", conditionMessage(e))
      })
      showModal(modalDialog(
        title = tr("Diagnostics"),
        htmltools::tags$pre(class = "rcmdr-help-text",
                            paste(report, collapse = "\n")),
        easyClose = TRUE,
        footer = modalButton(tr("Close"))
      ))
    },
    helpAboutCommander = function(state) {
      version <- tryCatch(
        as.character(utils::packageVersion("RcmdrShiny")),
        error = function(e) "0.1.0"
      )
      showModal(modalDialog(
        title = tr("About RcmdrShiny"),
        htmltools::tagList(
          htmltools::tags$p(htmltools::tags$strong(
            sprintf("RcmdrShiny %s", version)
          )),
          htmltools::tags$p(tr(
            "A Shiny version of the R Commander, derived from Rcmdr 2.15.0 (GPL-2+)."
          )),
          htmltools::tags$p(tr(
            "Copyright (C) 2001-2026 John Fox, Milan Bouchet-Valat and contributors."
          )),
          htmltools::tags$p(htmltools::tags$a(
            href = "https://www.r-commander.com/", target = "_blank",
            "https://www.r-commander.com/"
          ))
        ),
        easyClose = TRUE,
        footer = modalButton(tr("Close"))
      ))
    },
    browseRcmdrWebsite = function(state) {
      utils::browseURL("https://www.r-commander.com/")
    },
    browseRWebsite = function(state) {
      utils::browseURL("https://www.r-project.org/")
    },
    startHelp = function(state) {
      utils::help.start()
    },
    helpDataSet = function(state) {
      ds <- active_dataset(state)
      if (is.null(ds)) return(NULL)
      show_help_modal(ds, package = NULL)
    }
  )
}

#' @keywords internal
direct_commands <- function() {
  commands <- utils::modifyList(base_direct_commands(), plugin_commands())
  aliases <- plugin_aliases()
  if (length(aliases) > 0L) {
    for (alias in names(aliases)) {
      target <- commands[[aliases[[alias]]]]
      if (!is.null(target)) commands[[alias]] <- target
    }
  }
  commands
}

#' @keywords internal
request_download <- function(state, id) {
  if (is.null(state$session)) {
    showNotification(tr("The download is available from the corresponding tab."),
                     type = "message", duration = 5)
    return(invisible(NULL))
  }
  state$session$sendCustomMessage("rcmdr-click", id)
  invisible(id)
}

#' Render an R help topic as plain text
#' @keywords internal
help_topic_text <- function(topic, package_name = NULL) {
  if (is.null(package_name)) {
    packages <- c("RcmdrShiny", "RcmdrMisc", "car", "stats", "graphics",
                  "utils", "datasets", "base")
    found <- packages[vapply(packages, function(candidate) {
      length(tryCatch(
        do.call(utils::help, list(topic = topic, package = candidate)),
        error = function(e) NULL
      )) > 0L
    }, logical(1))]
    package_name <- if (length(found) == 0L) NA_character_ else found[[1L]]
  }

  help_file <- tryCatch(
    if (is.na(package_name)) {
      do.call(utils::help, list(topic = topic))
    } else {
      do.call(utils::help, list(topic = topic, package = package_name))
    },
    error = function(e) NULL
  )

  if (is.null(help_file) || length(help_file) == 0L) {
    return(NULL)
  }

  tryCatch({
    get_help_file <- get(".getHelpFile", envir = asNamespace("utils"))
    rd <- get_help_file(help_file)
    rendered <- utils::capture.output(tools::Rd2txt(rd))
    # Strip terminal underlining (character + backspace).
    gsub(".\b", "", paste(rendered, collapse = "\n"))
  }, error = function(e) NULL)
}

#' Show an R help topic in a modal
#' @keywords internal
show_help_modal <- function(topic, package = NULL) {
  text <- help_topic_text(topic, package_name = package)
  if (is.null(text)) {
    showNotification(
      sprintf(tr("No help found for '%s'."), topic),
      type = "warning", duration = 5
    )
    return(invisible(NULL))
  }

  showModal(modalDialog(
    title = sprintf(tr("Help: %s"), topic),
    htmltools::tags$pre(class = "rcmdr-help-text", text),
    size = "l",
    easyClose = TRUE,
    footer = modalButton(tr("Close"))
  ))
  invisible(NULL)
}

#' @keywords internal
command_enabled <- function(state, command) {
  if (!is_implemented_command(command)) return(FALSE)

  ds <- active_dataset(state)
  switch(
    command,
    readDataSet = TRUE,
    summarizeDataSet = !is.null(ds),
    numericalSummaries = length(numeric_variables(state)) > 0L,
    linearModel = length(numeric_variables(state)) > 0L,
    TRUE
  )
}

#' Modal for a dialog specification
#' @keywords internal
dialog_modal <- function(spec) {
  has_help <- !is.null(spec$help) ||
    !is.null(help_topic_for_dialog(spec))
  modalDialog(
    title = spec$title,
    uiOutput("dialog_body"),
    uiOutput("dialog_help_panel"),
    footer = htmltools::tagList(
      if (has_help) {
        actionButton("dialog_help", tr("Help"), class = "btn-outline-secondary")
      },
      actionButton("dialog_reset", tr("Reset"), class = "btn-outline-secondary"),
      actionButton("dialog_cancel", tr("Cancel"), class = "btn-outline-secondary"),
      actionButton("dialog_apply", tr("Apply"), class = "btn-outline-primary"),
      actionButton("dialog_ok", tr("OK"), class = "btn-primary")
    ),
    size = spec$size,
    easyClose = FALSE
  )
}

#' Run the commands returned by a dialog
#'
#' @param state Application state.
#' @param result List returned by a dialog `on_ok` callback.
#' @return `TRUE` when all commands succeeded.
#' @keywords internal
apply_dialog_result <- function(state, result) {
  ok <- TRUE
  # A new dialog result replaces any previous interactive plot.  The base
  # command below still produces the PNG shown in the gallery.
  state$plotly_widget <- NULL
  state$plotly_title <- NULL

  for (command in result$commands %||% character()) {
    outcome <- run_command(
      state, command,
      plot = if (isTRUE(result$plot)) TRUE else "auto"
    )
    if (!identical(outcome$status, "ok")) ok <- FALSE
  }

  if (!is.null(result$interactive) && plotly_available()) {
    widget <- plotly_build(state, result$interactive)
    if (!is.null(widget)) {
      state$plotly_widget <- widget
      state$plotly_title <- result$interactive_title %||% ""
    }
  }

  if (!is.null(result$activate_dataset)) {
    if (exists(result$activate_dataset, envir = state$env, inherits = FALSE)) {
      active_dataset(state, result$activate_dataset)
    }
  }
  if (!is.null(result$activate_model)) {
    if (exists(result$activate_model, envir = state$env, inherits = FALSE)) {
      active_model(state, result$activate_model)
    }
  }
  if (!is.null(result$report)) {
    state$report_title <- result$report$title %||% "RcmdrShiny report"
    request_download(
      state,
      if (identical(result$report$format, "html")) {
        "download_report_html"
      } else {
        "download_report_rmd"
      }
    )
  }
  if (!is.null(result$script) && is.function(state$set_script)) {
    state$set_script(result$script)
  }
  if (!is.null(result$tab) && is.function(state$show_tab)) {
    state$show_tab(result$tab)
  }
  if (!is.null(result$message)) {
    showNotification(result$message,
                     type = result$message_type %||% "message",
                     duration = 8)
  }
  state_touch(state)
  ok
}
