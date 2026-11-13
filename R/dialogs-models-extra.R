# Models, Tools and Help dialogs --------------------------------------------

model_choices <- function(state) list_all_models(state)

model_name <- function(state) active_model(state)

require_model <- function(state, message = NULL) {
  model <- active_model(state)
  if (is.null(model)) message %||% tr("There is no active model.") else NULL
}

model_combo <- function(id, state, selected = NULL, label = tr("Model")) {
  choices <- model_choices(state)
  combo_input(id, label, stats::setNames(choices, choices),
              selected = selected %||% (choices[[1L]] %||% NULL))
}

select_active_model_dialog <- function() {
  id <- "selectActiveModel"
  ns <- function(x) paste0(id, "_", x)

  dialog_spec(
    id = id, title = tr("Select Active Model"), help = "models",
    ui = function(state, memory) {
      model_combo(ns("model"), state, memory$model, tr("Models (pick one)"))
    },
    on_ok = function(input, state) {
      model <- input[[ns("model")]] %||% ""
      if (!nzchar(model)) return(list(error = tr("There are no models from which to choose.")))
      list(activate_model = model, memory = list(model = model))
    }
  )
}

compare_coefficients_dialog <- function() {
  id <- "compareCoefficients"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(models = NULL)

  dialog_spec(
    id = id, title = tr("Compare Model Coefficients"), help = "compareCoefs",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      var_input(ns("models"), tr("Models (pick two or more)"),
                model_choices(state), selected = m$models, multiple = TRUE)
    },
    on_ok = function(input, state) {
      models <- input[[ns("models")]]
      if (length(models) < 2L) {
        return(list(error = tr("You must select at least two models.")))
      }
      list(commands = cmd_compare_coefficients(models),
           memory = list(models = models))
    }
  )
}

add_observation_statistics_dialog <- function() {
  id <- "addObservationStatistics"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(fitted = TRUE, residuals = TRUE, rstudent = TRUE,
                   hatvalues = TRUE, cookd = TRUE, obsNumbers = TRUE)

  dialog_spec(
    id = id, title = tr("Add Observation Statistics to Data"), help = "fitted",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        checkboxes_input(
          ns("statistics"),
          c(fitted = tr("Fitted values"), residuals = tr("Residuals"),
            rstudent = tr("Studentized residuals"), hatvalues = tr("Hat-values"),
            cookd = tr("Cook's distances"), obsNumbers = tr("Observation indices")),
          selected = names(Filter(isTRUE, m))
        ),
        help_text(tr("Observation statistics are added to the active data set."))
      )
    },
    on_ok = function(input, state) {
      error <- require_model(state)
      if (!is.null(error)) return(list(error = error))
      choices <- c("fitted", "residuals", "rstudent", "hatvalues", "cookd",
                   "obsNumbers")
      selected <- choices[vapply(choices, function(choice) {
        isTRUE(input[[paste0(ns("statistics"), "_", choice)]])
      }, logical(1))]
      if (length(selected) == 0L) {
        return(list(error = tr("You must select at least one statistic.")))
      }
      model <- active_model(state)
      list(
        commands = cmd_add_observation_statistics(active_dataset(state),
                                                  model, selected),
        activate_dataset = active_dataset(state),
        memory = setNames(as.list(rep(TRUE, length(selected))), selected)
      )
    }
  )
}

stepwise_regression_dialog <- function() {
  id <- "stepwiseRegression"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(direction = "backward", criterion = "BIC")

  dialog_spec(
    id = id, title = tr("Stepwise Model Selection"), help = "stepwise",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        model_combo(ns("model"), state, memory$model),
        radio_input(ns("direction"), tr("Direction"),
                    c("Backward/forward" = "backward",
                      "Forward/backward" = "forward"), m$direction),
        radio_input(ns("criterion"), tr("Criterion"),
                    c("AIC" = "AIC", "BIC" = "BIC"), m$criterion)
      )
    },
    on_ok = function(input, state) {
      error <- require_model(state)
      if (!is.null(error)) return(list(error = error))
      list(
        commands = cmd_stepwise(
          input[[ns("model")]] %||% active_model(state),
          input[[ns("direction")]] %||% "backward",
          input[[ns("criterion")]] %||% "BIC"
        ),
        memory = list(model = input[[ns("model")]] %||% "",
                      direction = input[[ns("direction")]] %||% "backward",
                      criterion = input[[ns("criterion")]] %||% "BIC")
      )
    }
  )
}

subset_regression_dialog <- function() {
  id <- "subsetRegression"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(response = NULL, predictors = NULL, nbest = 1L)

  dialog_spec(
    id = id, title = tr("Subset Model Selection"), help = "regsubsets",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        var_input(ns("response"), tr("Response variable:"),
                  numeric_variables(state), selected = m$response),
        var_input(ns("predictors"), tr("Predictors:"),
                  variables(state), selected = m$predictors, multiple = TRUE),
        spin_input(ns("nbest"), tr("Number of best models:"), m$nbest,
                   min = 1, max = 50)
      )
    },
    on_ok = function(input, state) {
      response <- input[[ns("response")]] %||% ""
      predictors <- input[[ns("predictors")]]
      if (!nzchar(response) || length(predictors) == 0L) {
        return(list(error = tr("You must select a response and predictors.")))
      }
      list(
        commands = cmd_subset_regression(
          active_dataset(state), response, predictors,
          input[[ns("nbest")]] %||% 1
        ),
        memory = list(response = response, predictors = predictors,
                      nbest = input[[ns("nbest")]] %||% 1)
      )
    }
  )
}

confidence_intervals_dialog <- function() {
  id <- "confidenceIntervals"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(level = 0.95, type = "LR")

  dialog_spec(
    id = id, title = tr("Confidence Intervals"), help = "Confint",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        model_combo(ns("model"), state, memory$model),
        stats_confidence_input(ns("level"), m$level),
        radio_input(ns("type"), tr("Test Based On"),
                    c("Likelihood-ratio statistic" = "LR",
                      "Wald statistic" = "Wald"), m$type)
      )
    },
    on_ok = function(input, state) {
      error <- require_model(state)
      if (!is.null(error)) return(list(error = error))
      list(
        commands = cmd_confidence_intervals(
          input[[ns("model")]] %||% active_model(state),
          input[[ns("level")]] %||% 0.95,
          input[[ns("type")]] %||% "LR"
        ),
        memory = list(model = input[[ns("model")]] %||% "",
                      level = input[[ns("level")]] %||% 0.95,
                      type = input[[ns("type")]] %||% "LR")
      )
    }
  )
}

bootstrap_dialog <- function() {
  id <- "Bootstrap"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(samples = 1000L, level = 0.95, type = "perc",
                   method = "case")

  dialog_spec(
    id = id, title = tr("Bootstrap Confidence Intervals"), help = "Boot",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        model_combo(ns("model"), state, memory$model),
        spin_input(ns("samples"), tr("Number of bootstrap samples:"), m$samples,
                   min = 1, max = 100000),
        stats_confidence_input(ns("level"), m$level),
        radio_input(ns("type"), tr("Interval type"),
                    c("Percentile" = "perc", "Normal" = "norm",
                      "Basic" = "basic"), m$type),
        radio_input(ns("method"), tr("Resampling method"),
                    c("Cases" = "case", "Residuals" = "residual"), m$method)
      )
    },
    on_ok = function(input, state) {
      error <- require_model(state)
      if (!is.null(error)) return(list(error = error))
      list(
        commands = cmd_bootstrap(
          input[[ns("model")]] %||% active_model(state),
          input[[ns("samples")]] %||% 1000,
          input[[ns("level")]] %||% 0.95,
          input[[ns("type")]] %||% "perc",
          input[[ns("method")]] %||% "case"
        ),
        memory = list(model = input[[ns("model")]] %||% "",
                      samples = input[[ns("samples")]] %||% 1000,
                      level = input[[ns("level")]] %||% 0.95,
                      type = input[[ns("type")]] %||% "perc",
                      method = input[[ns("method")]] %||% "case")
      )
    }
  )
}

delta_method_dialog <- function() {
  id <- "DeltaMethodConfInt"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(expression = "", level = 0.95)

  dialog_spec(
    id = id, title = tr("Delta Method Confidence Interval"), help = "DeltaMethod",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        model_combo(ns("model"), state, memory$model),
        entry_input(ns("expression"), tr("Expression in model coefficients:"),
                    m$expression),
        stats_confidence_input(ns("level"), m$level)
      )
    },
    on_ok = function(input, state) {
      error <- require_model(state)
      if (!is.null(error)) return(list(error = error))
      expression <- trim_blanks(input[[ns("expression")]] %||% "")
      if (!nzchar(expression)) {
        return(list(error = tr("You must specify an expression.")))
      }
      list(
        commands = cmd_delta_method(
          input[[ns("model")]] %||% active_model(state), expression,
          input[[ns("level")]] %||% 0.95
        ),
        memory = list(model = input[[ns("model")]] %||% "",
                      expression = expression,
                      level = input[[ns("level")]] %||% 0.95)
      )
    }
  )
}

anova_table_dialog <- function() {
  id <- "anovaTable"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(type = "II", test = "F", use_car = TRUE)

  dialog_spec(
    id = id, title = tr("ANOVA Table"), help = "Anova",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        model_combo(ns("model"), state, memory$model),
        radio_input(ns("type"), tr("Type"),
                    c("Type II" = "II", "Type III" = "III"), m$type),
        radio_input(ns("test"), tr("Test"),
                    c("F" = "F", "Chi-square" = "Chisq"), m$test),
        checkbox_input(ns("use_car"), tr("Use car::Anova()"), m$use_car)
      )
    },
    on_ok = function(input, state) {
      error <- require_model(state)
      if (!is.null(error)) return(list(error = error))
      list(
        commands = cmd_anova_table(
          input[[ns("model")]] %||% active_model(state),
          input[[ns("type")]] %||% "II",
          input[[ns("test")]] %||% "F",
          isTRUE(input[[ns("use_car")]])
        ),
        memory = list(model = input[[ns("model")]] %||% "",
                      type = input[[ns("type")]] %||% "II",
                      test = input[[ns("test")]] %||% "F",
                      use_car = isTRUE(input[[ns("use_car")]]))
      )
    }
  )
}

compare_models_dialog <- function() {
  id <- "compareModels"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(first = NULL, second = NULL, test = "F")

  dialog_spec(
    id = id, title = tr("Compare Two Models"), help = "anova",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        model_combo(ns("first"), state, m$first, tr("First model")),
        model_combo(ns("second"), state, m$second, tr("Second model")),
        radio_input(ns("test"), tr("Test"), c("F" = "F", "Chi-square" = "Chisq"),
                    m$test)
      )
    },
    on_ok = function(input, state) {
      first <- input[[ns("first")]] %||% ""
      second <- input[[ns("second")]] %||% ""
      if (!nzchar(first) || !nzchar(second)) {
        return(list(error = tr("You must select two models.")))
      }
      if (identical(first, second)) {
        return(list(error = tr("The two models must be different.")))
      }
      list(
        commands = cmd_compare_models(first, second,
                                      input[[ns("test")]] %||% "F"),
        memory = list(first = first, second = second,
                      test = input[[ns("test")]] %||% "F")
      )
    }
  )
}

linear_hypothesis_dialog <- function() {
  id <- "testLinearHypothesis"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(hypothesis = "", level = 0.95)

  dialog_spec(
    id = id, title = tr("Linear Hypothesis"), help = "linearHypothesis",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        model_combo(ns("model"), state, memory$model),
        text_area(ns("hypothesis"), tr("Hypothesis (e.g. x = 0):"),
                  m$hypothesis, rows = 3L),
        stats_confidence_input(ns("level"), m$level)
      )
    },
    on_ok = function(input, state) {
      error <- require_model(state)
      if (!is.null(error)) return(list(error = error))
      hypothesis <- trim_blanks(input[[ns("hypothesis")]] %||% "")
      if (!nzchar(hypothesis)) return(list(error = tr("You must specify a hypothesis.")))
      list(
        commands = cmd_linear_hypothesis(
          input[[ns("model")]] %||% active_model(state), hypothesis,
          input[[ns("level")]] %||% 0.95
        ),
        memory = list(model = input[[ns("model")]] %||% "",
                      hypothesis = hypothesis,
                      level = input[[ns("level")]] %||% 0.95)
      )
    }
  )
}

diagnostic_dialog <- function(id, title, help, builder, extra_ui) {
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(model = NULL)

  dialog_spec(
    id = id, title = title, help = help,
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        model_combo(ns("model"), state, m$model),
        if (!is.null(extra_ui)) extra_ui(m, ns)
      )
    },
    on_ok = function(input, state) {
      error <- require_model(state)
      if (!is.null(error)) return(list(error = error))
      model <- input[[ns("model")]] %||% active_model(state)
      list(commands = builder(input, ns, state, model),
           memory = list(model = model))
    }
  )
}

breusch_pagan_dialog <- function() {
  diagnostic_dialog(
    "BreuschPaganTest", tr("Breusch-Pagan Test"), "bptest",
    function(input, ns, state, model) {
      cmd_bptest(model, active_dataset(state),
                 isTRUE(input[[ns("studentize")]]))
    },
    function(m, ns) {
      checkbox_input(ns("studentize"), tr("Studentized test"), TRUE)
    }
  )
}

durbin_watson_dialog <- function() {
  diagnostic_dialog(
    "DurbinWatsonTest", tr("Durbin-Watson Test"), "dwtest",
    function(input, ns, state, model) {
      cmd_dwtest(model, active_dataset(state), input[[ns("alternative")]] %||% "two.sided")
    },
    function(m, ns) {
      radio_input(ns("alternative"), tr("Alternative Hypothesis"),
                  c("Two-sided" = "two.sided", "Positive autocorrelation" = "greater",
                    "Negative autocorrelation" = "less"),
                  "two.sided")
    }
  )
}

reset_test_dialog <- function() {
  diagnostic_dialog(
    "RESETtest", tr("RESET Test"), "resettest",
    function(input, ns, state, model) {
      cmd_resettest(model, active_dataset(state),
                    input[[ns("power")]] %||% "2:3",
                    input[[ns("type")]] %||% "fitted")
    },
    function(m, ns) {
      htmltools::tagList(
        entry_input(ns("power"), tr("Powers to test:"), "2:3"),
        radio_input(ns("type"), tr("Fitted values"),
                    c("Fitted values" = "fitted", "Regressors" = "regressor",
                      "Fitted + regressors" = "fitted+regressor"), "fitted")
      )
    }
  )
}

transform_response_dialog <- function() {
  diagnostic_dialog(
    "transformResponse", tr("Response Transformation"), "powerTransform",
    function(input, ns, state, model) {
      cmd_transform_response(model, input[[ns("family")]] %||% "bcPower")
    },
    function(m, ns) {
      radio_input(ns("family"), tr("Transformation Family"),
                  c("Box-Cox" = "bcPower", "Box-Cox with negatives" = "bcnPower",
                    "Yeo-Johnson" = "yjPower"), "bcPower")
    }
  )
}

residual_qq_dialog <- function() {
  diagnostic_dialog(
    "residualQQPlot", tr("Residual Quantile-Comparison Plot"), "qqPlot",
    function(input, ns, state, model) {
      cmd_residual_qq(model, isTRUE(input[[ns("simulate")]]))
    },
    function(m, ns) {
      checkbox_input(ns("simulate"), tr("Simulate envelope"), TRUE)
    }
  )
}

crplots_dialog <- function() {
  diagnostic_dialog(
    "CRPlots", tr("Component+Residual Plots"), "crPlots",
    function(input, ns, state, model) {
      cmd_crplots(model, (input[[ns("span")]] %||% 50) / 100)
    },
    function(m, ns) {
      slider_input(ns("span"), tr("Span for smooth"), 5, 100, 50, 5)
    }
  )
}

identification_dialog <- function(id, title, help, builder) {
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(method = "auto", n = 2L)

  dialog_spec(
    id = id, title = title, help = help,
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        model_combo(ns("model"), state, memory$model),
        radio_input(ns("method"), tr("Identify Points"),
                    c("Automatically" = "auto", "Do not identify" = "not",
                      "Interactively with mouse" = "mouse"), m$method),
        spin_input(ns("n"), tr("Number of points to identify:"), m$n,
                   min = 0, max = 20)
      )
    },
    on_ok = function(input, state) {
      error <- require_model(state)
      if (!is.null(error)) return(list(error = error))
      method <- input[[ns("method")]] %||% "auto"
      n <- as.integer(input[[ns("n")]] %||% 2)
      if (is.na(n)) return(list(error = tr("The number of points must be an integer.")))
      list(
        commands = builder(active_model(state), method, n),
        memory = list(model = input[[ns("model")]] %||% "",
                      method = method, n = n)
      )
    }
  )
}

avplots_dialog <- function() {
  identification_dialog(
    "AVPlots", tr("Added-Variable Plots"), "avPlots",
    function(model, method, n) {
      cmd_avplots(model, if (identical(method, "auto")) "mahal" else
        if (identical(method, "mouse")) "identify" else "mahal",
        if (identical(method, "not")) 0 else n)
    }
  )
}

influence_plot_dialog <- function() {
  identification_dialog(
    "InfluencePlot", tr("Influence Plot"), "influencePlot",
    function(model, method, n) {
      cmd_influence_plot(model, if (identical(method, "mouse")) "identify" else "noteworthy", n)
    }
  )
}

influence_index_dialog <- function() {
  identification_dialog(
    "InfluenceIndexPlot", tr("Influence Index Plot"), "influenceIndexPlot",
    function(model, method, n) {
      cmd_influence_index(model, if (identical(method, "mouse")) "identify" else "y", n)
    }
  )
}

effect_plots_dialog <- function(id, title, help, builder) {
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(all = TRUE, predictors = NULL, style = "stacked",
                   partial = FALSE, span = 0.5)

  dialog_spec(
    id = id, title = title, help = help,
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        model_combo(ns("model"), state, memory$model),
        checkbox_input(ns("all"), tr("Plot all high-order effects"), m$all),
        var_input(ns("predictors"), tr("Predictors (if not all)"),
                  variables(state), selected = m$predictors, multiple = TRUE),
        radio_input(ns("style"), tr("Style of Graph"),
                    c("Stacked areas" = "stacked",
                      "Lines with confidence bands" = "lines"), m$style),
        checkbox_input(ns("partial"), tr("Partial residuals"), m$partial),
        slider_input(ns("span"), tr("Span for smooth"), 5, 100,
                     round((m$span %||% 0.5) * 100), 5)
      )
    },
    on_ok = function(input, state) {
      error <- require_model(state)
      if (!is.null(error)) return(list(error = error))
      all <- isTRUE(input[[ns("all")]])
      predictors <- input[[ns("predictors")]]
      if (!all && length(predictors) == 0L) {
        return(list(error = tr("You must select one or more predictors or plot all effects.")))
      }
      list(
        commands = builder(
          input[[ns("model")]] %||% active_model(state), predictors, all,
          input[[ns("style")]] %||% "stacked",
          isTRUE(input[[ns("partial")]]),
          (input[[ns("span")]] %||% 50) / 100
        ),
        memory = list(model = input[[ns("model")]] %||% "",
                      all = all, predictors = predictors,
                      style = input[[ns("style")]] %||% "stacked",
                      partial = isTRUE(input[[ns("partial")]]),
                      span = (input[[ns("span")]] %||% 50) / 100)
      )
    }
  )
}

three_dimensional_model_dialog <- function(id, title, help, builder) {
  dialog_spec(
    id = id, title = title, help = help,
    ui = function(state, memory) {
      htmltools::tagList(
        model_combo(paste0(id, "_model"), state, memory$model),
        help_text(tr("This plot is rendered in the 3D pane."))
      )
    },
    on_ok = function(input, state) {
      error <- require_model(state)
      if (!is.null(error)) return(list(error = error))
      list(commands = builder(active_model(state)),
           memory = list(model = input[[paste0(id, "_model")]] %||% ""))
    }
  )
}

load_packages_dialog <- function() {
  id <- "loadPackages"
  ns <- function(x) paste0(id, "_", x)

  dialog_spec(
    id = id, title = tr("Load Package(s)"), help = "library",
    ui = function(state, memory) {
      installed <- rownames(utils::installed.packages())
      installed <- sort(setdiff(installed, .packages()))
      var_input(ns("packages"), tr("Packages (pick one or more)"),
                installed, selected = memory$packages, multiple = TRUE)
    },
    on_ok = function(input, state) {
      packages <- input[[ns("packages")]]
      if (length(packages) == 0L) {
        return(list(error = tr("You must select at least one package.")))
      }
      list(commands = cmd_load_packages(packages),
           memory = list(packages = packages))
    }
  )
}

phase5_dialogs <- function() {
  list(
    selectActiveModel = select_active_model_dialog(),
    compareCoefficients = compare_coefficients_dialog(),
    addObservationStatistics = add_observation_statistics_dialog(),
    stepwiseRegression = stepwise_regression_dialog(),
    subsetRegression = subset_regression_dialog(),
    confidenceIntervals = confidence_intervals_dialog(),
    Bootstrap = bootstrap_dialog(),
    DeltaMethodConfInt = delta_method_dialog(),
    anovaTable = anova_table_dialog(),
    compareModels = compare_models_dialog(),
    testLinearHypothesis = linear_hypothesis_dialog(),
    BreuschPaganTest = breusch_pagan_dialog(),
    DurbinWatsonTest = durbin_watson_dialog(),
    RESETtest = reset_test_dialog(),
    transformResponse = transform_response_dialog(),
    residualQQPlot = residual_qq_dialog(),
    CRPlots = crplots_dialog(),
    CRPlot3D = three_dimensional_model_dialog(
      "CRPlot3D", tr("3D Component+Residual Plot"), "crPlot3d", cmd_crplot3d
    ),
    AVPlots = avplots_dialog(),
    AVPlot3D = three_dimensional_model_dialog(
      "AVPlot3D", tr("3D Added-Variable Plot"), "avPlot3d", cmd_avplot3d
    ),
    InfluencePlot = influence_plot_dialog(),
    InfluenceIndexPlot = influence_index_dialog(),
    effectPlots = effect_plots_dialog(
      "effectPlots", tr("Effect Plots"), "effect", cmd_effect_plots
    ),
    predictorEffectPlots = effect_plots_dialog(
      "predictorEffectPlots", tr("Predictor Effect Plots"), "predictorEffects",
      cmd_predictor_effects
    ),
    loadPackages = load_packages_dialog()
  )
}
