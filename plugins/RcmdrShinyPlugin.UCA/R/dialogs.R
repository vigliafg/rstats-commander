# Shiny dialogs for the UCA plugin --------------------------------------

uca_with_sizes <- function(type) type %in% c("c", "np", "p", "u")
uca_multicolumn <- function(type) type %in% c("R", "S", "xbar")

uca_qcc_dialog <- function(id, title, type, phase = "1",
                           graph_title = title,
                           x1title = "Measurements",
                           n1title = "Sample size",
                           x2title = "Measurements (Phase II)",
                           n2title = "Sample size (Phase II)",
                           help = "qcc") {
  ns <- function(x) paste0(id, "_", x)
  phase <- match.arg(phase, c("1", "2", "p"))
  with_sizes <- uca_with_sizes(type)

  RcmdrShiny::plugin_dialog(
    id = id, title = title, help = help, help_package = "qcc",
    ui = function(state, memory) {
      numeric <- RcmdrShiny::numeric_variables(state)
      htmltools::tagList(
        if (identical(phase, "p")) {
          htmltools::tagList(
            RcmdrShiny::entry_input(ns("center"), "Center:",
                                    memory$center %||% ""),
            if (uca_multicolumn(type)) {
              RcmdrShiny::entry_input(ns("stddev"), "Standard deviation:",
                                      memory$stddev %||% "")
            }
          )
        },
        if (phase %in% c("1", "2")) {
          htmltools::tagList(
            RcmdrShiny::var_input(
              ns("x1"), x1title, numeric,
              memory$x1 %||% character(), multiple = TRUE
            ),
            if (with_sizes) {
              RcmdrShiny::var_input(
                ns("n1"), n1title, numeric,
                memory$n1 %||% character(), multiple = FALSE
              )
            },
            RcmdrShiny::subset_input(ns("subset"), value = memory$subset %||% "")
          )
        },
        if (phase %in% c("2", "p")) {
          htmltools::tagList(
            RcmdrShiny::var_input(
              ns("x2"), x2title, numeric,
              memory$x2 %||% character(), multiple = TRUE
            ),
            if (with_sizes) {
              RcmdrShiny::var_input(
                ns("n2"), n2title, numeric,
                memory$n2 %||% character(), multiple = FALSE
              )
            },
            RcmdrShiny::subset_input(ns("subset2"), value = memory$subset2 %||% "")
          )
        },
        if (identical(phase, "2")) {
          htmltools::tagList(
            RcmdrShiny::checkbox_input(
              ns("plot_all"), "Plot all data", memory$plot_all %||% FALSE
            ),
            RcmdrShiny::checkbox_input(
              ns("renumber"), "Renumber second phase data",
              memory$renumber %||% FALSE
            )
          )
        }
      )
    },
    on_ok = function(input, state) {
      options <- list(
        x1 = input[[ns("x1")]] %||% character(),
        n1 = input[[ns("n1")]] %||% "",
        subset = input[[ns("subset")]] %||% "",
        x2 = input[[ns("x2")]] %||% character(),
        n2 = input[[ns("n2")]] %||% "",
        subset2 = input[[ns("subset2")]] %||% "",
        center = input[[ns("center")]] %||% "",
        stddev = input[[ns("stddev")]] %||% "",
        plot_all = isTRUE(input[[ns("plot_all")]]),
        renumber = isTRUE(input[[ns("renumber")]])
      )
      command <- tryCatch(
        build_qcc_command(
          RcmdrShiny::active_dataset(state), type, phase,
          options$x1, options$n1, options$subset,
          options$x2, options$n2, options$subset2,
          options$center, options$stddev, graph_title,
          options$plot_all, options$renumber
        ),
        error = function(e) e
      )
      if (inherits(command, "error")) {
        return(list(error = conditionMessage(command)))
      }
      list(commands = command, memory = options, plot = TRUE)
    }
  )
}

uca_qcc_dialogs <- function() {
  list(
    pchart1Menu = uca_qcc_dialog(
      "pchart1Menu", "p-chart", "p", "1", "p-chart\nfor",
      "Nonconforming units", "Sample size", help = "p-chart"
    ),
    pchart2Menu = uca_qcc_dialog(
      "pchart2Menu", "p-chart phase II from data", "p", "2",
      "p-chart phase II\nfor", "Nonconforming units (Phase I)",
      "Sample size (Phase I)", "Nonconforming units (Phase II)",
      "Sample size (Phase II)", help = "p-chart"
    ),
    pchartpMenu = uca_qcc_dialog(
      "pchartpMenu", "p-chart phase II from parameter", "p", "p",
      "p-chart phase II\nfor", "Nonconforming units (Phase I)",
      "Sample size (Phase I)", "Nonconforming units (Phase II)",
      "Sample size (Phase II)", help = "p-chart"
    ),
    npchart1Menu = uca_qcc_dialog(
      "npchart1Menu", "np-chart", "np", "1", "np-chart\nfor",
      "Nonconforming units", "Sample size", help = "np-chart"
    ),
    npchart2Menu = uca_qcc_dialog(
      "npchart2Menu", "np-chart phase II from data", "np", "2",
      "np-chart phase II\nfor", "Nonconforming units (Phase I)",
      "Sample size (Phase I)", "Nonconforming units (Phase II)",
      "Sample size (Phase II)", help = "np-chart"
    ),
    npchartpMenu = uca_qcc_dialog(
      "npchartpMenu", "np-chart phase II from parameter", "np", "p",
      "np-chart phase II\nfor", "Nonconforming units (Phase I)",
      "Sample size (Phase I)", "Nonconforming units (Phase II)",
      "Sample size (Phase II)", help = "np-chart"
    ),
    uchart1Menu = uca_qcc_dialog(
      "uchart1Menu", "u-chart (average rate)", "u", "1", "u-chart\nfor",
      "Nonconformities", "Sizes", help = "u-chart"
    ),
    uchart2Menu = uca_qcc_dialog(
      "uchart2Menu", "u-chart phase II from data", "u", "2",
      "u-chart phase II\nfor", "Nonconformities (Phase I)",
      "Sizes (Phase I)", "Nonconformities (Phase II)",
      "Sizes (Phase II)", help = "u-chart"
    ),
    uchartpMenu = uca_qcc_dialog(
      "uchartpMenu", "u-chart phase II from parameter", "u", "p",
      "u-chart phase II\nfor", "Nonconformities (Phase I)",
      "Sizes (Phase I)", "Nonconformities (Phase II)",
      "Sizes (Phase II)", help = "u-chart"
    ),
    cchart1Menu = uca_qcc_dialog(
      "cchart1Menu", "c-chart (rate)", "c", "1", "c-chart\nfor",
      "Nonconformities", "Sizes", help = "c-chart"
    ),
    cchart2Menu = uca_qcc_dialog(
      "cchart2Menu", "c-chart (rate) from data", "c", "2",
      "c-chart\nfor", "Nonconformities (Phase I)", "Sizes (Phase I)",
      "Nonconformities (Phase II)", "Sizes (Phase II)", help = "c-chart"
    ),
    cchartpMenu = uca_qcc_dialog(
      "cchartpMenu", "c-chart (rate) from parameter", "c", "p",
      "c-chart\nfor", "Nonconformities (Phase I)", "Sizes (Phase I)",
      "Nonconformities (Phase II)", "Sizes (Phase II)", help = "c-chart"
    ),
    xbar1mcMenu = uca_qcc_dialog(
      "xbar1mcMenu", "xbar-chart (multiple columns)", "xbar", "1",
      "xbar-chart\nfor", "Measurements (pick two or more)",
      help = "xbar-chart"
    ),
    xbar2mcMenu = uca_qcc_dialog(
      "xbar2mcMenu", "xbar-chart phase II from data (multiple columns)",
      "xbar", "2", "xbar-chart\nfor",
      "Measurements phase I (pick two or more)",
      x2title = "Measurements phase II (pick two or more)",
      help = "xbar-chart"
    ),
    xbarpmcMenu = uca_qcc_dialog(
      "xbarpmcMenu",
      "xbar-chart phase II from parameters (multiple columns)",
      "xbar", "p", "xbar-chart\nfor",
      "Measurements phase I (pick two or more)",
      x2title = "Measurements phase II (pick two or more)",
      help = "xbar-chart"
    ),
    R1mcMenu = uca_qcc_dialog(
      "R1mcMenu", "R-chart phase I (multiple columns)", "R", "1",
      "R-chart\nfor", "Measurements (pick two or more)", help = "R-chart"
    ),
    R2mcMenu = uca_qcc_dialog(
      "R2mcMenu", "R-chart phase II from data (multiple columns)", "R", "2",
      "R-chart\nfor", "Measurements phase I from data (pick two or more)",
      x2title = "Measurements phase II from data (pick two or more)",
      help = "R-chart"
    ),
    RpmcMenu = uca_qcc_dialog(
      "RpmcMenu", "R-chart phase II from parameters (multiple columns)", "R",
      "p", "R-chart\nfor",
      "Measurements phase I from parameters (pick two or more)",
      x2title = "Measurements phase II from parameters (pick two or more)",
      help = "R-chart"
    ),
    S1mcMenu = uca_qcc_dialog(
      "S1mcMenu", "S-chart (multiple columns)", "S", "1", "S-chart\nfor",
      "Measurements (pick two or more)", help = "S-chart"
    ),
    S2mcMenu = uca_qcc_dialog(
      "S2mcMenu", "S-chart phase II from data (multiple columns)", "S", "2",
      "S-chart\nfor", "Measurements phase I (pick two or more)",
      x2title = "Measurements phase II (pick two or more)", help = "S-chart"
    ),
    SpmcMenu = uca_qcc_dialog(
      "SpmcMenu", "S-chart phase II from parameters (multiple columns)", "S",
      "p", "S-chart\nfor", "Measurements phase I (pick two or more)",
      x2title = "Measurements phase II (pick two or more)", help = "S-chart"
    )
  )
}

uca_sigma_dialog <- function() {
  id <- "sigmaTest"
  ns <- function(x) paste0(id, "_", x)
  RcmdrShiny::plugin_dialog(
    id = id, title = "Single-Sample Variance Test", help = "sigma.test",
    help_package = "TeachingDemos",
    ui = function(state, memory) {
      htmltools::tagList(
        RcmdrShiny::var_input(
          ns("variable"), "Variable (pick one)",
          RcmdrShiny::numeric_variables(state),
          memory$variable %||% character(), multiple = FALSE
        ),
        RcmdrShiny::radio_input(
          ns("alternative"), "Alternative hypothesis",
          c("! = sigma0^2" = "two.sided", "< sigma0^2" = "less",
            "> sigma0^2" = "greater"),
          memory$alternative %||% "two.sided"
        ),
        RcmdrShiny::entry_input(
          ns("sigma"), "Null hypothesis: sigma^2 =", memory$sigma %||% "1.0"
        ),
        RcmdrShiny::entry_input(
          ns("level"), "Confidence level:", memory$level %||% "0.95"
        )
      )
    },
    on_ok = function(input, state) {
      variable <- input[[ns("variable")]] %||% ""
      if (!nzchar(variable)) return(list(error = "Select a variable."))
      options <- list(
        variable = variable,
        alternative = input[[ns("alternative")]] %||% "two.sided",
        sigma = input[[ns("sigma")]] %||% "1.0",
        level = input[[ns("level")]] %||% "0.95"
      )
      command <- tryCatch(
        build_sigma_command(
          RcmdrShiny::active_dataset(state), variable,
          options$alternative, options$sigma, options$level
        ),
        error = function(e) e
      )
      if (inherits(command, "error")) return(list(error = conditionMessage(command)))
      list(commands = command, memory = options)
    }
  )
}

uca_randomness_dialog <- function(type) {
  id <- if (identical(type, "factor")) "randomnessFTest" else "randomnessNTest"
  ns <- function(x) paste0(id, "_", x)
  choices <- if (identical(type, "factor")) {
    RcmdrShiny::factor_variables
  } else {
    RcmdrShiny::numeric_variables
  }
  RcmdrShiny::plugin_dialog(
    id = id,
    title = if (identical(type, "factor")) {
      "Randomness test for two level factor"
    } else {
      "Randomness test for numeric variable"
    },
    help = "runs.test", help_package = "tseries",
    ui = function(state, memory) {
      RcmdrShiny::var_input(
        ns("variable"), "Variable (pick one)", choices(state),
        memory$variable %||% character(), multiple = FALSE
      )
    },
    on_ok = function(input, state) {
      variable <- input[[ns("variable")]] %||% ""
      if (!nzchar(variable)) return(list(error = "Select a variable."))
      command <- build_randomness_command(
        RcmdrShiny::active_dataset(state), variable, type
      )
      list(commands = command, memory = list(variable = variable))
    }
  )
}

uca_pareto_dialog <- function() {
  id <- "paretochartMenu"
  ns <- function(x) paste0(id, "_", x)
  RcmdrShiny::plugin_dialog(
    id = id, title = "Pareto chart", help = "paretochart",
    help_package = "qicharts2",
    ui = function(state, memory) {
      RcmdrShiny::var_input(
        ns("variable"), "Variable", RcmdrShiny::factor_variables(state),
        memory$variable %||% character(), multiple = FALSE
      )
    },
    on_ok = function(input, state) {
      variable <- input[[ns("variable")]] %||% ""
      if (!nzchar(variable)) return(list(error = "Select a variable."))
      list(
        commands = build_pareto_command(
          RcmdrShiny::active_dataset(state), variable
        ),
        memory = list(variable = variable),
        plot = TRUE
      )
    }
  )
}

uca_predict_existing_dialog <- function() {
  id <- "predict4dataset"
  ns <- function(x) paste0(id, "_", x)
  RcmdrShiny::plugin_dialog(
    id = id, title = "Predict values for existing dataset", help = "predict",
    ui = function(state, memory) {
      sets <- ls(envir = state$env)
      sets <- sets[vapply(sets, function(name) {
        is.data.frame(get(name, envir = state$env, inherits = FALSE))
      }, logical(1))]
      RcmdrShiny::var_input(
        ns("dataset"), "Data set (pick one)", sort(sets),
        memory$dataset %||% RcmdrShiny::active_dataset(state) %||% character(),
        multiple = FALSE
      )
    },
    on_ok = function(input, state) {
      dataset <- input[[ns("dataset")]] %||% ""
      model <- RcmdrShiny::active_model(state)
      if (!nzchar(dataset)) return(list(error = "Select a data set."))
      if (is.null(model)) return(list(error = "No active model."))
      list(
        commands = build_predict_existing_command(model, dataset),
        memory = list(dataset = dataset),
        activate_dataset = dataset
      )
    }
  )
}

uca_predict_new_dialog <- function() {
  id <- "input2predict"
  ns <- function(x) paste0(id, "_", x)
  RcmdrShiny::plugin_dialog(
    id = id, title = "Input data and predict", help = "predict",
    ui = function(state, memory) {
      model <- RcmdrShiny::active_model(state)
      predictors <- uca_model_predictors(state)
      object <- if (is.null(model)) NULL else {
        get(model, envir = state$env, inherits = FALSE)
      }
      frame <- if (is.null(object)) NULL else {
        tryCatch(stats::model.frame(object), error = function(e) NULL)
      }
      fields <- lapply(predictors, function(name) {
        column <- if (!is.null(frame) && name %in% names(frame)) {
          frame[[name]]
        } else {
          NULL
        }
        if (is.factor(column) || is.character(column) || is.logical(column)) {
          choices <- if (is.factor(column)) levels(column) else unique(as.character(column))
          RcmdrShiny::combo_input(
            ns(name), name, choices, memory[[name]] %||% choices[[1L]]
          )
        } else {
          RcmdrShiny::entry_input(
            ns(name), name, memory[[name]] %||% ""
          )
        }
      })
      htmltools::tagList(
        htmltools::tags$p(
          htmltools::tags$strong("Active model: "), model %||% "none"
        ),
        if (length(predictors) == 0L) {
          htmltools::tags$p(class = "text-danger", "No predictors found.")
        } else {
          fields
        }
      )
    },
    on_ok = function(input, state) {
      model <- RcmdrShiny::active_model(state)
      if (is.null(model)) return(list(error = "No active model."))
      predictors <- uca_model_predictors(state)
      object <- get(model, envir = state$env, inherits = FALSE)
      frame <- tryCatch(stats::model.frame(object), error = function(e) NULL)
      values <- list()
      for (name in predictors) {
        value <- input[[ns(name)]]
        if (!is.null(frame) && name %in% names(frame)) {
          if (is.numeric(frame[[name]])) {
            value <- suppressWarnings(as.numeric(value))
          } else {
            value <- as.character(value)
          }
        }
        values[[name]] <- value
      }
      command <- tryCatch(
        build_predict_new_command(model, values),
        error = function(e) e
      )
      if (inherits(command, "error")) return(list(error = conditionMessage(command)))
      list(commands = command, memory = values)
    }
  )
}

uca_dialogs <- function() {
  c(
    list(
      sigmaTest = uca_sigma_dialog(),
      randomnessFTest = uca_randomness_dialog("factor"),
      randomnessNTest = uca_randomness_dialog("numeric"),
      paretochartMenu = uca_pareto_dialog(),
      predict4dataset = uca_predict_existing_dialog(),
      input2predict = uca_predict_new_dialog()
    ),
    uca_qcc_dialogs()
  )
}
