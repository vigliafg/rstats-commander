# Confidence intervals and hypothesis tests ----------------------------

ts_num <- function(value, name = "value") {
  number <- suppressWarnings(as.numeric(value))
  if (length(number) == 0L || is.na(number)) {
    stop(sprintf("%s must be a number.", name), call. = FALSE)
  }
  number
}

ts_level <- function(value) {
  level <- ts_num(value, "Confidence level")
  if (level <= 0 || level >= 1) stop("Confidence level must be between 0 and 1.")
  level
}

ts_ci_mean <- function(dataset, variable, level = 0.95,
                       alternative = "two.sided", known_variance = NULL) {
  x <- sprintf("%s$%s", dataset, variable)
  if (is.null(known_variance) || !nzchar(known_variance)) {
    return(sprintf("t.test(%s, conf.level = %s, alternative = '%s')",
                   x, ts_level(level), alternative))
  }
  variance <- ts_num(known_variance, "Known variance")
  paste(
    "local({",
    sprintf("  .x <- na.omit(%s)", x),
    "  .n <- length(.x)",
    sprintf("  .se <- sqrt(%s / .n)", variance),
    sprintf("  .level <- %s", ts_level(level)),
    sprintf("  .alternative <- '%s'", alternative),
    "  .alpha <- 1 - .level",
    '  .z <- if (.alternative == "two.sided") qnorm(1 - .alpha / 2) else qnorm(1 - .alpha)',
    '  .lower <- if (.alternative == "less") -Inf else mean(.x) - .z * .se',
    '  .upper <- if (.alternative == "greater") Inf else mean(.x) + .z * .se',
    "  c(lower = .lower, upper = .upper)",
    "})",
    sep = "\n"
  )
}

ts_test_mean <- function(dataset, variable, mu = 0, level = 0.95,
                         alternative = "two.sided", known_variance = NULL) {
  x <- sprintf("%s$%s", dataset, variable)
  mu <- ts_num(mu, "Null mean")
  if (is.null(known_variance) || !nzchar(known_variance)) {
    return(sprintf("t.test(%s, mu = %s, alternative = '%s', conf.level = %s)",
                   x, mu, alternative, ts_level(level)))
  }
  variance <- ts_num(known_variance, "Known variance")
  paste(
    "local({",
    sprintf("  .x <- na.omit(%s)", x),
    "  .n <- length(.x)",
    sprintf("  .z <- (mean(.x) - %s) / sqrt(%s / .n)", mu, variance),
    sprintf("  .alternative <- '%s'", alternative),
    '  .p <- switch(.alternative,',
    '    two.sided = 2 * pnorm(-abs(.z)),',
    '    less = pnorm(.z),',
    '    greater = pnorm(.z, lower.tail = FALSE))',
    "  c(statistic = .z, p.value = .p)",
    "})",
    sep = "\n"
  )
}

ts_ci_variance <- function(dataset, variable, level = 0.95) {
  x <- sprintf("%s$%s", dataset, variable)
  paste(
    "local({",
    sprintf("  .x <- na.omit(%s)", x),
    "  .n <- length(.x)",
    "  .df <- .n - 1",
    sprintf("  .alpha <- 1 - %s", ts_level(level)),
    "  c(lower = .df * var(.x) / qchisq(1 - .alpha / 2, .df),",
    "    upper = .df * var(.x) / qchisq(.alpha / 2, .df))",
    "})",
    sep = "\n"
  )
}

ts_test_variance <- function(dataset, variable, sigma2 = 1, level = 0.95,
                             alternative = "two.sided") {
  x <- sprintf("%s$%s", dataset, variable)
  sigma2 <- ts_num(sigma2, "Null variance")
  paste(
    "local({",
    sprintf("  .x <- na.omit(%s)", x),
    "  .n <- length(.x)",
    "  .stat <- (.n - 1) * var(.x) / ", sigma2,
    sprintf("  .alternative <- '%s'", alternative),
    '  .p <- switch(.alternative,',
    '    two.sided = 2 * min(pchisq(.stat, .n - 1), pchisq(.stat, .n - 1, lower.tail = FALSE)),',
    '    less = pchisq(.stat, .n - 1),',
    '    greater = pchisq(.stat, .n - 1, lower.tail = FALSE))',
    "  c(statistic = .stat, df = .n - 1, p.value = .p)",
    "})",
    sep = "\n"
  )
}

ts_ci_proportion <- function(successes, trials, level = 0.95) {
  sprintf("prop.test(%d, %d, conf.level = %s, correct = FALSE)",
          as.integer(successes), as.integer(trials), ts_level(level))
}

ts_test_proportion <- function(successes, trials, p0 = 0.5, level = 0.95,
                               alternative = "two.sided") {
  sprintf("prop.test(%d, %d, p = %s, alternative = '%s', conf.level = %s, correct = FALSE)",
          as.integer(successes), as.integer(trials), ts_num(p0, "Null proportion"),
          alternative, ts_level(level))
}

ts_ci_independent_means <- function(dataset, response, group, level = 0.95,
                                    equal_variance = FALSE) {
  sprintf("t.test(%s ~ %s, data = %s, conf.level = %s, var.equal = %s)",
          response, group, dataset, ts_level(level),
          if (isTRUE(equal_variance)) "TRUE" else "FALSE")
}

ts_test_independent_means <- function(dataset, response, group, mu = 0,
                                      level = 0.95, alternative = "two.sided",
                                      equal_variance = FALSE) {
  sprintf("t.test(%s ~ %s, data = %s, mu = %s, alternative = '%s', conf.level = %s, var.equal = %s)",
          response, group, dataset, ts_num(mu, "Null difference"),
          alternative, ts_level(level),
          if (isTRUE(equal_variance)) "TRUE" else "FALSE")
}

ts_ci_paired <- function(dataset, first, second, level = 0.95) {
  sprintf("t.test(%s$%s, %s$%s, paired = TRUE, conf.level = %s)",
          dataset, first, dataset, second, ts_level(level))
}

ts_test_paired <- function(dataset, first, second, mu = 0, level = 0.95,
                           alternative = "two.sided") {
  sprintf("t.test(%s$%s, %s$%s, paired = TRUE, mu = %s, alternative = '%s', conf.level = %s)",
          dataset, first, dataset, second, ts_num(mu, "Null difference"),
          alternative, ts_level(level))
}

ts_ci_variance_ratio <- function(dataset, response, group, level = 0.95) {
  sprintf("var.test(%s ~ %s, data = %s, conf.level = %s)",
          response, group, dataset, ts_level(level))
}

ts_test_variance_ratio <- function(dataset, response, group, level = 0.95,
                                   alternative = "two.sided") {
  sprintf("var.test(%s ~ %s, data = %s, alternative = '%s', conf.level = %s)",
          response, group, dataset, alternative, ts_level(level))
}

ts_ci_diff_proportions <- function(successes1, trials1, successes2, trials2,
                                   level = 0.95) {
  sprintf("prop.test(c(%d, %d), c(%d, %d), conf.level = %s, correct = FALSE)",
          as.integer(successes1), as.integer(successes2),
          as.integer(trials1), as.integer(trials2), ts_level(level))
}

ts_test_diff_proportions <- function(successes1, trials1, successes2, trials2,
                                     level = 0.95,
                                     alternative = "two.sided") {
  sprintf("prop.test(c(%d, %d), c(%d, %d), alternative = '%s', conf.level = %s, correct = FALSE)",
          as.integer(successes1), as.integer(successes2),
          as.integer(trials1), as.integer(trials2), alternative,
          ts_level(level))
}

ts_randomness_factor <- function(dataset, variable) {
  sprintf("with(%s, tseries::runs.test(%s))", dataset, variable)
}

ts_randomness_numeric <- function(dataset, variable) {
  sprintf("with(%s, randtests::runs.test(%s))", dataset, variable)
}
