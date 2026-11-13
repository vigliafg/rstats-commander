# "Linear Model" dialog ---------------------------------------------------

linear_model_dialog <- function() {
  id <- "linearModel"
  ns <- function(x) paste0(id, "_", x)

  defaults <- list(
    model_name = "",
    lhs = "",
    rhs = "",
    subset = "",
    weights = "",
    remove = ""
  )

  dialog_spec(
    id = id,
    title = tr("Linear Model"),
    help = "lm",
    on_open = function(state) {
      update_model_number(state)
    },
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      if (!nzchar(m$model_name)) {
        m$model_name <- paste0("LinearModel.", state$model_number)
      }
      weight_choices <- c(
        stats::setNames("", tr("<no variable selected>")),
        stats::setNames(numeric_variables(state), numeric_variables(state))
      )

      htmltools::tagList(
        entry_input(ns("model"), tr("Enter name for model:"), m$model_name),
        htmltools::tags$hr(),
        model_formula_input(
          id, variables(state), lhs = m$lhs, rhs = m$rhs
        ),
        htmltools::tags$hr(),
        entry_input(ns("subset"), tr("Subset (optional R expression):"), m$subset),
        selectInput(
          ns("weights"), tr("Weights"),
          choices = weight_choices, selected = m$weights, width = "100%"
        ),
        entry_input(
          ns("remove"), tr("Indices or names of row(s) to remove"),
          m$remove
        ),
        help_text(tr("The command lm(<response> ~ <predictors>, data=<dataset>) is generated on OK."))
      )
    },
    observers = function(input, output, session, state, refresh) {
      model_formula_observers(
        input, session, id,
        guard = function() identical(state$current_dialog, id)
      )
    },
    on_ok = function(input, state) {
      model_name <- trim_blanks(input[[ns("model")]])
      lhs <- input[[ns("lhs")]] %||% ""
      rhs <- trim_blanks(input[[ns("rhs")]] %||% "")
      subset <- trim_blanks(input[[ns("subset")]] %||% "")
      weights <- input[[ns("weights")]] %||% ""
      remove <- trim_blanks(input[[ns("remove")]] %||% "")

      if (!is_valid_name(model_name)) {
        return(list(error = sprintf(tr('"%s" is not a valid name.'), model_name)))
      }
      if (!nzchar(lhs)) {
        return(list(error = tr("Left-hand side of model empty.")))
      }
      if (!nzchar(rhs)) {
        return(list(error = tr("Right-hand side of model empty.")))
      }
      if (nzchar(subset) && nzchar(remove)) {
        return(list(error = tr("You cannot specify both case removal and subset cases")))
      }

      remove_rows <- ""
      if (nzchar(remove)) {
        cases <- cases_subset(active_dataset(state), dataset(state), remove)
        if (!is.null(cases$error)) {
          return(list(error = cases$error))
        }
        remove_rows <- cases$value
      }

      list(
        commands = lm_commands(
          dataset = active_dataset(state),
          model_name = model_name,
          lhs = lhs,
          rhs = rhs,
          subset = subset,
          weights = weights,
          remove_rows = remove_rows
        ),
        activate_model = model_name,
        memory = list(
          model_name = "",
          lhs = lhs,
          rhs = rhs,
          subset = subset,
          weights = weights,
          remove = remove
        )
      )
    }
  )
}
