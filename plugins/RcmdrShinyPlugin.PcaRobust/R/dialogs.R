# Shiny dialog for robust PCA -------------------------------------------

pca_robust_dialog_full <- function() {
  id <- "pcaRobust"
  ns <- function(x) paste0(id, "_", x)

  RcmdrShiny::plugin_dialog(
    id = id,
    title = "Robust Principal Component Analysis",
    help = "PcaHubert",
    help_package = "rrcov",
    ui = function(state, memory) {
      numeric <- RcmdrShiny::numeric_variables(state)
      htmltools::tagList(
        RcmdrShiny::var_input(
          ns("variables"), "Variables (select two or more)",
          numeric, memory$variables %||% numeric, multiple = TRUE
        ),
        RcmdrShiny::entry_input(
          ns("alpha"), "Confidence level (0.5 to 1):",
          memory$alpha %||% "0.75"
        ),
        htmltools::tags$fieldset(
          htmltools::tags$legend("Output"),
          RcmdrShiny::checkbox_input(
            ns("loadings"), "Factor loadings", memory$loadings %||% FALSE
          ),
          RcmdrShiny::checkbox_input(
            ns("scores"), "Scores", memory$scores %||% FALSE
          )
        ),
        htmltools::tags$fieldset(
          htmltools::tags$legend("Plots"),
          RcmdrShiny::checkbox_input(
            ns("screeplot"), "Screeplot", memory$screeplot %||% FALSE
          ),
          RcmdrShiny::checkbox_input(
            ns("biplot"), "Biplot", memory$biplot %||% FALSE
          ),
          RcmdrShiny::checkbox_input(
            ns("od_plot"), "Orthogonal distances plot",
            memory$od_plot %||% FALSE
          ),
          RcmdrShiny::checkbox_input(
            ns("sd_plot"), "Score distances plot",
            memory$sd_plot %||% FALSE
          ),
          RcmdrShiny::checkbox_input(
            ns("diagnostic"), "Diagnostic plot",
            memory$diagnostic %||% FALSE
          )
        )
      )
    },
    on_ok = function(input, state) {
      variables <- input[[ns("variables")]] %||% character()
      if (length(variables) < 2L) {
        return(list(error = "Select at least two numeric variables."))
      }
      options <- list(
        variables = variables,
        alpha = input[[ns("alpha")]] %||% "0.75",
        loadings = isTRUE(input[[ns("loadings")]]),
        scores = isTRUE(input[[ns("scores")]]),
        screeplot = isTRUE(input[[ns("screeplot")]]),
        biplot = isTRUE(input[[ns("biplot")]]),
        od_plot = isTRUE(input[[ns("od_plot")]]),
        sd_plot = isTRUE(input[[ns("sd_plot")]]),
        diagnostic = isTRUE(input[[ns("diagnostic")]])
      )
      commands <- tryCatch(
        build_pca_robust_commands(
          RcmdrShiny::active_dataset(state),
          options$variables, options$alpha, options$loadings, options$scores,
          options$screeplot, options$biplot, options$od_plot,
          options$sd_plot, options$diagnostic
        ),
        error = function(e) e
      )
      if (inherits(commands, "error")) {
        return(list(error = conditionMessage(commands)))
      }
      list(commands = commands, memory = options)
    }
  )
}

pca_robust_dialogs <- function() {
  list(pcaRobust = pca_robust_dialog_full())
}
