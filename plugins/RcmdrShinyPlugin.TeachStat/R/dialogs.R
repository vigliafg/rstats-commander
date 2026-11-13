# Shiny dialogs for TeachStat -------------------------------------------

ts_dialog <- function(id, title, fields, build, help = NULL) {
  force(fields)
  force(build)
  force(title)
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

ts_var <- function(name, label, kind = "numeric", multiple = FALSE,
                   default = character()) {
  list(name = name, label = label, type = "variable", kind = kind,
       multiple = multiple, default = default)
}

ts_entry <- function(name, label, default = "") {
  list(name = name, label = label, type = "entry", default = default)
}

ts_spin <- function(name, label, default = 1) {
  list(name = name, label = label, type = "spin", default = default)
}

ts_combo <- function(name, label, choices, default = NULL) {
  list(name = name, label = label, type = "combo", choices = choices,
       default = if (is.null(default)) choices[[1L]] else default)
}

ts_checkbox <- function(name, label, default = FALSE) {
  list(name = name, label = label, type = "checkbox", default = default)
}

ts_alternative_field <- function(default = "two.sided") {
  ts_combo("alternative", "Alternative hypothesis",
           c("two-sided" = "two.sided", "less" = "less",
             "greater" = "greater"), default)
}

ts_level_field <- function(default = "0.95") {
  ts_entry("level", "Confidence level", default)
}

ts_distr_params <- function(values, family) {
  spec <- ts_distr_specs[[family]]
  params <- list()
  for (name in names(spec$params)) {
    params[[name]] <- suppressWarnings(as.numeric(values[[name]]))
    if (is.na(params[[name]])) stop(sprintf("%s must be a number.", name))
  }
  params
}

ts_distribution_dialogs <- function() {
  prefixes <- c(normal = "normal", t = "t", chisq = "chisq", F = "F",
                exponential = "exponential", uniform = "uniform",
                binomial = "binomial", Poisson = "Poisson",
                geometric = "geom", negbinomial = "negbinomial")
  dialogs <- list()

  add <- function(id, title, fields, build) {
    dialogs[[id]] <<- ts_dialog(id, title, fields, build)
  }

  for (family in names(ts_distr_specs)) {
    spec <- ts_distr_specs[[family]]
    prefix <- prefixes[[family]]
    param_fields <- lapply(names(spec$params), function(name) {
      ts_entry(name, name, as.character(spec$params[[name]]))
    })

    add(paste0(prefix, "DistrQuantiles"),
        paste("Quantiles of the", family, "distribution"),
        c(param_fields,
          list(ts_entry("probs", "Probabilities",
                        "c(0.025, 0.5, 0.975)"))),
        local({
          fam <- family
          function(values, state) {
            ts_quantiles(fam, ts_distr_params(values, fam), values$probs)
          }
        }))

    add(paste0(prefix, "ProbabilitiesInter"),
        paste("Probabilities of the", family, "distribution"),
        c(param_fields,
          list(ts_entry("values", "Values", "c(0, 1)"),
               ts_checkbox("lower_tail", "Lower tail", TRUE))),
        local({
          fam <- family
          function(values, state) {
            ts_probabilities(fam, ts_distr_params(values, fam),
                             values$values, values$lower_tail)
          }
        }))

    if (isTRUE(spec$discrete)) {
      add(paste0(prefix, "DistrMass"),
          paste("Probabilities of the", family, "distribution"),
          c(param_fields, list(ts_entry("values", "Values", "0:10"))),
          local({
            fam <- family
            function(values, state) {
              ts_mass(fam, ts_distr_params(values, fam), values$values)
            }
          }))
    }

    add(paste0(prefix, "DistrPlot"),
        paste("Plot of the", family, "distribution"),
        param_fields,
        local({
          fam <- family
          function(values, state) {
            ts_plot(fam, ts_distr_params(values, fam))
          }
        }))

    add(paste0(prefix, "DistrCharac"),
        paste("Characteristics of the", family, "distribution"),
        param_fields,
        local({
          fam <- family
          function(values, state) {
            ts_characteristics(fam, ts_distr_params(values, fam))
          }
        }))

    add(paste0(prefix, "DistrSamples"),
        paste("Sample from the", family, "distribution"),
        c(param_fields,
          list(ts_spin("n", "Sample size", 30),
               ts_entry("seed", "Random seed (optional)", ""))),
        local({
          fam <- family
          function(values, state) {
            ts_samples(fam, ts_distr_params(values, fam),
                       values$n, values$seed %||% "")
          }
        }))
  }

  dialogs
}

ts_inference_dialogs <- function() {
  list(
    intervaloConfianzaMedia = ts_dialog(
      "intervaloConfianzaMedia", "Confidence interval for the mean",
      list(ts_var("variable", "Variable"), ts_level_field(),
           ts_alternative_field(),
           ts_entry("known_variance", "Known variance (optional)", "")),
      function(values, state) {
        if (!nzchar(values$variable)) stop("Select a variable.")
        ts_ci_mean(RcmdrShiny::active_dataset(state), values$variable,
                   values$level, values$alternative, values$known_variance)
      }
    ),
    intervaloConfianzaVarianza = ts_dialog(
      "intervaloConfianzaVarianza", "Confidence interval for the variance",
      list(ts_var("variable", "Variable"), ts_level_field()),
      function(values, state) {
        if (!nzchar(values$variable)) stop("Select a variable.")
        ts_ci_variance(RcmdrShiny::active_dataset(state), values$variable,
                       values$level)
      }
    ),
    intervaloConfianzaProporcion = ts_dialog(
      "intervaloConfianzaProporcion", "Confidence interval for a proportion",
      list(ts_spin("successes", "Successes", 0),
           ts_spin("trials", "Trials", 1), ts_level_field()),
      function(values, state) {
        ts_ci_proportion(values$successes, values$trials, values$level)
      }
    ),
    intervaloConfianzaMediasIndependientes = ts_dialog(
      "intervaloConfianzaMediasIndependientes",
      "Confidence interval for independent means",
      list(ts_var("response", "Response"), ts_var("group", "Group", "factor2"),
           ts_level_field(), ts_checkbox("equal_variance", "Equal variances")),
      function(values, state) {
        ts_ci_independent_means(RcmdrShiny::active_dataset(state),
                                values$response, values$group, values$level,
                                values$equal_variance)
      }
    ),
    intervaloConfianzaMediasPareadas = ts_dialog(
      "intervaloConfianzaMediasPareadas",
      "Confidence interval for paired means",
      list(ts_var("first", "First variable"), ts_var("second", "Second variable"),
           ts_level_field()),
      function(values, state) {
        ts_ci_paired(RcmdrShiny::active_dataset(state), values$first,
                     values$second, values$level)
      }
    ),
    intervaloConfianza2Varianzas = ts_dialog(
      "intervaloConfianza2Varianzas",
      "Confidence interval for the ratio of two variances",
      list(ts_var("response", "Response"), ts_var("group", "Group", "factor2"),
           ts_level_field()),
      function(values, state) {
        ts_ci_variance_ratio(RcmdrShiny::active_dataset(state),
                             values$response, values$group, values$level)
      }
    ),
    intervaloConfianzaDiferenciaProporciones = ts_dialog(
      "intervaloConfianzaDiferenciaProporciones",
      "Confidence interval for the difference of proportions",
      list(ts_spin("successes1", "Successes 1", 0),
           ts_spin("trials1", "Trials 1", 1),
           ts_spin("successes2", "Successes 2", 0),
           ts_spin("trials2", "Trials 2", 1), ts_level_field()),
      function(values, state) {
        ts_ci_diff_proportions(values$successes1, values$trials1,
                               values$successes2, values$trials2, values$level)
      }
    ),
    contrasteHipotesisMedia = ts_dialog(
      "contrasteHipotesisMedia", "Hypothesis testing for the mean",
      list(ts_var("variable", "Variable"), ts_entry("mu", "Null mean", "0"),
           ts_level_field(), ts_alternative_field(),
           ts_entry("known_variance", "Known variance (optional)", "")),
      function(values, state) {
        ts_test_mean(RcmdrShiny::active_dataset(state), values$variable,
                     values$mu, values$level, values$alternative,
                     values$known_variance)
      }
    ),
    contrasteHipotesisVarianza = ts_dialog(
      "contrasteHipotesisVarianza", "Hypothesis testing for the variance",
      list(ts_var("variable", "Variable"),
           ts_entry("sigma2", "Null variance", "1"),
           ts_level_field(), ts_alternative_field()),
      function(values, state) {
        ts_test_variance(RcmdrShiny::active_dataset(state), values$variable,
                         values$sigma2, values$level, values$alternative)
      }
    ),
    contrastHipotesisProporcion = ts_dialog(
      "contrastHipotesisProporcion", "Hypothesis testing for a proportion",
      list(ts_spin("successes", "Successes", 0),
           ts_spin("trials", "Trials", 1),
           ts_entry("p0", "Null proportion", "0.5"),
           ts_level_field(), ts_alternative_field()),
      function(values, state) {
        ts_test_proportion(values$successes, values$trials, values$p0,
                           values$level, values$alternative)
      }
    ),
    contrasteHipotesisMediasIndependientes = ts_dialog(
      "contrasteHipotesisMediasIndependientes",
      "Hypothesis testing for independent means",
      list(ts_var("response", "Response"), ts_var("group", "Group", "factor2"),
           ts_entry("mu", "Null difference", "0"), ts_level_field(),
           ts_alternative_field(), ts_checkbox("equal_variance", "Equal variances")),
      function(values, state) {
        ts_test_independent_means(RcmdrShiny::active_dataset(state),
                                  values$response, values$group, values$mu,
                                  values$level, values$alternative,
                                  values$equal_variance)
      }
    ),
    contrasteHipotesisMediasPareadas = ts_dialog(
      "contrasteHipotesisMediasPareadas",
      "Hypothesis testing for paired means",
      list(ts_var("first", "First variable"), ts_var("second", "Second variable"),
           ts_entry("mu", "Null difference", "0"), ts_level_field(),
           ts_alternative_field()),
      function(values, state) {
        ts_test_paired(RcmdrShiny::active_dataset(state), values$first,
                       values$second, values$mu, values$level,
                       values$alternative)
      }
    ),
    contrasteHipotesis2Varianzas = ts_dialog(
      "contrasteHipotesis2Varianzas",
      "Hypothesis testing for the ratio of two variances",
      list(ts_var("response", "Response"), ts_var("group", "Group", "factor2"),
           ts_level_field(), ts_alternative_field()),
      function(values, state) {
        ts_test_variance_ratio(RcmdrShiny::active_dataset(state),
                               values$response, values$group, values$level,
                               values$alternative)
      }
    ),
    contrasteHipotesisDiferenciaProporciones = ts_dialog(
      "contrasteHipotesisDiferenciaProporciones",
      "Hypothesis testing for the difference of proportions",
      list(ts_spin("successes1", "Successes 1", 0),
           ts_spin("trials1", "Trials 1", 1),
           ts_spin("successes2", "Successes 2", 0),
           ts_spin("trials2", "Trials 2", 1), ts_level_field(),
           ts_alternative_field()),
      function(values, state) {
        ts_test_diff_proportions(values$successes1, values$trials1,
                                 values$successes2, values$trials2,
                                 values$level, values$alternative)
      }
    )
  )
}

ts_descriptive_dialogs <- function() {
  list(
    resumenVariablesCualitativas = ts_dialog(
      "resumenVariablesCualitativas", "Frequency distribution",
      list(ts_var("variable", "Variable", "factor")),
      function(values, state) {
        ts_descriptive_factor(RcmdrShiny::active_dataset(state), values$variable)
      }
    ),
    resumenNumericoVDiscreta = ts_dialog(
      "resumenNumericoVDiscreta", "Numerical summary (discrete)",
      list(ts_var("variables", "Variables", "numeric", multiple = TRUE)),
      function(values, state) {
        ts_descriptive_numeric(RcmdrShiny::active_dataset(state), values$variables)
      }
    ),
    resumenNumericoVContinua = ts_dialog(
      "resumenNumericoVContinua", "Numerical summary",
      list(ts_var("variables", "Variables", "numeric", multiple = TRUE)),
      function(values, state) {
        ts_descriptive_numeric(RcmdrShiny::active_dataset(state), values$variables)
      }
    ),
    resumenNumericoPonderada = ts_dialog(
      "resumenNumericoPonderada", "Weighted numerical summary",
      list(ts_var("variable", "Variable"), ts_var("weights", "Weights")),
      function(values, state) {
        ts_descriptive_numeric(RcmdrShiny::active_dataset(state),
                               values$variable, weights = values$weights)
      }
    ),
    resumenDatosTabulados = ts_dialog(
      "resumenDatosTabulados", "Numerical summary of tabulated data",
      list(ts_entry("values", "Values (comma separated)", ""),
           ts_entry("frequencies", "Frequencies (comma separated)", "")),
      function(values, state) {
        values_text <- trimws(strsplit(values$values %||% "", ",")[[1L]])
        freq_text <- trimws(strsplit(values$frequencies %||% "", ",")[[1L]])
        if (length(values_text) == 0L || length(values_text) != length(freq_text)) {
          stop("Values and frequencies must have the same length.")
        }
        ts_descriptive_table(paste(values_text, collapse = ", "),
                             paste(freq_text, collapse = ", "))
      }
    )
  )
}

ts_index_dialogs <- function() {
  list(
    Sindexnumbers = ts_dialog(
      "Sindexnumbers", "Simple index numbers",
      list(ts_var("variable", "Variable"), ts_spin("base", "Base period", 1)),
      function(values, state) {
        ts_simple_index(RcmdrShiny::active_dataset(state), values$variable,
                        values$base)
      }
    ),
    Cindexnumbers = ts_dialog(
      "Cindexnumbers", "Complex index numbers",
      list(ts_var("variable", "Variable")),
      function(values, state) {
        ts_chain_index(RcmdrShiny::active_dataset(state), values$variable)
      }
    ),
    BCindexnumbers = ts_dialog(
      "BCindexnumbers", "Base change",
      list(ts_var("variable", "Variable"), ts_spin("base", "New base period", 1)),
      function(values, state) {
        ts_base_change(RcmdrShiny::active_dataset(state), values$variable,
                       values$base)
      }
    ),
    Pindexnumbers = ts_dialog(
      "Pindexnumbers", "Price index",
      list(ts_var("price", "Price variable"), ts_var("quantity", "Quantity variable"),
           ts_spin("base", "Base period", 1)),
      function(values, state) {
        ts_price_index(RcmdrShiny::active_dataset(state), values$price,
                       values$quantity, values$base)
      }
    ),
    Deflation = ts_dialog(
      "Deflation", "Deflation",
      list(ts_var("nominal", "Nominal variable"), ts_var("price", "Price variable")),
      function(values, state) {
        ts_deflation(RcmdrShiny::active_dataset(state), values$nominal,
                     values$price)
      }
    )
  )
}

ts_other_dialogs <- function() {
  list(
    oneWayAnovaRE = ts_dialog(
      "oneWayAnovaRE", "One-way ANOVA with random effects",
      list(ts_var("response", "Response"), ts_var("group", "Group", "factor2")),
      function(values, state) {
        ts_random_anova(RcmdrShiny::active_dataset(state), values$response,
                        values$group)
      }
    ),
    randomnessFTest = ts_dialog(
      "randomnessFTest", "Randomness test for two level factor",
      list(ts_var("variable", "Variable", "factor")),
      function(values, state) {
        ts_randomness_factor(RcmdrShiny::active_dataset(state), values$variable)
      }
    ),
    randomnessNTest = ts_dialog(
      "randomnessNTest", "Randomness test for numeric variable",
      list(ts_var("variable", "Variable")),
      function(values, state) {
        ts_randomness_numeric(RcmdrShiny::active_dataset(state), values$variable)
      }
    )
  )
}

ts_data_aliases <- function() {
  aliases <- list(
    newDataSet2 = "newDataSet",
    ConvertVariables = "numericToFactor",
    numericToFactor2 = "numericToFactor",
    binVariable2 = "binVariable",
    reorderFactors = "reorderFactor"
  )
  specs <- list()
  for (new_name in names(aliases)) {
    spec <- RcmdrShiny::get_dialog(aliases[[new_name]])
    if (!is.null(spec)) specs[[new_name]] <- spec
  }
  specs
}

ts_dialogs <- function() {
  dialogs <- list()
  parts <- list(
    ts_distribution_dialogs(),
    ts_inference_dialogs(),
    ts_descriptive_dialogs(),
    ts_index_dialogs(),
    ts_other_dialogs(),
    ts_data_aliases()
  )
  for (part in parts) {
    for (name in names(part)) dialogs[[name]] <- part[[name]]
  }
  dialogs
}
