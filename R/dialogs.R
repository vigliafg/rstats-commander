# Dialog runtime ------------------------------------------------------------
#
# A dialog is a small spec: a title, a UI builder, an on_ok callback and,
# optionally, an on_open hook and observers that need the Shiny session.
# The runtime renders the spec inside a modal and turns the returned commands
# into run_command() calls.

#' @keywords internal
dialog_spec <- function(id, title, ui, on_ok, on_open = NULL,
                        observers = NULL, size = "l") {
  list(
    id = id,
    title = title,
    ui = ui,
    on_ok = on_ok,
    on_open = on_open,
    observers = observers,
    size = size
  )
}

#' Available dialog specifications
#' @keywords internal
dialog_catalog <- function() {
  list(
    readDataSet = import_text_dialog(),
    numericalSummaries = numerical_summaries_dialog(),
    linearModel = linear_model_dialog()
  )
}

#' @keywords internal
get_dialog_spec <- function(id) {
  dialog_catalog()[[id]]
}

#' @keywords internal
is_implemented_command <- function(command) {
  !is.null(get_dialog_spec(command)) || command %in% names(direct_commands())
}

# Commands that do not need a dialog.  They are the first entries of the
# "porting registry": each one is a function of the application state.
direct_commands <- function() {
  list(
    summarizeDataSet = function(state) {
      ds <- active_dataset(state)
      if (is.null(ds)) return(NULL)
      run_command(state, paste0("summary(", ds, ")"))
    }
  )
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
      actionButton("dialog_reset", tr("Reset"), class = "btn-outline-secondary"),
      actionButton("dialog_cancel", tr("Cancel"), class = "btn-outline-secondary"),
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
    outcome <- run_command(state, command, plot = isTRUE(result$plot))
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
  state_touch(state)
  ok
}
