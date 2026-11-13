# Shiny dialogs for NMBU ------------------------------------------------

numbu_dialog <- function(id, title, fields, build, help = NULL) {
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

nv <- function(name, label, kind = "numeric", multiple = FALSE,
               default = character()) {
  list(name = name, label = label, type = "variable", kind = kind,
       multiple = multiple, default = default)
}
ne <- function(name, label, default = "") {
  list(name = name, label = label, type = "entry", default = default)
}
nc <- function(name, label, choices, default = NULL) {
  list(name = name, label = label, type = "combo", choices = choices,
       default = if (is.null(default)) choices[[1]] else default)
}
nchk <- function(name, label, default = FALSE) {
  list(name = name, label = label, type = "checkbox", default = default)
}

ntest_dialogs <- function() {
  alternative <- nc("alternative", "Alternative hypothesis",
                    c("two-sided" = "two.sided", "less" = "less",
                      "greater" = "greater"))
  list(
    singleSampleTTestNMBU = numbu_dialog(
      "singleSampleTTestNMBU", "Single-sample t-test",
      list(nv("response", "Variable"), ne("mu", "Null mean", "0"),
           ne("level", "Confidence level", "0.95"), alternative),
      function(values, state) build_t_test(
        "single", RcmdrShiny::active_dataset(state), values$response,
        mu = values$mu, level = values$level, alternative = values$alternative
      )
    ),
    independentSamplesTTestNMBU = numbu_dialog(
      "independentSamplesTTestNMBU", "Two-sample t-test",
      list(nv("response", "Response"), nv("group", "Group", "factor"),
           ne("mu", "Null difference", "0"), ne("level", "Confidence level", "0.95"),
           alternative, nchk("equal_variance", "Equal variances")),
      function(values, state) build_t_test(
        "independent", RcmdrShiny::active_dataset(state), values$response,
        group = values$group, mu = values$mu, level = values$level,
        alternative = values$alternative, equal_variance = values$equal_variance
      )
    ),
    pairedTTestNMBU = numbu_dialog(
      "pairedTTestNMBU", "Paired t-test",
      list(nv("first", "First variable"), nv("second", "Second variable"),
           ne("mu", "Null difference", "0"), ne("level", "Confidence level", "0.95"),
           alternative),
      function(values, state) build_t_test(
        "paired", RcmdrShiny::active_dataset(state), "", first = values$first,
        second = values$second, mu = values$mu, level = values$level,
        alternative = values$alternative
      )
    ),
    twoSamplesTTest = numbu_dialog(
      "twoSamplesTTest", "Two-sample t-test (unstacked)",
      list(nv("first", "First variable"), nv("second", "Second variable"),
           ne("level", "Confidence level", "0.95"), alternative,
           nchk("equal_variance", "Equal variances")),
      function(values, state) build_t_test(
        "unstacked", RcmdrShiny::active_dataset(state), "",
        first = values$first, second = values$second, level = values$level,
        alternative = values$alternative, equal_variance = values$equal_variance
      )
    ),
    oneSamplesTTestSum = numbu_dialog(
      "oneSamplesTTestSum", "One-sample t-test (summarized data)",
      list(ne("mean", "Mean", "0"), ne("sd", "Standard deviation", "1"),
           ne("n", "Sample size", "10"), ne("mu", "Null mean", "0"),
           ne("level", "Confidence level", "0.95"), alternative),
      function(values, state) build_t_summary(
        values$mean, values$sd, values$n, values$mu, values$level,
        values$alternative
      )
    ),
    twoSamplesTTestSum = numbu_dialog(
      "twoSamplesTTestSum", "Two-sample t-test (summarized data)",
      list(ne("mean1", "Mean 1", "0"), ne("sd1", "SD 1", "1"),
           ne("n1", "N 1", "10"), ne("mean2", "Mean 2", "0"),
           ne("sd2", "SD 2", "1"), ne("n2", "N 2", "10"),
           ne("level", "Confidence level", "0.95"), alternative),
      function(values, state) build_t_summary(
        as.numeric(values$mean1) - as.numeric(values$mean2),
        sqrt(as.numeric(values$sd1)^2 / as.numeric(values$n1) +
               as.numeric(values$sd2)^2 / as.numeric(values$n2)),
        as.numeric(values$n1) + as.numeric(values$n2) - 2,
        0, values$level, values$alternative
      )
    ),
    powerTtest = numbu_dialog(
      "powerTtest", "Power calculations for t tests",
      list(ne("delta", "Difference", "0.5"), ne("sd", "Standard deviation", "1"),
           ne("n", "Sample size", "30"), ne("alpha", "Significance level", "0.05"),
           nc("type", "Test type", c("two.sample" = "two.sample",
                                     "one.sample" = "one.sample",
                                     "paired" = "paired"))),
      function(values, state) build_power_t(
        values$delta, values$sd, values$n, values$alpha, values$type
      )
    ),
    singleSampleZTestNMBU = numbu_dialog(
      "singleSampleZTestNMBU", "Single-sample z-test",
      list(nv("response", "Variable"), ne("mu", "Null mean", "0"),
           ne("sigma", "Known sigma", "1"), alternative),
      function(values, state) build_z_test(
        "single", RcmdrShiny::active_dataset(state), values$response,
        mu = values$mu, sigma = values$sigma, alternative = values$alternative
      )
    ),
    independentSamplesZTestNMBU = numbu_dialog(
      "independentSamplesZTestNMBU", "Two-sample z-test (unstacked)",
      list(nv("first", "First variable"), nv("second", "Second variable"),
           ne("mu", "Null difference", "0"), ne("sigma", "Known sigma", "1"),
           alternative),
      function(values, state) build_z_test(
        "unstacked", RcmdrShiny::active_dataset(state), "",
        first = values$first, second = values$second, mu = values$mu,
        sigma = values$sigma, alternative = values$alternative
      )
    ),
    pairedZTestNMBU = numbu_dialog(
      "pairedZTestNMBU", "Paired z-test",
      list(nv("first", "First variable"), nv("second", "Second variable"),
           ne("mu", "Null difference", "0"), ne("sigma", "Known sigma", "1"),
           alternative),
      function(values, state) build_z_test(
        "paired", RcmdrShiny::active_dataset(state), "",
        first = values$first, second = values$second, mu = values$mu,
        sigma = values$sigma, alternative = values$alternative
      )
    ),
    proportionTest = numbu_dialog(
      "proportionTest", "Single-sample proportion test",
      list(ne("successes", "Successes", "0"), ne("n", "Sample size", "10"),
           ne("p0", "Null proportion", "0.5"), ne("level", "Confidence level", "0.95"),
           alternative),
      function(values, state) build_proportion(
        values$successes, values$n, values$p0, values$alternative, values$level
      )
    ),
    twoProportionTest = numbu_dialog(
      "twoProportionTest", "Two-sample proportion test",
      list(ne("s1", "Successes 1", "0"), ne("n1", "Sample size 1", "10"),
           ne("s2", "Successes 2", "0"), ne("n2", "Sample size 2", "10"),
           ne("level", "Confidence level", "0.95"), alternative),
      function(values, state) build_two_proportion(
        values$s1, values$n1, values$s2, values$n2, values$alternative,
        values$level
      )
    )
  )
}

nmodel_dialogs <- function() {
  list(
    oneWayAnovaNMBU = numbu_dialog(
      "oneWayAnovaNMBU", "One-way ANOVA",
      list(nv("response", "Response"), nv("factor", "Factor", "factor")),
      function(values, state) build_anova_nmbu(
        RcmdrShiny::active_dataset(state), values$response, values$factor,
        interaction = FALSE
      )
    ),
    multiWayAnovaNMBU = numbu_dialog(
      "multiWayAnovaNMBU", "Multi-way ANOVA",
      list(nv("response", "Response"), nv("factors", "Factors", "factor", TRUE),
           nchk("interaction", "Include interactions", TRUE)),
      function(values, state) build_anova_nmbu(
        RcmdrShiny::active_dataset(state), values$response, values$factors,
        values$interaction
      )
    ),
    plsRegressionModel = numbu_dialog(
      "plsRegressionModel", "Partial least squares regression",
      list(nv("response", "Response"), nv("predictors", "Predictors", multiple = TRUE),
           ne("components", "Components", "2")),
      function(values, state) build_pls(
        RcmdrShiny::active_dataset(state), values$response, values$predictors,
        values$components
      )
    ),
    predictRegressionModel = numbu_dialog(
      "predictRegressionModel", "Prediction",
      list(ne("dataset", "Data set name", "")),
      function(values, state) {
        model <- RcmdrShiny::active_model(state)
        if (is.null(model)) stop("No active model.")
        build_prediction(model, values$dataset)
      }
    ),
    coefNMBU = numbu_dialog(
      "coefNMBU", "Regression coefficients", list(),
      function(values, state) {
        model <- RcmdrShiny::active_model(state)
        if (is.null(model)) stop("No active model.")
        build_coefficients(model)
      }
    ),
    forwardAdd = numbu_dialog(
      "forwardAdd", "Forward selection", list(),
      function(values, state) build_stepwise(RcmdrShiny::active_model(state), "forward")
    ),
    backwardDrop = numbu_dialog(
      "backwardDrop", "Backward elimination", list(),
      function(values, state) build_stepwise(RcmdrShiny::active_model(state), "backward")
    ),
    forwardBackward = numbu_dialog(
      "forwardBackward", "Forward/backward selection", list(),
      function(values, state) build_stepwise(RcmdrShiny::active_model(state), "both")
    ),
    plotModelNMBU = numbu_dialog(
      "plotModelNMBU", "Basic diagnostic plots", list(),
      function(values, state) sprintf("plot(%s)", RcmdrShiny::active_model(state))
    ),
    addObservationStatisticsNMBU = numbu_dialog(
      "addObservationStatisticsNMBU", "Add observation statistics", list(),
      function(values, state) {
        model <- RcmdrShiny::active_model(state)
        dataset <- RcmdrShiny::active_dataset(state)
        c(
          sprintf("%s$.fitted <- fitted(%s)", dataset, model),
          sprintf("%s$.resid <- residuals(%s)", dataset, model)
        )
      }
    )
  )
}

numbu_dialogs <- function() {
  dialogs <- list()
  for (part in list(ntest_dialogs(), nmodel_dialogs())) {
    for (name in names(part)) dialogs[[name]] <- part[[name]]
  }
  aliases <- list(
    linearModelNMBU = "linearModel",
    generalizedLinearModelNMBU = "generalizedLinearModel",
    multinomialLogitModelNMBU = "multinomialLogitModel",
    ordinalRegressionModelNMBU = "ordinalRegressionModel",
    principalComponentsStat = "principalComponents"
  )
  for (new_name in names(aliases)) {
    spec <- RcmdrShiny::get_dialog(aliases[[new_name]])
    if (!is.null(spec)) dialogs[[new_name]] <- spec
  }
  dialogs
}
