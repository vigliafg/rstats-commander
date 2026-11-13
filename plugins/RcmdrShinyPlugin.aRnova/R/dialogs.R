# Shiny dialogs for aRnova ----------------------------------------------

arn_dialog <- function(id, title, fields, build, help = NULL) {
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
        } else {
          RcmdrShiny::checkbox_input(ns(field$name), field$label, value)
        }
      }))
    },
    on_ok = function(input, state) {
      values <- list()
      for (field in fields) values[[field$name]] <- input[[ns(field$name)]]
      command <- tryCatch(build(values, state), error = function(e) e)
      if (inherits(command, "error")) return(list(error = conditionMessage(command)))
      list(commands = command, memory = values)
    }
  )
}

arnova_dialogs <- function() {
  dialogs <- list(
    oneWayAnova_ = arn_dialog(
      "oneWayAnova_", "One-way ANOVA",
      list(
        list(name = "response", label = "Response", type = "variable",
             kind = "numeric", default = ""),
        list(name = "factor", label = "Factor", type = "variable",
             kind = "factor", default = "")
      ),
      function(values, state) {
        if (!nzchar(values$response) || !nzchar(values$factor)) {
          stop("Select a response and a factor.")
        }
        build_aov(RcmdrShiny::active_dataset(state), values$response,
                  values$factor, interaction = FALSE)
      }
    ),
    multiWayAnova_ = arn_dialog(
      "multiWayAnova_", "Multi-way ANOVA",
      list(
        list(name = "response", label = "Response", type = "variable",
             kind = "numeric", default = ""),
        list(name = "factors", label = "Factors", type = "variable",
             kind = "factor", multiple = TRUE),
        list(name = "interaction", label = "Include interactions",
             type = "checkbox", default = TRUE)
      ),
      function(values, state) {
        if (!nzchar(values$response)) stop("Select a response.")
        build_aov(RcmdrShiny::active_dataset(state), values$response,
                  values$factors, values$interaction)
      }
    ),
    repMeasAnovaSetup = arn_dialog(
      "repMeasAnovaSetup", "Repeated-measures ANOVA",
      list(
        list(name = "variables", label = "Repeated measures (wide)",
             type = "variable", kind = "numeric", multiple = TRUE),
        list(name = "within", label = "Within-subject factor name",
             type = "entry", default = "within"),
        list(name = "between", label = "Between-subject factor",
             type = "variable", kind = "factor", default = "")
      ),
      function(values, state) {
        build_repeated_measures(RcmdrShiny::active_dataset(state),
                                values$variables, values$within,
                                values$between %||% "")
      }
    )
  )
  glm <- RcmdrShiny::get_dialog("generalizedLinearModel")
  if (!is.null(glm)) dialogs$generalizedLinearModel_ <- glm
  dialogs
}
