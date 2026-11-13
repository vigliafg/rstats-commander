# Options -------------------------------------------------------------------

default_options <- function() {
  list(
    digits = 7L,
    width = 80L,
    stringsAsFactors = TRUE,
    assertSingleQuote = FALSE
  )
}

#' @keywords internal
option <- function(state, name, default = NULL) {
  value <- state$options[[name]]
  if (is.null(value)) default else value
}

#' @keywords internal
set_option <- function(state, name, value) {
  state$options[[name]] <- value
  state_touch(state)
  invisible(value)
}
