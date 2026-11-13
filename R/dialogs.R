# Dialog runtime ------------------------------------------------------------
#
# A dialog is a small spec: a title, a UI builder, an on_ok callback and,
# optionally, an on_open hook and observers that need the Shiny session.
# The runtime renders the spec inside a modal and turns the returned commands
# into run_command() calls.

#' @keywords internal
dialog_spec <- function(id, title, ui, on_ok, on_open = NULL,
                        observers = NULL, size = "l",
                        help = NULL, help_package = NULL) {
  list(
    id = id,
    title = title,
    ui = ui,
    on_ok = on_ok,
    on_open = on_open,
    observers = observers,
    size = size,
    help = help,
    help_package = help_package
  )
}

#' Available dialog specifications
#' @keywords internal
dialog_catalog <- function() {
  base <- list(
    readDataSet = import_text_dialog(),
    numericalSummaries = numerical_summaries_dialog(),
    linearModel = linear_model_dialog(),
    Options = options_dialog(),
    Setwd = setwd_dialog(),
    loadDataSet = load_dataset_dialog(),
    loadLog = load_script_dialog()
  )
  c(base, phase2_dialogs(), phase3_dialogs(), phase4_dialogs(), phase5_dialogs())
}

#' @keywords internal
get_dialog_spec <- function(id) {
  dialog_catalog()[[id]]
}

.implemented_commands_cache <- new.env(parent = emptyenv())

#' @keywords internal
implemented_commands <- function() {
  if (is.null(.implemented_commands_cache$names)) {
    .implemented_commands_cache$names <- c(
      names(dialog_catalog()),
      names(direct_commands())
    )
  }
  .implemented_commands_cache$names
}

#' @keywords internal
is_implemented_command <- function(command) {
  command %in% implemented_commands()
}

# Commands that do not need a dialog.  They are the first entries of the
# "porting registry": each one is a function of the application state.
direct_commands <- function() {
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
    loadPlugins = function(state) {
      showNotification(
        tr("The plugin API is minimal in this version; legacy Tk dialogs are not supported."),
        type = "message", duration = 8
      )
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
  modalDialog(
    title = spec$title,
    uiOutput("dialog_body"),
    footer = htmltools::tagList(
      if (!is.null(spec$help)) {
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
  for (command in result$commands %||% character()) {
    outcome <- run_command(
      state, command,
      plot = if (isTRUE(result$plot)) TRUE else "auto"
    )
    if (!identical(outcome$status, "ok")) ok <- FALSE
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
  if (!is.null(result$script) && is.function(state$set_script)) {
    state$set_script(result$script)
  }
  if (!is.null(result$tab) && is.function(state$show_tab)) {
    state$show_tab(result$tab)
  }
  state_touch(state)
  ok
}
