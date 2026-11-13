# Remaining NMBU dialogs ----------------------------------------------------
#
# The NMBU course menu exposes data utilities, z-tests on summarized data,
# multivariate methods and model diagnostics that the core does not provide.
# Each builder is pure; the dialogs only translate input values.

nb_num <- function(value, what) {
  number <- suppressWarnings(as.numeric(value))
  if (length(number) == 0L || is.na(number)) {
    stop(sprintf("%s must be a number.", what))
  }
  number
}

nb_model <- function(state) {
  model <- RcmdrShiny::active_model(state)
  if (is.null(model)) stop("Fit a model first and make it active.")
  model
}

nb_vars <- function(values, name) {
  selected <- values[[name]]
  if (is.null(selected)) character() else selected[nzchar(selected)]
}

nb_vector <- function(text, what) {
  values <- suppressWarnings(as.numeric(trimws(strsplit(
    as.character(text), ",", fixed = TRUE
  )[[1L]])))
  if (length(values) == 0L || anyNA(values)) {
    stop(sprintf("Enter the %s as comma-separated numbers.", what))
  }
  values
}

# -- data -------------------------------------------------------------------

nb_sequence <- function(from, to, by, name) {
  if (!nzchar(name)) stop("The data set name is required.")
  by <- nb_num(by, "Step")
  if (by == 0) stop("The step cannot be zero.")
  sprintf("%s <- data.frame(x = seq(%s, %s, by = %s))",
          name, nb_num(from, "Start"), nb_num(to, "End"), by)
}

nb_mean_center <- function(dataset, variables, suffix = "_c") {
  variables <- variables[nzchar(variables)]
  if (length(variables) == 0L) stop("Choose at least one variable.")
  vapply(variables, function(variable) {
    sprintf("%s$%s%s <- %s$%s - mean(%s$%s, na.rm = TRUE)",
            dataset, variable, suffix, dataset, variable, dataset, variable)
  }, character(1), USE.NAMES = FALSE)
}

# -- summarized z-tests -----------------------------------------------------

nb_z_one_summary <- function(mean, sigma, n, mu = 0,
                             alternative = "two.sided") {
  paste(
    "local({",
    sprintf("  .z <- (%s - %s) / (%s / sqrt(%d))",
            nb_num(mean, "Mean"), nb_num(mu, "Null mean"),
            nb_num(sigma, "Sigma"), as.integer(nb_num(n, "Sample size"))),
    sprintf("  .p <- switch('%s', two.sided = 2 * pnorm(-abs(.z)), less = pnorm(.z), greater = pnorm(.z, lower.tail = FALSE))",
            alternative),
    "  c(statistic = .z, p.value = .p)",
    "})",
    sep = "\n"
  )
}

nb_z_two_summary <- function(mean1, sigma1, n1, mean2, sigma2, n2,
                             alternative = "two.sided") {
  paste(
    "local({",
    sprintf("  .z <- (%s - %s) / sqrt(%s^2 / %d + %s^2 / %d)",
            nb_num(mean1, "Mean 1"), nb_num(mean2, "Mean 2"),
            nb_num(sigma1, "Sigma 1"), as.integer(nb_num(n1, "N 1")),
            nb_num(sigma2, "Sigma 2"), as.integer(nb_num(n2, "N 2"))),
    sprintf("  .p <- switch('%s', two.sided = 2 * pnorm(-abs(.z)), less = pnorm(.z), greater = pnorm(.z, lower.tail = FALSE))",
            alternative),
    "  c(statistic = .z, p.value = .p)",
    "})",
    sep = "\n"
  )
}

# -- statistics -------------------------------------------------------------

nb_covariance <- function(dataset, variables, kind = "cov") {
  variables <- variables[nzchar(variables)]
  if (length(variables) < 2L) stop("Choose at least two variables.")
  fun <- if (identical(kind, "cor")) "cor" else "cov"
  sprintf('with(%s, %s(%s, use = "pairwise.complete.obs"))',
          dataset, fun,
          paste0(dataset, "[, c(", paste0('"', variables, '"', collapse = ", "),
                 ")]"))
}

nb_cluster_variables <- function(dataset, variables, k = 2) {
  variables <- variables[nzchar(variables)]
  if (length(variables) < 2L) stop("Choose at least two variables.")
  paste0(
    "local({\n",
    sprintf("  .d <- scale(%s[, c(%s)])\n", dataset,
            paste0('"', variables, '"', collapse = ", ")),
    "  .fit <- hclust(dist(t(.d)))\n",
    sprintf("  plot(.fit, main = \"Variables\", xlab = \"\", sub = \"\")\n"),
    "  rect.hclust(.fit, k = ", max(2L, as.integer(k)), ")\n",
    "})"
  )
}

nb_relevant_components <- function(dataset, variables, factors = 2) {
  variables <- variables[nzchar(variables)]
  if (length(variables) < 2L) stop("Choose at least two variables.")
  sprintf(paste0(
    'psych::principal(%s[, c(%s)], nfactors = %d, rotate = "varimax")'
  ), dataset, paste0('"', variables, '"', collapse = ", "),
  max(1L, as.integer(factors)))
}

nb_simplex <- function(dataset, response, components) {
  components <- components[nzchar(components)]
  if (length(components) < 2L) stop("Choose at least two components.")
  sprintf("lm(%s ~ 0 + %s, data = %s)", response,
          paste(components, collapse = " + "), dataset)
}

nb_discriminant <- function(dataset, response, predictors, method = "lda") {
  predictors <- predictors[nzchar(predictors)]
  if (!nzchar(response) || length(predictors) == 0L) {
    stop("Choose a response and at least one predictor.")
  }
  function_name <- if (identical(method, "qda")) "MASS::qda" else "MASS::lda"
  sprintf("%s(%s ~ %s, data = %s)", function_name, response,
          paste(predictors, collapse = " + "), dataset)
}

nb_grand_mean <- function(model) {
  sprintf("confint(%s, \"(Intercept)\")", model)
}

nb_da_scores <- function(model) {
  sprintf("predict(%s)$x", model)
}

nb_cluster_list <- function(dataset, variables, k = 2) {
  variables <- variables[nzchar(variables)]
  if (length(variables) < 2L) stop("Choose at least two variables.")
  paste0(
    "local({\n",
    sprintf("  .d <- scale(%s[, c(%s)])\n", dataset,
            paste0('"', variables, '"', collapse = ", ")),
    "  .fit <- hclust(dist(.d))\n",
    sprintf("  .groups <- cutree(.fit, k = %d)\n", max(2L, as.integer(k))),
    sprintf("  %s$cluster <- factor(.groups)\n", dataset),
    "  table(.groups)\n",
    "})"
  )
}

nb_contrast <- function(model, hypothesis) {
  if (!nzchar(hypothesis)) stop("Enter the hypothesis to test.")
  sprintf('car::linearHypothesis(%s, "%s")', model,
          gsub('"', '\\\\"', hypothesis))
}

nb_posthoc <- function(model, factor) {
  if (!nzchar(factor)) stop("Choose the factor.")
  sprintf('TukeyHSD(%s, which = "%s")', model, factor)
}

nb_press <- function(model) {
  paste0(
    "local({\n",
    sprintf("  .fit <- %s\n", model),
    "  .r <- residuals(.fit); .h <- hatvalues(.fit)\n",
    "  .press <- sum((.r / (1 - .h))^2)\n",
    "  .y <- model.response(model.frame(.fit))\n",
    "  c(PRESS = .press,\n",
    "    R2pred = 1 - .press / sum((.y - mean(.y))^2),\n",
    "    RMSEP = sqrt(.press / length(.r)))\n",
    "})"
  )
}

nb_deviance_tests <- function(model) {
  sprintf("anova(%s, test = \"Chisq\")", model)
}

nb_inv_xtx <- function(model) {
  sprintf("solve(crossprod(model.matrix(%s)))", model)
}

nb_pca_plots <- function(model) {
  paste0(
    "local({\n",
    sprintf("  plot(%s, main = \"Variance explained\")\n", model),
    sprintf("  biplot(%s)\n", model),
    "})"
  )
}

nb_discriminant_plot <- function(model) {
  sprintf("plot(%s)", model)
}

nb_mixture_surface <- function(dataset, response, x, y) {
  if (any(!nzchar(c(response, x, y)))) {
    stop("Choose response and two components.")
  }
  paste0(
    "local({\n",
    sprintf("  .fit <- lm(%s ~ %s * %s, data = %s)\n", response, x, y, dataset),
    sprintf("  .x <- seq(min(%s$%s), max(%s$%s), length.out = 25)\n",
            dataset, x, dataset, x),
    sprintf("  .y <- seq(min(%s$%s), max(%s$%s), length.out = 25)\n",
            dataset, y, dataset, y),
    "  .z <- outer(.x, .y, function(a, b) {\n",
    sprintf("    predict(.fit, setNames(data.frame(a, b), c(\"%s\", \"%s\")))\n",
            x, y),
    "  })\n",
    "  persp(.x, .y, .z, theta = 30, phi = 20, ticktype = \"detailed\",\n",
    sprintf("        xlab = \"%s\", ylab = \"%s\", zlab = \"%s\")\n",
            x, y, response),
    "})"
  )
}

nb_stepwise <- function(model, direction = "both") {
  sprintf("MASS::stepAIC(%s, direction = \"%s\")", model, direction)
}

# -- graphs -----------------------------------------------------------------

nb_fitted_line <- function(dataset, x, y) {
  if (any(!nzchar(c(x, y)))) stop("Choose x and y.")
  paste0(
    "local({\n",
    sprintf("  car::scatterplot(%s ~ %s, data = %s, smooth = FALSE)\n",
            y, x, dataset),
    sprintf("  abline(lm(%s ~ %s, data = %s), lwd = 2, col = \"tomato\")\n",
            y, x, dataset),
    "})"
  )
}

nb_pie_summary <- function(labels, values) {
  labels <- trimws(strsplit(as.character(labels), ",", fixed = TRUE)[[1L]])
  values <- nb_vector(values, "values")
  if (length(labels) != length(values)) {
    stop("Labels and values must have the same length.")
  }
  if (any(values < 0)) stop("Values cannot be negative.")
  sprintf('pie(c(%s), labels = c(%s), main = "Summary")',
          paste(values, collapse = ", "),
          paste0('"', labels, '"', collapse = ", "))
}

nb_simplex_plot <- function(dataset, a, b, c) {
  if (any(!nzchar(c(a, b, c)))) stop("Choose three components.")
  paste0(
    "local({\n",
    sprintf("  .b <- %s$%s; .c <- %s$%s\n", dataset, b, dataset, c),
    "  .x <- .b + .c / 2\n",
    "  .y <- .c * sqrt(3) / 2\n",
    "  plot(.x, .y, asp = 1, xlab = \"\", ylab = \"\",\n",
    "       xlim = c(0, 1), ylim = c(0, sqrt(3)/2),\n",
    sprintf("       main = \"Simplex: %s, %s, %s\")\n", a, b, c),
    "  text(0, 0, ", sprintf('"%s"', a), ", pos = 1)\n",
    "  text(1, 0, ", sprintf('"%s"', b), ", pos = 1)\n",
    "  text(0.5, sqrt(3)/2, ", sprintf('"%s"', c), ", pos = 3)\n",
    "})"
  )
}

# -- dialogs ----------------------------------------------------------------

nb_alt <- function() {
  nc("alternative", "Alternative hypothesis",
     c("two-sided" = "two.sided", "less" = "less", "greater" = "greater"))
}

nb_extra_dialogs <- function() {
  list(
    createSequence = numbu_dialog(
      "createSequence", "Create data sequence",
      list(ne("from", "Start", "1"), ne("to", "End", "10"),
           ne("by", "Step", "1"), ne("name", "Data set name", "sequence")),
      function(values, state) {
        nb_sequence(values$from, values$to, values$by, values$name)
      },
      help_topic = "nmbu-data", plot = FALSE,
      activate = function(values, state) values$name
    ),
    meanCenter = numbu_dialog(
      "meanCenter", "Mean center variables",
      list(nv("variables", "Variables", "numeric", TRUE),
           ne("suffix", "Suffix for the new variables", "_c")),
      function(values, state) {
        nb_mean_center(RcmdrShiny::active_dataset(state),
                       nb_vars(values, "variables"),
                       if (is.null(values$suffix) || !nzchar(values$suffix)) {
                         "_c"
                       } else {
                         values$suffix
                       })
      },
      help_topic = "nmbu-data", plot = FALSE
    ),
    oneSamplesZTestSum = numbu_dialog(
      "oneSamplesZTestSum", "One-sample z-test (summarized data)",
      list(ne("mean", "Mean", "0"), ne("sigma", "Known sigma", "1"),
           ne("n", "Sample size", "10"), ne("mu", "Null mean", "0"),
           nb_alt()),
      function(values, state) {
        nb_z_one_summary(values$mean, values$sigma, values$n, values$mu,
                         values$alternative)
      },
      help_topic = "nmbu-tests", plot = FALSE
    ),
    twoSamplesZTestSum = numbu_dialog(
      "twoSamplesZTestSum", "Two-sample z-test (summarized data)",
      list(ne("mean1", "Mean 1", "0"), ne("sigma1", "Sigma 1", "1"),
           ne("n1", "N 1", "10"), ne("mean2", "Mean 2", "0"),
           ne("sigma2", "Sigma 2", "1"), ne("n2", "N 2", "10"),
           nb_alt()),
      function(values, state) {
        nb_z_two_summary(values$mean1, values$sigma1, values$n1,
                         values$mean2, values$sigma2, values$n2,
                         values$alternative)
      },
      help_topic = "nmbu-tests", plot = FALSE
    ),
    covarianceMatrix = numbu_dialog(
      "covarianceMatrix", "Covariance/correlation matrix",
      list(nv("variables", "Variables", "numeric", TRUE),
           nc("kind", "Matrix", c("Covariance" = "cov",
                                  "Correlation" = "cor"))),
      function(values, state) {
        nb_covariance(RcmdrShiny::active_dataset(state),
                      nb_vars(values, "variables"), values$kind)
      },
      help_topic = "nmbu-tests", plot = FALSE
    ),
    hierarchicalClusterVariable = numbu_dialog(
      "hierarchicalClusterVariable", "Hierarchical cluster analysis (variables)",
      list(nv("variables", "Variables", "numeric", TRUE),
           ne("k", "Number of groups", "2")),
      function(values, state) {
        nb_cluster_variables(RcmdrShiny::active_dataset(state),
                             nb_vars(values, "variables"), values$k)
      },
      help_topic = "nmbu-models"
    ),
    RelComp = numbu_dialog(
      "RelComp", "Relevant component analysis",
      list(nv("variables", "Variables", "numeric", TRUE),
           ne("factors", "Number of components", "2")),
      function(values, state) {
        nb_relevant_components(RcmdrShiny::active_dataset(state),
                               nb_vars(values, "variables"), values$factors)
      },
      help_topic = "nmbu-models", plot = FALSE
    ),
    simplex.analysis = numbu_dialog(
      "simplex.analysis", "Simplex mixture model",
      list(nv("response", "Response", "numeric", FALSE),
           nv("components", "Mixture components", "numeric", TRUE)),
      function(values, state) {
        nb_simplex(RcmdrShiny::active_dataset(state), values$response,
                   nb_vars(values, "components"))
      },
      help_topic = "nmbu-models", plot = FALSE
    ),
    discriminantAnalysis = numbu_dialog(
      "discriminantAnalysis", "LDA/QDA",
      list(nv("response", "Grouping factor", "factor", FALSE),
           nv("predictors", "Predictors", "numeric", TRUE),
           nc("method", "Method", c("Linear (LDA)" = "lda",
                                    "Quadratic (QDA)" = "qda"))),
      function(values, state) {
        nb_discriminant(RcmdrShiny::active_dataset(state), values$response,
                        nb_vars(values, "predictors"), values$method)
      },
      help_topic = "nmbu-models", plot = FALSE
    ),
    CIgrandMeanNMBU = numbu_dialog(
      "CIgrandMeanNMBU", "CI for the model grand mean",
      list(),
      function(values, state) nb_grand_mean(nb_model(state)),
      help_topic = "nmbu-models", plot = FALSE
    ),
    DA.coef = numbu_dialog(
      "DA.coef", "Discriminant scores",
      list(),
      function(values, state) nb_da_scores(nb_model(state)),
      help_topic = "nmbu-models", plot = FALSE
    ),
    hclust.list = numbu_dialog(
      "hclust.list", "Hierarchical merging",
      list(nv("variables", "Variables", "numeric", TRUE),
           ne("k", "Number of groups", "2")),
      function(values, state) {
        nb_cluster_list(RcmdrShiny::active_dataset(state),
                        nb_vars(values, "variables"), values$k)
      },
      help_topic = "nmbu-models", plot = FALSE
    ),
    contrastGUI = numbu_dialog(
      "contrastGUI", "Test contrast in ANOVA",
      list(ne("hypothesis", "Hypothesis", "x = 0")),
      function(values, state) nb_contrast(nb_model(state), values$hypothesis),
      help_topic = "nmbu-models", plot = FALSE
    ),
    postHocGUI = numbu_dialog(
      "postHocGUI", "Post hoc pair-wise tests",
      list(nv("factor", "Factor", "factor", FALSE)),
      function(values, state) nb_posthoc(nb_model(state), values$factor),
      help_topic = "nmbu-models", plot = FALSE
    ),
    PRESS.GUI = numbu_dialog(
      "PRESS.GUI", "PRESS, R2pred and RMSEP",
      list(),
      function(values, state) nb_press(nb_model(state)),
      help_topic = "nmbu-models", plot = FALSE
    ),
    deviance_tests_GUI = numbu_dialog(
      "deviance_tests_GUI", "Deviance tests",
      list(),
      function(values, state) nb_deviance_tests(nb_model(state)),
      help_topic = "nmbu-models", plot = FALSE
    ),
    invXtXGUI = numbu_dialog(
      "invXtXGUI", "Store and display (X'X)^-1",
      list(),
      function(values, state) nb_inv_xtx(nb_model(state)),
      help_topic = "nmbu-models", plot = FALSE
    ),
    principalComponentPlots = numbu_dialog(
      "principalComponentPlots", "PCA/PCR/PLS plots",
      list(),
      function(values, state) nb_pca_plots(nb_model(state)),
      help_topic = "nmbu-models"
    ),
    discriminantPlot = numbu_dialog(
      "discriminantPlot", "2D discriminant plot",
      list(),
      function(values, state) nb_discriminant_plot(nb_model(state)),
      help_topic = "nmbu-models"
    ),
    mixtureGUI = numbu_dialog(
      "mixtureGUI", "Mixture model response surface",
      list(nv("response", "Response", "numeric", FALSE),
           nv("x", "First component", "numeric", FALSE),
           nv("y", "Second component", "numeric", FALSE)),
      function(values, state) {
        nb_mixture_surface(RcmdrShiny::active_dataset(state), values$response,
                           values$x, values$y)
      },
      help_topic = "nmbu-models"
    ),
    backwardForward = numbu_dialog(
      "backwardForward", "Backward/forward model selection",
      list(),
      function(values, state) nb_stepwise(nb_model(state), "both"),
      help_topic = "nmbu-models", plot = FALSE
    ),
    wideForwardAdd = numbu_dialog(
      "wideForwardAdd", "Forward model selection",
      list(),
      function(values, state) nb_stepwise(nb_model(state), "forward"),
      help_topic = "nmbu-models", plot = FALSE
    ),
    fittedLinePlot = numbu_dialog(
      "fittedLinePlot", "Fitted regression plot",
      list(nv("x", "Explanatory variable", "numeric", FALSE),
           nv("y", "Response", "numeric", FALSE)),
      function(values, state) {
        nb_fitted_line(RcmdrShiny::active_dataset(state), values$x, values$y)
      },
      help_topic = "nmbu-models"
    ),
    pieChartNMBU = numbu_dialog(
      "pieChartNMBU", "Pie/bar chart from summaries",
      list(ne("labels", "Labels (comma separated)", "a, b, c"),
           ne("values", "Values (comma separated)", "10, 20, 30")),
      function(values, state) nb_pie_summary(values$labels, values$values),
      help_topic = "nmbu-models"
    ),
    simplexGUI = numbu_dialog(
      "simplexGUI", "Simplex mixture design plot",
      list(nv("a", "First component", "numeric", FALSE),
           nv("b", "Second component", "numeric", FALSE),
           nv("c", "Third component", "numeric", FALSE)),
      function(values, state) {
        nb_simplex_plot(RcmdrShiny::active_dataset(state), values$a,
                        values$b, values$c)
      },
      help_topic = "nmbu-models"
    )
  )
}
