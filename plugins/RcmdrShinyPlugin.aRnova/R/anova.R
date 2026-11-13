# ANOVA command builders -------------------------------------------------

build_aov <- function(dataset, response, factors, interaction = TRUE) {
  if (length(factors) == 0L) stop("Select at least one factor.")
  rhs <- if (isTRUE(interaction)) {
    paste(factors, collapse = " * ")
  } else {
    paste(factors, collapse = " + ")
  }
  c(
    sprintf(".model <- aov(%s ~ %s, data = %s)", response, rhs, dataset),
    "summary(.model)"
  )
}

build_repeated_measures <- function(dataset, variables, within = "within",
                                    between = "") {
  if (length(variables) < 2L) stop("Select at least two repeated measures.")
  varying <- paste(sprintf('"%s"', variables), collapse = ", ")
  rhs <- if (nzchar(between)) {
    sprintf("%s * %s + Error(id/%s)", within, between, within)
  } else {
    sprintf("%s + Error(id/%s)", within, within)
  }
  paste(
    "local({",
    sprintf('  .long <- reshape(%s, varying = list(c(%s)), v.names = "value",',
            dataset, varying),
    sprintf('                  timevar = "%s", times = c(%s), direction = "long")',
            within, varying),
    sprintf("  .model <- aov(value ~ %s, data = .long)", rhs),
    "  summary(.model)",
    "})",
    sep = "\n"
  )
}
