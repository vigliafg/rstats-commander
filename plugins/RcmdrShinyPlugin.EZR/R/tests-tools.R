# Tests and diagnostic accuracy for EZR -------------------------------------
#
# Builders for the EZR test menu.  Where a package is optional the generated
# command uses its namespace and the menu entry is hidden by the install
# predicate; base R covers the rest.

ezr_test_prob_diff <- function(x1, n1, x2, n2, level = 0.95) {
  x1 <- as.integer(x1); n1 <- as.integer(n1)
  x2 <- as.integer(x2); n2 <- as.integer(n2)
  if (any(is.na(c(x1, n1, x2, n2)))) stop("The counts must be integers.")
  if (x1 > n1 || x2 > n2) stop("Successes cannot exceed the sample size.")
  sprintf('prop.test(c(%d, %d), c(%d, %d), conf.level = %.4g)$conf.int',
          x1, x2, n1, n2, as.numeric(level))
}

ezr_test_prob_ratio <- function(x1, n1, x2, n2, level = 0.95) {
  x1 <- as.integer(x1); n1 <- as.integer(n1)
  x2 <- as.integer(x2); n2 <- as.integer(n2)
  if (any(is.na(c(x1, n1, x2, n2)))) stop("The counts must be integers.")
  if (any(c(x1, x2) == 0)) stop("Both groups need at least one success.")
  if (x1 > n1 || x2 > n2) stop("Successes cannot exceed the sample size.")
  paste0(
    "local({\n",
    sprintf("  .p1 <- %d / %d; .p2 <- %d / %d\n", x1, n1, x2, n2),
    "  .se <- sqrt(1/", x1, " - 1/", n1, " + 1/", x2, " - 1/", n2, ")\n",
    sprintf("  exp(log(.p1 / .p2) + c(-1, 1) * qnorm(1 - %.4g/2) * .se)\n",
            as.numeric(level)),
    "})"
  )
}

ezr_test_cochran_q <- function(successes, totals) {
  successes <- as.integer(successes)
  totals <- as.integer(totals)
  k <- length(successes)
  if (k < 3L) stop("At least three paired samples are required.")
  paste0(
    "local({\n",
    sprintf("  .x <- c(%s); .n <- c(%s)\n",
            paste(successes, collapse = ", "), paste(totals, collapse = ", ")),
    "  .p <- .x / .n\n",
    "  .q <- (length(.x) - 1) * (length(.x) * sum(.x^2) - sum(.x)^2) /\n",
    "        (length(.x) * sum(.x) - sum(.x^2))\n",
    "  .df <- length(.x) - 1\n",
    "  c(Q = .q, df = .df, p.value = pchisq(.q, .df, lower.tail = FALSE))\n",
    "})"
  )
}

ezr_test_trend <- function(x, n) {
  x <- as.integer(x); n <- as.integer(n)
  if (length(x) != length(n) || length(x) < 3L) {
    stop("Provide at least three groups with successes and totals.")
  }
  if (any(x > n)) stop("Successes cannot exceed the sample size.")
  sprintf("prop.trend.test(c(%s), c(%s))",
          paste(x, collapse = ", "), paste(n, collapse = ", "))
}

ezr_test_modified_poisson <- function(dataset, response, predictors) {
  if (!nzchar(response) || length(predictors) == 0L) {
    stop("Choose a response and at least one predictor.")
  }
  formula <- paste(response, "~", paste(predictors, collapse = " + "))
  paste0(
    "local({\n",
    sprintf("  .fit <- glm(%s, data = %s, family = poisson)\n",
            formula, dataset),
    "  lmtest::coeftest(.fit, vcov = sandwich::vcovHC(.fit, type = \"HC0\"))\n",
    "})"
  )
}

ezr_test_grubbs <- function(dataset, variable) {
  if (!nzchar(variable)) stop("Choose a numeric variable.")
  paste0(
    "local({\n",
    sprintf("  .x <- %s$%s\n", dataset, variable),
    "  .n <- length(.x); .g <- max(abs(.x - mean(.x))) / sd(.x)\n",
    "  .t <- sqrt(.n * (.n - 2) * .g^2 / ((.n - 1)^2 - .n * .g^2))\n",
    "  c(G = .g, u = .t,\n",
    "    p.value = .n * (1 - pt(.t, .n - 2)))\n",
    "})"
  )
}

ezr_test_ks <- function(dataset, variable) {
  if (!nzchar(variable)) stop("Choose a numeric variable.")
  sprintf('ks.test(%s$%s, "pnorm", mean(%s$%s), sd(%s$%s))',
          dataset, variable, dataset, variable, dataset, variable)
}

ezr_test_variances <- function(dataset, response, group) {
  if (!nzchar(response) || !nzchar(group)) {
    stop("Choose a response and a grouping factor.")
  }
  sprintf("var.test(%s ~ %s, data = %s)", response, group, dataset)
}

ezr_test_ancova <- function(dataset, response, factor, covariate) {
  if (!nzchar(response) || !nzchar(factor) || !nzchar(covariate)) {
    stop("Choose a response, a factor and a covariate.")
  }
  paste0(
    "local({\n",
    sprintf("  .fit <- lm(%s ~ %s + %s, data = %s)\n",
            response, factor, covariate, dataset),
    "  car::Anova(.fit, type = \"II\")\n",
    "})"
  )
}

ezr_test_jonckheere <- function(dataset, response, group) {
  if (!nzchar(response) || !nzchar(group)) {
    stop("Choose a response and an ordered factor.")
  }
  sprintf("clinfun::jonckheere.test(%s$%s, %s$%s)",
          dataset, response, dataset, group)
}

ezr_test_predictive <- function(tp, fp, fn, tn) {
  values <- as.integer(c(tp, fp, fn, tn))
  if (anyNA(values) || any(values < 0L)) stop("The cell counts must be non-negative integers.")
  paste0(
    "local({\n",
    sprintf("  .tp <- %d; .fp <- %d; .fn <- %d; .tn <- %d\n",
            values[1], values[2], values[3], values[4]),
    "  c(PPV = .tp / (.tp + .fp), NPV = .tn / (.tn + .fn),\n",
    "    sensitivity = .tp / (.tp + .fn),\n",
    "    specificity = .tn / (.tn + .fp))\n",
    "})"
  )
}

ezr_test_roc_compare <- function(dataset, outcome, marker1, marker2) {
  if (any(!nzchar(c(outcome, marker1, marker2)))) {
    stop("Choose an outcome and two markers.")
  }
  paste0(
    "local({\n",
    sprintf("  .r1 <- pROC::roc(%s$%s, %s$%s, quiet = TRUE)\n",
            dataset, outcome, dataset, marker1),
    sprintf("  .r2 <- pROC::roc(%s$%s, %s$%s, quiet = TRUE)\n",
            dataset, outcome, dataset, marker2),
    "  pROC::roc.test(.r1, .r2)\n",
    "})"
  )
}

ezr_test_survival_roc <- function(dataset, time, status, marker, horizon) {
  if (any(!nzchar(c(time, status, marker)))) {
    stop("Choose time, status and marker variables.")
  }
  sprintf(paste0(
    "timeROC::timeROC(%s$%s, %s$%s, %s$%s, cause = 1, ",
    "times = %s, iid = FALSE)"
  ), dataset, time, dataset, status, dataset, marker, as.numeric(horizon))
}

ezr_test_reliability <- function(dataset, variables) {
  variables <- variables[nzchar(variables)]
  if (length(variables) < 2L) stop("Choose at least two items.")
  sprintf("psych::alpha(%s[, c(%s)])", dataset,
          paste0('"', variables, '"', collapse = ", "))
}

ezr_test_dialogs <- function() {
  list(
    StatMedProbDiffCI = ezr_dialog(
      "StatMedProbDiffCI", "Confidence interval for a difference between two proportions",
      list(ei("x1", "Successes in group 1", 10), ei("n1", "Group 1 size", 20),
           ei("x2", "Successes in group 2", 15), ei("n2", "Group 2 size", 20),
           ee("level", "Confidence level", "0.95")),
      function(values, state) {
        ezr_test_prob_diff(values$x1, values$n1, values$x2, values$n2,
                           values$level)
      },
      help_topic = "ezr-tests", plot = FALSE
    ),
    StatMedProbRatioCI = ezr_dialog(
      "StatMedProbRatioCI", "Confidence interval for a ratio of two proportions",
      list(ei("x1", "Successes in group 1", 10), ei("n1", "Group 1 size", 20),
           ei("x2", "Successes in group 2", 15), ei("n2", "Group 2 size", 20),
           ee("level", "Confidence level", "0.95")),
      function(values, state) {
        ezr_test_prob_ratio(values$x1, values$n1, values$x2, values$n2,
                            values$level)
      },
      help_topic = "ezr-tests", plot = FALSE
    ),
    StatMedCochranQ = ezr_dialog(
      "StatMedCochranQ", "Cochran Q test for paired proportions",
      list(ee("successes", "Successes per group (comma separated)", "10, 12, 15"),
           ee("totals", "Group sizes (comma separated)", "20, 20, 20")),
      function(values, state) {
        ezr_test_cochran_q(
          strsplit(as.character(values$successes), ",", fixed = TRUE)[[1L]],
          strsplit(as.character(values$totals), ",", fixed = TRUE)[[1L]]
        )
      },
      help_topic = "ezr-tests", plot = FALSE
    ),
    StatMedPropTrend = ezr_dialog(
      "StatMedPropTrend", "Cochran-Armitage test for trend in proportions",
      list(ee("x", "Successes (comma separated)", "10, 15, 20"),
           ee("n", "Totals (comma separated)", "20, 20, 20")),
      function(values, state) {
        ezr_test_trend(
          strsplit(as.character(values$x), ",", fixed = TRUE)[[1L]],
          strsplit(as.character(values$n), ",", fixed = TRUE)[[1L]]
        )
      },
      help_topic = "ezr-tests", plot = FALSE
    ),
    StatMedModifiedPoissonRegression = ezr_dialog(
      "StatMedModifiedPoissonRegression", "Modified Poisson regression",
      list(ev("response", "Binary response", "factor", FALSE),
           ev("predictors", "Predictors", "all", TRUE)),
      function(values, state) {
        ezr_test_modified_poisson(RcmdrShiny::active_dataset(state),
                                  values$response, values$predictors)
      },
      help_topic = "ezr-tests", plot = FALSE
    ),
    StatMedSG = ezr_dialog(
      "StatMedSG", "Smirnov-Grubbs test for outliers",
      list(ev("variable", "Numeric variable", "numeric", FALSE)),
      function(values, state) {
        ezr_test_grubbs(RcmdrShiny::active_dataset(state), values$variable)
      },
      help_topic = "ezr-tests", plot = FALSE
    ),
    StatMedKS = ezr_dialog(
      "StatMedKS", "Kolmogorov-Smirnov test for normality",
      list(ev("variable", "Numeric variable", "numeric", FALSE)),
      function(values, state) {
        ezr_test_ks(RcmdrShiny::active_dataset(state), values$variable)
      },
      help_topic = "ezr-tests", plot = FALSE
    ),
    StatMedFTest = ezr_dialog(
      "StatMedFTest", "Two-variances F-test",
      list(ev("response", "Numeric variable", "numeric", FALSE),
           ev("group", "Grouping factor", "factor", FALSE)),
      function(values, state) {
        ezr_test_variances(RcmdrShiny::active_dataset(state),
                           values$response, values$group)
      },
      help_topic = "ezr-tests", plot = FALSE
    ),
    StatMedANCOVA = ezr_dialog(
      "StatMedANCOVA", "ANCOVA",
      list(ev("response", "Response", "numeric", FALSE),
           ev("factor", "Factor", "factor", FALSE),
           ev("covariate", "Covariate", "numeric", FALSE)),
      function(values, state) {
        ezr_test_ancova(RcmdrShiny::active_dataset(state), values$response,
                        values$factor, values$covariate)
      },
      help_topic = "ezr-tests", plot = FALSE
    ),
    StatMedJT = ezr_dialog(
      "StatMedJT", "Jonckheere-Terpstra test",
      list(ev("response", "Response", "numeric", FALSE),
           ev("group", "Ordered factor", "factor", FALSE)),
      function(values, state) {
        ezr_test_jonckheere(RcmdrShiny::active_dataset(state),
                            values$response, values$group)
      },
      help_topic = "ezr-tests", plot = FALSE
    ),
    StatMedPredictiveValue = ezr_dialog(
      "StatMedPredictiveValue", "Positive and negative predictive values",
      list(ei("tp", "True positives", 30), ei("fp", "False positives", 10),
           ei("fn", "False negatives", 5), ei("tn", "True negatives", 55)),
      function(values, state) {
        ezr_test_predictive(values$tp, values$fp, values$fn, values$tn)
      },
      help_topic = "ezr-tests", plot = FALSE
    ),
    StatMedROCtest = ezr_dialog(
      "StatMedROCtest", "Compare two ROC curves",
      list(ev("outcome", "Outcome (0/1)", "factor", FALSE),
           ev("marker1", "First marker", "numeric", FALSE),
           ev("marker2", "Second marker", "numeric", FALSE)),
      function(values, state) {
        ezr_test_roc_compare(RcmdrShiny::active_dataset(state),
                             values$outcome, values$marker1, values$marker2)
      },
      help_topic = "ezr-tests", plot = FALSE
    ),
    StatMedSurvivalROC = ezr_dialog(
      "StatMedSurvivalROC", "ROC curve for time-to-event data",
      list(ev("time", "Follow-up time", "numeric", FALSE),
           ev("status", "Status", "all", FALSE),
           ev("marker", "Marker", "numeric", FALSE),
           ei("horizon", "Time horizon", 12)),
      function(values, state) {
        ezr_test_survival_roc(RcmdrShiny::active_dataset(state),
                              values$time, values$status, values$marker,
                              values$horizon)
      },
      help_topic = "ezr-tests", plot = FALSE
    ),
    StatMedReliability = ezr_dialog(
      "StatMedReliability", "Cronbach's alpha coefficient for reliability",
      list(ev("variables", "Items", "numeric", TRUE)),
      function(values, state) {
        ezr_test_reliability(RcmdrShiny::active_dataset(state),
                             values$variables)
      },
      help_topic = "ezr-tests", plot = FALSE
    )
  )
}
