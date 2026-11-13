# Shiny dialogs for survival --------------------------------------------

surv_dialog <- function(id, title, fields, build, help = NULL) {
  ns <- function(x) paste0(id, "_", x)
  RcmdrShiny::plugin_dialog(
    id = id, title = title, help = help, help_package = "survival",
    ui = function(state, memory) {
      htmltools::tagList(lapply(fields, function(field) {
        value <- if (is.null(memory)) NULL else memory[[field$name]]
        if (is.null(value)) value <- field$default
        if (identical(field$type, "variable")) {
          choices <- switch(
            field$kind,
            numeric = RcmdrShiny::numeric_variables(state),
            factor = RcmdrShiny::factor_variables(state),
            survtime = {
              df <- RcmdrShiny::dataset(state)
              if (is.null(df)) character() else names(df)[vapply(
                df, function(x) is.numeric(x) || inherits(x, "Date"),
                logical(1)
              )]
            },
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

sv <- function(name, label, kind = "numeric", multiple = FALSE,
               default = character()) {
  list(name = name, label = label, type = "variable", kind = kind,
       multiple = multiple, default = default)
}

survival_dialogs <- function() {
  list(
    Survfit = surv_dialog(
      "Survfit", "Survival function", list(
        sv("time", "Time variable", "survtime", default = ""),
        sv("event", "Event indicator", "numeric", default = ""),
        sv("strata", "Strata", "factor", multiple = TRUE),
        list(name = "conf_type", label = "Confidence type", type = "combo",
             choices = c("log" = "log", "log-log" = "log-log",
                         "plain" = "plain", "none" = "none"), default = "log"),
        list(name = "conf_int", label = "Confidence level", type = "entry",
             default = "0.95"),
        list(name = "detail", label = "Summary", type = "combo",
             choices = c("default" = "default", "detailed" = "detailed"),
             default = "default"),
        list(name = "quantiles", label = "Quantiles", type = "entry",
             default = "c(0.25, 0.5, 0.75)")
      ),
      function(values, state) {
        if (!nzchar(values$time)) stop("Select a time variable.")
        build_survfit(RcmdrShiny::active_dataset(state), values$time,
                      values$event %||% "", values$strata %||% character(),
                      values$conf_type, values$conf_int, values$detail,
                      values$quantiles)
      }
    ),
    Survdiff = surv_dialog(
      "Survdiff", "Compare survival functions", list(
        sv("time", "Time variable", "survtime", default = ""),
        sv("event", "Event indicator", "numeric", default = ""),
        sv("strata", "Strata", "factor", multiple = TRUE),
        list(name = "rho", label = "rho", type = "entry", default = "0")
      ),
      function(values, state) {
        if (!nzchar(values$time) || !nzchar(values$event)) {
          stop("Select time and event variables.")
        }
        if (length(values$strata) == 0L) stop("Select at least one stratum.")
        build_survdiff(RcmdrShiny::active_dataset(state), values$time,
                       values$event, values$strata, values$rho)
      }
    ),
    SurvivalData = surv_dialog(
      "SurvivalData", "Survival data definition", list(
        sv("time", "Time variable", "survtime", default = ""),
        sv("event", "Event indicator", "numeric", default = ""),
        sv("strata", "Strata", "factor", multiple = TRUE),
        list(name = "type", label = "Censoring type", type = "combo",
             choices = c("right" = "right", "left" = "left",
                         "interval" = "interval", "counting" = "counting"),
             default = "right")
      ),
      function(values, state) {
        if (!nzchar(values$time)) stop("Select a time variable.")
        build_survival_data(RcmdrShiny::active_dataset(state), values$time,
                            values$event %||% "", values$strata %||% character(),
                            values$type)
      }
    ),
    Unfold = surv_dialog(
      "Unfold", "Convert wide to long data", list(
        sv("time_vars", "Time variables", "survtime", multiple = TRUE),
        list(name = "timevar", label = "Time variable name", type = "entry",
             default = "time"),
        list(name = "v.names", label = "Response name", type = "entry",
             default = "response")
      ),
      function(values, state) {
        if (length(values$time_vars) < 2L) stop("Select at least two variables.")
        build_unfold(RcmdrShiny::active_dataset(state), "", values$time_vars,
                     values$timevar, values$v.names)
      }
    ),
    toDate = surv_dialog(
      "toDate", "Convert variable to date", list(
        sv("variable", "Variable", "all", default = ""),
        list(name = "format", label = "Date format", type = "entry",
             default = "%Y-%m-%d")
      ),
      function(values, state) {
        if (!nzchar(values$variable)) stop("Select a variable.")
        build_to_date(RcmdrShiny::active_dataset(state), values$variable,
                      values$format)
      }
    ),
    CoxModel = surv_dialog(
      "CoxModel", "Cox regression model", list(
        list(name = "model", label = "Model name", type = "entry",
             default = "CoxModel.1"),
        sv("time", "Time variable", "survtime", default = ""),
        sv("event", "Event indicator", "numeric", default = ""),
        sv("predictors", "Predictors", "all", multiple = TRUE),
        sv("strata", "Strata", "factor", multiple = TRUE),
        sv("cluster", "Cluster", "factor", default = ""),
        list(name = "ties", label = "Ties method", type = "combo",
             choices = c("efron" = "efron", "breslow" = "breslow",
                         "exact" = "exact"), default = "efron")
      ),
      function(values, state) {
        if (!nzchar(values$model)) stop("Enter a model name.")
        if (!nzchar(values$time) || !nzchar(values$event)) {
          stop("Select time and event variables.")
        }
        build_coxph(values$model, RcmdrShiny::active_dataset(state),
                    values$time, values$event, values$predictors,
                    values$strata %||% character(),
                    values$cluster %||% "", values$ties)
      }
    ),
    survregModel = surv_dialog(
      "survregModel", "Parametric survival model", list(
        list(name = "model", label = "Model name", type = "entry",
             default = "SurvregModel.1"),
        sv("time", "Time variable", "survtime", default = ""),
        sv("event", "Event indicator", "numeric", default = ""),
        sv("predictors", "Predictors", "all", multiple = TRUE),
        list(name = "distribution", label = "Distribution", type = "combo",
             choices = c("weibull" = "weibull", "exponential" = "exponential",
                         "lognormal" = "lognormal", "loglogistic" = "loglogistic",
                         "gaussian" = "gaussian"), default = "weibull")
      ),
      function(values, state) {
        if (!nzchar(values$model)) stop("Enter a model name.")
        build_survreg(values$model, RcmdrShiny::active_dataset(state),
                      values$time, values$event, values$predictors,
                      values$distribution)
      }
    ),
    CoxZPH = surv_dialog(
      "CoxZPH", "Test proportional hazards", list(),
      function(values, state) {
        model <- RcmdrShiny::active_model(state)
        if (is.null(model)) stop("No active model.")
        build_cox_zph(model)
      }
    ),
    PlotCoxph = surv_dialog(
      "PlotCoxph", "Cox-model survival function", list(),
      function(values, state) {
        model <- RcmdrShiny::active_model(state)
        if (is.null(model)) stop("No active model.")
        build_cox_plot(model)
      }
    ),
    TermPlots = surv_dialog(
      "TermPlots", "Plot terms in Cox model", list(),
      function(values, state) {
        model <- RcmdrShiny::active_model(state)
        if (is.null(model)) stop("No active model.")
        build_term_plot(model)
      }
    ),
    CoxDfbetas = surv_dialog(
      "CoxDfbetas", "Plot survival-regression dfbetas", list(),
      function(values, state) {
        model <- RcmdrShiny::active_model(state)
        if (is.null(model)) stop("No active model.")
        build_cox_dfbetas(model, "dfbetas")
      }
    ),
    CoxDfbeta = surv_dialog(
      "CoxDfbeta", "Plot survival-regression dfbeta", list(),
      function(values, state) {
        model <- RcmdrShiny::active_model(state)
        if (is.null(model)) stop("No active model.")
        build_cox_dfbetas(model, "dfbeta")
      }
    ),
    MartingalePlotsDialog = surv_dialog(
      "MartingalePlotsDialog", "Plot null Martingale residuals", list(),
      function(values, state) {
        model <- RcmdrShiny::active_model(state)
        if (is.null(model)) stop("No active model.")
        build_martingale(model)
      }
    ),
    PartialResPlots = surv_dialog(
      "PartialResPlots", "Cox-model partial-residual plots", list(),
      function(values, state) {
        model <- RcmdrShiny::active_model(state)
        if (is.null(model)) stop("No active model.")
        build_partial_residuals(model)
      }
    )
  )
}
