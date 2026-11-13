# Shiny dialogs for HH --------------------------------------------------

hh_dialog <- function(id, title, fields, build, help = NULL) {
  force(fields)
  force(build)
  force(title)
  ns <- function(x) paste0(id, "_", x)
  RcmdrShiny::plugin_dialog(
    id = id, title = title, help = help, help_package = "HH",
    ui = function(state, memory) {
      htmltools::tagList(lapply(fields, function(field) {
        value <- if (is.null(memory)) NULL else memory[[field$name]]
        if (is.null(value)) value <- field$default
        if (identical(field$type, "variable")) {
          choices <- switch(
            field$kind,
            numeric = RcmdrShiny::numeric_variables(state),
            factor = RcmdrShiny::factor_variables(state),
            factor2 = RcmdrShiny::two_level_factors(state),
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

hh_model_predictors <- function(state) {
  model <- RcmdrShiny::active_model(state)
  if (is.null(model)) return(character())
  object <- get(model, envir = state$env, inherits = FALSE)
  terms <- tryCatch(stats::terms(object), error = function(e) NULL)
  if (is.null(terms)) return(character())
  all.vars(stats::delete.response(terms))
}

hh_dialogs <- function() {
  list(
    twoWayTable.HH = hh_dialog(
      "twoWayTable.HH", "Two-way table", list(
        list(name = "row", label = "Row factor", type = "variable", kind = "factor", default = ""),
        list(name = "col", label = "Column factor", type = "variable", kind = "factor", default = ""),
        list(name = "chisq", label = "Chi-square test", type = "checkbox", default = TRUE),
        list(name = "fisher", label = "Fisher exact test", type = "checkbox", default = FALSE)
      ),
      function(values, state) {
        if (!nzchar(values$row) || !nzchar(values$col)) stop("Select two factors.")
        build_hh_two_way(RcmdrShiny::active_dataset(state), values$row,
                         values$col, values$chisq, values$fisher)
      }
    ),
    enterTable.HH = hh_dialog(
      "enterTable.HH", "Enter and analyze two-way table", list(
        list(name = "counts", label = "Counts (row by row, comma separated)", type = "entry", default = ""),
        list(name = "rows", label = "Row names (comma separated)", type = "entry", default = "A, B"),
        list(name = "cols", label = "Column names (comma separated)", type = "entry", default = "X, Y"),
        list(name = "chisq", label = "Chi-square test", type = "checkbox", default = TRUE),
        list(name = "fisher", label = "Fisher exact test", type = "checkbox", default = FALSE)
      ),
      function(values, state) {
        counts <- trimws(strsplit(values$counts %||% "", ",")[[1L]])
        counts <- suppressWarnings(as.numeric(counts))
        if (length(counts) == 0L || anyNA(counts)) stop("Enter numeric counts.")
        rows <- trimws(strsplit(values$rows %||% "", ",")[[1L]])
        cols <- trimws(strsplit(values$cols %||% "", ",")[[1L]])
        if (length(counts) != length(rows) * length(cols)) {
          stop("The number of counts must be rows x columns.")
        }
        build_hh_enter_table(counts, rows, cols, values$chisq, values$fisher)
      }
    ),
    analyzeTwoWayTable.HH = hh_dialog(
      "analyzeTwoWayTable.HH", "Analyze two-way table", list(
        list(name = "object", label = "Table object", type = "entry", default = ".Table"),
        list(name = "chisq", label = "Chi-square test", type = "checkbox", default = TRUE),
        list(name = "fisher", label = "Fisher exact test", type = "checkbox", default = FALSE)
      ),
      function(values, state) {
        if (!nzchar(values$object)) stop("Enter a table object.")
        build_hh_analyze_table(values$object, values$chisq, values$fisher)
      }
    ),
    bestSubsetsRegressionModel.HH = hh_dialog(
      "bestSubsetsRegressionModel.HH", "Best subsets regression", list(
        list(name = "response", label = "Response variable", type = "variable", kind = "numeric", default = ""),
        list(name = "predictors", label = "Predictors", type = "variable", kind = "numeric", multiple = TRUE, default = character()),
        list(name = "nbest", label = "Best subsets", type = "spin", default = 1),
        list(name = "statistic", label = "Plot statistic", type = "combo",
             choices = c("bic" = "bic", "cp" = "Cp", "adjr2" = "adjr2", "r2" = "r2"),
             default = "bic")
      ),
      function(values, state) {
        if (!nzchar(values$response)) stop("Select a response.")
        build_hh_best_subsets(RcmdrShiny::active_dataset(state), values$response,
                              values$predictors, values$nbest, values$statistic)
      }
    ),
    confidenceIntervalsPlot = hh_dialog(
      "confidenceIntervalsPlot", "Confidence interval plot", list(
        list(name = "response", label = "Response variable", type = "variable", kind = "numeric", default = ""),
        list(name = "predictors", label = "Explanatory variable", type = "variable", kind = "numeric", multiple = FALSE, default = "")
      ),
      function(values, state) {
        if (!nzchar(values$response)) stop("Select a response.")
        if (!nzchar(values$predictors)) stop("Select an explanatory variable.")
        build_hh_ci_plot(RcmdrShiny::active_dataset(state), values$response,
                         values$predictors)
      }
    ),
    PredictModel = hh_dialog(
      "PredictModel", "Prediction intervals", list(
        list(name = "dataset", label = "Data set name", type = "entry", default = "")
      ),
      function(values, state) {
        model <- RcmdrShiny::active_model(state)
        if (is.null(model)) stop("No active model.")
        if (!nzchar(values$dataset)) stop("Select a data set.")
        build_hh_predict_existing(model, values$dataset)
      }
    ),
    scatterPlot.HH = hh_dialog(
      "scatterPlot.HH", "Scatterplot (HH)", list(
        list(name = "x", label = "X variable", type = "variable", kind = "numeric", default = ""),
        list(name = "y", label = "Y variable", type = "variable", kind = "numeric", default = ""),
        list(name = "group", label = "Grouping variable", type = "variable", kind = "factor", default = "")
      ),
      function(values, state) {
        if (!nzchar(values$x) || !nzchar(values$y)) stop("Select two variables.")
        build_hh_scatterplot(RcmdrShiny::active_dataset(state), values$x,
                             values$y, values$group)
      }
    ),
    scatterPlotMatrix.HH = hh_dialog(
      "scatterPlotMatrix.HH", "Scatterplot matrix", list(
        list(name = "variables", label = "Variables", type = "variable", kind = "numeric", multiple = TRUE, default = character())
      ),
      function(values, state) {
        if (length(values$variables) < 2L) stop("Select at least two variables.")
        build_hh_scatterplot_matrix(RcmdrShiny::active_dataset(state),
                                    values$variables)
      }
    ),
    Xyplot.HH = hh_dialog(
      "Xyplot.HH", "XY conditioning plot", list(
        list(name = "x", label = "X variable", type = "variable", kind = "numeric", default = ""),
        list(name = "y", label = "Y variable", type = "variable", kind = "numeric", default = ""),
        list(name = "group", label = "Conditioning variable", type = "variable", kind = "factor", default = "")
      ),
      function(values, state) {
        if (!nzchar(values$x) || !nzchar(values$y)) stop("Select two variables.")
        build_hh_xyplot(RcmdrShiny::active_dataset(state), values$x,
                        values$y, values$group)
      }
    ),
    Xyplot.HH2 = hh_dialog(
      "Xyplot.HH2", "lattice plot", list(
        list(name = "x", label = "X variable", type = "variable", kind = "numeric", default = ""),
        list(name = "y", label = "Y variable", type = "variable", kind = "numeric", default = "")
      ),
      function(values, state) {
        if (!nzchar(values$x) || !nzchar(values$y)) stop("Select two variables.")
        build_hh_xyplot(RcmdrShiny::active_dataset(state), values$x, values$y)
      }
    ),
    LikertFormula = hh_dialog(
      "LikertFormula", "Likert plot", list(
        list(name = "variables", label = "Likert variables", type = "variable", kind = "factor", multiple = TRUE, default = character())
      ),
      function(values, state) build_hh_likert(RcmdrShiny::active_dataset(state), values$variables)
    ),
    ResizeEtcDialog = hh_dialog(
      "ResizeEtcDialog", "Resize lattice plots", list(
        list(name = "object", label = "Trellis object", type = "entry", default = ""),
        list(name = "width", label = "Width (inches)", type = "entry", default = "7"),
        list(name = "height", label = "Height (inches)", type = "entry", default = "5")
      ),
      function(values, state) {
        if (!nzchar(values$object)) stop("Enter a trellis object.")
        sprintf("HH::ResizeEtc(%s, width = %s, height = %s)", values$object,
                values$width, values$height)
      }
    ),
    Interaction2wtRcmdr = hh_dialog(
      "Interaction2wtRcmdr", "Plot of two-way interactions", list(
        list(name = "response", label = "Response", type = "variable", kind = "numeric", default = ""),
        list(name = "factors", label = "Factors", type = "variable", kind = "factor", multiple = TRUE, default = character())
      ),
      function(values, state) build_hh_interaction(RcmdrShiny::active_dataset(state),
                                                   values$response, values$factors)
    ),
    DotplottbRcmdr = hh_dialog(
      "DotplottbRcmdr", "Dotplot", list(
        list(name = "response", label = "Response", type = "variable", kind = "numeric", default = ""),
        list(name = "factor", label = "Factor", type = "variable", kind = "factor", default = "")
      ),
      function(values, state) build_hh_dotplot(RcmdrShiny::active_dataset(state),
                                               values$response, values$factor)
    ),
    Regr1Plot = hh_dialog(
      "Regr1Plot", "Squared residuals", list(
        list(name = "x", label = "X variable", type = "variable", kind = "numeric", default = ""),
        list(name = "y", label = "Y variable", type = "variable", kind = "numeric", default = "")
      ),
      function(values, state) build_hh_regr1(RcmdrShiny::active_dataset(state),
                                             values$x, values$y)
    ),
    QQPlot.HH = hh_dialog(
      "QQPlot.HH", "Quantile-comparison plot", list(
        list(name = "variable", label = "Variable", type = "variable", kind = "numeric", default = ""),
        list(name = "distribution", label = "Distribution", type = "combo",
             choices = c("normal" = "norm", "t" = "t", "chisq" = "chisq"),
             default = "norm")
      ),
      function(values, state) build_hh_qq(RcmdrShiny::active_dataset(state),
                                          values$variable, values$distribution)
    ),
    Scatter3DDialog.HH = hh_dialog(
      "Scatter3DDialog.HH", "3D scatterplot", list(
        list(name = "x", label = "X variable", type = "variable", kind = "numeric", default = ""),
        list(name = "y", label = "Y variable", type = "variable", kind = "numeric", default = ""),
        list(name = "z", label = "Z variable", type = "variable", kind = "numeric", default = "")
      ),
      function(values, state) build_hh_scatter3d(RcmdrShiny::active_dataset(state),
                                                 values$x, values$y, values$z)
    ),
    anovaTableII.HH = hh_dialog(
      "anovaTableII.HH", "ANOVA table (Type II)", list(),
      function(values, state) {
        model <- RcmdrShiny::active_model(state)
        if (is.null(model)) stop("No active model.")
        build_hh_anova(model, "II")
      }
    ),
    anovaTableI.HH = hh_dialog(
      "anovaTableI.HH", "ANOVA table (Type I)", list(),
      function(values, state) {
        model <- RcmdrShiny::active_model(state)
        if (is.null(model)) stop("No active model.")
        build_hh_anova(model, "I")
      }
    ),
    normal.and.t.hypotheses.plot = hh_dialog(
      "normal.and.t.hypotheses.plot", "Plot hypotheses or confidence intervals", list(
        list(name = "mu", label = "Mean", type = "entry", default = "0"),
        list(name = "sd", label = "Standard deviation", type = "entry", default = "1"),
        list(name = "alpha", label = "Alpha", type = "entry", default = "0.05")
      ),
      function(values, state) build_hh_hypothesis_plot("normal", values)
    ),
    FHypothesesPlot = hh_dialog(
      "FHypothesesPlot", "Plot F hypotheses", list(
        list(name = "df1", label = "Numerator df", type = "entry", default = "3"),
        list(name = "df2", label = "Denominator df", type = "entry", default = "20"),
        list(name = "alpha", label = "Alpha", type = "entry", default = "0.05")
      ),
      function(values, state) build_hh_hypothesis_plot("f", values)
    ),
    ChisqHypothesesPlot = hh_dialog(
      "ChisqHypothesesPlot", "Plot chi-squared hypotheses", list(
        list(name = "df", label = "Degrees of freedom", type = "entry", default = "3"),
        list(name = "alpha", label = "Alpha", type = "entry", default = "0.05")
      ),
      function(values, state) build_hh_hypothesis_plot("chisq", values)
    ),
    R_options = hh_dialog(
      "R_options", "R options (HH)", list(
        list(name = "pch", label = "Plotting character", type = "spin", default = 1),
        list(name = "stars", label = "Show significance stars", type = "checkbox", default = TRUE)
      ),
      function(values, state) build_hh_options(values$pch, values$stars)
    ),
    MMCmenu = hh_dialog(
      "MMCmenu", "MMC plot", list(),
      function(values, state) {
        model <- RcmdrShiny::active_model(state)
        if (is.null(model)) stop("No active model.")
        build_hh_mmc(model)
      }
    )
  )
}
