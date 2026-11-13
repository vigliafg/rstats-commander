# Statistics menu dialogs ---------------------------------------------------

stats_default_model <- function(state, prefix = "Model") {
  paste0(prefix, ".", state$model_number)
}

stats_model_open <- function(state) update_model_number(state)

stats_alternative_input <- function(id, value = "two.sided",
                                    labels = c("Two-sided" = "two.sided",
                                               "Less" = "less",
                                               "Greater" = "greater")) {
  radio_input(id, tr("Alternative Hypothesis"), labels, value, inline = TRUE)
}

stats_confidence_input <- function(id, value = 0.95) {
  spin_input(id, tr("Confidence level:"), value, min = 0.01, max = 0.999,
             step = 0.01)
}

stats_test_input <- function(id, choices, value) {
  radio_input(id, tr("Test"), choices, value, inline = TRUE)
}

stats_model_dialog <- function(id, title, help, kind = "lm",
                               defaults = list(), extra_ui = NULL,
                               on_submit = NULL) {
  ns <- function(x) paste0(id, "_", x)

  dialog_spec(
    id = id, title = title, help = help,
    on_open = stats_model_open,
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      if (!nzchar(m$model %||% "")) m$model <- stats_default_model(state)
      htmltools::tagList(
        entry_input(ns("model"), tr("Enter name for model:"), m$model),
        model_formula_input(id, variables(state),
                            lhs = m$lhs %||% "", rhs = m$rhs %||% ""),
        subset_input(ns("subset"), tr("Subset expression:"), m$subset %||% ""),
        if (identical(kind, "lm") || identical(kind, "glm") ||
            identical(kind, "lmer") || identical(kind, "glmer")) {
          combo_input(
            ns("weights"), tr("Weights"),
            c(stats::setNames("", tr("<no variable selected>")),
              stats::setNames(numeric_variables(state), numeric_variables(state))),
            selected = m$weights %||% ""
          )
        },
        entry_input(ns("remove"), tr("Indices or names of row(s) to remove"),
                    m$remove %||% ""),
        if (!is.null(extra_ui)) extra_ui(m, ns)
      )
    },
    observers = function(input, output, session, state, refresh) {
      model_formula_observers(
        input, session, id,
        guard = function() identical(state$current_dialog, id)
      )
    },
    on_ok = function(input, state) {
      m <- list(
        model = trim_blanks(input[[ns("model")]] %||% ""),
        lhs = input[[ns("lhs")]] %||% "",
        rhs = trim_blanks(input[[ns("rhs")]] %||% ""),
        subset = trim_blanks(input[[ns("subset")]] %||% ""),
        weights = input[[ns("weights")]] %||% "",
        remove = trim_blanks(input[[ns("remove")]] %||% "")
      )
      if (!is_valid_name(m$model)) {
        return(list(error = sprintf(tr('"%s" is not a valid name.'), m$model)))
      }
      if (!nzchar(m$lhs)) return(list(error = tr("Left-hand side of model empty.")))
      if (!nzchar(m$rhs)) return(list(error = tr("Right-hand side of model empty.")))
      if (nzchar(m$subset) && nzchar(m$remove)) {
        return(list(error = tr("You cannot specify both case removal and subset cases")))
      }
      remove_rows <- ""
      if (nzchar(m$remove)) {
        cases <- cases_subset(active_dataset(state), dataset(state), m$remove)
        if (!is.null(cases$error)) return(list(error = cases$error))
        remove_rows <- cases$value
      }
      if (is.null(on_submit)) {
        commands <- cmd_linear_regression(
          active_dataset(state), m$model, m$lhs, m$rhs,
          subset = m$subset, weights = m$weights, remove_rows = remove_rows
        )
      } else {
        commands <- on_submit(input, ns, state, m, remove_rows)
      }
      list(
        commands = commands,
        activate_model = m$model,
        memory = c(m, list(model = ""))
      )
    }
  )
}

# Summaries -----------------------------------------------------------------

frequency_distribution_dialog <- function() {
  id <- "frequencyDistribution"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(variables = NULL, goodness = FALSE, probs = "")

  dialog_spec(
    id = id, title = tr("Frequency Distributions"), help = "table",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        var_input(ns("variables"), tr("Variables (pick one or more)"),
                  names(dataset(state))[vapply(dataset(state),
                                               function(x) is.factor(x) || is.character(x) || is.logical(x),
                                               logical(1))],
                  selected = m$variables, multiple = TRUE),
        checkbox_input(ns("goodness"),
                       tr("Chi-square goodness-of-fit test (for one variable only)"),
                       m$goodness),
        entry_input(ns("probs"), tr("Hypothesized probabilities (comma separated, optional):"),
                    m$probs)
      )
    },
    on_ok = function(input, state) {
      variables <- input[[ns("variables")]]
      if (length(variables) == 0L) {
        return(list(error = tr("You must select a variable.")))
      }
      goodness <- isTRUE(input[[ns("goodness")]])
      if (goodness && length(variables) > 1L) {
        return(list(error = tr("Goodness-of-fit test not available when more than one variable is selected.")))
      }
      probs <- NULL
      if (goodness) {
        text <- trim_blanks(input[[ns("probs")]] %||% "")
        if (nzchar(text)) {
          probs <- suppressWarnings(as.numeric(trimws(strsplit(text, ",", fixed = TRUE)[[1L]])))
          if (anyNA(probs) || any(probs < 0)) {
            return(list(error = tr("Invalid probabilities.")))
          }
        }
      }
      list(
        commands = vapply(variables, function(variable) {
          cmd_frequency_table(active_dataset(state), variable, goodness, probs)
        }, character(1)),
        memory = list(variables = variables, goodness = goodness,
                      probs = input[[ns("probs")]] %||% "")
      )
    }
  )
}

statistics_table_dialog <- function() {
  id <- "statisticsTable"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(groups = NULL, responses = NULL, statistic = "mean",
                   other = "")

  dialog_spec(
    id = id, title = tr("Table of Statistics"), help = "Tapply",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        var_input(ns("groups"), tr("Factors (pick one or more)"),
                  factor_variables(state), selected = m$groups, multiple = TRUE),
        var_input(ns("responses"), tr("Response variables (pick one or more)"),
                  numeric_variables(state), selected = m$responses,
                  multiple = TRUE),
        radio_input(ns("statistic"), tr("Statistic"),
                    c("Mean" = "mean", "Median" = "median",
                      "Standard deviation" = "sd",
                      "Interquartile range" = "IQR", "Other" = "other"),
                    m$statistic),
        entry_input(ns("other"), tr("Other statistic:"), m$other)
      )
    },
    on_ok = function(input, state) {
      groups <- input[[ns("groups")]]
      responses <- input[[ns("responses")]]
      if (length(groups) == 0L) return(list(error = tr("No factors selected.")))
      if (length(responses) == 0L) {
        return(list(error = tr("You must select a response variable.")))
      }
      statistic <- input[[ns("statistic")]] %||% "mean"
      if (identical(statistic, "other")) {
        statistic <- trim_blanks(input[[ns("other")]] %||% "")
        if (!nzchar(statistic)) return(list(error = tr("You must specify a statistic.")))
      }
      list(
        commands = vapply(responses, function(response) {
          cmd_statistics_table(active_dataset(state), response, groups, statistic)
        }, character(1)),
        memory = list(groups = groups, responses = responses,
                      statistic = input[[ns("statistic")]] %||% "mean",
                      other = input[[ns("other")]] %||% "")
      )
    }
  )
}

correlation_matrix_dialog <- function() {
  id <- "correlationMatrix"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(variables = NULL, type = "Pearson", use = "complete",
                   pvalues = FALSE)

  dialog_spec(
    id = id, title = tr("Correlation Matrix"), help = "rcorr.adjust",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        var_input(ns("variables"), tr("Variables (pick two or more)"),
                  numeric_variables(state), selected = m$variables,
                  multiple = TRUE),
        radio_input(ns("type"), tr("Type of Correlations"),
                    c("Pearson product-moment" = "Pearson",
                      "Spearman rank-order" = "Spearman",
                      "Partial" = "partial"), m$type),
        radio_input(ns("use"), tr("Observations to Use"),
                    c("Complete observations" = "complete",
                      "Pairwise-complete observations" = "pairwise.complete"),
                    m$use),
        checkbox_input(ns("pvalues"), tr("Pairwise p-values"), m$pvalues)
      )
    },
    on_ok = function(input, state) {
      variables <- input[[ns("variables")]]
      type <- input[[ns("type")]] %||% "Pearson"
      if (length(variables) < 2L) {
        return(list(error = tr("Fewer than 2 variables selected.")))
      }
      if (identical(type, "partial") && length(variables) < 3L) {
        return(list(error = tr("Fewer than 3 variables selected\nfor partial correlations.")))
      }
      list(
        commands = cmd_correlation_matrix(
          active_dataset(state), variables, type,
          use = input[[ns("use")]] %||% "complete",
          pvalues = isTRUE(input[[ns("pvalues")]])
        ),
        memory = list(variables = variables, type = type,
                      use = input[[ns("use")]] %||% "complete",
                      pvalues = isTRUE(input[[ns("pvalues")]]))
      )
    }
  )
}

correlation_test_dialog <- function() {
  id <- "correlationTest"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(variables = NULL, method = "pearson",
                   alternative = "two.sided")

  dialog_spec(
    id = id, title = tr("Correlation Test"), help = "cor.test",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        var_input(ns("variables"), tr("Variables (pick two)"),
                  numeric_variables(state), selected = m$variables,
                  multiple = TRUE),
        radio_input(ns("method"), tr("Type of Correlation"),
                    c("Pearson product-moment" = "pearson",
                      "Spearman rank-order" = "spearman",
                      "Kendall's tau" = "kendall"), m$method),
        stats_alternative_input(ns("alternative"), m$alternative)
      )
    },
    on_ok = function(input, state) {
      variables <- input[[ns("variables")]]
      if (length(variables) != 2L) {
        return(list(error = tr("You must select exactly two variables.")))
      }
      list(
        commands = cmd_correlation_test(
          active_dataset(state), variables[[1L]], variables[[2L]],
          alternative = input[[ns("alternative")]] %||% "two.sided",
          method = input[[ns("method")]] %||% "pearson"
        ),
        memory = list(variables = variables,
                      method = input[[ns("method")]] %||% "pearson",
                      alternative = input[[ns("alternative")]] %||% "two.sided")
      )
    }
  )
}

normality_test_dialog <- function() {
  id <- "NormalityTest"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(variable = NULL, test = "shapiro.test", groups = "",
                   nclasses = "")

  dialog_spec(
    id = id, title = tr("Test of Normality"), help = "normalityTest",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        var_input(ns("variable"), tr("Variable (pick one)"),
                  numeric_variables(state), selected = m$variable),
        stats_test_input(
          ns("test"),
          c("Shapiro-Wilk" = "shapiro.test",
            "Anderson-Darling" = "ad.test",
            "Cramer-von Mises" = "cvm.test",
            "Lilliefors (Kolmogorov-Smirnov)" = "lillie.test",
            "Shapiro-Francia" = "sf.test",
            "Pearson chi-square" = "pearson.test"),
          m$test
        ),
        combo_input(ns("groups"), tr("Test by (optional)"),
                    c(stats::setNames("", tr("<none>")),
                      stats::setNames(factor_variables(state), factor_variables(state))),
                    selected = m$groups %||% ""),
        entry_input(ns("nclasses"), tr("Number of bins for Pearson chi-square (optional):"),
                    m$nclasses)
      )
    },
    on_ok = function(input, state) {
      variable <- input[[ns("variable")]] %||% ""
      if (!nzchar(variable)) return(list(error = tr("You must select a variable.")))
      groups <- input[[ns("groups")]] %||% ""
      if (!nzchar(groups)) groups <- NULL
      test <- input[[ns("test")]] %||% "shapiro.test"
      nclasses <- trim_blanks(input[[ns("nclasses")]] %||% "")
      if (identical(test, "pearson.test") && nzchar(nclasses)) {
        bins <- suppressWarnings(as.numeric(nclasses))
        if (is.na(bins) || bins < 4) {
          return(list(error = tr("Number of bins must be a number >= 4")))
        }
      }
      list(
        commands = cmd_normality_test(active_dataset(state), variable, test,
                                      groups, if (nzchar(nclasses)) nclasses else NULL),
        memory = list(variable = variable, test = test,
                      groups = groups %||% "", nclasses = nclasses)
      )
    }
  )
}

transform_variables_dialog <- function() {
  id <- "transformVariables"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(variables = NULL, family = "bcPower", rhs = "")

  dialog_spec(
    id = id, title = tr("Transform Variables Toward Normality"),
    help = "powerTransform",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        var_input(ns("variables"), tr("Select variables to transform (one or more)"),
                  numeric_variables(state), selected = m$variables,
                  multiple = TRUE),
        radio_input(ns("family"), tr("Transformation Family"),
                    c("Box-Cox" = "bcPower",
                      "Box-Cox with negatives" = "bcnPower",
                      "Yeo-Johnson" = "yjPower"), m$family),
        entry_input(ns("rhs"), tr("Condition on (optional formula):"), m$rhs)
      )
    },
    on_ok = function(input, state) {
      variables <- input[[ns("variables")]]
      if (length(variables) == 0L) {
        return(list(error = tr("You must select one or more variables.")))
      }
      list(
        commands = cmd_power_transform(
          active_dataset(state), variables,
          family = input[[ns("family")]] %||% "bcPower",
          rhs = input[[ns("rhs")]] %||% "1"
        ),
        memory = list(variables = variables,
                      family = input[[ns("family")]] %||% "bcPower",
                      rhs = input[[ns("rhs")]] %||% "")
      )
    }
  )
}

# Contingency tables --------------------------------------------------------

table_options_ui <- function(ns, m, include_controls = FALSE) {
  htmltools::tagList(
    radio_input(ns("percents"), tr("Compute Percentages"),
                c("Row percentages" = "row", "Column percentages" = "column",
                  "Percentages of total" = "total", "No percentages" = "none"),
                m$percents %||% "none"),
    checkboxes_input(
      ns("tests"),
      c(chisq = tr("Chi-square test of independence"),
        components = tr("Components of chi-square statistic"),
        expected = tr("Print expected frequencies"),
        fisher = tr("Fisher's exact test")),
      selected = names(Filter(isTRUE, m[c("chisq", "components", "expected", "fisher")]))
    ),
    subset_input(ns("subset"), tr("Subset expression:"), m$subset %||% "")
  )
}

table_options_on_ok <- function(input, ns) {
  list(
    percents = input[[ns("percents")]] %||% "none",
    chisq = isTRUE(input[[paste0(ns("tests"), "_chisq")]]),
    components = isTRUE(input[[paste0(ns("tests"), "_components")]]),
    expected = isTRUE(input[[paste0(ns("tests"), "_expected")]]),
    fisher = isTRUE(input[[paste0(ns("tests"), "_fisher")]]),
    subset = trim_blanks(input[[ns("subset")]] %||% "")
  )
}

two_way_table_dialog <- function() {
  id <- "twoWayTable"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(row = NULL, column = NULL, percents = "none",
                   chisq = TRUE, components = FALSE, expected = FALSE,
                   fisher = FALSE, subset = "")

  dialog_spec(
    id = id, title = tr("Two-Way Table"), help = "xtabs",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        var_input(ns("row"), tr("Row variable (pick one)"),
                  factor_variables(state), selected = m$row),
        var_input(ns("column"), tr("Column variable (pick one)"),
                  factor_variables(state), selected = m$column),
        table_options_ui(ns, m)
      )
    },
    on_ok = function(input, state) {
      row <- input[[ns("row")]] %||% ""
      column <- input[[ns("column")]] %||% ""
      if (!nzchar(row) || !nzchar(column)) {
        return(list(error = tr("You must select two variables.")))
      }
      if (identical(row, column)) {
        return(list(error = tr("Row and column variables are the same.")))
      }
      options <- table_options_on_ok(input, ns)
      list(
        commands = cmd_two_way_table(
          active_dataset(state), row, column,
          percents = options$percents, chisq = options$chisq,
          components = options$components, expected = options$expected,
          fisher = options$fisher, subset = options$subset
        ),
        memory = c(list(row = row, column = column), options)
      )
    }
  )
}

two_way_counts_dialog <- function() {
  id <- "twoWayTableFromCounts"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(row = NULL, column = NULL, count = NULL,
                   percents = "none", chisq = TRUE, components = FALSE,
                   expected = FALSE, fisher = FALSE)

  dialog_spec(
    id = id, title = tr("Two-Way Table from Counts"), help = "xtabs",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        var_input(ns("row"), tr("Row variable (pick one)"),
                  factor_variables(state), selected = m$row),
        var_input(ns("column"), tr("Column variable (pick one)"),
                  factor_variables(state), selected = m$column),
        var_input(ns("count"), tr("Counts variable (pick one)"),
                  numeric_variables(state), selected = m$count),
        table_options_ui(ns, m)
      )
    },
    on_ok = function(input, state) {
      row <- input[[ns("row")]] %||% ""
      column <- input[[ns("column")]] %||% ""
      count <- input[[ns("count")]] %||% ""
      if (!nzchar(row) || !nzchar(column) || !nzchar(count)) {
        return(list(error = tr("You must select two factors and a counts variable.")))
      }
      if (row == column) {
        return(list(error = tr("Row and column variables are the same.")))
      }
      options <- table_options_on_ok(input, ns)
      list(
        commands = cmd_two_way_counts(
          active_dataset(state), row, column, count,
          percents = options$percents, chisq = options$chisq,
          components = options$components, expected = options$expected,
          fisher = options$fisher
        ),
        memory = c(list(row = row, column = column, count = count), options)
      )
    }
  )
}

multi_way_table_dialog <- function() {
  id <- "multiWayTable"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(row = NULL, column = NULL, controls = NULL,
                   percents = "none", subset = "")

  dialog_spec(
    id = id, title = tr("Multi-Way Table"), help = "xtabs",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        var_input(ns("row"), tr("Row variable (pick one)"),
                  factor_variables(state), selected = m$row),
        var_input(ns("column"), tr("Column variable (pick one)"),
                  factor_variables(state), selected = m$column),
        var_input(ns("controls"), tr("Control variables (pick one or more)"),
                  factor_variables(state), selected = m$controls,
                  multiple = TRUE),
        radio_input(ns("percents"), tr("Compute Percentages"),
                    c("Row percentages" = "row", "Column percentages" = "column",
                      "No percentages" = "none"), m$percents),
        subset_input(ns("subset"), tr("Subset expression:"), m$subset)
      )
    },
    on_ok = function(input, state) {
      row <- input[[ns("row")]] %||% ""
      column <- input[[ns("column")]] %||% ""
      controls <- input[[ns("controls")]]
      if (!nzchar(row) || !nzchar(column) || length(controls) == 0L) {
        return(list(error = tr("You must select row, column and control variables.")))
      }
      if (length(unique(c(row, column, controls))) < length(c(row, column, controls))) {
        return(list(error = tr("Row, column, and control variables must be different.")))
      }
      list(
        commands = cmd_multi_way_table(
          active_dataset(state), row, column, controls,
          percents = input[[ns("percents")]] %||% "none",
          subset = trim_blanks(input[[ns("subset")]] %||% "")
        ),
        memory = list(row = row, column = column, controls = controls,
                      percents = input[[ns("percents")]] %||% "none",
                      subset = input[[ns("subset")]] %||% "")
      )
    }
  )
}

enter_table_dialog <- function() {
  id <- "enterTable"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(rowvar = "row", colvar = "column",
                   rownames = "A, B", colnames = "X, Y",
                   counts = "1, 2, 3, 4", percents = "none",
                   chisq = TRUE, expected = FALSE, components = FALSE,
                   fisher = FALSE)

  dialog_spec(
    id = id, title = tr("Enter and Analyze Two-Way Table"), help = "xtabs",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        entry_input(ns("rowvar"), tr("Row variable name:"), m$rowvar),
        entry_input(ns("colvar"), tr("Column variable name:"), m$colvar),
        entry_input(ns("rownames"), tr("Row names (comma separated):"), m$rownames),
        entry_input(ns("colnames"), tr("Column names (comma separated):"), m$colnames),
        entry_input(ns("counts"), tr("Counts (comma separated, row by row):"), m$counts),
        table_options_ui(ns, m)
      )
    },
    on_ok = function(input, state) {
      rowvar <- trim_blanks(input[[ns("rowvar")]] %||% "")
      colvar <- trim_blanks(input[[ns("colvar")]] %||% "")
      rownames <- trimws(strsplit(trim_blanks(input[[ns("rownames")]] %||% ""), ",", fixed = TRUE)[[1L]])
      colnames <- trimws(strsplit(trim_blanks(input[[ns("colnames")]] %||% ""), ",", fixed = TRUE)[[1L]])
      counts <- suppressWarnings(as.numeric(trimws(strsplit(
        trim_blanks(input[[ns("counts")]] %||% ""), ",", fixed = TRUE
      )[[1L]])))
      if (!nzchar(rowvar) || !nzchar(colvar)) {
        return(list(error = tr("You must enter row and column variable names.")))
      }
      if (anyNA(counts) || length(counts) != length(rownames) * length(colnames)) {
        return(list(error = tr("The number of counts must equal rows x columns.")))
      }
      options <- table_options_on_ok(input, ns)
      list(
        commands = cmd_enter_table(
          rowvar, colvar, rownames, colnames, counts,
          percents = options$percents, chisq = options$chisq,
          expected = options$expected, components = options$components,
          fisher = options$fisher
        ),
        memory = list(rowvar = rowvar, colvar = colvar,
                      rownames = input[[ns("rownames")]] %||% "",
                      colnames = input[[ns("colnames")]] %||% "",
                      counts = input[[ns("counts")]] %||% "",
                      percents = options$percents, chisq = options$chisq,
                      expected = options$expected, components = options$components,
                      fisher = options$fisher)
      )
    }
  )
}

# Means ---------------------------------------------------------------------

independent_t_dialog <- function() {
  id <- "independentSamplesTTest"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(group = NULL, response = NULL, alternative = "two.sided",
                   conf = 0.95, var_equal = FALSE)

  dialog_spec(
    id = id, title = tr("Independent Samples t-Test"), help = "t.test",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        var_input(ns("group"), tr("Groups (pick one)"),
                  two_level_factors(state), selected = m$group),
        var_input(ns("response"), tr("Response Variable (pick one)"),
                  numeric_variables(state), selected = m$response),
        stats_alternative_input(ns("alternative"), m$alternative),
        stats_confidence_input(ns("conf"), m$conf),
        checkbox_input(ns("var_equal"), tr("Assume equal variances?"), m$var_equal)
      )
    },
    on_ok = function(input, state) {
      group <- input[[ns("group")]] %||% ""
      response <- input[[ns("response")]] %||% ""
      if (!nzchar(group)) return(list(error = tr("You must select a groups variable.")))
      if (!nzchar(response)) return(list(error = tr("You must select a response variable.")))
      list(
        commands = cmd_independent_t(
          active_dataset(state), response, group,
          alternative = input[[ns("alternative")]] %||% "two.sided",
          conf_level = input[[ns("conf")]] %||% 0.95,
          var_equal = isTRUE(input[[ns("var_equal")]])
        ),
        memory = list(group = group, response = response,
                      alternative = input[[ns("alternative")]] %||% "two.sided",
                      conf = input[[ns("conf")]] %||% 0.95,
                      var_equal = isTRUE(input[[ns("var_equal")]]))
      )
    }
  )
}

paired_t_dialog <- function() {
  id <- "pairedTTest"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(x = NULL, y = NULL, alternative = "two.sided", conf = 0.95)

  dialog_spec(
    id = id, title = tr("Paired t-Test"), help = "t.test",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        var_input(ns("x"), tr("First variable (pick one)"),
                  numeric_variables(state), selected = m$x),
        var_input(ns("y"), tr("Second variable (pick one)"),
                  numeric_variables(state), selected = m$y),
        stats_alternative_input(ns("alternative"), m$alternative),
        stats_confidence_input(ns("conf"), m$conf)
      )
    },
    on_ok = function(input, state) {
      x <- input[[ns("x")]] %||% ""
      y <- input[[ns("y")]] %||% ""
      if (!nzchar(x) || !nzchar(y)) {
        return(list(error = tr("You must select two variables.")))
      }
      if (identical(x, y)) return(list(error = tr("Variables must be different.")))
      list(
        commands = cmd_paired_t(active_dataset(state), x, y,
                                input[[ns("alternative")]] %||% "two.sided",
                                input[[ns("conf")]] %||% 0.95),
        memory = list(x = x, y = y,
                      alternative = input[[ns("alternative")]] %||% "two.sided",
                      conf = input[[ns("conf")]] %||% 0.95)
      )
    }
  )
}

single_t_dialog <- function() {
  id <- "singleSampleTTest"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(x = NULL, alternative = "two.sided", mu = 0, conf = 0.95)

  dialog_spec(
    id = id, title = tr("Single-Sample t-Test"), help = "t.test",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        var_input(ns("x"), tr("Variable (pick one)"),
                  numeric_variables(state), selected = m$x),
        stats_alternative_input(
          ns("alternative"), m$alternative,
          c("Population mean != mu0" = "two.sided",
            "Population mean < mu0" = "less",
            "Population mean > mu0" = "greater")
        ),
        spin_input(ns("mu"), tr("Null hypothesis: mu ="), m$mu),
        stats_confidence_input(ns("conf"), m$conf)
      )
    },
    on_ok = function(input, state) {
      x <- input[[ns("x")]] %||% ""
      if (!nzchar(x)) return(list(error = tr("You must select a variable.")))
      list(
        commands = cmd_single_t(active_dataset(state), x,
                                input[[ns("alternative")]] %||% "two.sided",
                                input[[ns("mu")]] %||% 0,
                                input[[ns("conf")]] %||% 0.95),
        memory = list(x = x,
                      alternative = input[[ns("alternative")]] %||% "two.sided",
                      mu = input[[ns("mu")]] %||% 0,
                      conf = input[[ns("conf")]] %||% 0.95)
      )
    }
  )
}

one_way_anova_dialog <- function() {
  id <- "oneWayAnova"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(model = "", group = NULL, response = NULL,
                   pairwise = FALSE, welch = FALSE, conf = 0.95)

  dialog_spec(
    id = id, title = tr("One-Way ANOVA"), help = "anova",
    on_open = stats_model_open,
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      if (!nzchar(m$model)) m$model <- stats_default_model(state, "AnovaModel")
      htmltools::tagList(
        entry_input(ns("model"), tr("Enter name for model:"), m$model),
        var_input(ns("group"), tr("Groups (pick one)"),
                  factor_variables(state), selected = m$group),
        var_input(ns("response"), tr("Response Variable (pick one)"),
                  numeric_variables(state), selected = m$response),
        checkbox_input(ns("pairwise"), tr("Pairwise comparisons of means"),
                       m$pairwise),
        stats_confidence_input(ns("conf"), m$conf),
        checkbox_input(ns("welch"),
                       tr("Welch F-test not assuming equal variances"), m$welch)
      )
    },
    on_ok = function(input, state) {
      group <- input[[ns("group")]] %||% ""
      response <- input[[ns("response")]] %||% ""
      model <- trim_blanks(input[[ns("model")]] %||% "")
      if (!nzchar(group)) return(list(error = tr("You must select a groups factor.")))
      if (!nzchar(response)) return(list(error = tr("You must select a response variable.")))
      if (!is_valid_name(model)) {
        return(list(error = sprintf(tr('"%s" is not a valid name.'), model)))
      }
      list(
        commands = cmd_one_way_anova(
          active_dataset(state), model, response, group,
          pairwise = isTRUE(input[[ns("pairwise")]]),
          welch = isTRUE(input[[ns("welch")]]),
          conf_level = input[[ns("conf")]] %||% 0.95
        ),
        activate_model = model,
        memory = list(model = "", group = group, response = response,
                      pairwise = isTRUE(input[[ns("pairwise")]]),
                      welch = isTRUE(input[[ns("welch")]]),
                      conf = input[[ns("conf")]] %||% 0.95)
      )
    }
  )
}

multi_way_anova_dialog <- function() {
  id <- "multiWayAnova"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(model = "", groups = NULL, response = NULL)

  dialog_spec(
    id = id, title = tr("Multi-Way ANOVA"), help = "Anova",
    on_open = stats_model_open,
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      if (!nzchar(m$model)) m$model <- stats_default_model(state, "AnovaModel")
      htmltools::tagList(
        entry_input(ns("model"), tr("Enter name for model:"), m$model),
        var_input(ns("groups"), tr("Factors (pick one or more)"),
                  factor_variables(state), selected = m$groups, multiple = TRUE),
        var_input(ns("response"), tr("Response Variable (pick one)"),
                  numeric_variables(state), selected = m$response)
      )
    },
    on_ok = function(input, state) {
      groups <- input[[ns("groups")]]
      response <- input[[ns("response")]] %||% ""
      model <- trim_blanks(input[[ns("model")]] %||% "")
      if (length(groups) == 0L) return(list(error = tr("You must select at least one factor.")))
      if (!nzchar(response)) return(list(error = tr("You must select a response variable.")))
      if (!is_valid_name(model)) {
        return(list(error = sprintf(tr('"%s" is not a valid name.'), model)))
      }
      list(
        commands = cmd_multi_way_anova(active_dataset(state), model, response, groups),
        activate_model = model,
        memory = list(model = "", groups = groups, response = response)
      )
    }
  )
}

one_way_rm_dialog <- function() {
  id <- "oneWayRepeatedMeasures"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(responses = NULL, within = "time", levels = "",
                   between = NULL, test = "univariate")

  dialog_spec(
    id = id, title = tr("One-Factor Repeated-Measures ANOVA/ANCOVA"),
    help = "Anova",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        var_input(ns("responses"), tr("Within-subject responses"),
                  numeric_variables(state), selected = m$responses,
                  multiple = TRUE),
        entry_input(ns("within"), tr("Within-subject factor name:"), m$within),
        entry_input(ns("levels"), tr("Level names (comma separated):"), m$levels),
        var_input(ns("between"), tr("Between-subject factors (optional)"),
                  factor_variables(state), selected = m$between,
                  multiple = TRUE),
        radio_input(ns("test"), tr("Test"),
                    c("Univariate" = "univariate",
                      "Multivariate" = "multivariate"), m$test)
      )
    },
    on_ok = function(input, state) {
      responses <- input[[ns("responses")]]
      within <- trim_blanks(input[[ns("within")]] %||% "")
      text <- trim_blanks(input[[ns("levels")]] %||% "")
      if (length(responses) < 2L) {
        return(list(error = tr("at least 2 responses must be specified")))
      }
      if (!is_valid_name(within)) {
        return(list(error = sprintf(tr('"%s" is not a valid name.'), within)))
      }
      levels <- if (nzchar(text)) {
        trimws(strsplit(text, ",", fixed = TRUE)[[1L]])
      } else {
        paste0("Level-", seq_along(responses))
      }
      if (length(levels) != length(responses)) {
        return(list(error = tr("The number of level names must match the number of responses.")))
      }
      between <- input[[ns("between")]]
      list(
        commands = cmd_one_way_repeated(
          active_dataset(state), responses, within, levels,
          between = between,
          test = input[[ns("test")]] %||% "univariate"
        ),
        memory = list(responses = responses, within = within, levels = text,
                      between = between,
                      test = input[[ns("test")]] %||% "univariate")
      )
    }
  )
}

two_way_rm_dialog <- function() {
  id <- "twoWayRepeatedMeasures"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(responses = NULL, rowname = "row", rowlevels = "",
                   colname = "column", collevels = "", between = NULL,
                   test = "univariate")

  dialog_spec(
    id = id, title = tr("Two-Factor Repeated-Measures ANOVA/ANCOVA"),
    help = "Anova",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        var_input(ns("responses"), tr("Responses (row by row)"),
                  numeric_variables(state), selected = m$responses,
                  multiple = TRUE),
        entry_input(ns("rowname"), tr("Row factor name:"), m$rowname),
        entry_input(ns("rowlevels"), tr("Row levels (comma separated):"), m$rowlevels),
        entry_input(ns("colname"), tr("Column factor name:"), m$colname),
        entry_input(ns("collevels"), tr("Column levels (comma separated):"), m$collevels),
        var_input(ns("between"), tr("Between-subject factors (optional)"),
                  factor_variables(state), selected = m$between, multiple = TRUE),
        radio_input(ns("test"), tr("Test"),
                    c("Univariate" = "univariate",
                      "Multivariate" = "multivariate"), m$test)
      )
    },
    on_ok = function(input, state) {
      responses <- input[[ns("responses")]]
      rowname <- trim_blanks(input[[ns("rowname")]] %||% "")
      colname <- trim_blanks(input[[ns("colname")]] %||% "")
      rowlevels <- trimws(strsplit(trim_blanks(input[[ns("rowlevels")]] %||% ""), ",", fixed = TRUE)[[1L]])
      collevels <- trimws(strsplit(trim_blanks(input[[ns("collevels")]] %||% ""), ",", fixed = TRUE)[[1L]])
      if (length(responses) < 4L) {
        return(list(error = tr("at least 2 rows and 2 columns of responses must be specified")))
      }
      if (!is_valid_name(rowname) || !is_valid_name(colname)) {
        return(list(error = tr("The within-subject factor names must be valid names.")))
      }
      if (length(responses) != length(rowlevels) * length(collevels)) {
        return(list(error = tr("The number of responses must equal rows x columns.")))
      }
      list(
        commands = cmd_two_way_repeated(
          active_dataset(state), responses, rowname, rowlevels,
          colname, collevels, between = input[[ns("between")]],
          test = input[[ns("test")]] %||% "univariate"
        ),
        memory = list(responses = responses, rowname = rowname,
                      rowlevels = input[[ns("rowlevels")]] %||% "",
                      colname = colname,
                      collevels = input[[ns("collevels")]] %||% "",
                      between = input[[ns("between")]],
                      test = input[[ns("test")]] %||% "univariate")
      )
    }
  )
}

# Variances -----------------------------------------------------------------

two_variances_dialog <- function() {
  id <- "twoVariancesFTest"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(group = NULL, response = NULL,
                   alternative = "two.sided", conf = 0.95)

  dialog_spec(
    id = id, title = tr("Two-Variances F-Test"), help = "var.test",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        var_input(ns("group"), tr("Groups (pick one)"),
                  two_level_factors(state), selected = m$group),
        var_input(ns("response"), tr("Response Variable (pick one)"),
                  numeric_variables(state), selected = m$response),
        radio_input(ns("alternative"), tr("Alternative Hypothesis"),
                    c("Two-sided" = "two.sided", "Ratio < 1" = "less",
                      "Ratio > 1" = "greater"), m$alternative),
        stats_confidence_input(ns("conf"), m$conf)
      )
    },
    on_ok = function(input, state) {
      group <- input[[ns("group")]] %||% ""
      response <- input[[ns("response")]] %||% ""
      if (!nzchar(group) || !nzchar(response)) {
        return(list(error = tr("You must select a group and a response variable.")))
      }
      list(
        commands = cmd_two_variances_f(
          active_dataset(state), response, group,
          alternative = input[[ns("alternative")]] %||% "two.sided",
          conf_level = input[[ns("conf")]] %||% 0.95
        ),
        memory = list(group = group, response = response,
                      alternative = input[[ns("alternative")]] %||% "two.sided",
                      conf = input[[ns("conf")]] %||% 0.95)
      )
    }
  )
}

variance_test_dialog <- function(id, title, help, builder) {
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(response = NULL, groups = NULL, center = "median")

  dialog_spec(
    id = id, title = title, help = help,
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        var_input(ns("response"), tr("Response Variable (pick one)"),
                  numeric_variables(state), selected = m$response),
        var_input(ns("groups"), tr("Factors (pick one or more)"),
                  factor_variables(state), selected = m$groups,
                  multiple = identical(id, "BartlettTest") ||
                    identical(id, "LeveneTest")),
        if (identical(id, "LeveneTest")) {
          radio_input(ns("center"), tr("Center"),
                      c("Median" = "median", "Mean" = "mean"), m$center)
        }
      )
    },
    on_ok = function(input, state) {
      response <- input[[ns("response")]] %||% ""
      groups <- input[[ns("groups")]]
      if (!nzchar(response) || length(groups) == 0L) {
        return(list(error = tr("You must select a response and at least one factor.")))
      }
      commands <- if (identical(id, "LeveneTest")) {
        cmd_levene(active_dataset(state), response, groups,
                   input[[ns("center")]] %||% "median")
      } else {
        builder(active_dataset(state), response, groups)
      }
      list(
        commands = commands,
        memory = list(response = response, groups = groups,
                      center = input[[ns("center")]] %||% "median")
      )
    }
  )
}

sigma_test_dialog <- function() {
  id <- "sigmaTestMenu"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(x = NULL, alternative = "two.sided", sigma = 1, conf = 0.95)

  dialog_spec(
    id = id, title = tr("Single-Sample Variance Test"), help = "sigma.test",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        var_input(ns("x"), tr("Variable (pick one)"),
                  numeric_variables(state), selected = m$x),
        stats_alternative_input(ns("alternative"), m$alternative),
        spin_input(ns("sigma"), tr("Null hypothesis: sigma0^2 ="), m$sigma,
                   min = 0, step = 0.1),
        stats_confidence_input(ns("conf"), m$conf)
      )
    },
    on_ok = function(input, state) {
      x <- input[[ns("x")]] %||% ""
      if (!nzchar(x)) return(list(error = tr("You must select a variable.")))
      list(
        commands = cmd_sigma_test(active_dataset(state), x,
                                  input[[ns("alternative")]] %||% "two.sided",
                                  input[[ns("sigma")]] %||% 1,
                                  input[[ns("conf")]] %||% 0.95),
        memory = list(x = x,
                      alternative = input[[ns("alternative")]] %||% "two.sided",
                      sigma = input[[ns("sigma")]] %||% 1,
                      conf = input[[ns("conf")]] %||% 0.95)
      )
    }
  )
}

# Proportions ---------------------------------------------------------------

single_proportion_dialog <- function() {
  id <- "singleProportionTest"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(x = NULL, test = "normal", alternative = "two.sided",
                   p = 0.5, conf = 0.95)

  dialog_spec(
    id = id, title = tr("Single-Sample Proportion Test"), help = "prop.test",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        var_input(ns("x"), tr("Variable (pick one)"),
                  factor_variables(state), selected = m$x),
        radio_input(ns("test"), tr("Test"),
                    c("Normal approximation (no continuity correction)" = "normal",
                      "Normal approximation (continuity correction)" = "corrected",
                      "Exact binomial" = "binomial"), m$test),
        stats_alternative_input(ns("alternative"), m$alternative),
        spin_input(ns("p"), tr("Null hypothesis: p ="), m$p, min = 0, max = 1,
                   step = 0.01),
        stats_confidence_input(ns("conf"), m$conf)
      )
    },
    on_ok = function(input, state) {
      x <- input[[ns("x")]] %||% ""
      if (!nzchar(x)) return(list(error = tr("You must select a variable.")))
      list(
        commands = cmd_single_proportion(
          active_dataset(state), x,
          test = input[[ns("test")]] %||% "normal",
          alternative = input[[ns("alternative")]] %||% "two.sided",
          p = input[[ns("p")]] %||% 0.5,
          conf_level = input[[ns("conf")]] %||% 0.95
        ),
        memory = list(x = x, test = input[[ns("test")]] %||% "normal",
                      alternative = input[[ns("alternative")]] %||% "two.sided",
                      p = input[[ns("p")]] %||% 0.5,
                      conf = input[[ns("conf")]] %||% 0.95)
      )
    }
  )
}

two_proportions_dialog <- function() {
  id <- "twoSampleProportionsTest"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(groups = NULL, response = NULL, test = "normal",
                   alternative = "two.sided", conf = 0.95)

  dialog_spec(
    id = id, title = tr("Two-Sample Proportions Test"), help = "prop.test",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        var_input(ns("groups"), tr("Groups (pick one)"),
                  two_level_factors(state), selected = m$groups),
        var_input(ns("response"), tr("Response (pick one)"),
                  two_level_factors(state), selected = m$response),
        radio_input(ns("test"), tr("Test"),
                    c("Normal approximation (no continuity correction)" = "normal",
                      "Normal approximation (continuity correction)" = "corrected"),
                    m$test),
        stats_alternative_input(ns("alternative"), m$alternative),
        stats_confidence_input(ns("conf"), m$conf)
      )
    },
    on_ok = function(input, state) {
      groups <- input[[ns("groups")]] %||% ""
      response <- input[[ns("response")]] %||% ""
      if (!nzchar(groups) || !nzchar(response)) {
        return(list(error = tr("You must select groups and a response variable.")))
      }
      list(
        commands = cmd_two_proportions(
          active_dataset(state), groups, response,
          test = input[[ns("test")]] %||% "normal",
          alternative = input[[ns("alternative")]] %||% "two.sided",
          conf_level = input[[ns("conf")]] %||% 0.95
        ),
        memory = list(groups = groups, response = response,
                      test = input[[ns("test")]] %||% "normal",
                      alternative = input[[ns("alternative")]] %||% "two.sided",
                      conf = input[[ns("conf")]] %||% 0.95)
      )
    }
  )
}

# Nonparametric -------------------------------------------------------------

two_sample_wilcoxon_dialog <- function() {
  id <- "twoSampleWilcoxonTest"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(group = NULL, response = NULL, test = "default",
                   alternative = "two.sided")

  dialog_spec(
    id = id, title = tr("Two-Sample Wilcoxon Test"), help = "wilcox.test",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        var_input(ns("group"), tr("Groups (pick one)"),
                  two_level_factors(state), selected = m$group),
        var_input(ns("response"), tr("Response Variable (pick one)"),
                  numeric_variables(state), selected = m$response),
        radio_input(ns("test"), tr("Test"),
                    c("Default" = "default", "Exact" = "exact",
                      "Normal approximation" = "correct"), m$test),
        stats_alternative_input(ns("alternative"), m$alternative)
      )
    },
    on_ok = function(input, state) {
      group <- input[[ns("group")]] %||% ""
      response <- input[[ns("response")]] %||% ""
      if (!nzchar(group) || !nzchar(response)) {
        return(list(error = tr("You must select a group and a response variable.")))
      }
      list(
        commands = cmd_two_sample_wilcoxon(
          active_dataset(state), response, group,
          alternative = input[[ns("alternative")]] %||% "two.sided",
          test = input[[ns("test")]] %||% "default"
        ),
        memory = list(group = group, response = response,
                      test = input[[ns("test")]] %||% "default",
                      alternative = input[[ns("alternative")]] %||% "two.sided")
      )
    }
  )
}

paired_wilcoxon_dialog <- function() {
  id <- "pairedWilcoxonTest"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(x = NULL, y = NULL, test = "default",
                   alternative = "two.sided")

  dialog_spec(
    id = id, title = tr("Paired-Samples Wilcoxon Test"), help = "wilcox.test",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        var_input(ns("x"), tr("First variable (pick one)"),
                  numeric_variables(state), selected = m$x),
        var_input(ns("y"), tr("Second variable (pick one)"),
                  numeric_variables(state), selected = m$y),
        radio_input(ns("test"), tr("Test"),
                    c("Default" = "default", "Exact" = "exact",
                      "Normal approximation" = "correct"), m$test),
        stats_alternative_input(ns("alternative"), m$alternative)
      )
    },
    on_ok = function(input, state) {
      x <- input[[ns("x")]] %||% ""
      y <- input[[ns("y")]] %||% ""
      if (!nzchar(x) || !nzchar(y)) {
        return(list(error = tr("You must select two variables.")))
      }
      if (identical(x, y)) return(list(error = tr("The two variables must be different.")))
      list(
        commands = cmd_paired_wilcoxon(
          active_dataset(state), x, y,
          alternative = input[[ns("alternative")]] %||% "two.sided",
          test = input[[ns("test")]] %||% "default"
        ),
        memory = list(x = x, y = y,
                      test = input[[ns("test")]] %||% "default",
                      alternative = input[[ns("alternative")]] %||% "two.sided")
      )
    }
  )
}

kruskal_dialog <- function() {
  id <- "KruskalWallisTest"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(group = NULL, response = NULL)

  dialog_spec(
    id = id, title = tr("Kruskal-Wallis Test"), help = "kruskal.test",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        var_input(ns("group"), tr("Groups (pick one)"),
                  factor_variables(state), selected = m$group),
        var_input(ns("response"), tr("Response Variable (pick one)"),
                  numeric_variables(state), selected = m$response)
      )
    },
    on_ok = function(input, state) {
      group <- input[[ns("group")]] %||% ""
      response <- input[[ns("response")]] %||% ""
      if (!nzchar(group) || !nzchar(response)) {
        return(list(error = tr("You must select a group and a response variable.")))
      }
      list(
        commands = cmd_kruskal_wallis(active_dataset(state), response, group),
        memory = list(group = group, response = response)
      )
    }
  )
}

friedman_dialog <- function() {
  id <- "FriedmanTest"
  ns <- function(x) paste0(id, "_", x)

  dialog_spec(
    id = id, title = tr("Friedman Rank-Sum Test"), help = "friedman.test",
    ui = function(state, memory) {
      var_input(ns("responses"), tr("Variables (pick two or more)"),
                numeric_variables(state), selected = memory$responses,
                multiple = TRUE)
    },
    on_ok = function(input, state) {
      responses <- input[[ns("responses")]]
      if (length(responses) < 2L) {
        return(list(error = tr("You must select at least two variables.")))
      }
      list(
        commands = cmd_friedman(active_dataset(state), responses),
        memory = list(responses = responses)
      )
    }
  )
}

one_sample_wilcoxon_dialog <- function() {
  id <- "onesampleWilcoxonTest"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(x = NULL, test = "default", alternative = "two.sided",
                   mu = 0)

  dialog_spec(
    id = id, title = tr("Single-Sample Wilcoxon Test"), help = "wilcox.test",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        var_input(ns("x"), tr("Variable (pick one)"),
                  numeric_variables(state), selected = m$x),
        radio_input(ns("test"), tr("Test"),
                    c("Default" = "default", "Exact" = "exact",
                      "Normal approximation" = "correct"), m$test),
        stats_alternative_input(ns("alternative"), m$alternative),
        spin_input(ns("mu"), tr("Null hypothesis: mu ="), m$mu)
      )
    },
    on_ok = function(input, state) {
      x <- input[[ns("x")]] %||% ""
      if (!nzchar(x)) return(list(error = tr("You must select a variable.")))
      list(
        commands = cmd_one_sample_wilcoxon(
          active_dataset(state), x,
          alternative = input[[ns("alternative")]] %||% "two.sided",
          mu = input[[ns("mu")]] %||% 0,
          test = input[[ns("test")]] %||% "default"
        ),
        memory = list(x = x, test = input[[ns("test")]] %||% "default",
                      alternative = input[[ns("alternative")]] %||% "two.sided",
                      mu = input[[ns("mu")]] %||% 0)
      )
    }
  )
}

# Dimensional analysis ------------------------------------------------------

reliability_dialog <- function() {
  id <- "Reliability"
  ns <- function(x) paste0(id, "_", x)

  dialog_spec(
    id = id, title = tr("Scale Reliability"), help = "reliability",
    ui = function(state, memory) {
      var_input(ns("variables"), tr("Variables (pick three or more)"),
                numeric_variables(state), selected = memory$variables,
                multiple = TRUE)
    },
    on_ok = function(input, state) {
      variables <- input[[ns("variables")]]
      if (length(variables) < 3L) {
        return(list(error = tr("Fewer than 3 variables selected.")))
      }
      list(
        commands = cmd_reliability(active_dataset(state), variables),
        memory = list(variables = variables)
      )
    }
  )
}

pca_dialog <- function() {
  id <- "principalComponents"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(variables = NULL, correlations = TRUE, subset = "",
                   scree = FALSE)

  dialog_spec(
    id = id, title = tr("Principal Components Analysis"), help = "princomp",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        var_input(ns("variables"), tr("Variables (pick two or more)"),
                  numeric_variables(state), selected = m$variables,
                  multiple = TRUE),
        checkbox_input(ns("correlations"), tr("Analyze correlation matrix"),
                       m$correlations),
        checkbox_input(ns("scree"), tr("Screeplot"), m$scree),
        subset_input(ns("subset"), tr("Subset expression:"), m$subset)
      )
    },
    on_ok = function(input, state) {
      variables <- input[[ns("variables")]]
      if (length(variables) < 2L) {
        return(list(error = tr("Fewer than 2 variables selected.")))
      }
      list(
        commands = cmd_pca(
          active_dataset(state), variables,
          cor = isTRUE(input[[ns("correlations")]]),
          subset = trim_blanks(input[[ns("subset")]] %||% ""),
          scree = isTRUE(input[[ns("scree")]])
        ),
        memory = list(variables = variables,
                      correlations = isTRUE(input[[ns("correlations")]]),
                      subset = input[[ns("subset")]] %||% "",
                      scree = isTRUE(input[[ns("scree")]]))
      )
    }
  )
}

factor_analysis_dialog <- function() {
  id <- "factorAnalysis"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(variables = NULL, factors = 2L, rotation = "varimax",
                   scores = "none", subset = "")

  dialog_spec(
    id = id, title = tr("Factor Analysis"), help = "factanal",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        var_input(ns("variables"), tr("Variables (pick three or more)"),
                  numeric_variables(state), selected = m$variables,
                  multiple = TRUE),
        spin_input(ns("factors"), tr("Number of factors:"), m$factors,
                   min = 1, max = 20, step = 1),
        radio_input(ns("rotation"), tr("Rotation"),
                    c("Varimax" = "varimax", "Promax" = "promax",
                      "None" = "none"), m$rotation),
        radio_input(ns("scores"), tr("Scores"),
                    c("None" = "none", "Regression" = "regression",
                      "Bartlett" = "Bartlett"), m$scores),
        subset_input(ns("subset"), tr("Subset expression:"), m$subset)
      )
    },
    on_ok = function(input, state) {
      variables <- input[[ns("variables")]]
      if (length(variables) < 3L) {
        return(list(error = tr("Fewer than 3 variables selected.")))
      }
      list(
        commands = cmd_factor_analysis(
          active_dataset(state), variables,
          factors = input[[ns("factors")]] %||% 2,
          rotation = input[[ns("rotation")]] %||% "varimax",
          scores = input[[ns("scores")]] %||% "none",
          subset = trim_blanks(input[[ns("subset")]] %||% "")
        ),
        memory = list(variables = variables,
                      factors = input[[ns("factors")]] %||% 2,
                      rotation = input[[ns("rotation")]] %||% "varimax",
                      scores = input[[ns("scores")]] %||% "none",
                      subset = input[[ns("subset")]] %||% "")
      )
    }
  )
}

cfa_dialog <- function() {
  id <- "CFA"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(model = "", name = "")

  dialog_spec(
    id = id, title = tr("Confirmatory Factor Analysis"), help = "sem",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      if (!nzchar(m$name)) m$name <- stats_default_model(state, "CFA")
      htmltools::tagList(
        text_area(ns("model"), tr("SEM model specification (specifyModel text):"),
                  m$model, rows = 8L),
        entry_input(ns("name"), tr("Name for model:"), m$name)
      )
    },
    on_ok = function(input, state) {
      model <- trim_blanks(input[[ns("model")]] %||% "")
      name <- trim_blanks(input[[ns("name")]] %||% "")
      if (!nzchar(model)) return(list(error = tr("You must specify the model.")))
      if (!is_valid_name(name)) {
        return(list(error = sprintf(tr('"%s" is not a valid name.'), name)))
      }
      list(
        commands = cmd_cfa(active_dataset(state), model, name),
        activate_model = name,
        memory = list(model = model, name = name)
      )
    }
  )
}

# Cluster analysis ----------------------------------------------------------

kmeans_dialog <- function() {
  id <- "kmeansClustering"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(variables = NULL, centers = 3L, iter = 10L, seeds = 10L,
                   summary = TRUE, plot = FALSE, assign = "",
                   subset = "")

  dialog_spec(
    id = id, title = tr("K-Means Clustering"), help = "KMeans",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        var_input(ns("variables"), tr("Variables (pick one or more)"),
                  numeric_variables(state), selected = m$variables,
                  multiple = TRUE),
        spin_input(ns("centers"), tr("Number of clusters:"), m$centers,
                   min = 2, max = 20, step = 1),
        spin_input(ns("iter"), tr("Maximum iterations:"), m$iter,
                   min = 1, max = 100, step = 1),
        spin_input(ns("seeds"), tr("Number of random starts:"), m$seeds,
                   min = 1, max = 100, step = 1),
        checkbox_input(ns("summary"), tr("Print cluster summary"), m$summary),
        checkbox_input(ns("plot"), tr("Bi-plot of clusters"), m$plot),
        entry_input(ns("assign"), tr("Assigned cluster variable (optional):"),
                    m$assign),
        subset_input(ns("subset"), tr("Subset expression:"), m$subset)
      )
    },
    on_ok = function(input, state) {
      variables <- input[[ns("variables")]]
      if (length(variables) == 0L) {
        return(list(error = tr("No variables selected.")))
      }
      assign <- trim_blanks(input[[ns("assign")]] %||% "")
      if (nzchar(assign) && !is_valid_name(assign)) {
        return(list(error = sprintf(tr('"%s" is not a valid name.'), assign)))
      }
      list(
        commands = cmd_kmeans(
          active_dataset(state), variables,
          centers = input[[ns("centers")]] %||% 3,
          iter_max = input[[ns("iter")]] %||% 10,
          num_seeds = input[[ns("seeds")]] %||% 10,
          summary = isTRUE(input[[ns("summary")]]),
          plot = isTRUE(input[[ns("plot")]]),
          assign = assign,
          subset = trim_blanks(input[[ns("subset")]] %||% "")
        ),
        memory = list(variables = variables,
                      centers = input[[ns("centers")]] %||% 3,
                      iter = input[[ns("iter")]] %||% 10,
                      seeds = input[[ns("seeds")]] %||% 10,
                      summary = isTRUE(input[[ns("summary")]]),
                      plot = isTRUE(input[[ns("plot")]]),
                      assign = assign,
                      subset = input[[ns("subset")]] %||% "")
      )
    }
  )
}

hclust_dialog <- function() {
  id <- "hierarchicalCluster"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(solution = "", variables = NULL, method = "ward.D",
                   distance = "euc", dendro = TRUE, subset = "")

  dialog_spec(
    id = id, title = tr("Hierarchical Cluster Analysis"), help = "hclust",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      if (!nzchar(m$solution)) {
        n <- sum(vapply(ls(envir = state$env), function(x) {
          inherits(get(x, envir = state$env), "hclust")
        }, logical(1)))
        m$solution <- paste0("HClust.", n + 1L)
      }
      htmltools::tagList(
        entry_input(ns("solution"), tr("Name for clustering solution:"),
                    m$solution),
        var_input(ns("variables"), tr("Variables (pick one or more)"),
                  numeric_variables(state), selected = m$variables,
                  multiple = TRUE),
        radio_input(ns("method"), tr("Clustering Method"),
                    c("Ward" = "ward.D", "Complete" = "complete",
                      "Average" = "average", "Single" = "single",
                      "McQuitty" = "mcquitty", "Median" = "median",
                      "Centroid" = "centroid"), m$method),
        radio_input(ns("distance"), tr("Distance"),
                    c("Euclidean" = "euc", "Squared Euclidean" = "euc2",
                      "City-block" = "city", "Untransformed" = "none"),
                    m$distance),
        checkbox_input(ns("dendro"), tr("Plot dendrogram"), m$dendro),
        subset_input(ns("subset"), tr("Subset expression:"), m$subset)
      )
    },
    on_ok = function(input, state) {
      solution <- trim_blanks(input[[ns("solution")]] %||% "")
      variables <- input[[ns("variables")]]
      if (!is_valid_name(solution)) {
        return(list(error = sprintf(tr('"%s" is not a valid name.'), solution)))
      }
      if (length(variables) == 0L) {
        return(list(error = tr("No variables selected.")))
      }
      list(
        commands = cmd_hclust(
          active_dataset(state), solution, variables,
          method = input[[ns("method")]] %||% "ward.D",
          distance = input[[ns("distance")]] %||% "euc",
          dendro = isTRUE(input[[ns("dendro")]]),
          subset = trim_blanks(input[[ns("subset")]] %||% "")
        ),
        memory = list(solution = solution, variables = variables,
                      method = input[[ns("method")]] %||% "ward.D",
                      distance = input[[ns("distance")]] %||% "euc",
                      dendro = isTRUE(input[[ns("dendro")]]),
                      subset = input[[ns("subset")]] %||% "")
      )
    }
  )
}

hclust_solutions <- function(state) {
  objects <- ls(envir = state$env)
  objects[vapply(objects, function(x) inherits(get(x, envir = state$env), "hclust"),
                 logical(1))]
}

hclust_summary_dialog <- function() {
  id <- "hclustSummary"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(solution = NULL, clusters = 3L, summary = TRUE, plot = FALSE)

  dialog_spec(
    id = id, title = tr("Summarize Hierarchical Clustering"), help = "cutree",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      solutions <- hclust_solutions(state)
      htmltools::tagList(
        combo_input(ns("solution"), tr("Clustering solution"),
                    stats::setNames(solutions, solutions),
                    selected = m$solution),
        spin_input(ns("clusters"), tr("Number of clusters:"), m$clusters,
                   min = 2, max = 20, step = 1),
        checkbox_input(ns("summary"), tr("Print cluster summary"), m$summary),
        checkbox_input(ns("plot"), tr("Plot dendrogram"), m$plot)
      )
    },
    on_ok = function(input, state) {
      solution <- input[[ns("solution")]] %||% ""
      if (!nzchar(solution)) {
        return(list(error = tr("A clustering solution has not been selected.")))
      }
      list(
        commands = cmd_hclust_summary(
          solution, input[[ns("clusters")]] %||% 3,
          summary = isTRUE(input[[ns("summary")]]),
          plot = isTRUE(input[[ns("plot")]])
        ),
        memory = list(solution = solution,
                      clusters = input[[ns("clusters")]] %||% 3,
                      summary = isTRUE(input[[ns("summary")]]),
                      plot = isTRUE(input[[ns("plot")]]))
      )
    }
  )
}

append_hclust_dialog <- function() {
  id <- "appendHclustGroup"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(solution = NULL, clusters = 3L, label = "cluster")

  dialog_spec(
    id = id, title = tr("Add Hierarchical Clustering to Data Set"),
    help = "cutree",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      solutions <- hclust_solutions(state)
      htmltools::tagList(
        combo_input(ns("solution"), tr("Clustering solution"),
                    stats::setNames(solutions, solutions),
                    selected = m$solution),
        spin_input(ns("clusters"), tr("Number of clusters:"), m$clusters,
                   min = 2, max = 20, step = 1),
        entry_input(ns("label"), tr("Assigned cluster label:"), m$label)
      )
    },
    on_ok = function(input, state) {
      solution <- input[[ns("solution")]] %||% ""
      label <- trim_blanks(input[[ns("label")]] %||% "")
      if (!nzchar(solution)) {
        return(list(error = tr("A clustering solution has not been selected.")))
      }
      if (!is_valid_name(label)) {
        return(list(error = sprintf(tr('"%s" is not a valid name.'), label)))
      }
      list(
        commands = cmd_append_hclust(active_dataset(state), solution,
                                     input[[ns("clusters")]] %||% 3, label),
        activate_dataset = active_dataset(state),
        memory = list(solution = solution,
                      clusters = input[[ns("clusters")]] %||% 3,
                      label = label)
      )
    }
  )
}

# Models --------------------------------------------------------------------

linear_regression_dialog <- function() {
  id <- "linearRegressionModel"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(model = "", response = NULL, predictors = NULL,
                   subset = "", weights = "", remove = "")

  dialog_spec(
    id = id, title = tr("Linear Regression"), help = "lm",
    on_open = stats_model_open,
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      if (!nzchar(m$model)) m$model <- stats_default_model(state, "LinearModel")
      htmltools::tagList(
        entry_input(ns("model"), tr("Enter name for model:"), m$model),
        var_input(ns("response"), tr("Response variable:"),
                  numeric_variables(state), selected = m$response),
        var_input(ns("predictors"), tr("Predictors (pick one or more)"),
                  variables(state), selected = m$predictors,
                  multiple = TRUE),
        subset_input(ns("subset"), tr("Subset expression:"), m$subset),
        combo_input(ns("weights"), tr("Weights"),
                    c(stats::setNames("", tr("<no variable selected>")),
                      stats::setNames(numeric_variables(state), numeric_variables(state))),
                    selected = m$weights %||% ""),
        entry_input(ns("remove"), tr("Indices or names of row(s) to remove"), m$remove)
      )
    },
    on_ok = function(input, state) {
      model <- trim_blanks(input[[ns("model")]] %||% "")
      response <- input[[ns("response")]] %||% ""
      predictors <- input[[ns("predictors")]]
      if (!is_valid_name(model)) {
        return(list(error = sprintf(tr('"%s" is not a valid name.'), model)))
      }
      if (!nzchar(response)) return(list(error = tr("You must select a response variable.")))
      if (length(predictors) == 0L) return(list(error = tr("You must select at least one predictor.")))
      subset <- trim_blanks(input[[ns("subset")]] %||% "")
      remove <- trim_blanks(input[[ns("remove")]] %||% "")
      if (nzchar(subset) && nzchar(remove)) {
        return(list(error = tr("You cannot specify both case removal and subset cases")))
      }
      remove_rows <- ""
      if (nzchar(remove)) {
        cases <- cases_subset(active_dataset(state), dataset(state), remove)
        if (!is.null(cases$error)) return(list(error = cases$error))
        remove_rows <- cases$value
      }
      list(
        commands = cmd_linear_regression(
          active_dataset(state), model, response, predictors,
          subset = subset,
          weights = input[[ns("weights")]] %||% "",
          remove_rows = remove_rows
        ),
        activate_model = model,
        memory = list(model = "", response = response, predictors = predictors,
                      subset = subset, weights = input[[ns("weights")]] %||% "",
                      remove = remove)
      )
    }
  )
}

glm_dialog <- function() {
  id <- "generalizedLinearModel"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(family = "binomial", link = "logit")

  stats_model_dialog(
    id, tr("Generalized Linear Model"), "glm", kind = "glm",
    defaults = list(model = "", lhs = "", rhs = "", subset = "", weights = "",
                    remove = "", family = "binomial", link = "logit"),
    extra_ui = function(m, ns) {
      htmltools::tagList(
        radio_input(ns("family"), tr("Family"),
                    c("binomial" = "binomial", "gaussian" = "gaussian",
                      "Gamma" = "Gamma", "inverse.gaussian" = "inverse.gaussian",
                      "poisson" = "poisson", "quasibinomial" = "quasibinomial",
                      "quasipoisson" = "quasipoisson", "quasi" = "quasi"),
                    m$family),
        entry_input(ns("link"), tr("Link function:"), m$link)
      )
    },
    on_submit = function(input, ns, state, m, remove_rows) {
      cmd_glm(
        active_dataset(state), m$model, m$lhs, m$rhs,
        family = input[[ns("family")]] %||% "binomial",
        link = input[[ns("link")]] %||% "logit",
        subset = m$subset, weights = m$weights, remove_rows = remove_rows
      )
    }
  )
}

model_formula_only_dialog <- function(id, title, help, default_prefix,
                                      builder, extra_ui = NULL) {
  ns <- function(x) paste0(id, "_", x)

  dialog_spec(
    id = id, title = title, help = help,
    on_open = stats_model_open,
    ui = function(state, memory) {
      m <- utils::modifyList(
        list(model = "", lhs = "", rhs = "", subset = "", remove = ""),
        memory %||% list()
      )
      if (!nzchar(m$model)) m$model <- stats_default_model(state, default_prefix)
      htmltools::tagList(
        entry_input(ns("model"), tr("Enter name for model:"), m$model),
        model_formula_input(id, variables(state), lhs = m$lhs, rhs = m$rhs),
        subset_input(ns("subset"), tr("Subset expression:"), m$subset),
        entry_input(ns("remove"), tr("Indices or names of row(s) to remove"), m$remove),
        if (!is.null(extra_ui)) extra_ui(m, ns)
      )
    },
    observers = function(input, output, session, state, refresh) {
      model_formula_observers(
        input, session, id,
        guard = function() identical(state$current_dialog, id)
      )
    },
    on_ok = function(input, state) {
      model <- trim_blanks(input[[ns("model")]] %||% "")
      lhs <- input[[ns("lhs")]] %||% ""
      rhs <- trim_blanks(input[[ns("rhs")]] %||% "")
      subset <- trim_blanks(input[[ns("subset")]] %||% "")
      remove <- trim_blanks(input[[ns("remove")]] %||% "")
      if (!is_valid_name(model)) {
        return(list(error = sprintf(tr('"%s" is not a valid name.'), model)))
      }
      if (!nzchar(lhs)) return(list(error = tr("Left-hand side of model empty.")))
      if (!nzchar(rhs)) return(list(error = tr("Right-hand side of model empty.")))
      if (nzchar(subset) && nzchar(remove)) {
        return(list(error = tr("You cannot specify both case removal and subset cases")))
      }
      remove_rows <- ""
      if (nzchar(remove)) {
        cases <- cases_subset(active_dataset(state), dataset(state), remove)
        if (!is.null(cases$error)) return(list(error = cases$error))
        remove_rows <- cases$value
      }
      list(
        commands = builder(input, ns, state, model, lhs, rhs, subset, remove_rows),
        activate_model = model,
        memory = list(model = "", lhs = lhs, rhs = rhs, subset = subset,
                      remove = remove)
      )
    }
  )
}

polr_dialog <- function() {
  model_formula_only_dialog(
    "ordinalRegressionModel", tr("Ordinal Regression Model"), "polr", "OrdinalModel",
    builder = function(input, ns, state, model, lhs, rhs, subset, remove_rows) {
      cmd_polr(active_dataset(state), model, lhs, rhs,
               method = input[[ns("method")]] %||% "logistic",
               subset = subset, remove_rows = remove_rows)
    },
    extra_ui = function(m, ns) {
      radio_input(ns("method"), tr("Link"),
                  c("logit" = "logistic", "probit" = "probit",
                    "loglog" = "loglog", "cloglog" = "cloglog",
                    "cauchit" = "cauchit"), m$method %||% "logistic")
    }
  )
}

multinom_dialog <- function() {
  model_formula_only_dialog(
    "multinomialLogitModel", tr("Multinomial Logit Model"), "multinom",
    "MultinomModel",
    builder = function(input, ns, state, model, lhs, rhs, subset, remove_rows) {
      cmd_multinom(active_dataset(state), model, lhs, rhs,
                   subset = subset, remove_rows = remove_rows)
    }
  )
}

lmer_dialog <- function() {
  model_formula_only_dialog(
    "linearMixedModel", tr("Linear Mixed Model"), "lmer", "LinearMixedModel",
    builder = function(input, ns, state, model, lhs, rhs, subset, remove_rows) {
      cmd_lmer(active_dataset(state), model, lhs, rhs,
               reml = isTRUE(input[[ns("reml")]]),
               subset = subset, remove_rows = remove_rows)
    },
    extra_ui = function(m, ns) {
      checkbox_input(ns("reml"), tr("Use REML estimation"),
                     m$reml %||% TRUE)
    }
  )
}

glmer_dialog <- function() {
  model_formula_only_dialog(
    "generalizedLinearMixedModel", tr("Generalized Linear Mixed Model"),
    "glmer", "GLMMModel",
    builder = function(input, ns, state, model, lhs, rhs, subset, remove_rows) {
      cmd_glmer(active_dataset(state), model, lhs, rhs,
                family = input[[ns("family")]] %||% "binomial",
                link = input[[ns("link")]] %||% "logit",
                subset = subset, remove_rows = remove_rows)
    },
    extra_ui = function(m, ns) {
      htmltools::tagList(
        radio_input(ns("family"), tr("Family"),
                    c("binomial" = "binomial", "poisson" = "poisson",
                      "gaussian" = "gaussian"), m$family %||% "binomial"),
        entry_input(ns("link"), tr("Link function:"), m$link %||% "logit")
      )
    }
  )
}

# Registry ------------------------------------------------------------------

phase3_dialogs <- function() {
  list(
    frequencyDistribution = frequency_distribution_dialog(),
    statisticsTable = statistics_table_dialog(),
    correlationMatrix = correlation_matrix_dialog(),
    correlationTest = correlation_test_dialog(),
    NormalityTest = normality_test_dialog(),
    transformVariables = transform_variables_dialog(),
    twoWayTable = two_way_table_dialog(),
    twoWayTableFromCounts = two_way_counts_dialog(),
    multiWayTable = multi_way_table_dialog(),
    enterTable = enter_table_dialog(),
    independentSamplesTTest = independent_t_dialog(),
    pairedTTest = paired_t_dialog(),
    singleSampleTTest = single_t_dialog(),
    oneWayAnova = one_way_anova_dialog(),
    multiWayAnova = multi_way_anova_dialog(),
    oneWayRepeatedMeasures = one_way_rm_dialog(),
    twoWayRepeatedMeasures = two_way_rm_dialog(),
    twoVariancesFTest = two_variances_dialog(),
    BartlettTest = variance_test_dialog("BartlettTest", tr("Bartlett's Test"),
                                        "bartlett.test", cmd_bartlett),
    LeveneTest = variance_test_dialog("LeveneTest", tr("Levene's Test"),
                                      "leveneTest", cmd_levene),
    sigmaTestMenu = sigma_test_dialog(),
    singleProportionTest = single_proportion_dialog(),
    twoSampleProportionsTest = two_proportions_dialog(),
    twoSampleWilcoxonTest = two_sample_wilcoxon_dialog(),
    pairedWilcoxonTest = paired_wilcoxon_dialog(),
    KruskalWallisTest = kruskal_dialog(),
    FriedmanTest = friedman_dialog(),
    onesampleWilcoxonTest = one_sample_wilcoxon_dialog(),
    Reliability = reliability_dialog(),
    principalComponents = pca_dialog(),
    factorAnalysis = factor_analysis_dialog(),
    CFA = cfa_dialog(),
    kmeansClustering = kmeans_dialog(),
    hierarchicalCluster = hclust_dialog(),
    hclustSummary = hclust_summary_dialog(),
    appendHclustGroup = append_hclust_dialog(),
    linearRegressionModel = linear_regression_dialog(),
    generalizedLinearModel = glm_dialog(),
    multinomialLogitModel = multinom_dialog(),
    ordinalRegressionModel = polr_dialog(),
    linearMixedModel = lmer_dialog(),
    generalizedLinearMixedModel = glmer_dialog()
  )
}
