# Shiny widget library ------------------------------------------------------
#
# Names mirror the Rcmdr widgets they replace (variableListBox, checkBoxes,
# radioButtons, ...), so that a dialog can be ported by substituting widgets
# without rewriting its validation logic.

w_label <- function(text) {
  htmltools::tags$label(text, class = "form-label")
}

#' @keywords internal
form_group <- function(label, input, help = NULL) {
  htmltools::div(
    class = "mb-3",
    if (!is.null(label)) w_label(label),
    input,
    if (!is.null(help)) htmltools::tags$div(class = "form-text", help)
  )
}

#' Variable selector
#'
#' Shiny equivalent of Rcmdr's `variableListBox()`.
#' @export
var_input <- function(id, label, choices, selected = NULL, multiple = FALSE,
                      size = NULL, placeholder = NULL) {
  if (length(choices) == 0L) {
    return(form_group(
      label,
      htmltools::tags$div(class = "text-muted", tr("No variables available"))
    ))
  }
  options <- list()
  if (!is.null(placeholder)) options$placeholder <- placeholder
  if (is.null(selected) || (length(selected) == 1L && !nzchar(selected))) {
    selected <- character()
  }
  selected <- intersect(selected, choices)
  selectizeInput(
    id, label,
    choices = stats::setNames(choices, choices),
    selected = selected,
    multiple = multiple,
    width = "100%",
    options = options
  )
}

#' @keywords internal
groups_input <- function(id, label, choices, selected = NULL) {
  selectInput(
    id, label,
    choices = choices,
    selected = if (is.null(selected)) choices[[1L]] else selected,
    width = "100%"
  )
}

#' Single checkbox
#' @export
checkbox_input <- function(id, label, value = FALSE) {
  checkboxInput(id, label, value = isTRUE(value))
}

#' Group of checkboxes laid out in a grid
#'
#' `choices` is a named character vector: names are the suffixes used to build
#' input ids (`<prefix>_<name>`) and values are the labels.
#' @export
checkboxes_input <- function(prefix, choices, selected = character(), ncol = 1L) {
  ids <- names(choices)
  if (is.null(ids)) ids <- choices
  htmltools::div(
    class = "row",
    lapply(seq_along(choices), function(i) {
      htmltools::div(
        class = sprintf("col-md-%d", max(1L, floor(12L / ncol))),
        checkboxInput(
          paste0(prefix, "_", ids[[i]]),
          choices[[i]],
          value = isTRUE(ids[[i]] %in% selected)
        )
      )
    })
  )
}

#' Radio buttons
#' @export
radio_input <- function(id, label, choices, selected = NULL, inline = TRUE) {
  if (is.null(names(choices))) names(choices) <- choices
  radioButtons(
    id, label,
    choices = choices,
    selected = if (is.null(selected)) choices[[1L]] else selected,
    inline = inline
  )
}

#' Text entry
#' @export
entry_input <- function(id, label, value = "", placeholder = NULL, width = NULL) {
  textInput(id, label, value = value, placeholder = placeholder, width = width)
}

#' Numeric entry
#' @export
spin_input <- function(id, label, value = 0, min = NA, max = NA, step = 1) {
  numericInput(id, label, value = value, min = min, max = max, step = step)
}

#' @keywords internal
text_area <- function(id, label, value = "", rows = 4L) {
  textAreaInput(id, label, value = value, rows = rows, resize = "vertical")
}

#' @keywords internal
help_text <- function(...) {
  htmltools::tags$div(class = "form-text", ...)
}

#' @keywords internal
dialog_tabs <- function(...) {
  tabsetPanel(...)
}

#' @keywords internal
button_row <- function(...) {
  htmltools::div(class = "d-flex gap-2 flex-wrap", ...)
}

# A compact label/value helper used by the menus and the status bar.
kv <- function(label, value) {
  htmltools::tags$span(
    htmltools::tags$strong(label), " ",
    htmltools::tags$span(value)
  )
}
