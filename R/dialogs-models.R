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

  operator_button <- function(op, label) {
    actionButton(ns(paste0("op_", op)), label, class = "btn-sm btn-outline-secondary")
  }

  dialog_spec(
    id = id,
    title = tr("Linear Model"),
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
        var_input(
          ns("lhs"), tr("Response variable:"),
          variables(state), selected = m$lhs, multiple = FALSE
        ),
        entry_input(ns("rhs"), tr("Model formula (right-hand side):"), m$rhs),
        htmltools::div(
          class = "row g-2 align-items-end mb-3",
          htmltools::div(
            class = "col-md-6",
            selectInput(
              ns("insert_var"), tr("Add variable"),
              choices = stats::setNames(variables(state), variables(state)),
              width = "100%"
            )
          ),
          htmltools::div(
            class = "col-md-3",
            actionButton(ns("insert"), tr("Insert"),
                         class = "btn-sm btn-outline-primary")
          ),
          htmltools::div(
            class = "col-md-3",
            button_row(
              operator_button("plus", "+"),
              operator_button("star", "*"),
              operator_button("colon", ":"),
              operator_button("caret", "^"),
              operator_button("lparen", "("),
              operator_button("rparen", ")")
            )
          )
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
      guard <- function() identical(state$current_dialog, id)

      append <- function(text) {
        current <- input[[ns("rhs")]] %||% ""
        updateTextInput(
          session, ns("rhs"),
          value = paste0(current, if (nzchar(current)) " " else "", text)
        )
      }

      observeEvent(input[[ns("insert")]], {
        req(guard())
        variable <- input[[ns("insert_var")]]
        if (!is.null(variable) && nzchar(variable)) {
          current <- trim_blanks(input[[ns("rhs")]] %||% "")
          updateTextInput(
            session, ns("rhs"),
            value = paste0(current, if (nzchar(current)) " + " else "", variable)
          )
        }
      }, ignoreInit = TRUE)

      operators <- c(
        plus = "+", star = "*", colon = ":",
        caret = "^", lparen = "(", rparen = ")"
      )
      for (key in names(operators)) {
        local({
          op <- operators[[key]]
          observeEvent(input[[ns(paste0("op_", key))]], {
            req(guard())
            append(op)
          }, ignoreInit = TRUE)
        })
      }
      invisible(NULL)
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
