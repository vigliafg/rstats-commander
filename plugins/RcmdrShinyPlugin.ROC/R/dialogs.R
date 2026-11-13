# Shiny dialogs for ROC -------------------------------------------------

roc_memory <- function(memory, name, default) {
  if (is.null(memory) || is.null(memory[[name]])) default else memory[[name]]
}

roc_data_ui <- function(state, ns, memory, comparison = FALSE,
                        two_labels = FALSE, lr = FALSE) {
  numeric <- RcmdrShiny::numeric_variables(state)
  factors <- RcmdrShiny::factor_variables(state)
  tagList(
    if (!isTRUE(lr)) {
      RcmdrShiny::var_input(
        ns("prediction"), "Predictions variable 1 (pick one)",
        numeric, roc_memory(memory, "prediction", character()), multiple = FALSE
      )
    },
    if (isTRUE(comparison)) {
      RcmdrShiny::var_input(
        ns("prediction2"), "Predictions variable 2 (pick one)",
        numeric, roc_memory(memory, "prediction2", character()), multiple = FALSE
      )
    },
    if (isTRUE(two_labels)) {
      RcmdrShiny::var_input(
        ns("label"), "Outcome variable 1 (pick one)",
        factors, roc_memory(memory, "label", character()), multiple = FALSE
      )
    } else {
      RcmdrShiny::var_input(
        ns("label"), "Outcome variable (pick one)",
        factors, roc_memory(memory, "label", character()), multiple = FALSE
      )
    },
    if (isTRUE(two_labels)) {
      RcmdrShiny::var_input(
        ns("label2"), "Outcome variable 2 (pick one)",
        factors, roc_memory(memory, "label2", character()), multiple = FALSE
      )
    }
  )
}

roc_options_ui <- function(ns, memory, comparison = FALSE) {
  tagList(
    htmltools::tags$fieldset(
      htmltools::tags$legend("Data options"),
      RcmdrShiny::radio_input(
        ns("direction"), "Direction",
        c("auto" = "auto", "Control > cases" = "gt",
          "Control <= cases" = "lt"),
        roc_memory(memory, "direction", "auto")
      ),
      RcmdrShiny::checkbox_input(
        ns("na_rm"), "Remove NAs", roc_memory(memory, "na_rm", TRUE)
      ),
      RcmdrShiny::checkbox_input(
        ns("percent"), "Show/input % instead of 0-1",
        roc_memory(memory, "percent", FALSE)
      )
    ),
    htmltools::tags$fieldset(
      htmltools::tags$legend("AUC"),
      RcmdrShiny::checkbox_input(
        ns("auc"), "Compute area under the curve (AUC)",
        roc_memory(memory, "auc", TRUE)
      ),
      RcmdrShiny::checkbox_input(
        ns("partial_auc"), "Compute partial AUC",
        roc_memory(memory, "partial_auc", FALSE)
      ),
      RcmdrShiny::entry_input(
        ns("partial_from"), "Partial AUC from:",
        roc_memory(memory, "partial_from", "0")
      ),
      RcmdrShiny::entry_input(
        ns("partial_to"), "Partial AUC to:",
        roc_memory(memory, "partial_to", "1")
      ),
      RcmdrShiny::radio_input(
        ns("partial_focus"), "Partial AUC focus",
        c("specificity" = "specificity", "sensitivity" = "sensitivity"),
        roc_memory(memory, "partial_focus", "specificity")
      ),
      RcmdrShiny::checkbox_input(
        ns("partial_correct"), "Correct partial AUC",
        roc_memory(memory, "partial_correct", FALSE)
      )
    ),
    htmltools::tags$fieldset(
      htmltools::tags$legend("Confidence interval"),
      RcmdrShiny::checkbox_input(
        ns("ci_compute"), "Compute confidence interval (CI)",
        roc_memory(memory, "ci_compute", TRUE)
      ),
      RcmdrShiny::entry_input(
        ns("ci_level"), "Confidence level:",
        roc_memory(memory, "ci_level", "0.95")
      ),
      RcmdrShiny::radio_input(
        ns("ci_method"), "CI method",
        c("delong" = "delong", "bootstrap" = "bootstrap", "auto" = "auto"),
        roc_memory(memory, "ci_method", "bootstrap")
      ),
      RcmdrShiny::radio_input(
        ns("ci_type"), "Type of CI",
        c("auc" = "auc", "se" = "se", "sp" = "sp",
          "thresholds" = "thresholds"),
        roc_memory(memory, "ci_type", "se")
      ),
      RcmdrShiny::checkbox_input(
        ns("ci_boot_stratified"), "Stratified bootstrap",
        roc_memory(memory, "ci_boot_stratified", FALSE)
      ),
      RcmdrShiny::entry_input(
        ns("ci_boot_n"), "Bootstrap replicates:",
        roc_memory(memory, "ci_boot_n", "2000")
      ),
      RcmdrShiny::entry_input(
        ns("ci_values"), "CI values:",
        roc_memory(memory, "ci_values", "seq(0, 1, 0.05)")
      ),
      RcmdrShiny::checkbox_input(
        ns("ci_plot"), "Plot confidence intervals",
        roc_memory(memory, "ci_plot", FALSE)
      ),
      RcmdrShiny::radio_input(
        ns("ci_plot_type"), "CI plot type",
        c("shape" = "shape", "bars" = "bars"),
        roc_memory(memory, "ci_plot_type", "shape")
      )
    ),
    htmltools::tags$fieldset(
      htmltools::tags$legend("Plot"),
      RcmdrShiny::checkbox_input(
        ns("plot"), "Plot ROC curve", roc_memory(memory, "plot", TRUE)
      ),
      RcmdrShiny::checkbox_input(
        ns("print_auc"), "Display AUC",
        roc_memory(memory, "print_auc", FALSE)
      ),
      RcmdrShiny::checkbox_input(
        ns("auc_polygon"), "Polygon of AUC",
        roc_memory(memory, "auc_polygon", FALSE)
      ),
      RcmdrShiny::checkbox_input(
        ns("max_auc_polygon"), "Polygon of maximal AUC",
        roc_memory(memory, "max_auc_polygon", FALSE)
      ),
      RcmdrShiny::checkbox_input(
        ns("grid"), "Display grid", roc_memory(memory, "grid", FALSE)
      ),
      RcmdrShiny::checkbox_input(
        ns("identity"), "Display identity line",
        roc_memory(memory, "identity", TRUE)
      ),
      RcmdrShiny::combo_input(
        ns("print_thresholds"), "Display thresholds",
        c("no" = "no", "best" = "best", "all" = "all",
          "local maximas" = "local maximas", "<custom>" = "custom"),
        roc_memory(memory, "print_thresholds", "no")
      ),
      RcmdrShiny::entry_input(
        ns("custom_thresholds"), "Custom thresholds:",
        roc_memory(memory, "custom_thresholds", "c(0.5, 1, 10, 100)")
      ),
      RcmdrShiny::entry_input(
        ns("color"), "ROC color:", roc_memory(memory, "color", "#1c61b6")
      ),
      RcmdrShiny::combo_input(
        ns("lty"), "Line type",
        c("solid" = "solid", "dashed" = "dashed", "dotted" = "dotted",
          "dotdash" = "dotdash", "longdash" = "longdash",
          "twodash" = "twodash", "blank" = "blank"),
        roc_memory(memory, "lty", "solid")
      ),
      RcmdrShiny::entry_input(
        ns("xlab"), "x-axis label:", roc_memory(memory, "xlab", "")
      ),
      RcmdrShiny::entry_input(
        ns("ylab"), "y-axis label:", roc_memory(memory, "ylab", "")
      ),
      RcmdrShiny::entry_input(
        ns("main"), "Graph title:", roc_memory(memory, "main", "")
      ),
      RcmdrShiny::checkbox_input(
        ns("values"), "Display values (Se, Sp, thresholds)",
        roc_memory(memory, "values", FALSE)
      )
    ),
    htmltools::tags$fieldset(
      htmltools::tags$legend("Smoothing"),
      RcmdrShiny::checkbox_input(
        ns("smooth"), "Smooth ROC curve",
        roc_memory(memory, "smooth", FALSE)
      ),
      RcmdrShiny::combo_input(
        ns("smoothing_method"), "Smoothing method",
        c("binormal" = "binormal", "density" = "density",
          "fitdistr" = "fitdistr", "logcondens" = "logcondens",
          "logcondens.smooth" = "logcondens.smooth"),
        roc_memory(memory, "smoothing_method", "binormal")
      ),
      RcmdrShiny::entry_input(
        ns("bandwidth"), "Numeric bandwidth:",
        roc_memory(memory, "bandwidth", "")
      ),
      RcmdrShiny::combo_input(
        ns("distribution_cases"), "Distribution of cases",
        c("normal" = "normal", "lognormal" = "lognormal",
          "logistic" = "logistic", "exponential" = "exponential",
          "weibull" = "weibull", "gamma" = "gamma", "cauchy" = "cauchy"),
        roc_memory(memory, "distribution_cases", "normal")
      ),
      RcmdrShiny::combo_input(
        ns("distribution_controls"), "Distribution of controls",
        c("normal" = "normal", "lognormal" = "lognormal",
          "logistic" = "logistic", "exponential" = "exponential",
          "weibull" = "weibull", "gamma" = "gamma", "cauchy" = "cauchy"),
        roc_memory(memory, "distribution_controls", "normal")
      )
    ),
    if (isTRUE(comparison)) {
      htmltools::tags$fieldset(
        htmltools::tags$legend("Test"),
        RcmdrShiny::radio_input(
          ns("test_method"), "Test method",
          c("auto" = "auto", "delong" = "delong",
            "bootstrap" = "bootstrap", "venkatraman" = "venkatraman"),
          roc_memory(memory, "test_method", "auto")
        ),
        RcmdrShiny::radio_input(
          ns("test_alternative"), "Alternative",
          c("two.sided" = "two.sided", "less" = "less",
            "greater" = "greater"),
          roc_memory(memory, "test_alternative", "two.sided")
        ),
        RcmdrShiny::entry_input(
          ns("test_boot_n"), "Number of replicates:",
          roc_memory(memory, "test_boot_n", "2000")
        ),
        RcmdrShiny::checkbox_input(
          ns("pvalue"), "Display p-value",
          roc_memory(memory, "pvalue", TRUE)
        ),
        RcmdrShiny::entry_input(
          ns("legend1"), "Legend of ROC 1:",
          roc_memory(memory, "legend1", "")
        ),
        RcmdrShiny::entry_input(
          ns("legend2"), "Legend of ROC 2:",
          roc_memory(memory, "legend2", "")
        ),
        RcmdrShiny::entry_input(
          ns("color2"), "ROC 2 color:",
          roc_memory(memory, "color2", "#008600")
        ),
        RcmdrShiny::combo_input(
          ns("lty2"), "ROC 2 line type",
          c("solid" = "solid", "dashed" = "dashed", "dotted" = "dotted",
            "dotdash" = "dotdash", "longdash" = "longdash",
            "twodash" = "twodash", "blank" = "blank"),
          roc_memory(memory, "lty2", "solid")
        )
      )
    }
  )
}

roc_read_options <- function(input, ns) {
  list(
    direction = input[[ns("direction")]] %||% "auto",
    na_rm = isTRUE(input[[ns("na_rm")]]),
    percent = isTRUE(input[[ns("percent")]]),
    auc = isTRUE(input[[ns("auc")]]),
    partial_auc = isTRUE(input[[ns("partial_auc")]]),
    partial_from = input[[ns("partial_from")]] %||% "0",
    partial_to = input[[ns("partial_to")]] %||% "1",
    partial_focus = input[[ns("partial_focus")]] %||% "specificity",
    partial_correct = isTRUE(input[[ns("partial_correct")]]),
    ci_compute = isTRUE(input[[ns("ci_compute")]]),
    ci_level = input[[ns("ci_level")]] %||% "0.95",
    ci_method = input[[ns("ci_method")]] %||% "bootstrap",
    ci_type = input[[ns("ci_type")]] %||% "se",
    ci_boot_stratified = isTRUE(input[[ns("ci_boot_stratified")]]),
    ci_boot_n = input[[ns("ci_boot_n")]] %||% "2000",
    ci_values = input[[ns("ci_values")]] %||% "seq(0, 1, 0.05)",
    ci_plot = isTRUE(input[[ns("ci_plot")]]),
    ci_plot_type = input[[ns("ci_plot_type")]] %||% "shape",
    plot = isTRUE(input[[ns("plot")]]),
    print_auc = isTRUE(input[[ns("print_auc")]]),
    auc_polygon = isTRUE(input[[ns("auc_polygon")]]),
    max_auc_polygon = isTRUE(input[[ns("max_auc_polygon")]]),
    grid = isTRUE(input[[ns("grid")]]),
    identity = isTRUE(input[[ns("identity")]]),
    print_thresholds = input[[ns("print_thresholds")]] %||% "no",
    custom_thresholds = input[[ns("custom_thresholds")]] %||%
      "c(0.5, 1, 10, 100)",
    color = input[[ns("color")]] %||% "#1c61b6",
    lty = input[[ns("lty")]] %||% "solid",
    xlab = input[[ns("xlab")]] %||% "",
    ylab = input[[ns("ylab")]] %||% "",
    main = input[[ns("main")]] %||% "",
    values = isTRUE(input[[ns("values")]]),
    smooth = isTRUE(input[[ns("smooth")]]),
    smoothing_method = input[[ns("smoothing_method")]] %||% "binormal",
    bandwidth = input[[ns("bandwidth")]] %||% "",
    distribution_cases = input[[ns("distribution_cases")]] %||% "normal",
    distribution_controls = input[[ns("distribution_controls")]] %||% "normal"
  )
}

roc_add_test_options <- function(options, input, ns) {
  options$test_method <- input[[ns("test_method")]] %||% "auto"
  options$test_alternative <- input[[ns("test_alternative")]] %||% "two.sided"
  options$test_boot_n <- input[[ns("test_boot_n")]] %||% "2000"
  options$pvalue <- isTRUE(input[[ns("pvalue")]])
  options$legend1 <- input[[ns("legend1")]] %||% ""
  options$legend2 <- input[[ns("legend2")]] %||% ""
  options$color2 <- input[[ns("color2")]] %||% "#008600"
  options$lty2 <- input[[ns("lty2")]] %||% "solid"
  options
}

roc_single_dialog <- function() {
  id <- "fncvpROC"
  ns <- function(x) paste0(id, "_", x)
  RcmdrShiny::plugin_dialog(
    id = id, title = "Plot ROC curve", help = "plot.roc",
    help_package = "pROC",
    ui = function(state, memory) {
      htmltools::tagList(
        roc_data_ui(state, ns, memory),
        roc_options_ui(ns, memory)
      )
    },
    on_ok = function(input, state) {
      prediction <- input[[ns("prediction")]] %||% ""
      label <- input[[ns("label")]] %||% ""
      if (!nzchar(prediction)) return(list(error = "Select a prediction variable."))
      if (!nzchar(label)) return(list(error = "Select an outcome variable."))
      options <- roc_read_options(input, ns)
      commands <- tryCatch(
        build_roc_single_commands(
          RcmdrShiny::active_dataset(state), prediction, label, options
        ),
        error = function(e) e
      )
      if (inherits(commands, "error")) return(list(error = conditionMessage(commands)))
      list(commands = commands, memory = options)
    }
  )
}

roc_comparison_dialog <- function(paired) {
  id <- if (isTRUE(paired)) "fncPairedpROC" else "fncUnpairedpROC"
  ns <- function(x) paste0(id, "_", x)
  RcmdrShiny::plugin_dialog(
    id = id,
    title = if (isTRUE(paired)) "Paired ROC curves comparison" else
      "Unpaired ROC curves comparison",
    help = "roc.test", help_package = "pROC",
    ui = function(state, memory) {
      htmltools::tagList(
        roc_data_ui(state, ns, memory, comparison = TRUE,
                    two_labels = !isTRUE(paired)),
        roc_options_ui(ns, memory, comparison = TRUE)
      )
    },
    on_ok = function(input, state) {
      prediction1 <- input[[ns("prediction")]] %||% ""
      prediction2 <- input[[ns("prediction2")]] %||% ""
      label1 <- input[[ns("label")]] %||% ""
      label2 <- if (isTRUE(paired)) NULL else input[[ns("label2")]] %||% ""
      if (!nzchar(prediction1) || !nzchar(prediction2)) {
        return(list(error = "Select two prediction variables."))
      }
      if (!nzchar(label1)) return(list(error = "Select an outcome variable."))
      if (!isTRUE(paired) && !nzchar(label2)) {
        return(list(error = "Select the second outcome variable."))
      }
      options <- roc_add_test_options(roc_read_options(input, ns), input, ns)
      commands <- tryCatch(
        build_roc_comparison_commands(
          RcmdrShiny::active_dataset(state),
          prediction1, prediction2, label1, label2,
          paired = paired, options = options
        ),
        error = function(e) e
      )
      if (inherits(commands, "error")) return(list(error = conditionMessage(commands)))
      list(commands = commands, memory = options)
    }
  )
}

roc_lr_dialog <- function() {
  id <- "fncLRpROC"
  ns <- function(x) paste0(id, "_", x)
  RcmdrShiny::plugin_dialog(
    id = id, title = "Plot ROC curve for logistic regression model",
    help = "plot.roc", help_package = "pROC",
    ui = function(state, memory) {
      model <- RcmdrShiny::active_model(state)
      htmltools::tagList(
        htmltools::tags$p(
          htmltools::tags$strong("Active model: "),
          model %||% "none"
        ),
        roc_options_ui(ns, memory)
      )
    },
    on_ok = function(input, state) {
      model <- RcmdrShiny::active_model(state)
      if (is.null(model)) return(list(error = "No active model."))
      object <- get(model, envir = state$env, inherits = FALSE)
      if (!inherits(object, "glm")) {
        return(list(error = "The active model is not a glm."))
      }
      options <- roc_read_options(input, ns)
      commands <- tryCatch(
        build_roc_lr_commands(model, RcmdrShiny::active_dataset(state), options),
        error = function(e) e
      )
      if (inherits(commands, "error")) return(list(error = conditionMessage(commands)))
      list(commands = commands, memory = options)
    }
  )
}

roc_hosmer_dialog <- function() {
  id <- "fndHosmerLemeshow"
  ns <- function(x) paste0(id, "_", x)
  RcmdrShiny::plugin_dialog(
    id = id, title = "Hosmer-Lemeshow GOF Test",
    help = "hoslem.test", help_package = "ResourceSelection",
    ui = function(state, memory) {
      htmltools::tagList(
        htmltools::tags$p(
          htmltools::tags$strong("Active model: "),
          RcmdrShiny::active_model(state) %||% "none"
        ),
        RcmdrShiny::spin_input(
          ns("bins"), "Number of bins:", memory$bins %||% 10,
          min = 1, step = 1
        ),
        RcmdrShiny::checkbox_input(
          ns("classification"), "Classification table",
          memory$classification %||% TRUE
        ),
        RcmdrShiny::checkbox_input(
          ns("percent_correct"), "Percentage correct",
          memory$percent_correct %||% TRUE
        )
      )
    },
    on_ok = function(input, state) {
      model <- RcmdrShiny::active_model(state)
      if (is.null(model)) return(list(error = "No active model."))
      object <- get(model, envir = state$env, inherits = FALSE)
      if (!inherits(object, "glm")) {
        return(list(error = "The active model is not a glm."))
      }
      options <- list(
        bins = input[[ns("bins")]] %||% 10,
        classification = isTRUE(input[[ns("classification")]]),
        percent_correct = isTRUE(input[[ns("percent_correct")]])
      )
      commands <- tryCatch(
        build_hosmer_lemeshow_commands(
          model, RcmdrShiny::active_dataset(state),
          options$bins, options$classification, options$percent_correct
        ),
        error = function(e) e
      )
      if (inherits(commands, "error")) return(list(error = conditionMessage(commands)))
      list(commands = commands, memory = options)
    }
  )
}

roc_dialogs <- function() {
  list(
    fncvpROC = roc_single_dialog(),
    fncPairedpROC = roc_comparison_dialog(TRUE),
    fncUnpairedpROC = roc_comparison_dialog(FALSE),
    fndHosmerLemeshow = roc_hosmer_dialog(),
    fncLRpROC = roc_lr_dialog()
  )
}
