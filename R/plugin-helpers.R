# Plugin helpers ------------------------------------------------------------
#
# Small, stable helpers that plugin packages can use without reaching into
# unexported internals.  They complement the state accessors exported from
# state.R (active_dataset(), active_model(), dataset(), variables(), ...).

#' Build a formula from variable names
#'
#' Plugin dialogs collect variable names from widgets and need to turn them
#' into the formula strings used by Rcmdr commands.
#'
#' @param response Optional response variable name.
#' @param predictors Character vector of predictor names.
#' @param interactions Optional list of character vectors.  A vector with more
#'   than one element becomes an interaction term such as `(a * b)`.
#' @return A formula string, for example `"y ~ x1 + x2"`.
#' @export
plugin_formula <- function(response = NULL, predictors = character(),
                           interactions = list()) {
  predictors <- as.character(predictors %||% character())
  terms <- predictors[nzchar(predictors)]

  for (interaction in interactions %||% list()) {
    interaction <- as.character(interaction)
    interaction <- interaction[nzchar(interaction)]
    if (length(interaction) == 0L) next
    terms <- c(
      terms,
      if (length(interaction) == 1L) {
        interaction
      } else {
        paste0("(", paste(interaction, collapse = " * "), ")")
      }
    )
  }

  rhs <- paste(unique(terms), collapse = " + ")
  if (is.null(response) || !nzchar(response)) {
    rhs
  } else {
    paste0(response, " ~ ", if (nzchar(rhs)) rhs else "1")
  }
}

#' Variable names by type
#'
#' `variables()` returns all variables in the active data set;
#' `numeric_variables()` and `factor_variables()` filter them.  Factors,
#' logicals and character variables are all treated as categorical, matching
#' Rcmdr's menu predicates.
#'
#' @param state Application state created by [AppState()].
#' @return A character vector of variable names.
#' @name plugin-variables
NULL

#' Active data frame
#'
#' Returns the active data frame, or `NULL` when no data set is active.
#'
#' @param state Application state created by [AppState()].
#' @return A data frame or `NULL`.
#' @name plugin-dataset
NULL
