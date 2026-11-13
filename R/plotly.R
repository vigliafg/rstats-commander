# Interactive plots with plotly ---------------------------------------------
#
# The browser cannot support Tk's identify()/locator(), but plotly gives
# hover, zoom and selection.  When plotly is installed the four main graph
# dialogs additionally build an interactive widget; the base graphics command
# still runs, so the PNG gallery and the export keep working.
#
# `interactive` in a dialog result is a single R expression that evaluates to a
# plotly object.  It is evaluated in the session environment, so it sees the
# same data the command sees.

#' Whether interactive plots are available
#' @return `TRUE` when the `plotly` package is installed.
#' @keywords internal
plotly_available <- function() {
  requireNamespace("plotly", quietly = TRUE)
}

plotly_code_scatter <- function(dataset, x, y, group = NULL, smooth = FALSE,
                                log = "") {
  color <- if (is.null(group)) "" else sprintf(", color = ~%s", group)
  paste0(
    "plotly::plot_ly(data = ", dataset, ", x = ~", x, ", y = ~", y,
    color, ", type = \"scatter\", mode = \"markers\")",
    if (isTRUE(smooth)) {
      sprintf(" |> plotly::add_lines(data = %s, x = ~%s, y = ~%s, inherit = FALSE)",
              dataset, x, y)
    } else {
      ""
    },
    switch(log,
           x = " |> plotly::layout(xaxis = list(type = \"log\"))",
           y = " |> plotly::layout(yaxis = list(type = \"log\"))",
           xy = " |> plotly::layout(xaxis = list(type = \"log\"), yaxis = list(type = \"log\"))",
           "")
  )
}

plotly_code_histogram <- function(dataset, variable, group = NULL) {
  color <- if (is.null(group)) "" else sprintf(", color = ~%s", group)
  paste0(
    "plotly::plot_ly(data = ", dataset, ", x = ~", variable, color,
    ", type = \"histogram\")"
  )
}

plotly_code_boxplot <- function(dataset, variables, response = NULL,
                                group = NULL) {
  if (!is.null(group) && nzchar(group) && !is.null(response) && nzchar(response)) {
    return(paste0(
      "plotly::plot_ly(data = ", dataset, ", y = ~", response,
      ", color = ~", group, ", type = \"box\")"
    ))
  }
  variables <- variables[nzchar(variables)]
  if (length(variables) == 0L) return("NULL")
  parts <- vapply(variables, function(variable) {
    sprintf("plotly::add_boxplot(data = %s, y = ~%s, name = \"%s\")",
            dataset, variable, variable)
  }, character(1))
  paste0("plotly::plot_ly()", paste0(" |> ", parts, collapse = ""))
}

plotly_code_line <- function(dataset, x, y) {
  y <- y[nzchar(y)]
  if (length(y) == 0L) return("NULL")
  parts <- vapply(y, function(variable) {
    sprintf("plotly::add_lines(data = %s, x = ~%s, y = ~%s, name = \"%s\")",
            dataset, x, variable, variable)
  }, character(1))
  paste0("plotly::plot_ly()", paste0(" |> ", parts, collapse = ""))
}

#' Evaluate an interactive plot expression
#'
#' @param state Application state.
#' @param code Character expression returning a plotly object.
#' @return The widget, or `NULL` when plotly is missing or evaluation fails.
#' @keywords internal
plotly_build <- function(state, code) {
  if (!plotly_available() || is.null(code) || !nzchar(code)) return(NULL)
  tryCatch(
    eval(parse(text = code), envir = state$env),
    error = function(e) NULL
  )
}
