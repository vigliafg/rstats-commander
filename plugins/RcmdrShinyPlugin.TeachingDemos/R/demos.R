# Teaching demonstration commands ---------------------------------------

demo_number <- function(value, default, min = NULL, max = NULL, name = "value") {
  number <- suppressWarnings(as.numeric(value))
  if (length(number) == 0L || is.na(number)) {
    stop(sprintf("%s must be a number.", name), call. = FALSE)
  }
  if (!is.null(min) && number < min) {
    stop(sprintf("%s must be at least %s.", name, min), call. = FALSE)
  }
  if (!is.null(max) && number > max) {
    stop(sprintf("%s must be at most %s.", name, max), call. = FALSE)
  }
  number
}

build_clt_command <- function(distribution = "normal", n = 30L,
                              reps = 1000L, statistic = "mean") {
  n <- as.integer(demo_number(n, 30L, 1))
  reps <- as.integer(demo_number(reps, 1000L, 10))
  generator <- switch(
    distribution,
    normal = "rnorm(.n)",
    uniform = "runif(.n)",
    exponential = "rexp(.n)",
    stop("Unknown distribution.", call. = FALSE)
  )
  fun <- if (identical(statistic, "sum")) "sum" else "mean"
  paste(
    "local({",
    sprintf("  .n <- %d", n),
    sprintf("  .reps <- %d", reps),
    sprintf("  .stat <- replicate(.reps, %s(%s))", fun, generator),
    '  hist(.stat, col="lightblue", border="white", main="Central limit theorem",',
    '       xlab=paste("Sample", .stat))',
    "  abline(v = mean(.stat), col = 2, lwd = 2)",
    "})",
    sep = "\n"
  )
}

build_ci_simulation_command <- function(mean = 0, sd = 1, n = 30L,
                                        level = 0.95, reps = 100L) {
  n <- as.integer(demo_number(n, 30L, 2))
  reps <- as.integer(demo_number(reps, 100L, 10))
  level <- demo_number(level, 0.95, 0.01, 0.999)
  paste(
    "local({",
    sprintf("  .mean <- %s", mean),
    sprintf("  .sd <- %s", sd),
    sprintf("  .n <- %d", n),
    sprintf("  .level <- %s", level),
    sprintf("  .reps <- %d", reps),
    "  .intervals <- t(replicate(.reps, {",
    "    .x <- rnorm(.n, mean = .mean, sd = .sd)",
    "    .test <- t.test(.x, conf.level = .level)$conf.int",
    "    .test",
    "  }))",
    "  .cover <- .intervals[, 1] <= .mean & .mean <= .intervals[, 2]",
    "  plot(NA, xlim = range(.intervals), ylim = c(1, .reps),",
    '       xlab = "Confidence interval", ylab = "Replicate")',
    "  segments(.intervals[, 1], seq_len(.reps), .intervals[, 2], seq_len(.reps),",
    "           col = ifelse(.cover, 1, 2))",
    "  abline(v = .mean, col = 4, lty = 2)",
    "})",
    sep = "\n"
  )
}

build_power_command <- function(effect = 0.5, n = 30L, alpha = 0.05,
                                alternative = "two.sided") {
  n <- as.integer(demo_number(n, 30L, 2))
  alpha <- demo_number(alpha, 0.05, 0.001, 0.5)
  effect <- demo_number(effect, 0.5, 0.01)
  paste(
    "local({",
    sprintf("  .effect <- %s", effect),
    sprintf("  .n <- %d", n),
    sprintf("  .alpha <- %s", alpha),
    sprintf("  .alternative <- '%s'", alternative),
    "  .sizes <- seq(5, max(10, 3 * .n), by = 5)",
    "  .power <- sapply(.sizes, function(.n) {",
    "    .crit <- qt(1 - .alpha / 2, df = .n - 1)",
    "    .ncp <- .effect * sqrt(.n)",
    "    1 - pt(.crit, df = .n - 1, ncp = .ncp) + pt(-.crit, df = .n - 1, ncp = .ncp)",
    "  })",
    '  plot(.sizes, .power, type = "l", lwd = 2, col = 4,',
    '       xlab = "Sample size", ylab = "Power", main = "Power of the one-sample t test")',
    "  abline(h = 0.8, lty = 2, col = 2)",
    "})",
    sep = "\n"
  )
}

build_coin_command <- function(trials = 100L, prob = 0.5) {
  trials <- as.integer(demo_number(trials, 100L, 1))
  prob <- demo_number(prob, 0.5, 0, 1)
  paste(
    "local({",
    sprintf("  .flips <- rbinom(1, size = %d, prob = %s)", trials, prob),
    '  barplot(c(.flips, %d - .flips), names.arg = c("Heads", "Tails"),',
    '          col = c("gold", "grey70"), main = "Flip a coin")',
    "})",
    sep = "\n"
  )
}

build_die_command <- function(rolls = 100L) {
  rolls <- as.integer(demo_number(rolls, 100L, 1))
  paste(
    "local({",
    sprintf("  .rolls <- sample(1:6, %d, replace = TRUE)", rolls),
    "  .counts <- table(factor(.rolls, levels = 1:6))",
    '  barplot(.counts, col = "lightblue", main = "Roll a die", xlab = "Face")',
    "})",
    sep = "\n"
  )
}

build_regression_demo_command <- function(n = 30L, intercept = 0,
                                          slope = 1, sd = 1) {
  n <- as.integer(demo_number(n, 30L, 3))
  paste(
    "local({",
    sprintf("  .n <- %d", n),
    sprintf("  .intercept <- %s", intercept),
    sprintf("  .slope <- %s", slope),
    sprintf("  .sd <- %s", sd),
    "  .x <- rnorm(.n)",
    "  .y <- .intercept + .slope * .x + rnorm(.n, sd = .sd)",
    "  plot(.x, .y, pch = 19, col = 4, main = 'Simple linear regression',",
    "       xlab = 'x', ylab = 'y')",
    "  abline(lm(.y ~ .x), col = 2, lwd = 2)",
    "})",
    sep = "\n"
  )
}

build_correlation_demo_command <- function(n = 100L, rho = 0.7) {
  n <- as.integer(demo_number(n, 100L, 3))
  rho <- demo_number(rho, 0.7, -0.99, 0.99)
  paste(
    "local({",
    sprintf("  .n <- %d", n),
    sprintf("  .rho <- %s", rho),
    "  .x <- rnorm(.n)",
    "  .y <- .rho * .x + sqrt(1 - .rho^2) * rnorm(.n)",
    "  plot(.x, .y, pch = 19, col = 4, main = paste('Correlation r =', round(cor(.x, .y), 2)),",
    "       xlab = 'x', ylab = 'y')",
    "})",
    sep = "\n"
  )
}

build_distribution_plot_command <- function(family, params = list()) {
  family <- match.arg(family, c("binom", "norm", "t", "gamma"))
  if (identical(family, "binom")) {
    size <- as.integer(demo_number(params$size %||% 10, 10, 1))
    prob <- demo_number(params$prob %||% 0.5, 0.5, 0, 1)
    return(paste(
      "local({",
      sprintf("  .x <- 0:%d", size),
      sprintf("  .p <- dbinom(.x, size = %d, prob = %s)", size, prob),
      '  barplot(.p, names.arg = .x, col = "lightblue",',
      '          main = "Binomial distribution", xlab = "Successes", ylab = "Probability")',
      "})",
      sep = "\n"
    ))
  }
  if (identical(family, "norm")) {
    mean <- demo_number(params$mean %||% 0, 0)
    sd <- demo_number(params$sd %||% 1, 1, 0.001)
    return(paste(
      "local({",
      "  .x <- seq(-4, 4, length.out = 200)",
      sprintf("  .y <- dnorm(.x, mean = %s, sd = %s)", mean, sd),
      '  plot(.x, .y, type = "l", lwd = 2, col = 4,',
      '       main = "Normal distribution", xlab = "x", ylab = "Density")',
      "})",
      sep = "\n"
    ))
  }
  if (identical(family, "t")) {
    df <- demo_number(params$df %||% 5, 5, 1)
    return(paste(
      "local({",
      "  .x <- seq(-5, 5, length.out = 200)",
      sprintf("  .y <- dt(.x, df = %s)", df),
      '  plot(.x, .y, type = "l", lwd = 2, col = 4,',
      sprintf('       main = "t distribution (df = %s)", xlab = "x", ylab = "Density")', df),
      "})",
      sep = "\n"
    ))
  }
  shape <- demo_number(params$shape %||% 2, 2, 0.001)
  rate <- demo_number(params$rate %||% 1, 1, 0.001)
  paste(
    "local({",
    "  .x <- seq(0, qgamma(0.999, shape = ", shape, ", rate = ", rate, "), length.out = 200)",
    sprintf("  .y <- dgamma(.x, shape = %s, rate = %s)", shape, rate),
    '  plot(.x, .y, type = "l", lwd = 2, col = 4,',
    sprintf('       main = "Gamma distribution (shape = %s, rate = %s)", xlab = "x", ylab = "Density")', shape, rate),
    "})",
    sep = "\n"
  )
}
