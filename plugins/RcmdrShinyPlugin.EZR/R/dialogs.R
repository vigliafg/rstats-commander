# Shiny dialogs for EZR -------------------------------------------------

ezr_dialog <- function(id, title, fields, build, help = NULL) {
  ns <- function(x) paste0(id, "_", x)
  RcmdrShiny::plugin_dialog(
    id = id, title = title, help = help,
    ui = function(state, memory) {
      htmltools::tagList(lapply(fields, function(field) {
        value <- if (is.null(memory)) NULL else memory[[field$name]]
        if (is.null(value)) value <- field$default
        if (identical(field$type, "variable")) {
          choices <- switch(
            field$kind,
            numeric = RcmdrShiny::numeric_variables(state),
            factor = RcmdrShiny::factor_variables(state),
            all = RcmdrShiny::variables(state)
          )
          RcmdrShiny::var_input(ns(field$name), field$label, choices, value,
                                multiple = isTRUE(field$multiple))
        } else if (identical(field$type, "entry")) {
          RcmdrShiny::entry_input(ns(field$name), field$label, value)
        } else if (identical(field$type, "spin")) {
          RcmdrShiny::spin_input(ns(field$name), field$label, value)
        } else if (identical(field$type, "checkbox")) {
          RcmdrShiny::checkbox_input(ns(field$name), field$label, value)
        } else {
          RcmdrShiny::combo_input(ns(field$name), field$label,
                                  field$choices, value)
        }
      }))
    },
    on_ok = function(input, state) {
      values <- list()
      for (field in fields) values[[field$name]] <- input[[ns(field$name)]]
      command <- tryCatch(build(values, state), error = function(e) e)
      if (inherits(command, "error")) return(list(error = conditionMessage(command)))
      list(commands = command, memory = values, plot = TRUE)
    }
  )
}

ev <- function(name, label, kind = "numeric", multiple = FALSE,
               default = character()) {
  list(name = name, label = label, type = "variable", kind = kind,
       multiple = multiple, default = default)
}
ee <- function(name, label, default = "") {
  list(name = name, label = label, type = "entry", default = default)
}
ei <- function(name, label, default = 1) {
  list(name = name, label = label, type = "spin", default = default)
}
ec <- function(name, label, choices, default = NULL) {
  list(name = name, label = label, type = "combo", choices = choices,
       default = if (is.null(default)) choices[[1]] else default)
}
echk <- function(name, label, default = FALSE) {
  list(name = name, label = label, type = "checkbox", default = default)
}

ezr_alt <- function() {
  ec("alternative", "Alternative hypothesis",
     c("two-sided" = "two.sided", "less" = "less", "greater" = "greater"))
}

ezr_dialogs <- function() {
  dialogs <- list(
    StatMedVariableCheck = ezr_dialog(
      "StatMedVariableCheck", "Variables in active data set", list(),
      function(values, state) paste0("str(", RcmdrShiny::active_dataset(state), ")")
    ),
    StatMedTrainTestSplit = ezr_dialog(
      "StatMedTrainTestSplit", "Training-test data split",
      list(ee("train", "Training data name", "train"),
           ee("test", "Test data name", "test"),
           ee("proportion", "Training proportion", "0.7")),
      function(values, state) ezr_split(RcmdrShiny::active_dataset(state),
                                        values$train, values$test,
                                        values$proportion)
    ),
    StatMedDummy = ezr_dialog(
      "StatMedDummy", "Create dummy variables",
      list(ev("variable", "Factor", "factor", FALSE),
           ee("prefix", "Prefix", "")),
      function(values, state) ezr_dummy(RcmdrShiny::active_dataset(state),
                                        values$variable, values$prefix)
    ),
    StatMedDatediff = ezr_dialog(
      "StatMedDatediff", "Difference between two dates",
      list(ev("first", "First date", "all", FALSE),
           ev("second", "Second date", "all", FALSE),
           ee("name", "New variable", "datediff")),
      function(values, state) sprintf("%s$%s <- as.numeric(%s$%s - %s$%s)",
                                      RcmdrShiny::active_dataset(state),
                                      values$name,
                                      RcmdrShiny::active_dataset(state),
                                      values$first,
                                      RcmdrShiny::active_dataset(state),
                                      values$second)
    ),
    StatMedNAgroup = ezr_dialog(
      "StatMedNAgroup", "Missing observations to a group",
      list(ev("variable", "Variable", "all", FALSE),
           ee("label", "Label", "Missing")),
      function(values, state) ezr_na_group(RcmdrShiny::active_dataset(state),
                                           values$variable, values$label)
    ),
    StatMedProbCI = ezr_dialog(
      "StatMedProbCI", "Confidence interval for a proportion",
      list(ei("successes", "Successes", 0), ei("n", "Sample size", 10),
           ee("level", "Confidence level", "0.95")),
      function(values, state) ezr_prop_ci(values$successes, values$n, values$level)
    ),
    StatMedProbSingle = ezr_dialog(
      "StatMedProbSingle", "One-sample proportion test",
      list(ei("successes", "Successes", 0), ei("n", "Sample size", 10),
           ee("p0", "Null proportion", "0.5"), ezr_alt()),
      function(values, state) ezr_prop_test(values$successes, values$n,
                                            values$p0, values$alternative)
    ),
    StatMedTwoWayTable = ezr_dialog(
      "StatMedTwoWayTable", "Two-way table and proportions",
      list(ev("row", "Row factor", "factor", FALSE),
           ev("col", "Column factor", "factor", FALSE)),
      function(values, state) c(
        sprintf(".tab <- table(%s$%s, %s$%s)",
                RcmdrShiny::active_dataset(state), values$row,
                RcmdrShiny::active_dataset(state), values$col),
        ".tab", "chisq.test(.tab)", "fisher.test(.tab)"
      )
    ),
    StatMedMcNemar = ezr_dialog(
      "StatMedMcNemar", "McNemar test",
      list(ev("row", "First factor", "factor", FALSE),
           ev("col", "Second factor", "factor", FALSE)),
      function(values, state) sprintf("mcnemar.test(table(%s$%s, %s$%s))",
                                      RcmdrShiny::active_dataset(state), values$row,
                                      RcmdrShiny::active_dataset(state), values$col)
    ),
    StatMedLogisticRegression = ezr_dialog(
      "StatMedLogisticRegression", "Logistic regression",
      list(ev("response", "Response (0/1)", "numeric", FALSE),
           ev("predictors", "Predictors", multiple = TRUE)),
      function(values, state) ezr_regression(
        RcmdrShiny::active_dataset(state), values$response, values$predictors,
        "binomial"
      )
    ),
    StatMedMeanCI = ezr_dialog(
      "StatMedMeanCI", "Confidence interval for a mean",
      list(ev("response", "Variable", "numeric", FALSE),
           ee("level", "Confidence level", "0.95"), ezr_alt()),
      function(values, state) ezr_mean_ci(RcmdrShiny::active_dataset(state),
                                          values$response, values$level,
                                          values$alternative)
    ),
    StatMedSingleSampleTTest = ezr_dialog(
      "StatMedSingleSampleTTest", "Single-sample t-test",
      list(ev("response", "Variable", "numeric", FALSE),
           ee("mu", "Null mean", "0"), ee("level", "Confidence level", "0.95"),
           ezr_alt()),
      function(values, state) ezr_t_test(
        "single", RcmdrShiny::active_dataset(state), values$response,
        mu = values$mu, level = values$level, alternative = values$alternative
      )
    ),
    StatMedTtest = ezr_dialog(
      "StatMedTtest", "Two-sample t-test",
      list(ev("response", "Response", "numeric", FALSE),
           ev("group", "Group", "factor", FALSE),
           ee("mu", "Null difference", "0"), ee("level", "Confidence level", "0.95"),
           ezr_alt(), echk("equal_variance", "Equal variances")),
      function(values, state) ezr_t_test(
        "independent", RcmdrShiny::active_dataset(state), values$response,
        group = values$group, mu = values$mu, level = values$level,
        alternative = values$alternative, equal_variance = values$equal_variance
      )
    ),
    StatMedPairedTtest = ezr_dialog(
      "StatMedPairedTtest", "Paired t-test",
      list(ev("first", "First variable", "numeric", FALSE),
           ev("second", "Second variable", "numeric", FALSE),
           ee("mu", "Null difference", "0"), ee("level", "Confidence level", "0.95"),
           ezr_alt()),
      function(values, state) ezr_t_test(
        "paired", RcmdrShiny::active_dataset(state), "",
        first = values$first, second = values$second, mu = values$mu,
        level = values$level, alternative = values$alternative
      )
    ),
    StatMedBartlett = ezr_dialog(
      "StatMedBartlett", "Bartlett test",
      list(ev("response", "Response", "numeric", FALSE),
           ev("group", "Group", "factor", FALSE)),
      function(values, state) sprintf("bartlett.test(%s ~ %s, data = %s)",
                                      values$response, values$group,
                                      RcmdrShiny::active_dataset(state))
    ),
    StatMedANOVA = ezr_dialog(
      "StatMedANOVA", "One-way ANOVA",
      list(ev("response", "Response", "numeric", FALSE),
           ev("factor", "Factor", "factor", FALSE)),
      function(values, state) ezr_anova(RcmdrShiny::active_dataset(state),
                                        values$response, values$factor)
    ),
    StatMedMultiANOVA = ezr_dialog(
      "StatMedMultiANOVA", "Multi-way ANOVA",
      list(ev("response", "Response", "numeric", FALSE),
           ev("factors", "Factors", "factor", TRUE)),
      function(values, state) ezr_anova(RcmdrShiny::active_dataset(state),
                                        values$response, values$factors, TRUE)
    ),
    StatMedCorrelation = ezr_dialog(
      "StatMedCorrelation", "Correlation test",
      list(ev("first", "First variable", "numeric", FALSE),
           ev("second", "Second variable", "numeric", FALSE),
           ec("method", "Method", c("pearson" = "pearson",
                                    "spearman" = "spearman",
                                    "kendall" = "kendall"))),
      function(values, state) ezr_correlation(RcmdrShiny::active_dataset(state),
                                              values$first, values$second,
                                              values$method)
    ),
    StatMedLinearMixedModel = ezr_dialog(
      "StatMedLinearMixedModel", "Linear mixed model",
      list(ev("response", "Response", "numeric", FALSE),
           ev("predictors", "Fixed predictors", multiple = TRUE),
           ev("group", "Random group", "factor", FALSE)),
      function(values, state) c(
        sprintf(".model <- lme4::lmer(%s ~ %s + (1 | %s), data = %s)",
                values$response, paste(values$predictors, collapse = " + "),
                values$group, RcmdrShiny::active_dataset(state)),
        "summary(.model)"
      )
    ),
    StatMedMannW = ezr_dialog(
      "StatMedMannW", "Mann-Whitney U test",
      list(ev("response", "Response", "numeric", FALSE),
           ev("group", "Group", "factor", FALSE)),
      function(values, state) ezr_nonparam("mann", RcmdrShiny::active_dataset(state),
                                           values$response, values$group)
    ),
    StatMedWilSign = ezr_dialog(
      "StatMedWilSign", "Wilcoxon signed rank test",
      list(ev("first", "First variable", "numeric", FALSE),
           ev("second", "Second variable", "numeric", FALSE)),
      function(values, state) ezr_nonparam("wilcox", RcmdrShiny::active_dataset(state),
                                           "", "", values$first, values$second)
    ),
    StatMedKruWalli = ezr_dialog(
      "StatMedKruWalli", "Kruskal-Wallis test",
      list(ev("response", "Response", "numeric", FALSE),
           ev("group", "Group", "factor", FALSE)),
      function(values, state) ezr_nonparam("kruskal", RcmdrShiny::active_dataset(state),
                                           values$response, values$group)
    ),
    StatMedFriedman = ezr_dialog(
      "StatMedFriedman", "Friedman test",
      list(ev("variables", "Repeated measures", "numeric", TRUE)),
      function(values, state) sprintf("friedman.test(as.matrix(%s[, c(%s)]))",
                                      RcmdrShiny::active_dataset(state),
                                      paste(sprintf('"%s"', values$variables), collapse = ", "))
    ),
    StatMedSpearman = ezr_dialog(
      "StatMedSpearman", "Spearman rank correlation",
      list(ev("first", "First variable", "numeric", FALSE),
           ev("second", "Second variable", "numeric", FALSE)),
      function(values, state) ezr_correlation(RcmdrShiny::active_dataset(state),
                                              values$first, values$second,
                                              "spearman")
    ),
    StatMedKaplanMeier = ezr_dialog(
      "StatMedKaplanMeier", "Kaplan-Meier survival curve",
      list(ev("time", "Time", "numeric", FALSE),
           ev("event", "Event", "numeric", FALSE),
           ev("group", "Group", "factor", FALSE)),
      function(values, state) ezr_survival(
        "km", RcmdrShiny::active_dataset(state), values$time, values$event,
        values$group %||% ""
      )
    ),
    StatMedCoxRegression = ezr_dialog(
      "StatMedCoxRegression", "Cox proportional hazards regression",
      list(ev("time", "Time", "numeric", FALSE),
           ev("event", "Event", "numeric", FALSE),
           ev("predictors", "Predictors", multiple = TRUE)),
      function(values, state) ezr_survival(
        "cox", RcmdrShiny::active_dataset(state), values$time, values$event,
        "", values$predictors
      )
    ),
    StatMedTest = ezr_dialog(
      "StatMedTest", "Accuracy of qualitative test",
      list(ev("test", "Test result", "factor", FALSE),
           ev("reference", "Reference standard", "factor", FALSE)),
      function(values, state) c(
        sprintf(".tab <- table(%s$%s, %s$%s)",
                RcmdrShiny::active_dataset(state), values$test,
                RcmdrShiny::active_dataset(state), values$reference),
        ".tab", "prop.table(.tab, 1)", "chisq.test(.tab)"
      )
    ),
    StatMedKappa = ezr_dialog(
      "StatMedKappa", "Kappa statistics",
      list(ev("first", "First test", "factor", FALSE),
           ev("second", "Second test", "factor", FALSE)),
      function(values, state) sprintf("irr::kappa2(cbind(%s$%s, %s$%s))",
                                      RcmdrShiny::active_dataset(state), values$first,
                                      RcmdrShiny::active_dataset(state), values$second)
    ),
    StatMedROC = ezr_dialog(
      "StatMedROC", "ROC curve analysis",
      list(ev("response", "Outcome", "factor", FALSE),
           ev("predictor", "Predictor", "numeric", FALSE)),
      function(values, state) ezr_roc(RcmdrShiny::active_dataset(state),
                                      values$response, values$predictor)
    ),
    StatMedHistogram = ezr_dialog(
      "StatMedHistogram", "Histogram",
      list(ev("variable", "Variable", "numeric", FALSE), ei("bins", "Bins", 20)),
      function(values, state) ezr_histogram(RcmdrShiny::active_dataset(state),
                                            values$variable, values$bins)
    ),
    StatMedBoxPlot = ezr_dialog(
      "StatMedBoxPlot", "Boxplot",
      list(ev("variable", "Variable", "numeric", FALSE),
           ev("group", "Group", "factor", FALSE)),
      function(values, state) ezr_boxplot(RcmdrShiny::active_dataset(state),
                                          values$variable, values$group %||% "")
    ),
    StatMedBarGraph = ezr_dialog(
      "StatMedBarGraph", "Bar graph (frequencies)",
      list(ev("variable", "Variable", "factor", FALSE)),
      function(values, state) ezr_barplot(RcmdrShiny::active_dataset(state),
                                          values$variable)
    ),
    StatMedScatterPlot = ezr_dialog(
      "StatMedScatterPlot", "Scatterplot",
      list(ev("x", "X variable", "numeric", FALSE),
           ev("y", "Y variable", "numeric", FALSE),
           ev("group", "Group", "factor", FALSE)),
      function(values, state) ezr_scatter(RcmdrShiny::active_dataset(state),
                                          values$x, values$y, values$group %||% "")
    ),
    StatMedTableOne = ezr_dialog(
      "StatMedTableOne", "Summary table of sample characteristics",
      list(ev("variables", "Variables", "all", TRUE),
           ev("group", "Group", "factor", FALSE)),
      function(values, state) ezr_tableone(RcmdrShiny::active_dataset(state),
                                           values$variables, values$group %||% "")
    )
  )

  aliases <- list(
    StatMedReadDataSet = "readDataSet",
    StatMedCompute = "Compute",
    StatMedNumericToFactor = "numericToFactor",
    StatMedReorderFactor = "reorderFactor",
    StatMedRecodeDialog = "RecodeDialog",
    StatMedDeleteVariable = "deleteVariable",
    StatMedSubsetDataSet = "subsetDataSet",
    StatMedSort = "sortDataSet",
    StatMedFrequency = "frequencyDistribution",
    StatMedNumericalSummaries = "numericalSummaries",
    StatMedLinearRegression = "linearModel",
    StatMedOrdinalRegressionModel = "ordinalRegressionModel",
    StatMedMultinomialLogitModel = "multinomialLogitModel",
    StatMedScatterPlotMatrix = "scatterplotMatrix",
    StatMedQQPlot = "qqPlot",
    StatMedBarMeans = "plotMeans",
    StatMedPlotMeans = "plotMeans"
  )
  for (new_name in names(aliases)) {
    spec <- RcmdrShiny::get_dialog(aliases[[new_name]])
    if (!is.null(spec)) dialogs[[new_name]] <- spec
  }
  dialogs
}
