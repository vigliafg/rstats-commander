# Application state ---------------------------------------------------------
#
# The state is a plain environment so that it can be created and inspected
# without a running Shiny session (useful for tests).  A single state belongs
# to a single session: the package targets a local, single-user deployment and
# therefore keeps Rcmdr's .GlobalEnv semantics.

#' Create an application state
#'
#' @param env Evaluation environment used by [run_command()].  Defaults to the
#'   global environment, mirroring Rcmdr.
#' @return An environment of class `RcmdrShinyState`.
#' @export
AppState <- function(env = globalenv()) {
  state <- new.env(parent = emptyenv())
  class(state) <- "RcmdrShinyState"

  state$env <- env
  state$active_dataset <- NULL
  state$active_model <- NULL

  state$log <- character()
  state$output <- character()
  state$messages <- character()
  state$warnings <- character()
  state$last_error <- NULL

  state$dialog_memory <- list()
  state$plots <- list()
  state$current_dialog <- NULL

  state$model_number <- 0L
  state$revision <- 0L
  state$busy <- FALSE
  state$options <- list(
    digits = 7L,
    width = 80L,
    stringsAsFactors = TRUE
  )

  # Called after every mutation that the UI should react to.  The Shiny server
  # replaces it with a function that bumps a reactive counter.
  state$notify <- function() invisible(NULL)

  state
}

is_app_state <- function(state) inherits(state, "RcmdrShinyState")

#' @keywords internal
state_touch <- function(state) {
  if (!is_app_state(state)) return(invisible(NULL))
  state$revision <- state$revision + 1L
  notify <- state$notify
  if (is.function(notify)) notify()
  invisible(state$revision)
}

#' Active data set
#'
#' `active_dataset()` gets or sets the name of the active data set.
#' @param state Application state.
#' @param value Name of an object in `state$env` holding a data frame.  Use
#'   `NULL` to clear the active data set.
#' @export
active_dataset <- function(state, value) {
  if (missing(value)) return(state$active_dataset)

  if (is.null(value)) {
    state$active_dataset <- NULL
    state$active_model <- NULL
    state_touch(state)
    return(invisible(NULL))
  }

  if (!is.character(value) || length(value) != 1L || is.na(value)) {
    stop("The active data set must be a single object name.", call. = FALSE)
  }
  if (!exists(value, envir = state$env, inherits = FALSE)) {
    stop(sprintf("Object '%s' does not exist.", value), call. = FALSE)
  }
  object <- get(value, envir = state$env, inherits = FALSE)
  if (!is.data.frame(object)) {
    stop(sprintf("Object '%s' is not a data frame.", value), call. = FALSE)
  }

  if (!identical(state$active_dataset, value)) {
    state$active_model <- NULL
  }
  state$active_dataset <- value
  state_touch(state)
  invisible(value)
}

#' @keywords internal
dataset <- function(state) {
  name <- state$active_dataset
  if (is.null(name) || !exists(name, envir = state$env, inherits = FALSE)) {
    return(NULL)
  }
  object <- get(name, envir = state$env, inherits = FALSE)
  if (!is.data.frame(object)) NULL else object
}

#' @keywords internal
variables <- function(state) {
  df <- dataset(state)
  if (is.null(df)) character() else names(df)
}

#' @keywords internal
numeric_variables <- function(state) {
  df <- dataset(state)
  if (is.null(df)) return(character())
  names(df)[vapply(df, is.numeric, logical(1))]
}

#' @keywords internal
factor_variables <- function(state) {
  df <- dataset(state)
  if (is.null(df)) return(character())
  names(df)[vapply(df, function(x) is.factor(x) || is.logical(x) || is.character(x), logical(1))]
}

#' @keywords internal
two_level_factors <- function(state) {
  df <- dataset(state)
  if (is.null(df)) return(character())
  vars <- factor_variables(state)
  vars[vapply(vars, function(v) {
    x <- df[[v]]
    if (is.character(x)) x <- factor(x)
    nlevels(x) == 2L
  }, logical(1))]
}

# Rcmdr's discreteness threshold (see listDiscreteNumeric in Rcmdr).
discreteness_threshold <- function(n) {
  if (!is.finite(n) || n < 1) return(100L)
  min(round(2 * sqrt(n)), round(10 * log10(n)), 100L)
}

#' @keywords internal
discrete_numeric_variables <- function(state) {
  df <- dataset(state)
  if (is.null(df)) return(character())
  vars <- numeric_variables(state)
  if (length(vars) == 0L) return(character())
  threshold <- discreteness_threshold(nrow(df))
  vars[vapply(vars, function(v) length(unique(df[[v]])) <= threshold, logical(1))]
}

#' Active model
#'
#' @param state Application state.
#' @param value Name of an object in `state$env`, or `NULL`.
#' @export
active_model <- function(state, value) {
  if (missing(value)) return(state$active_model)
  if (!is.null(value)) {
    if (!is.character(value) || length(value) != 1L || is.na(value)) {
      stop("The active model must be a single object name.", call. = FALSE)
    }
    if (!exists(value, envir = state$env, inherits = FALSE)) {
      stop(sprintf("Object '%s' does not exist.", value), call. = FALSE)
    }
  }
  state$active_model <- value
  state_touch(state)
  invisible(value)
}

#' @keywords internal
update_model_number <- function(state, increment = 1L) {
  state$model_number <- max(1L, as.integer(state$model_number + increment))
  invisible(state$model_number)
}

#' Dialog memory
#' @keywords internal
get_dialog_memory <- function(state, id) {
  state$dialog_memory[[id]]
}

#' @keywords internal
set_dialog_memory <- function(state, id, values) {
  state$dialog_memory[[id]] <- values
  invisible(values)
}

#' @keywords internal
clear_dialog_memory <- function(state, id) {
  state$dialog_memory[[id]] <- NULL
  invisible(NULL)
}

# Small utilities -----------------------------------------------------------

`%||%` <- function(x, y) {
  if (is.null(x) || (length(x) == 1L && is.na(x))) y else x
}

trim_blanks <- function(x) {
  if (is.null(x)) return("")
  gsub("^[[:space:]]+|[[:space:]]+$", "", x)
}

#' @keywords internal
is_valid_name <- function(name) {
  if (!is.character(name) || length(name) != 1L || is.na(name) || !nzchar(name)) {
    return(FALSE)
  }
  if (!identical(make.names(name), name)) return(FALSE)
  !name %in% c(
    "if", "else", "repeat", "while", "function", "for", "next", "break",
    "TRUE", "FALSE", "NULL", "Inf", "NaN", "NA", "NA_integer_",
    "NA_real_", "NA_character_", "in"
  )
}

#' Attach packages needed by Rcmdr-generated commands
#' @keywords internal
attach_packages <- function(packages) {
  for (package in packages) {
    if (!package %in% .packages()) {
      suppressPackageStartupMessages(
        library(package, character.only = TRUE, quietly = TRUE,
                warn.conflicts = FALSE)
      )
    }
  }
  invisible(NULL)
}

quote_string <- function(x) paste0('"', x, '"')

quote_vars <- function(x) {
  if (length(x) == 1L) {
    quote_string(x)
  } else {
    paste0("c(", paste0(quote_string(x), collapse = ", "), ")")
  }
}
