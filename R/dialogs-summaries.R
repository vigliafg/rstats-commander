# "Numerical Summaries" dialog --------------------------------------------

numerical_summaries_dialog <- function() {
  id <- "numericalSummaries"
  ns <- function(x) paste0(id, "_", x)

  stat_choices <- c(
    mean = "Mean",
    sd = "Standard Deviation",
    se.mean = "Standard Error of Mean",
    var = "Variance",
    IQR = "Interquartile Range",
    cv = "Coefficient of Variation",
    counts = "Frequency Counts"
  )

  defaults <- list(
    x = NULL,
    groups = "",
    mean = TRUE,
    sd = TRUE,
    se.mean = FALSE,
    var = FALSE,
    IQR = TRUE,
    cv = FALSE,
    counts = FALSE,
    quantiles = TRUE,
    quantiles_values = "0, .25, .5, .75, 1",
    skewness = FALSE,
    kurtosis = FALSE,
    type = "2"
  )

  dialog_spec(
    id = id,
    title = tr("Numerical Summaries"),
    # Rcmdr calls Library("RcmdrMisc") when this dialog opens; its commands
    # (numSummary, binnedCounts, discreteCounts) rely on the package being
    # attached.
    on_open = function(state) {
      attach_packages("RcmdrMisc")
    },
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      selected <- names(stat_choices)[vapply(
        names(stat_choices),
        function(name) isTRUE(m[[name]]),
        logical(1)
      )]
      group_choices <- c(
        stats::setNames("", tr("<none>")),
        stats::setNames(factor_variables(state), factor_variables(state))
      )

      dialog_tabs(
        tabPanel(
          tr("Data"),
          var_input(
            ns("x"), tr("Variables (pick one or more)"),
            numeric_variables(state), selected = m$x, multiple = TRUE
          ),
          groups_input(
            ns("groups"), tr("Summarize by:"),
            choices = group_choices,
            selected = if ((m$groups %||% "") %in% group_choices) m$groups else ""
          )
        ),
        tabPanel(
          tr("Statistics"),
          checkboxes_input(id, stat_choices, selected = selected, ncol = 2L),
          htmltools::tags$hr(),
          checkboxes_input(
            id,
            c(skewness = "Skewness", kurtosis = "Kurtosis"),
            selected = names(Filter(isTRUE, m[c("skewness", "kurtosis")])),
            ncol = 2L
          ),
          radio_input(
            ns("type"), tr("Type"),
            c("Type 1" = "1", "Type 2" = "2", "Type 3" = "3"),
            m$type, inline = TRUE
          ),
          htmltools::tags$hr(),
          checkbox_input(ns("quantiles"), tr("Quantiles:"), m$quantiles),
          entry_input(ns("quantiles_values"), NULL, m$quantiles_values)
        )
      )
    },
    on_ok = function(input, state) {
      x <- input[[ns("x")]]
      if (length(x) == 0L) {
        return(list(error = tr("You must select a variable.")))
      }

      flags <- lapply(
        c("mean", "sd", "se.mean", "var", "IQR", "cv"),
        function(name) isTRUE(input[[ns(name)]])
      )
      names(flags) <- c("mean", "sd", "se.mean", "var", "IQR", "cv")
      quantiles <- isTRUE(input[[ns("quantiles")]])
      counts <- isTRUE(input[[ns("counts")]])
      skewness <- isTRUE(input[[ns("skewness")]])
      kurtosis <- isTRUE(input[[ns("kurtosis")]])

      if (!quantiles) flags$quantiles <- FALSE
      if (!any(unlist(flags)) && !quantiles && !counts) {
        return(list(error = tr("No statistics selected.")))
      }

      groups <- input[[ns("groups")]] %||% ""
      if (!nzchar(groups)) groups <- NULL

      df <- dataset(state)
      group_levels <- NULL
      if (!is.null(groups)) {
        group <- df[[groups]]
        if (is.character(group)) group <- factor(group)
        group_levels <- levels(group)
        df[[groups]] <- group
      }

      commands <- num_summary_commands(
        dataset = active_dataset(state),
        x = x,
        mean = flags$mean %||% FALSE,
        sd = flags$sd %||% FALSE,
        se.mean = flags$se.mean %||% FALSE,
        var = flags$var %||% FALSE,
        IQR = flags$IQR %||% FALSE,
        cv = flags$cv %||% FALSE,
        counts = counts,
        quantiles = quantiles,
        quantiles_values = input[[ns("quantiles_values")]] %||% "",
        skewness = skewness,
        kurtosis = kurtosis,
        type = input[[ns("type")]] %||% "2",
        groups = groups,
        group_levels = group_levels,
        discrete = discrete_numeric_variables(state)
      )

      if (length(commands) == 0L) {
        return(list(error = tr("No statistics selected.")))
      }

      list(
        commands = commands,
        memory = list(
          x = x,
          groups = groups %||% "",
          mean = flags$mean %||% FALSE,
          sd = flags$sd %||% FALSE,
          se.mean = flags$se.mean %||% FALSE,
          var = flags$var %||% FALSE,
          IQR = flags$IQR %||% FALSE,
          cv = flags$cv %||% FALSE,
          counts = counts,
          quantiles = quantiles,
          quantiles_values = input[[ns("quantiles_values")]] %||% "",
          skewness = skewness,
          kurtosis = kurtosis,
          type = input[[ns("type")]] %||% "2"
        )
      )
    }
  )
}
