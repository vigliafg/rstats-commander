# Shiny dialogs for FactoMineR ------------------------------------------

facto_dialog <- function(id, title, fields, build) {
  ns <- function(x) paste0(id, "_", x)
  RcmdrShiny::plugin_dialog(
    id = id, title = title, help = NULL, help_package = "FactoMineR",
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
        } else {
          RcmdrShiny::entry_input(ns(field$name), field$label, value)
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

fv <- function(name, label, kind = "numeric", multiple = TRUE,
               default = character()) {
  list(name = name, label = label, type = "variable", kind = kind,
       multiple = multiple, default = default)
}
fe <- function(name, label, default = "") {
  list(name = name, label = label, type = "entry", default = default)
}

facto_dialogs <- function() {
  list(
    FactoPCA = facto_dialog(
      "FactoPCA", "Principal Component Analysis (PCA)",
      list(fv("variables", "Active variables"),
           fv("quanti_sup", "Supplementary quantitative variables", default = character()),
           fv("quali_sup", "Supplementary categorical variables", "factor", default = character())),
      function(values, state) build_facto_pca(
        RcmdrShiny::active_dataset(state), values$variables,
        values$quanti_sup %||% character(), values$quali_sup %||% character()
      )
    ),
    FactoCA = facto_dialog(
      "FactoCA", "Correspondence Analysis (CA)",
      list(fv("row", "Row factor", "factor", FALSE),
           fv("col", "Column factor", "factor", FALSE)),
      function(values, state) build_facto_ca(
        RcmdrShiny::active_dataset(state), values$row, values$col
      )
    ),
    FactoMCA = facto_dialog(
      "FactoMCA", "Multiple Correspondence Analysis (MCA)",
      list(fv("variables", "Variables", "factor")),
      function(values, state) build_facto_mca(
        RcmdrShiny::active_dataset(state), values$variables
      )
    ),
    FactoMFA = facto_dialog(
      "FactoMFA", "Multiple Factor Analysis (MFA)",
      list(fv("variables", "Variables", "all"),
           fe("groups", "Group sizes (comma separated)", "")),
      function(values, state) {
        groups <- trimws(strsplit(values$groups, ",")[[1L]])
        if (length(groups) == 0L || any(!nzchar(groups))) {
          stop("Enter the group sizes.")
        }
        build_facto_mfa(RcmdrShiny::active_dataset(state), values$variables,
                        as.integer(groups), "MFA")
      }
    ),
    FactoDMFA = facto_dialog(
      "FactoDMFA", "Dual Multiple Factor Analysis (DMFA)",
      list(fv("variables", "Variables", "all"),
           fe("groups", "Group sizes (comma separated)", "")),
      function(values, state) {
        groups <- trimws(strsplit(values$groups, ",")[[1L]])
        if (length(groups) == 0L || any(!nzchar(groups))) {
          stop("Enter the group sizes.")
        }
        build_facto_mfa(RcmdrShiny::active_dataset(state), values$variables,
                        as.integer(groups), "DMFA")
      }
    ),
    FactoFAMD = facto_dialog(
      "FactoFAMD", "Factor Analysis of Mixed Data (FAMD)",
      list(fv("variables", "Variables", "all")),
      function(values, state) build_facto_famd(
        RcmdrShiny::active_dataset(state), values$variables
      )
    ),
    FactoHCPC = facto_dialog(
      "FactoHCPC", "Hierarchical Clustering on Principal Components",
      list(fe("object", "FactoMineR result object", ".pca")),
      function(values, state) build_facto_hcpc(values$object)
    ),
    FactoGPA = facto_dialog(
      "FactoGPA", "General Procrustes Analysis (GPA)",
      list(fv("variables", "Variables"),
           fe("groups", "Group sizes (comma separated)", "")),
      function(values, state) {
        groups <- trimws(strsplit(values$groups, ",")[[1L]])
        if (length(groups) == 0L || any(!nzchar(groups))) {
          stop("Enter the group sizes.")
        }
        build_facto_gpa(RcmdrShiny::active_dataset(state), values$variables,
                        as.integer(groups))
      }
    ),
    Factocatdes = facto_dialog(
      "Factocatdes", "Description of categories",
      list(fv("variable", "Categorical variable", "factor", FALSE)),
      function(values, state) build_facto_catdes(
        RcmdrShiny::active_dataset(state), values$variable
      )
    ),
    Factoprefpls = facto_dialog(
      "Factoprefpls", "Scatter plot with additional variables",
      list(fv("variables", "Variables")),
      function(values, state) build_facto_prefpls(
        RcmdrShiny::active_dataset(state), values$variables
      )
    )
  )
}
