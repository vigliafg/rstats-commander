# Graph and table tools for EZR --------------------------------------------
#
# The core already ships the common plots.  EZR adds the clinical visualisations
# that have no core equivalent.  Builders are pure so the generated code can be
# tested without drawing anything.

ezr_graph_violin <- function(dataset, variable, group = "") {
  if (!nzchar(variable)) stop("Choose a numeric variable.")
  if (nzchar(group)) {
    sprintf('vioplot::vioplot(%s ~ %s, data = %s, col = "grey80", xlab = %s)',
            variable, group, dataset, ezr_quote(group))
  } else {
    sprintf('vioplot::vioplot(%s$%s, col = "grey80", xlab = %s)',
            dataset, variable, ezr_quote(variable))
  }
}

ezr_graph_ordered <- function(dataset, variable, decreasing = TRUE) {
  if (!nzchar(variable)) stop("Choose a variable.")
  sprintf(paste0(
    'with(%s, barplot(sort(table(%s), decreasing = %s), ',
    'las = 2, ylab = "Count", main = %s))'
  ), dataset, variable, isTRUE(decreasing), ezr_quote(variable))
}

ezr_graph_swim <- function(dataset, id, start, end, status = "") {
  if (!nzchar(end)) stop("Choose the end time.")
  status_code <- if (nzchar(status)) {
    sprintf('col = ifelse(%s$%s == 1, "tomato", "steelblue")', dataset, status)
  } else {
    'col = "steelblue"'
  }
  start_code <- if (nzchar(start)) sprintf("%s$%s", dataset, start) else "0"
  paste0(
    "local({\n",
    sprintf("  .d <- %s[order(%s$%s), ]\n", dataset, dataset, end),
    sprintf("  plot(NA, xlim = c(0, max(.d$%s)), ylim = c(0.5, nrow(.d) + 0.5),\n",
            end),
    '       xlab = "Time", ylab = "Patient", yaxt = "n")\n',
    sprintf("  segments(%s, seq_len(nrow(.d)), .d$%s, seq_len(nrow(.d)),\n",
            start_code, end),
    sprintf("           lwd = 2, %s)\n", status_code),
    "})"
  )
}

ezr_graph_sankey <- function(dataset, from, to) {
  if (!nzchar(from) || !nzchar(to)) stop("Choose two variables.")
  paste0(
    "local({\n",
    sprintf("  .d <- as.data.frame(table(%s$%s, %s$%s))\n",
            dataset, from, dataset, to),
    '  names(.d) <- c("from", "to", "Freq")\n',
    '  .d <- .d[.d$Freq > 0, ]\n',
    "  ggplot2::ggplot(.d,\n",
    "    ggplot2::aes(y = Freq, axis1 = from, axis2 = to)) +\n",
    "    ggalluvial::geom_alluvium(ggplot2::aes(fill = from), width = 1/4) +\n",
    "    ggalluvial::geom_stratum(width = 1/4) +\n",
    '    ggplot2::geom_text(stat = "stratum",\n',
    "      ggplot2::aes(label = ggplot2::after_stat(stratum))) +\n",
    '    ggplot2::labs(x = "", y = "Count", fill = ',
    ezr_quote(from), ")\n",
    "})"
  )
}

ezr_graph_consort <- function(screened, excluded, randomised, analysed) {
  values <- c(screened = as.numeric(screened), excluded = as.numeric(excluded),
              randomised = as.numeric(randomised), analysed = as.numeric(analysed))
  if (anyNA(values)) stop("All counts must be numbers.")
  paste0(
    "local({\n",
    sprintf("  .n <- c(screened = %d, excluded = %d, randomised = %d, analysed = %d)\n",
            as.integer(values[["screened"]]), as.integer(values[["excluded"]]),
            as.integer(values[["randomised"]]), as.integer(values[["analysed"]])),
    "  plot.new(); plot.window(xlim = c(0, 1), ylim = c(0, 1))\n",
    "  .box <- function(x, y, label) {\n",
    "    rect(x - 0.19, y - 0.055, x + 0.19, y + 0.055, col = \"white\")\n",
    "    text(x, y, label, cex = 0.85)\n",
    "  }\n",
    "  .arrow <- function(x0, y0, x1, y1) arrows(x0, y0, x1, y1, length = 0.08)\n",
    "  .box(0.42, 0.90, paste(\"Screened:\", .n[[\"screened\"]]))\n",
    "  .box(0.82, 0.66, paste(\"Excluded:\", .n[[\"excluded\"]]))\n",
    "  .box(0.42, 0.66, paste(\"Randomised:\", .n[[\"randomised\"]]))\n",
    "  .box(0.42, 0.34, paste(\"Analysed:\", .n[[\"analysed\"]]))\n",
    "  .arrow(0.42, 0.845, 0.42, 0.715)\n",
    "  .arrow(0.61, 0.66, 0.63, 0.66)\n",
    "  .arrow(0.42, 0.605, 0.42, 0.395)\n",
    "})"
  )
}

ezr_graph_adjusted_survival <- function(dataset, time, event, group = "") {
  if (!nzchar(time) || !nzchar(event)) stop("Choose time and event variables.")
  formula <- if (nzchar(group)) {
    sprintf("survival::Surv(%s, %s) ~ %s", time, event, group)
  } else {
    sprintf("survival::Surv(%s, %s) ~ 1", time, event)
  }
  paste0(
    "local({\n",
    sprintf("  .fit <- survival::survfit(survival::coxph(%s, data = %s))\n",
            formula, dataset),
    '  plot(.fit, col = seq_along(.fit$strata), lwd = 2,\n',
    '       xlab = "Time", ylab = "Adjusted survival")\n',
    "})"
  )
}

ezr_graph_adjusted_cuminc <- function(dataset, time, status, group = "") {
  if (!nzchar(time) || !nzchar(status)) {
    stop("Choose time and status variables.")
  }
  group_code <- if (nzchar(group)) sprintf("%s$%s", dataset, group) else "1"
  paste0(
    "local({\n",
    sprintf("  .ci <- cmprsk::cuminc(%s$%s, %s$%s, %s)\n",
            dataset, time, dataset, status, group_code),
    "  plot(.ci, lwd = 2, xlab = \"Time\", ylab = \"Cumulative incidence\")\n",
    "})"
  )
}

ezr_graph_stack_cuminc <- function(dataset, time, status) {
  if (!nzchar(time) || !nzchar(status)) {
    stop("Choose time and status variables.")
  }
  paste0(
    "local({\n",
    sprintf("  .ci <- cmprsk::cuminc(%s$%s, %s$%s)\n",
            dataset, time, dataset, status),
    "  .t <- .ci[[1]]$time\n",
    "  .e1 <- .ci[[1]]$est\n",
    "  .e2 <- if (length(.ci) > 1) .ci[[2]]$est[seq_along(.t)] else rep(0, length(.t))\n",
    "  .e2[is.na(.e2)] <- 0\n",
    '  plot(.t, .e1 + .e2, type = "n", ylim = c(0, 1),\n',
    '       xlab = "Time", ylab = "Cumulative incidence")\n',
    '  polygon(c(.t, rev(.t)), c(rep(0, length(.t)), rev(.e1)),\n',
    '          col = "steelblue", border = NA)\n',
    '  polygon(c(.t, rev(.t)), c(.e1, rev(.e1 + .e2)),\n',
    '          col = "tomato", border = NA)\n',
    "})"
  )
}

ezr_graph_options <- function(cex = 1, lwd = 1, las = 0, bty = "o") {
  sprintf('par(cex = %.3g, lwd = %.3g, las = %d, bty = %s)',
          as.numeric(cex), as.numeric(lwd), as.integer(las), ezr_quote(bty))
}

ezr_summary_results <- function(state) {
  model <- RcmdrShiny::active_model(state)
  if (!is.null(model)) {
    return(sprintf("summary(%s)", model))
  }
  dataset <- RcmdrShiny::active_dataset(state)
  if (is.null(dataset)) stop("There is no active data set or model.")
  sprintf("summary(%s)", dataset)
}

ezr_graph_dialogs <- function() {
  list(
    StatMedViolinPlot = ezr_dialog(
      "StatMedViolinPlot", "Violin plot",
      list(ev("variable", "Numeric variable", "numeric", FALSE),
           ev("group", "Group (optional)", "factor", FALSE)),
      function(values, state) {
        ezr_graph_violin(RcmdrShiny::active_dataset(state), values$variable,
                         if (is.null(values$group)) "" else values$group)
      },
      help_topic = "ezr-graphs-tables"
    ),
    StatMedOrderedChart = ezr_dialog(
      "StatMedOrderedChart", "Ordered chart",
      list(ev("variable", "Factor or discrete variable", "all", FALSE),
           echk("decreasing", "Largest first", TRUE)),
      function(values, state) {
        ezr_graph_ordered(RcmdrShiny::active_dataset(state), values$variable,
                          isTRUE(values$decreasing))
      },
      help_topic = "ezr-graphs-tables"
    ),
    StatMedSwimPlot = ezr_dialog(
      "StatMedSwimPlot", "Swimmer plot",
      list(ev("id", "Patient identifier (optional)", "all", FALSE),
           ev("start", "Start time (optional)", "numeric", FALSE),
           ev("end", "End time", "numeric", FALSE),
           ev("status", "Event indicator (optional)", "all", FALSE)),
      function(values, state) {
        ezr_graph_swim(RcmdrShiny::active_dataset(state),
                       if (is.null(values$id)) "" else values$id,
                       if (is.null(values$start)) "" else values$start,
                       values$end,
                       if (is.null(values$status)) "" else values$status)
      },
      help_topic = "ezr-graphs-tables"
    ),
    StatMedSankey = ezr_dialog(
      "StatMedSankey", "Sankey diagram",
      list(ev("from", "From variable", "factor", FALSE),
           ev("to", "To variable", "factor", FALSE)),
      function(values, state) {
        ezr_graph_sankey(RcmdrShiny::active_dataset(state),
                         values$from, values$to)
      },
      help_topic = "ezr-graphs-tables"
    ),
    StatMedConsort = ezr_dialog(
      "StatMedConsort", "CONSORT diagram",
      list(ei("screened", "Screened", 100),
           ei("excluded", "Excluded", 20),
           ei("randomised", "Randomised", 80),
           ei("analysed", "Analysed", 76)),
      function(values, state) {
        ezr_graph_consort(values$screened, values$excluded,
                          values$randomised, values$analysed)
      },
      help_topic = "ezr-graphs-tables"
    ),
    StatMedAdjustedSurvival = ezr_dialog(
      "StatMedAdjustedSurvival", "Adjusted survival curve",
      list(ev("time", "Follow-up time", "numeric", FALSE),
           ev("event", "Event indicator", "all", FALSE),
           ev("group", "Group (optional)", "factor", FALSE)),
      function(values, state) {
        ezr_graph_adjusted_survival(RcmdrShiny::active_dataset(state),
                                    values$time, values$event,
                                    if (is.null(values$group)) "" else values$group)
      },
      help_topic = "ezr-graphs-tables"
    ),
    StatMedAdjustedCumInc = ezr_dialog(
      "StatMedAdjustedCumInc", "Adjusted cumulative incidence curve",
      list(ev("time", "Follow-up time", "numeric", FALSE),
           ev("status", "Competing event status", "all", FALSE),
           ev("group", "Group (optional)", "factor", FALSE)),
      function(values, state) {
        ezr_graph_adjusted_cuminc(RcmdrShiny::active_dataset(state),
                                  values$time, values$status,
                                  if (is.null(values$group)) "" else values$group)
      },
      help_topic = "ezr-graphs-tables"
    ),
    StatMedStackCumInc = ezr_dialog(
      "StatMedStackCumInc", "Stacked cumulative incidences",
      list(ev("time", "Follow-up time", "numeric", FALSE),
           ev("status", "Competing event status", "all", FALSE)),
      function(values, state) {
        ezr_graph_stack_cuminc(RcmdrShiny::active_dataset(state),
                               values$time, values$status)
      },
      help_topic = "ezr-graphs-tables"
    ),
    StatMedGraphOptions = ezr_dialog(
      "StatMedGraphOptions", "Graph settings",
      list(ee("cex", "Character expansion", "1"),
           ee("lwd", "Line width", "1"),
           ec("las", "Axis labels", c("0", "1", "2", "3"), "0"),
           ec("bty", "Box type", c("o", "l", "7", "c", "u", "n"), "o")),
      function(values, state) {
        ezr_graph_options(values$cex, values$lwd, values$las, values$bty)
      },
      help_topic = "ezr-graphs-tables", plot = FALSE
    ),
    StatMedSummaryResults = ezr_dialog(
      "StatMedSummaryResults", "Summary table of results",
      list(),
      function(values, state) ezr_summary_results(state),
      help_topic = "ezr-graphs-tables", plot = FALSE
    )
  )
}
