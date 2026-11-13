# Command generation for the Graphs and Distributions menus -----------------

# Graphs --------------------------------------------------------------------

#' @keywords internal
cmd_index_plot <- function(dataset, variables, type = "h") {
  vars <- if (length(variables) == 1L) {
    paste0('"', variables, '"')
  } else {
    paste0("c(", paste0('"', variables, '"', collapse = ","), ")")
  }
  paste0("indexplot(", dataset, "[,", vars, ", drop=FALSE], type='", type, "')")
}

#' @keywords internal
cmd_histogram <- function(dataset, variable, groups = NULL,
                          scale = "frequency", breaks = "Sturges") {
  if (is.null(groups)) {
    paste0("with(", dataset, ", Hist(", variable, ', scale="', scale,
           '", breaks="', breaks, '"))')
  } else {
    paste0("with(", dataset, ", Hist(", variable, ", groups=", groups,
           ', scale="', scale, '", breaks="', breaks, '"))')
  }
}

#' @keywords internal
cmd_stem_leaf <- function(dataset, variable) {
  paste0("with(", dataset, ", stem.leaf(", variable, "))")
}

#' @keywords internal
cmd_boxplot <- function(dataset, variables, response = NULL, group = NULL) {
  if (!is.null(group) && nzchar(group)) {
    paste0("Boxplot(", response %||% variables[[1L]], " ~ ", group,
           ", data=", dataset, ', id=list(method="y"))')
  } else {
    paste0("Boxplot(~ ", paste(variables, collapse = " + "), ", data=", dataset,
           ', id=list(method="y"))')
  }
}

#' @keywords internal
cmd_dotplot <- function(dataset, variable, groups = NULL) {
  if (is.null(groups)) {
    paste0("with(", dataset, ", Dotplot(", variable, ", bin=FALSE))")
  } else {
    paste0("with(", dataset, ", Dotplot(", variable, ", by=", groups,
           ", bin=FALSE))")
  }
}

#' @keywords internal
cmd_scatterplot <- function(dataset, x, y, groups = NULL,
                            smooth = FALSE, boxplots = FALSE, log = "") {
  extras <- paste0(
    if (isTRUE(smooth)) ', smooth=TRUE' else "",
    ", boxplots=", isTRUE(boxplots),
    if (nzchar(log)) paste0(', log="', log, '"') else ""
  )
  if (is.null(groups)) {
    paste0("scatterplot(", y, "~", x, ", data=", dataset, extras, ")")
  } else {
    paste0("scatterplot(", y, "~", x, " | ", groups, ", data=", dataset,
           extras, ")")
  }
}

#' @keywords internal
cmd_scatterplot_matrix <- function(dataset, variables, smooth = TRUE,
                                   density = TRUE) {
  paste0("scatterplotMatrix(~", paste(variables, collapse = "+"),
         ", data=", dataset, ", smooth=", isTRUE(smooth),
         ", density=", isTRUE(density), ")")
}

#' @keywords internal
cmd_barplot <- function(dataset, variable, groups = NULL) {
  if (is.null(groups)) {
    paste0("with(", dataset, ", Barplot(", variable, "))")
  } else {
    paste0("with(", dataset, ", Barplot(", variable, ", by=", groups, "))")
  }
}

#' @keywords internal
cmd_piechart <- function(dataset, variable) {
  paste0("with(", dataset, ", piechart(", variable, "))")
}

#' @keywords internal
cmd_lineplot <- function(dataset, x, y) {
  paste0("with(", dataset, ", lineplot(", x, ", ", paste(y, collapse = ", "),
         "))")
}

#' @keywords internal
cmd_qqplot <- function(dataset, variable, groups = NULL) {
  if (is.null(groups)) {
    paste0("with(", dataset, ", qqPlot(", variable, "))")
  } else {
    paste0("with(", dataset, ", qqPlot(", variable, " ~ ", groups, "))")
  }
}

#' @keywords internal
cmd_plot_means <- function(dataset, response, group,
                           error_bars = "se", legend = TRUE) {
  paste0("with(", dataset, ", plotMeans(", response, ", ", group,
         ', error.bars="', error_bars, '", legend=', isTRUE(legend), "))")
}

#' @keywords internal
cmd_scatter3d <- function(dataset, y, x1, x2, groups = NULL) {
  if (is.null(groups)) {
    paste0("scatter3d(", y, "~", x1, "+", x2, ", data=", dataset, ")")
  } else {
    paste0("scatter3d(", y, "~", x1, "+", x2, "|", groups,
           ", data=", dataset, ")")
  }
}

#' @keywords internal
cmd_xyplot <- function(dataset, x, y, groups = NULL, type = "p",
                       layout = NULL) {
  layout_code <- if (is.null(layout) || !nzchar(layout)) "" else
    paste0(", layout=c(", layout, ")")
  if (is.null(groups)) {
    paste0("xyplot(", y, " ~ ", x, ", data=", dataset, ', type="', type,
           '"', layout_code, ")")
  } else {
    paste0("xyplot(", y, " ~ ", x, " | ", groups, ", data=", dataset,
           ', type="', type, '"', layout_code, ")")
  }
}

#' @keywords internal
cmd_stripchart <- function(dataset, response, groups = NULL,
                           method = "stack") {
  if (is.null(groups)) {
    paste0("stripchart(", dataset, "$", response, ', method="', method, '")')
  } else {
    paste0("stripchart(", response, " ~ ", groups, ", data=", dataset,
           ', method="', method, '")')
  }
}

#' @keywords internal
cmd_density_plot <- function(dataset, variable, groups = NULL, bw = "") {
  bw_code <- if (nzchar(bw)) paste0(", bw=", bw) else ""
  if (is.null(groups)) {
    paste0("densityPlot(~ ", variable, ", data=", dataset, bw_code, ")")
  } else {
    paste0("densityPlot(", variable, "~", groups, ", data=", dataset,
           bw_code, ")")
  }
}

#' @keywords internal
cmd_discrete_plot <- function(dataset, variable, groups = NULL) {
  if (is.null(groups)) {
    paste0("with(", dataset, ", discretePlot(", variable, "))")
  } else {
    paste0("with(", dataset, ", discretePlot(", variable, ", by=", groups, "))")
  }
}

#' @keywords internal
cmd_symbox <- function(dataset, variable) {
  paste0("with(", dataset, ", symbox(", variable, "))")
}

#' @keywords internal
cmd_set_palette <- function(colors) {
  paste0('palette(c("', paste(colors, collapse = '", "'), '"))')
}

#' @keywords internal
cmd_set_seed <- function(seed) {
  paste0("set.seed(", as.integer(seed), ")")
}

# Distributions -------------------------------------------------------------

distribution_info <- function(name) {
  info <- switch(
    name,
    normal = list(title = "Normal", fun = "norm",
                  params = list(list("mean", "Mean", "0"),
                                list("sd", "Standard deviation", "1")),
                  discrete = FALSE),
    t = list(title = "t", fun = "t",
             params = list(list("df", "Degrees of freedom", "")),
             discrete = FALSE),
    chisq = list(title = "ChiSquared", fun = "chisq",
                 params = list(list("df", "Degrees of freedom", "")),
                 discrete = FALSE),
    F = list(title = "F", fun = "f",
             params = list(list("df1", "Numerator degrees of freedom", ""),
                           list("df2", "Denominator degrees of freedom", "")),
             discrete = FALSE),
    exponential = list(title = "Exponential", fun = "exp",
                       params = list(list("rate", "Rate", "1")),
                       discrete = FALSE),
    uniform = list(title = "Uniform", fun = "unif",
                   params = list(list("min", "Minimum", "0"),
                                 list("max", "Maximum", "1")),
                   discrete = FALSE),
    beta = list(title = "Beta", fun = "beta",
                params = list(list("shape1", "Shape 1", ""),
                              list("shape2", "Shape 2", "")),
                discrete = FALSE),
    Cauchy = list(title = "Cauchy", fun = "cauchy",
                  params = list(list("location", "Location", "0"),
                                list("scale", "Scale", "1")),
                  discrete = FALSE),
    logistic = list(title = "Logistic", fun = "logis",
                    params = list(list("location", "Location", "0"),
                                  list("scale", "Scale", "1")),
                    discrete = FALSE),
    lognormal = list(title = "Lognormal", fun = "lnorm",
                     params = list(list("meanlog", "Mean (log scale)", "0"),
                                   list("sdlog", "Standard deviation (log scale)", "1")),
                     discrete = FALSE),
    gamma = list(title = "Gamma", fun = "gamma",
                 params = list(list("shape", "Shape", ""),
                               list("scale", "Scale (inverse rate)", "1")),
                 discrete = FALSE),
    Weibull = list(title = "Weibull", fun = "weibull",
                   params = list(list("shape", "Shape", ""),
                                 list("scale", "Scale", "1")),
                   discrete = FALSE),
    binomial = list(title = "Binomial", fun = "binom",
                    params = list(list("size", "Size", ""),
                                  list("prob", "Probability of success", "0.5")),
                    discrete = TRUE),
    Poisson = list(title = "Poisson", fun = "pois",
                   params = list(list("lambda", "Mean", "1")),
                   discrete = TRUE),
    geom = list(title = "Geometric", fun = "geom",
                params = list(list("prob", "Probability of success", "0.5")),
                discrete = TRUE),
    hyper = list(title = "Hypergeometric", fun = "hyper",
                 params = list(list("m", "Number of white balls", "1"),
                               list("n", "Number of black balls", "1"),
                               list("k", "Number of balls drawn", "1")),
                 discrete = TRUE),
    negbinomial = list(title = "NegativeBinomial", fun = "nbinom",
                       params = list(list("size", "Target number of successes", "1"),
                                     list("prob", "Probability of success", "0.5")),
                       discrete = TRUE),
    NULL
  )
  info
}

distribution_menu_names <- function() {
  c("normal", "t", "chisq", "F", "exponential", "uniform", "beta", "Cauchy",
    "logistic", "lognormal", "gamma", "Weibull", "binomial", "Poisson",
    "geom", "hyper", "negbinomial")
}

#' @keywords internal
cmd_distribution_quantiles <- function(name, probabilities, params,
                                       lower_tail = TRUE) {
  info <- distribution_info(name)
  param_code <- paste0(
    paste0(names(params), "=", unlist(params), collapse = ", ")
  )
  paste0("q", info$fun, "(c(", paste(probabilities, collapse = ","), "), ",
         param_code, ", lower.tail=", isTRUE(lower_tail), ")")
}

#' @keywords internal
cmd_distribution_probabilities <- function(name, values, params,
                                           lower_tail = TRUE) {
  info <- distribution_info(name)
  param_code <- paste0(
    paste0(names(params), "=", unlist(params), collapse = ", ")
  )
  paste0("p", info$fun, "(c(", paste(values, collapse = ","), "), ",
         param_code, ", lower.tail=", isTRUE(lower_tail), ")")
}

#' @keywords internal
cmd_distribution_mass <- function(name, x, params) {
  info <- distribution_info(name)
  param_code <- paste0(
    paste0(names(params), "=", unlist(params), collapse = ", ")
  )
  paste0("d", info$fun, "(c(", paste(x, collapse = ","), "), ",
         param_code, ")")
}

#' @keywords internal
cmd_distribution_plot <- function(name, params, type = "density",
                                  from = NULL, to = NULL) {
  info <- distribution_info(name)
  param_code <- paste0(
    paste0(names(params), "=", unlist(params), collapse = ", ")
  )
  if (isTRUE(info$discrete)) {
    to_value <- if (is.null(to) || !nzchar(to)) from else to
    x <- if (is.null(from) || !nzchar(from)) "0:20" else
      paste0(as.integer(from), ":", as.integer(to_value))
    if (identical(type, "density")) {
      paste0("plot(", x, ", d", info$fun, "(", x, ", ", param_code,
             '), type="h", xlab="x", ylab="Density")')
    } else {
      paste0("plot(", x, ", p", info$fun, "(", x, ", ", param_code,
             '), type="s", xlab="x", ylab="Cumulative Probability")')
    }
  } else {
    fn <- if (identical(type, "density")) paste0("d", info$fun) else
      paste0("p", info$fun)
    from_code <- if (is.null(from) || !nzchar(from)) "" else
      paste0(", from=", from, ", to=", to)
    paste0('curve(', fn, '(x, ', param_code, ')', from_code,
           ', xlab="x", ylab="', if (identical(type, "density")) "Density" else "Cumulative Probability",
           '")')
  }
}

#' @keywords internal
cmd_distribution_samples <- function(name, params, dataset,
                                     n = 100L, samples = 1L,
                                     summaries = character()) {
  info <- distribution_info(name)
  param_code <- paste0(
    paste0(names(params), "=", unlist(params), collapse = ", ")
  )
  n <- as.integer(n)
  samples <- as.integer(samples)
  commands <- c(
    paste0(dataset, " <- as.data.frame(matrix(r", info$fun, "(",
           samples * n, ", ", param_code, "), ncol=", n, "))"),
    if (samples == 1L) {
      paste0('rownames(', dataset, ') <- "sample"')
    } else {
      paste0('rownames(', dataset, ') <- paste("sample", 1:', samples, ', sep="")')
    },
    if (n == 1L) {
      paste0('colnames(', dataset, ') <- "obs"')
    } else {
      paste0('colnames(', dataset, ') <- paste("obs", 1:', n, ', sep="")')
    }
  )
  if (length(summaries) > 0L) {
    block <- paste0(dataset, " <- within(", dataset, ", {\n")
    if ("mean" %in% summaries) {
      block <- paste0(block, "  mean <- rowMeans(", dataset, "[,1:", n, "])\n")
    }
    if ("sd" %in% summaries) {
      block <- paste0(block, "  sd <- apply(", dataset, "[,1:", n,
                      "], 1, sd)\n")
    }
    commands <- c(commands, paste0(block, "})"))
  }
  commands
}
