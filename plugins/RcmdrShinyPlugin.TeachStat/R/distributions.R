# Random-variable command builders --------------------------------------

ts_distr_specs <- list(
  normal = list(fun = "norm", params = c(mean = 0, sd = 1), discrete = FALSE),
  t = list(fun = "t", params = c(df = 5), discrete = FALSE),
  chisq = list(fun = "chisq", params = c(df = 5), discrete = FALSE),
  F = list(fun = "f", params = c(df1 = 5, df2 = 10), discrete = FALSE),
  exponential = list(fun = "exp", params = c(rate = 1), discrete = FALSE),
  uniform = list(fun = "unif", params = c(min = 0, max = 1), discrete = FALSE),
  binomial = list(fun = "binom", params = c(size = 10, prob = 0.5), discrete = TRUE),
  Poisson = list(fun = "pois", params = c(lambda = 3), discrete = TRUE),
  geometric = list(fun = "geom", params = c(prob = 0.3), discrete = TRUE),
  negbinomial = list(fun = "nbinom", params = c(size = 5, prob = 0.5), discrete = TRUE)
)

ts_args <- function(params) {
  paste(vapply(names(params), function(name) {
    sprintf("%s = %s", name, params[[name]])
  }, character(1)), collapse = ", ")
}

ts_call <- function(prefix, family, params, arguments = "") {
  spec <- ts_distr_specs[[family]]
  fun <- paste0(prefix, spec$fun)
  args <- ts_args(params)
  suffix <- if (nzchar(arguments)) paste0(", ", arguments) else ""
  sprintf("%s(%s)", fun, paste0(args, suffix))
}

ts_quantiles <- function(family, params, probs = "c(0.025, 0.5, 0.975)") {
  spec <- ts_distr_specs[[family]]
  sprintf("q%s(%s, %s)", spec$fun, probs, ts_args(params))
}

ts_probabilities <- function(family, params, values = "c(0, 1)",
                             lower_tail = TRUE) {
  spec <- ts_distr_specs[[family]]
  sprintf("p%s(%s, %s, lower.tail = %s)", spec$fun, values,
          ts_args(params), if (isTRUE(lower_tail)) "TRUE" else "FALSE")
}

ts_mass <- function(family, params, values = "0:10") {
  spec <- ts_distr_specs[[family]]
  sprintf("d%s(%s, %s)", spec$fun, values, ts_args(params))
}

ts_plot <- function(family, params) {
  spec <- ts_distr_specs[[family]]
  args <- ts_args(params)
  if (isTRUE(spec$discrete)) {
    paste(
      "local({",
      sprintf("  .x <- 0:max(10, ceiling(q%s(0.999, %s)))", spec$fun, args),
      sprintf("  .y <- d%s(.x, %s)", spec$fun, args),
      '  plot(.x, .y, type = "h", lwd = 2, col = 4,',
      sprintf('       main = "%s distribution", xlab = "x", ylab = "Probability")', family),
      "})",
      sep = "\n"
    )
  } else {
    paste(
      "local({",
      sprintf("  .x <- seq(q%s(0.001, %s), q%s(0.999, %s), length.out = 300)",
              spec$fun, args, spec$fun, args),
      sprintf("  .y <- d%s(.x, %s)", spec$fun, args),
      '  plot(.x, .y, type = "l", lwd = 2, col = 4,',
      sprintf('       main = "%s distribution", xlab = "x", ylab = "Density")', family),
      "})",
      sep = "\n"
    )
  }
}

ts_characteristics <- function(family, params) {
  spec <- ts_distr_specs[[family]]
  paste(
    "local({",
    sprintf("  .sample <- r%s(10000, %s)", spec$fun, ts_args(params)),
    "  c(mean = mean(.sample), variance = var(.sample), sd = sd(.sample))",
    "})",
    sep = "\n"
  )
}

ts_samples <- function(family, params, n = 30, seed = "") {
  spec <- ts_distr_specs[[family]]
  call <- sprintf("r%s(%d, %s)", spec$fun, as.integer(n), ts_args(params))
  if (nzchar(seed)) {
    paste(sprintf("set.seed(%s)", seed), call, sep = "\n")
  } else {
    call
  }
}
