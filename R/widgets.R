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

#' Slider
#' @export
slider_input <- function(id, label, min, max, value, step = 1) {
  sliderInput(id, label, min = min, max = max, value = value, step = step)
}

#' Drop-down / combo box
#' @export
combo_input <- function(id, label, choices, selected = NULL, multiple = FALSE) {
  if (is.null(selected) || (length(selected) == 1L && !nzchar(selected))) {
    selected <- character()
  }
  selectInput(
    id, label,
    choices = choices,
    selected = if (length(selected) == 0L) NULL else selected,
    multiple = multiple,
    width = "100%"
  )
}

#' Subset expression entry
#' @export
subset_input <- function(id, label = tr("Subset expression:"), value = "") {
  textInput(id, label, value = value, width = "100%")
}

#' Read-only text area
#' @keywords internal
text_area <- function(id, label, value = "", rows = 4L) {
  textAreaInput(id, label, value = value, rows = rows, resize = "vertical")
}

#' File or directory chooser
#'
#' The text entry is the source of truth: it can be typed, which keeps the
#' generated command reproducible and makes the widget testable.  The button
#' opens `shinyFiles` for local browsing.
#' @export
file_input <- function(id, label, value = "", button = TRUE,
                       placeholder = NULL, filetypes = NULL) {
  tagList(
    textInput(id, label, value = value, placeholder = placeholder,
              width = "100%"),
    if (isTRUE(button)) {
      shinyFiles::shinyFilesButton(
        paste0(id, "_browse"),
        tr("Browse..."),
        tr("Select a file"),
        multiple = FALSE
      )
    }
  )
}

#' @export
dir_input <- function(id, label, value = "", button = TRUE,
                      placeholder = NULL) {
  tagList(
    textInput(id, label, value = value, placeholder = placeholder,
              width = "100%"),
    if (isTRUE(button)) {
      shinyFiles::shinyDirButton(
        paste0(id, "_browse"),
        tr("Browse..."),
        tr("Select a directory")
      )
    }
  )
}

#' Observers for [file_input()]
#' @keywords internal
file_input_observers <- function(input, session, id, roots,
                                 guard = function() TRUE,
                                 filetypes = NULL, state = NULL) {
  browse <- paste0(id, "_browse")
  shinyFiles::shinyFileChoose(input, browse, roots = roots,
                              filetypes = filetypes)
  observeEvent(input[[browse]], {
    if (!isTRUE(guard())) return()
    selected <- shinyFiles::parseFilePaths(roots, input[[browse]])
    if (nrow(selected) > 0L) {
      updateTextInput(session, id, value = as.character(selected$datapath[[1L]]))
    }
  }, ignoreInit = TRUE)
  invisible(NULL)
}

#' Observers for [dir_input()]
#' @keywords internal
dir_input_observers <- function(input, session, id, roots,
                                guard = function() TRUE) {
  browse <- paste0(id, "_browse")
  shinyFiles::shinyDirChoose(input, browse, roots = roots)
  observeEvent(input[[browse]], {
    if (!isTRUE(guard())) return()
    selected <- shinyFiles::parseDirPath(roots, input[[browse]])
    if (length(selected) > 0L) {
      updateTextInput(session, id, value = as.character(selected[[1L]]))
    }
  }, ignoreInit = TRUE)
  invisible(NULL)
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

#' Model formula builder
#'
#' Shiny equivalent of Rcmdr's `modelFormula()`: a response selector, a
#' free-form right-hand side, an "insert variable" control and the usual
#' formula operators.
#' @export
model_formula_input <- function(id, variables, lhs = "", rhs = "",
                                response_label = tr("Response variable:"),
                                formula_label = tr("Model formula (right-hand side):"),
                                show_operators = TRUE) {
  operator_button <- function(op, label) {
    actionButton(paste0(id, "_op_", op), label,
                 class = "btn-sm btn-outline-secondary")
  }

  tagList(
    var_input(paste0(id, "_lhs"), response_label, variables, selected = lhs),
    entry_input(paste0(id, "_rhs"), formula_label, rhs),
    htmltools::div(
      class = "row g-2 align-items-end mb-3",
      htmltools::div(
        class = "col-md-6",
        selectInput(
          paste0(id, "_insert_var"), tr("Add variable"),
          choices = stats::setNames(variables, variables), width = "100%"
        )
      ),
      htmltools::div(
        class = "col-md-3",
        actionButton(paste0(id, "_insert"), tr("Insert"),
                     class = "btn-sm btn-outline-primary")
      ),
      if (isTRUE(show_operators)) {
        htmltools::div(
          class = "col-md-3",
          button_row(
            operator_button("plus", "+"),
            operator_button("star", "*"),
            operator_button("colon", ":"),
            operator_button("caret", "^"),
            operator_button("lparen", "("),
            operator_button("rparen", ")")
          )
        )
      }
    )
  )
}

#' Observers for [model_formula_input()]
#' @keywords internal
model_formula_observers <- function(input, session, id, guard = function() TRUE) {
  append_text <- function(text) {
    current <- input[[paste0(id, "_rhs")]] %||% ""
    updateTextInput(
      session, paste0(id, "_rhs"),
      value = paste0(current, if (nzchar(current)) " " else "", text)
    )
  }

  observeEvent(input[[paste0(id, "_insert")]], {
    if (!isTRUE(guard())) return()
    variable <- input[[paste0(id, "_insert_var")]]
    if (!is.null(variable) && nzchar(variable)) {
      current <- trim_blanks(input[[paste0(id, "_rhs")]] %||% "")
      updateTextInput(
        session, paste0(id, "_rhs"),
        value = paste0(current, if (nzchar(current)) " + " else "", variable)
      )
    }
  }, ignoreInit = TRUE)

  operators <- c(
    plus = "+", star = "*", colon = ":",
    caret = "^", lparen = "(", rparen = ")"
  )
  for (key in names(operators)) {
    local({
      op <- operators[[key]]
      observeEvent(input[[paste0(id, "_op_", key)]], {
        if (!isTRUE(guard())) return()
        append_text(op)
      }, ignoreInit = TRUE)
    })
  }
  invisible(NULL)
}

# A compact label/value helper used by the menus and the status bar.
kv <- function(label, value) {
  htmltools::tags$span(
    htmltools::tags$strong(label), " ",
    htmltools::tags$span(value)
  )
}
