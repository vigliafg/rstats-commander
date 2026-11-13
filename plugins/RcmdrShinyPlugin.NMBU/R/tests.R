# NMBU test and model builders ------------------------------------------

numbu_num <- function(value, name) {
  number <- suppressWarnings(as.numeric(value))
  if (length(number) == 0L || is.na(number)) stop(sprintf("%s must be a number.", name))
  number
}

build_t_test <- function(kind, dataset, response, group = "", first = "",
                         second = "", mu = 0, level = 0.95,
                         alternative = "two.sided", equal_variance = FALSE) {
  if (identical(kind, "single")) {
    return(sprintf("t.test(%s$%s, mu = %s, alternative = '%s', conf.level = %s)",
                   dataset, response, numbu_num(mu, "Null mean"),
                   alternative, numbu_num(level, "Confidence level")))
  }
  if (identical(kind, "independent")) {
    return(sprintf("t.test(%s ~ %s, data = %s, mu = %s, alternative = '%s', conf.level = %s, var.equal = %s)",
                   response, group, dataset, numbu_num(mu, "Null mean"),
                   alternative, numbu_num(level, "Confidence level"),
                   if (isTRUE(equal_variance)) "TRUE" else "FALSE"))
  }
  if (identical(kind, "paired")) {
    return(sprintf("t.test(%s$%s, %s$%s, paired = TRUE, mu = %s, alternative = '%s', conf.level = %s)",
                   dataset, first, dataset, second, numbu_num(mu, "Null mean"),
                   alternative, numbu_num(level, "Confidence level")))
  }
  if (identical(kind, "unstacked")) {
    return(sprintf("t.test(%s$%s, %s$%s, alternative = '%s', conf.level = %s, var.equal = %s)",
                   dataset, first, dataset, second, alternative,
                   numbu_num(level, "Confidence level"),
                   if (isTRUE(equal_variance)) "TRUE" else "FALSE"))
  }
  stop("Unknown t-test kind.")
}

build_z_test <- function(kind, dataset, response, group = "", first = "",
                         second = "", mu = 0, sigma = 1, level = 0.95,
                         alternative = "two.sided") {
  if (identical(kind, "single")) {
    return(paste(
      "local({",
      sprintf("  .x <- na.omit(%s$%s)", dataset, response),
      sprintf("  .z <- (mean(.x) - %s) / (%s / sqrt(length(.x)))",
              numbu_num(mu, "Null mean"), numbu_num(sigma, "Sigma")),
      sprintf("  .p <- switch('%s', two.sided = 2 * pnorm(-abs(.z)), less = pnorm(.z), greater = pnorm(.z, lower.tail = FALSE))",
              alternative),
      "  c(statistic = .z, p.value = .p)",
      "})",
      sep = "\n"
    ))
  }
  if (identical(kind, "paired")) {
    return(paste(
      "local({",
      sprintf("  .x <- na.omit(%s$%s - %s$%s)", dataset, first, dataset, second),
      sprintf("  .z <- (mean(.x) - %s) / (%s / sqrt(length(.x)))",
              numbu_num(mu, "Null mean"), numbu_num(sigma, "Sigma")),
      sprintf("  .p <- switch('%s', two.sided = 2 * pnorm(-abs(.z)), less = pnorm(.z), greater = pnorm(.z, lower.tail = FALSE))",
              alternative),
      "  c(statistic = .z, p.value = .p)",
      "})",
      sep = "\n"
    ))
  }
  if (identical(kind, "unstacked")) {
    return(paste(
      "local({",
      sprintf("  .x <- na.omit(%s$%s); .y <- na.omit(%s$%s)",
              dataset, first, dataset, second),
      sprintf("  .z <- (mean(.x) - mean(.y) - %s) / sqrt(%s^2 / length(.x) + %s^2 / length(.y))",
              numbu_num(mu, "Null difference"), numbu_num(sigma, "Sigma"),
              numbu_num(sigma, "Sigma")),
      sprintf("  .p <- switch('%s', two.sided = 2 * pnorm(-abs(.z)), less = pnorm(.z), greater = pnorm(.z, lower.tail = FALSE))",
              alternative),
      "  c(statistic = .z, p.value = .p)",
      "})",
      sep = "\n"
    ))
  }
  if (identical(kind, "summarized")) {
    return(paste(
      "local({",
      sprintf("  .z <- (mean - %s) / (%s / sqrt(n))", numbu_num(mu, "Null mean"),
              numbu_num(sigma, "Sigma")),
      sprintf("  .p <- switch('%s', two.sided = 2 * pnorm(-abs(.z)), less = pnorm(.z), greater = pnorm(.z, lower.tail = FALSE))",
              alternative),
      "  c(statistic = .z, p.value = .p)",
      "})",
      sep = "\n"
    ))
  }
  stop("Unknown z-test kind.")
}

build_t_summary <- function(mean, sd, n, mu = 0, level = 0.95,
                            alternative = "two.sided") {
  paste(
    "local({",
    sprintf("  .mean <- %s; .sd <- %s; .n <- %d", numbu_num(mean, "Mean"),
            numbu_num(sd, "SD"), as.integer(numbu_num(n, "N"))),
    sprintf("  .t <- (.mean - %s) / (.sd / sqrt(.n))", numbu_num(mu, "Null mean")),
    "  .df <- .n - 1",
    sprintf("  .p <- switch('%s', two.sided = 2 * pt(-abs(.t), .df), less = pt(.t, .df), greater = pt(.t, .df, lower.tail = FALSE))",
            alternative),
    "  c(statistic = .t, df = .df, p.value = .p)",
    "})",
    sep = "\n"
  )
}

build_proportion <- function(successes, sample_size, p0 = 0.5,
                             alternative = "two.sided", level = 0.95) {
  sprintf("prop.test(%d, %d, p = %s, alternative = '%s', conf.level = %s, correct = FALSE)",
          as.integer(numbu_num(successes, "Successes")),
          as.integer(numbu_num(sample_size, "Sample size")),
          numbu_num(p0, "Null proportion"), alternative,
          numbu_num(level, "Confidence level"))
}

build_two_proportion <- function(s1, n1, s2, n2, alternative = "two.sided",
                                 level = 0.95) {
  sprintf("prop.test(c(%d, %d), c(%d, %d), alternative = '%s', conf.level = %s, correct = FALSE)",
          as.integer(numbu_num(s1, "Successes 1")),
          as.integer(numbu_num(s2, "Successes 2")),
          as.integer(numbu_num(n1, "Sample size 1")),
          as.integer(numbu_num(n2, "Sample size 2")),
          alternative, numbu_num(level, "Confidence level"))
}

build_power_t <- function(delta = 0.5, sd = 1, n = 30, alpha = 0.05,
                          type = "two.sample") {
  sprintf("power.t.test(delta = %s, sd = %s, n = %d, sig.level = %s, type = '%s')",
          numbu_num(delta, "Delta"), numbu_num(sd, "SD"),
          as.integer(numbu_num(n, "N")), numbu_num(alpha, "Alpha"), type)
}

build_anova_nmbu <- function(dataset, response, factors, interaction = TRUE) {
  rhs <- if (isTRUE(interaction)) paste(factors, collapse = " * ") else {
    paste(factors, collapse = " + ")
  }
  c(
    sprintf(".model <- aov(%s ~ %s, data = %s)", response, rhs, dataset),
    "summary(.model)"
  )
}

build_pls <- function(dataset, response, predictors, components = 2) {
  if (length(predictors) == 0L) stop("Select at least one predictor.")
  c(
    sprintf(".pls <- pls::plsr(%s ~ %s, data = %s, ncomp = %d)",
            response, paste(predictors, collapse = " + "), dataset,
            as.integer(components)),
    "summary(.pls)"
  )
}

build_stepwise <- function(model, direction = "both", criterion = "AIC") {
  c(
    sprintf(".stepwise <- MASS::stepAIC(%s, direction = '%s')", model, direction),
    "summary(.stepwise)"
  )
}

build_prediction <- function(model, dataset) {
  sprintf("%s$fitted.%s <- predict(%s, %s)", dataset, model, model, dataset)
}

build_coefficients <- function(model) {
  c(sprintf("coef(%s)", model), sprintf("confint(%s)", model))
}
