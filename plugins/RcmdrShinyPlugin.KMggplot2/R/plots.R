# ggplot2 command builders ----------------------------------------------

kmg_quote <- function(value) gsub('"', '\\\\"', paste0(value))

kmg_labs <- function(values) {
  parts <- character()
  if (nzchar(values$xlab %||% "")) {
    parts <- c(parts, sprintf('x = "%s"', kmg_quote(values$xlab)))
  }
  if (nzchar(values$ylab %||% "")) {
    parts <- c(parts, sprintf('y = "%s"', kmg_quote(values$ylab)))
  }
  if (nzchar(values$title %||% "")) {
    parts <- c(parts, sprintf('title = "%s"', kmg_quote(values$title)))
  }
  if (length(parts) == 0L) "" else paste0(" + ggplot2::labs(", paste(parts, collapse = ", "), ")")
}

kmg_facet <- function(values) {
  rows <- values$facet_row %||% ""
  cols <- values$facet_col %||% ""
  if (!nzchar(rows) && !nzchar(cols)) return("")
  parts <- character()
  if (nzchar(rows)) parts <- c(parts, sprintf("rows = ggplot2::vars(%s)", rows))
  if (nzchar(cols)) parts <- c(parts, sprintf("cols = ggplot2::vars(%s)", cols))
  paste0(" + ggplot2::facet_grid(", paste(parts, collapse = ", "), ")")
}

kmg_plot <- function(dataset, mapping, geom, values, extra = "") {
  paste0(
    "ggplot2::ggplot(", dataset, ", ggplot2::aes(", mapping, ")) + ",
    geom, extra, kmg_labs(values), kmg_facet(values),
    " + ggplot2::theme_bw()"
  )
}

build_kmg_histogram <- function(dataset, values) {
  bins <- as.integer(values$bins %||% 30)
  fill <- values$fill %||% "#4C78A8"
  kmg_plot(
    dataset, sprintf("x = %s", values$variable),
    sprintf("ggplot2::geom_histogram(bins = %d, fill = \"%s\", colour = \"white\")",
            bins, kmg_quote(fill)),
    values
  )
}

build_kmg_qq <- function(dataset, values) {
  kmg_plot(
    dataset, sprintf("sample = %s", values$variable),
    "ggplot2::stat_qq() + ggplot2::stat_qq_line(colour = \"red\")",
    values
  )
}

build_kmg_box <- function(dataset, values) {
  type <- values$type %||% "boxplot"
  group <- values$group %||% ""
  y <- values$variable
  mapping <- if (nzchar(group)) {
    sprintf("x = %s, y = %s", group, y)
  } else {
    sprintf("x = \"\", y = %s", y)
  }
  geom <- switch(
    type,
    violin = "ggplot2::geom_violin(fill = \"#4C78A8\", colour = NA)",
    ci = paste0(
      "ggplot2::stat_summary(fun = mean, geom = \"point\", colour = \"red\") + ",
      "ggplot2::stat_summary(fun.data = ggplot2::mean_se, geom = \"errorbar\", width = 0.2)"
    ),
    "ggplot2::geom_boxplot(fill = \"#4C78A8\", colour = \"grey20\")"
  )
  kmg_plot(dataset, mapping, geom, values)
}

build_kmg_scatter <- function(dataset, values) {
  mapping <- sprintf("x = %s, y = %s", values$x, values$y)
  if (nzchar(values$colour %||% "")) {
    mapping <- paste0(mapping, sprintf(", colour = %s", values$colour))
  }
  kmg_plot(dataset, mapping, "ggplot2::geom_point(size = 2, alpha = 0.8)", values)
}

build_kmg_line <- function(dataset, values) {
  mapping <- sprintf("x = %s, y = %s", values$x, values$y)
  if (nzchar(values$colour %||% "")) {
    mapping <- paste0(mapping, sprintf(", colour = %s", values$colour))
  }
  kmg_plot(
    dataset, mapping,
    "ggplot2::geom_line() + ggplot2::geom_point(size = 1.5)",
    values
  )
}

build_kmg_pie <- function(dataset, values) {
  kmg_plot(
    dataset, sprintf("x = \"\", fill = %s", values$variable),
    "ggplot2::geom_bar(width = 1) + ggplot2::coord_polar(\"y\")",
    values
  )
}

build_kmg_bar <- function(dataset, values) {
  kmg_plot(
    dataset, sprintf("x = %s", values$variable),
    "ggplot2::geom_bar(fill = \"#4C78A8\")",
    values
  )
}

build_kmg_contour <- function(dataset, values) {
  mapping <- sprintf("x = %s, y = %s", values$x, values$y)
  if (nzchar(values$z %||% "")) {
    mapping <- paste0(mapping, sprintf(", z = %s", values$z))
  }
  kmg_plot(dataset, mapping, "ggplot2::geom_density_2d()", values)
}

build_kmg_scattermatrix <- function(dataset, values) {
  variables <- values$variables %||% character()
  if (length(variables) < 2L) stop("Select at least two variables.")
  sprintf("pairs(%s[, c(%s)])", dataset,
          paste(sprintf('"%s"', variables), collapse = ", "))
}

build_kmg_km <- function(dataset, values) {
  time <- values$time
  status <- values$status
  group <- values$group %||% ""
  formula <- if (nzchar(group)) {
    sprintf("survival::Surv(%s, %s) ~ %s", time, status, group)
  } else {
    sprintf("survival::Surv(%s, %s) ~ 1", time, status)
  }
  paste(
    "local({",
    sprintf("  .fit <- survival::survfit(%s, data = %s)", formula, dataset),
    "  plot(.fit, col = 1:6, lwd = 2, xlab = 'Time', ylab = 'Survival')",
    "  if (!is.null(.fit$strata)) legend('topright', legend = names(.fit$strata),",
    "                                  col = 1:6, lwd = 2)",
    "})",
    sep = "\n"
  )
}

build_kmg_factorize <- function(dataset, values) {
  variable <- values$variable
  breaks <- as.integer(values$breaks %||% 4)
  new_name <- trimws(values$new_name %||% "")
  if (!nzchar(new_name)) new_name <- paste0(variable, ".f")
  sprintf("%s$%s <- cut(%s$%s, breaks = %d)",
          dataset, new_name, dataset, variable, breaks)
}

kmg_distribution_spec <- list(
  norm = list(fun = "dnorm", args = c("mean", "sd"), limits = "c(-4, 4)", discrete = FALSE),
  t = list(fun = "dt", args = "df", limits = "c(-5, 5)", discrete = FALSE),
  chisq = list(fun = "dchisq", args = "df", limits = NULL, discrete = FALSE),
  f = list(fun = "df", args = c("df1", "df2"), limits = NULL, discrete = FALSE),
  exp = list(fun = "dexp", args = "rate", limits = NULL, discrete = FALSE),
  unif = list(fun = "dunif", args = c("min", "max"), limits = NULL, discrete = FALSE),
  beta = list(fun = "dbeta", args = c("shape1", "shape2"), limits = "c(0, 1)", discrete = FALSE),
  cauchy = list(fun = "dcauchy", args = c("location", "scale"), limits = NULL, discrete = FALSE),
  logis = list(fun = "dlogis", args = c("location", "scale"), limits = NULL, discrete = FALSE),
  lnorm = list(fun = "dlnorm", args = c("meanlog", "sdlog"), limits = NULL, discrete = FALSE),
  gamma = list(fun = "dgamma", args = c("shape", "rate"), limits = NULL, discrete = FALSE),
  weibull = list(fun = "dweibull", args = c("shape", "scale"), limits = NULL, discrete = FALSE),
  binom = list(fun = "dbinom", args = c("size", "prob"), discrete = TRUE),
  pois = list(fun = "dpois", args = "lambda", discrete = TRUE),
  geom = list(fun = "dgeom", args = "prob", discrete = TRUE),
  hyper = list(fun = "dhyper", args = c("m", "n", "k"), discrete = TRUE),
  nbinom = list(fun = "dnbinom", args = c("size", "prob"), discrete = TRUE)
)

kmg_distribution_args <- function(family, values) {
  spec <- kmg_distribution_spec[[family]]
  args <- vapply(spec$args, function(name) {
    sprintf("%s = %s", name, values[[name]])
  }, character(1))
  paste(args, collapse = ", ")
}

build_kmg_distribution <- function(family, values) {
  spec <- kmg_distribution_spec[[family]]
  if (is.null(spec)) stop("Unknown distribution.")
  args <- kmg_distribution_args(family, values)
  if (isTRUE(spec$discrete)) {
    qfun <- paste0("q", family)
    return(paste(
      "local({",
      sprintf("  .x <- 0:max(10, ceiling(%s(0.999, %s)))", qfun, args),
      sprintf("  .p <- %s(.x, %s)", spec$fun, args),
      "  ggplot2::ggplot(data.frame(x = .x, p = .p), ggplot2::aes(x = x, y = p)) +",
      "    ggplot2::geom_col(fill = '#4C78A8') +",
      sprintf("    ggplot2::labs(title = '%s distribution', x = 'x', y = 'Probability') +", family),
      "    ggplot2::theme_bw()",
      "})",
      sep = "\n"
    ))
  }
  limits <- spec$limits
  if (is.null(limits)) {
    limits <- switch(
      family,
      chisq = sprintf("c(0, qchisq(0.999, %s))", args),
      f = sprintf("c(0, qf(0.999, %s))", args),
      exp = sprintf("c(0, qexp(0.999, %s))", args),
      unif = sprintf("c(%s)", args),
      cauchy = "c(-6, 6)",
      logis = "c(-8, 8)",
      lnorm = "c(0, 8)",
      gamma = sprintf("c(0, qgamma(0.999, %s))", args),
      weibull = sprintf("c(0, qweibull(0.999, %s))", args),
      "c(-4, 4)"
    )
  }
  paste(
    "local({",
    sprintf("  .limits <- %s", limits),
    "  ggplot2::ggplot(data.frame(x = .limits), ggplot2::aes(x = x)) +",
    sprintf("    ggplot2::stat_function(fun = stats::%s, args = list(%s), n = 300, colour = '#4C78A8', size = 1) +",
            spec$fun, args),
    sprintf("    ggplot2::labs(title = '%s distribution', x = 'x', y = 'Density') +", family),
    "    ggplot2::theme_bw()",
    "})",
    sep = "\n"
  )
}
