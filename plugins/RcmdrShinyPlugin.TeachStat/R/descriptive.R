# Descriptive statistics, index numbers and ANOVA ----------------------

ts_descriptive_factor <- function(dataset, variable) {
  c(
    sprintf("table(%s$%s)", dataset, variable),
    sprintf("prop.table(table(%s$%s))", dataset, variable)
  )
}

ts_descriptive_numeric <- function(dataset, variables,
                                   groups = NULL, weights = NULL) {
  vars <- paste(sprintf("%s$%s", dataset, variables), collapse = ", ")
  if (!is.null(weights) && nzchar(weights)) {
    return(sprintf(
      "local({ .x <- %s; .w <- %s$%s; c(mean = weighted.mean(.x, .w, na.rm = TRUE), sd = sqrt(sum(.w * (.x - weighted.mean(.x, .w, na.rm = TRUE))^2, na.rm = TRUE) / (sum(.w, na.rm = TRUE) - 1))) })",
      vars, dataset, weights
    ))
  }
  if (!is.null(groups) && nzchar(groups)) {
    return(sprintf("RcmdrMisc::numSummary(%s, groups = %s$%s)",
                   vars, dataset, groups))
  }
  sprintf("RcmdrMisc::numSummary(%s)", vars)
}

ts_descriptive_table <- function(values, frequencies) {
  sprintf(
    "local({ .x <- c(%s); .f <- c(%s); c(mean = weighted.mean(.x, .f), variance = sum(.f * (.x - weighted.mean(.x, .f))^2) / (sum(.f) - 1)) })",
    values, frequencies
  )
}

ts_simple_index <- function(dataset, variable, base = 1) {
  sprintf("local({ .x <- %s$%s; 100 * .x / .x[%d] })",
          dataset, variable, as.integer(base))
}

ts_chain_index <- function(dataset, variable) {
  sprintf("local({ .x <- %s$%s; 100 * cumprod(c(1, .x[-1] / .x[-length(.x)])) })",
          dataset, variable)
}

ts_base_change <- function(dataset, variable, base = 1) {
  sprintf("local({ .x <- %s$%s; 100 * .x / .x[%d] })",
          dataset, variable, as.integer(base))
}

ts_price_index <- function(dataset, price, quantity, base = 1) {
  sprintf(
    "local({ .p <- %s$%s; .q <- %s$%s; 100 * (.p * .q) / (.p[%d] * .q[%d]) })",
    dataset, price, dataset, quantity, as.integer(base), as.integer(base)
  )
}

ts_deflation <- function(dataset, nominal, price) {
  sprintf("local({ 100 * %s$%s / %s$%s })",
          dataset, nominal, dataset, price)
}

ts_random_anova <- function(dataset, response, group) {
  c(
    sprintf(".model <- lme4::lmer(%s ~ (1 | %s), data = %s)",
            response, group, dataset),
    "summary(.model)"
  )
}

ts_predict_existing <- function(model, dataset) {
  sprintf("%s$fitted.%s <- predict(%s, %s)", dataset, model, model, dataset)
}
