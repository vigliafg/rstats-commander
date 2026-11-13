# Graphs and Distributions menu dialogs -------------------------------------

graph_vars <- function(state) numeric_variables(state)
graph_factors <- function(state) factor_variables(state)

graph_group_input <- function(id, state, selected = "") {
  combo_input(
    id, tr("Groups (optional)"),
    c(stats::setNames("", tr("<none>")),
      stats::setNames(graph_factors(state), graph_factors(state))),
    selected = selected %||% ""
  )
}

# Graphs --------------------------------------------------------------------

index_plot_dialog <- function() {
  id <- "indexPlot"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(variables = NULL, type = "h")

  dialog_spec(
    id = id, title = tr("Index Plot"), help = "indexplot",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        var_input(ns("variables"), tr("Variables (pick one or more)"),
                  graph_vars(state), selected = m$variables, multiple = TRUE),
        radio_input(ns("type"), tr("Plot type"),
                    c("Points" = "p", "Lines" = "l", "Histogram" = "h"),
                    m$type)
      )
    },
    on_ok = function(input, state) {
      variables <- input[[ns("variables")]]
      if (length(variables) == 0L) return(list(error = tr("You must select a variable.")))
      list(
        commands = cmd_index_plot(active_dataset(state), variables,
                                  input[[ns("type")]] %||% "h"),
        memory = list(variables = variables, type = input[[ns("type")]] %||% "h")
      )
    }
  )
}

histogram_dialog <- function() {
  id <- "Histogram"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(variable = NULL, group = "", scale = "frequency",
                   breaks = "Sturges")

  dialog_spec(
    id = id, title = tr("Histogram"), help = "Hist",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        var_input(ns("variable"), tr("Variable (pick one)"),
                  graph_vars(state), selected = m$variable),
        graph_group_input(ns("group"), state, m$group),
        radio_input(ns("scale"), tr("Scale"),
                    c("Frequency" = "frequency", "Density" = "density",
                      "Percent" = "percent"), m$scale),
        entry_input(ns("breaks"), tr("Breaks:"), m$breaks)
      )
    },
    on_ok = function(input, state) {
      variable <- input[[ns("variable")]] %||% ""
      if (!nzchar(variable)) return(list(error = tr("You must select a variable.")))
      group <- input[[ns("group")]] %||% ""
      list(
        commands = cmd_histogram(active_dataset(state), variable,
                                 if (nzchar(group)) group else NULL,
                                 input[[ns("scale")]] %||% "frequency",
                                 input[[ns("breaks")]] %||% "Sturges"),
        interactive = plotly_code_histogram(active_dataset(state), variable,
                                            if (nzchar(group)) group else NULL),
        interactive_title = tr("Histogram"),
        memory = list(variable = variable, group = group,
                      scale = input[[ns("scale")]] %||% "frequency",
                      breaks = input[[ns("breaks")]] %||% "Sturges")
      )
    }
  )
}

stem_dialog <- function() {
  id <- "stemAndLeaf"
  ns <- function(x) paste0(id, "_", x)

  dialog_spec(
    id = id, title = tr("Stem-and-Leaf Display"), help = "stem.leaf",
    ui = function(state, memory) {
      var_input(ns("variable"), tr("Variable (pick one)"),
                graph_vars(state), selected = memory$variable)
    },
    on_ok = function(input, state) {
      variable <- input[[ns("variable")]] %||% ""
      if (!nzchar(variable)) return(list(error = tr("You must select a variable.")))
      list(commands = cmd_stem_leaf(active_dataset(state), variable),
           memory = list(variable = variable))
    }
  )
}

boxplot_dialog <- function() {
  id <- "boxPlot"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(variables = NULL, response = NULL, group = "")

  dialog_spec(
    id = id, title = tr("Boxplot"), help = "Boxplot",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        var_input(ns("variables"), tr("Variables (pick one or more)"),
                  graph_vars(state), selected = m$variables, multiple = TRUE),
        var_input(ns("response"), tr("Response (when grouping)"),
                  graph_vars(state), selected = m$response),
        graph_group_input(ns("group"), state, m$group),
        help_text(tr("Without a group, one box per selected variable. With a group, the response is plotted by group."))
      )
    },
    on_ok = function(input, state) {
      variables <- input[[ns("variables")]]
      group <- input[[ns("group")]] %||% ""
      response <- input[[ns("response")]] %||% ""
      if (length(variables) == 0L && !nzchar(response)) {
        return(list(error = tr("You must select a variable.")))
      }
      if (nzchar(group) && !nzchar(response)) {
        if (length(variables) == 0L) {
          return(list(error = tr("You must select a response variable.")))
        }
        response <- variables[[1L]]
      }
      list(
        commands = cmd_boxplot(active_dataset(state), variables,
                               if (nzchar(response)) response else NULL,
                               if (nzchar(group)) group else NULL),
        interactive = plotly_code_boxplot(
          active_dataset(state), variables,
          if (nzchar(response)) response else NULL,
          if (nzchar(group)) group else NULL
        ),
        interactive_title = tr("Boxplot"),
        memory = list(variables = variables, response = response, group = group)
      )
    }
  )
}

dotplot_dialog <- function() {
  id <- "DotPlot"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(variable = NULL, group = "")

  dialog_spec(
    id = id, title = tr("Dot Plot"), help = "Dotplot",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        var_input(ns("variable"), tr("Variable (pick one)"),
                  graph_vars(state), selected = m$variable),
        graph_group_input(ns("group"), state, m$group)
      )
    },
    on_ok = function(input, state) {
      variable <- input[[ns("variable")]] %||% ""
      if (!nzchar(variable)) return(list(error = tr("You must select a variable.")))
      group <- input[[ns("group")]] %||% ""
      list(
        commands = cmd_dotplot(active_dataset(state), variable,
                               if (nzchar(group)) group else NULL),
        memory = list(variable = variable, group = group)
      )
    }
  )
}

scatterplot_dialog <- function() {
  id <- "scatterPlot"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(x = NULL, y = NULL, group = "", smooth = FALSE,
                   boxplots = FALSE, log = "")

  dialog_spec(
    id = id, title = tr("Scatterplot"), help = "scatterplot",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        var_input(ns("x"), tr("Horizontal axis (pick one)"),
                  graph_vars(state), selected = m$x),
        var_input(ns("y"), tr("Vertical axis (pick one)"),
                  graph_vars(state), selected = m$y),
        graph_group_input(ns("group"), state, m$group),
        checkbox_input(ns("smooth"), tr("Least-squares line"), m$smooth),
        checkbox_input(ns("boxplots"), tr("Marginal boxplots"), m$boxplots),
        radio_input(ns("log"), tr("Log axes"),
                    c("None" = "", "x" = "x", "y" = "y", "xy" = "xy"), m$log)
      )
    },
    on_ok = function(input, state) {
      x <- input[[ns("x")]] %||% ""
      y <- input[[ns("y")]] %||% ""
      if (!nzchar(x) || !nzchar(y)) return(list(error = tr("You must select two variables.")))
      if (identical(x, y)) return(list(error = tr("Variables must be different.")))
      group <- input[[ns("group")]] %||% ""
      list(
        commands = cmd_scatterplot(
          active_dataset(state), x, y,
          if (nzchar(group)) group else NULL,
          isTRUE(input[[ns("smooth")]]), isTRUE(input[[ns("boxplots")]]),
          input[[ns("log")]] %||% ""
        ),
        interactive = plotly_code_scatter(
          active_dataset(state), x, y,
          if (nzchar(group)) group else NULL,
          isTRUE(input[[ns("smooth")]]),
          input[[ns("log")]] %||% ""
        ),
        interactive_title = tr("Scatterplot"),
        memory = list(x = x, y = y, group = group,
                      smooth = isTRUE(input[[ns("smooth")]]),
                      boxplots = isTRUE(input[[ns("boxplots")]]),
                      log = input[[ns("log")]] %||% "")
      )
    }
  )
}

scatterplot_matrix_dialog <- function() {
  id <- "scatterPlotMatrix"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(variables = NULL, smooth = TRUE, density = TRUE)

  dialog_spec(
    id = id, title = tr("Scatterplot Matrix"), help = "scatterplotMatrix",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        var_input(ns("variables"), tr("Variables (pick two or more)"),
                  graph_vars(state), selected = m$variables, multiple = TRUE),
        checkbox_input(ns("smooth"), tr("Smooth lines"), m$smooth),
        checkbox_input(ns("density"), tr("Density plots on diagonal"), m$density)
      )
    },
    on_ok = function(input, state) {
      variables <- input[[ns("variables")]]
      if (length(variables) < 2L) {
        return(list(error = tr("Fewer than 2 variables selected.")))
      }
      list(
        commands = cmd_scatterplot_matrix(
          active_dataset(state), variables,
          isTRUE(input[[ns("smooth")]]), isTRUE(input[[ns("density")]])
        ),
        memory = list(variables = variables,
                      smooth = isTRUE(input[[ns("smooth")]]),
                      density = isTRUE(input[[ns("density")]]))
      )
    }
  )
}

bar_graph_dialog <- function() {
  id <- "barGraph"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(variable = NULL, group = "")

  dialog_spec(
    id = id, title = tr("Bar Graph"), help = "Barplot",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        var_input(ns("variable"), tr("Variable (pick one)"),
                  graph_factors(state), selected = m$variable),
        graph_group_input(ns("group"), state, m$group)
      )
    },
    on_ok = function(input, state) {
      variable <- input[[ns("variable")]] %||% ""
      if (!nzchar(variable)) return(list(error = tr("You must select a variable.")))
      group <- input[[ns("group")]] %||% ""
      list(
        commands = cmd_barplot(active_dataset(state), variable,
                               if (nzchar(group)) group else NULL),
        memory = list(variable = variable, group = group)
      )
    }
  )
}

pie_chart_dialog <- function() {
  id <- "pieChart"
  ns <- function(x) paste0(id, "_", x)

  dialog_spec(
    id = id, title = tr("Pie Chart"), help = "piechart",
    ui = function(state, memory) {
      var_input(ns("variable"), tr("Variable (pick one)"),
                graph_factors(state), selected = memory$variable)
    },
    on_ok = function(input, state) {
      variable <- input[[ns("variable")]] %||% ""
      if (!nzchar(variable)) return(list(error = tr("You must select a variable.")))
      list(commands = cmd_piechart(active_dataset(state), variable),
           memory = list(variable = variable))
    }
  )
}

line_plot_dialog <- function() {
  id <- "linePlot"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(x = NULL, y = NULL)

  dialog_spec(
    id = id, title = tr("Line Graph"), help = "lineplot",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        var_input(ns("x"), tr("X variable (pick one)"),
                  variables(state), selected = m$x),
        var_input(ns("y"), tr("Y variable(s) (pick one or more)"),
                  graph_vars(state), selected = m$y, multiple = TRUE)
      )
    },
    on_ok = function(input, state) {
      x <- input[[ns("x")]] %||% ""
      y <- input[[ns("y")]]
      if (!nzchar(x) || length(y) == 0L) {
        return(list(error = tr("You must select x and y variables.")))
      }
      list(commands = cmd_lineplot(active_dataset(state), x, y),
           interactive = plotly_code_line(active_dataset(state), x, y),
           interactive_title = tr("Line Graph"),
           memory = list(x = x, y = y))
    }
  )
}

qq_plot_dialog <- function() {
  id <- "QQPlot"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(variable = NULL, group = "")

  dialog_spec(
    id = id, title = tr("Quantile-Comparison Plot"), help = "qqPlot",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        var_input(ns("variable"), tr("Variable (pick one)"),
                  graph_vars(state), selected = m$variable),
        graph_group_input(ns("group"), state, m$group)
      )
    },
    on_ok = function(input, state) {
      variable <- input[[ns("variable")]] %||% ""
      if (!nzchar(variable)) return(list(error = tr("You must select a variable.")))
      group <- input[[ns("group")]] %||% ""
      list(
        commands = cmd_qqplot(active_dataset(state), variable,
                              if (nzchar(group)) group else NULL),
        memory = list(variable = variable, group = group)
      )
    }
  )
}

plot_means_dialog <- function() {
  id <- "PlotMeans"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(response = NULL, group = NULL, error_bars = "se",
                   legend = TRUE)

  dialog_spec(
    id = id, title = tr("Plot of Means"), help = "plotMeans",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        var_input(ns("response"), tr("Response Variable (pick one)"),
                  graph_vars(state), selected = m$response),
        var_input(ns("group"), tr("Factor (pick one)"),
                  graph_factors(state), selected = m$group),
        radio_input(ns("error_bars"), tr("Error bars"),
                    c("Standard error" = "se", "Standard deviation" = "sd",
                      "Confidence interval" = "ci"), m$error_bars),
        checkbox_input(ns("legend"), tr("Show legend"), m$legend)
      )
    },
    on_ok = function(input, state) {
      response <- input[[ns("response")]] %||% ""
      group <- input[[ns("group")]] %||% ""
      if (!nzchar(response) || !nzchar(group)) {
        return(list(error = tr("You must select a response and a factor.")))
      }
      list(
        commands = cmd_plot_means(active_dataset(state), response, group,
                                  input[[ns("error_bars")]] %||% "se",
                                  isTRUE(input[[ns("legend")]])),
        memory = list(response = response, group = group,
                      error_bars = input[[ns("error_bars")]] %||% "se",
                      legend = isTRUE(input[[ns("legend")]]))
      )
    }
  )
}

scatter3d_dialog <- function() {
  id <- "Scatter3D"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(y = NULL, x1 = NULL, x2 = NULL, group = "")

  dialog_spec(
    id = id, title = tr("3D Scatterplot"), help = "scatter3d",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        var_input(ns("y"), tr("Response (vertical axis)"),
                  graph_vars(state), selected = m$y),
        var_input(ns("x1"), tr("Horizontal axis"), graph_vars(state),
                  selected = m$x1),
        var_input(ns("x2"), tr("Out-of-screen axis"), graph_vars(state),
                  selected = m$x2),
        graph_group_input(ns("group"), state, m$group)
      )
    },
    on_ok = function(input, state) {
      y <- input[[ns("y")]] %||% ""
      x1 <- input[[ns("x1")]] %||% ""
      x2 <- input[[ns("x2")]] %||% ""
      if (!all(nzchar(c(y, x1, x2)))) {
        return(list(error = tr("You must select three variables.")))
      }
      if (length(unique(c(y, x1, x2))) < 3L) {
        return(list(error = tr("Variables must be different.")))
      }
      group <- input[[ns("group")]] %||% ""
      list(
        commands = cmd_scatter3d(active_dataset(state), y, x1, x2,
                                 if (nzchar(group)) group else NULL),
        memory = list(y = y, x1 = x1, x2 = x2, group = group)
      )
    }
  )
}

xyplot_dialog <- function() {
  id <- "Xyplot"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(x = NULL, y = NULL, group = "", type = "p", layout = "")

  dialog_spec(
    id = id, title = tr("XY Conditioning Plot"), help = "xyplot",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        var_input(ns("x"), tr("X variable (pick one)"),
                  variables(state), selected = m$x),
        var_input(ns("y"), tr("Y variable (pick one)"),
                  graph_vars(state), selected = m$y),
        graph_group_input(ns("group"), state, m$group),
        radio_input(ns("type"), tr("Plot type"),
                    c("Points" = "p", "Lines" = "l", "Both" = "b"), m$type),
        entry_input(ns("layout"), tr("Layout (e.g. 2,2):"), m$layout)
      )
    },
    on_ok = function(input, state) {
      x <- input[[ns("x")]] %||% ""
      y <- input[[ns("y")]] %||% ""
      if (!nzchar(x) || !nzchar(y)) return(list(error = tr("You must select two variables.")))
      group <- input[[ns("group")]] %||% ""
      list(
        commands = cmd_xyplot(active_dataset(state), x, y,
                              if (nzchar(group)) group else NULL,
                              input[[ns("type")]] %||% "p",
                              input[[ns("layout")]] %||% ""),
        memory = list(x = x, y = y, group = group,
                      type = input[[ns("type")]] %||% "p",
                      layout = input[[ns("layout")]] %||% "")
      )
    }
  )
}

stripchart_dialog <- function() {
  id <- "stripChart"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(response = NULL, group = "", method = "stack")

  dialog_spec(
    id = id, title = tr("Strip Chart"), help = "stripchart",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        var_input(ns("response"), tr("Response Variable (pick one)"),
                  graph_vars(state), selected = m$response),
        graph_group_input(ns("group"), state, m$group),
        radio_input(ns("method"), tr("Method"),
                    c("Stack" = "stack", "Jitter" = "jitter"), m$method)
      )
    },
    on_ok = function(input, state) {
      response <- input[[ns("response")]] %||% ""
      if (!nzchar(response)) return(list(error = tr("You must select a variable.")))
      group <- input[[ns("group")]] %||% ""
      list(
        commands = cmd_stripchart(active_dataset(state), response,
                                  if (nzchar(group)) group else NULL,
                                  input[[ns("method")]] %||% "stack"),
        memory = list(response = response, group = group,
                      method = input[[ns("method")]] %||% "stack")
      )
    }
  )
}

density_plot_dialog <- function() {
  id <- "DensityPlot"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(variable = NULL, group = "", bw = "")

  dialog_spec(
    id = id, title = tr("Density Estimate"), help = "densityPlot",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        var_input(ns("variable"), tr("Variable (pick one)"),
                  graph_vars(state), selected = m$variable),
        graph_group_input(ns("group"), state, m$group),
        entry_input(ns("bw"), tr("Bandwidth (optional):"), m$bw)
      )
    },
    on_ok = function(input, state) {
      variable <- input[[ns("variable")]] %||% ""
      if (!nzchar(variable)) return(list(error = tr("You must select a variable.")))
      group <- input[[ns("group")]] %||% ""
      list(
        commands = cmd_density_plot(active_dataset(state), variable,
                                    if (nzchar(group)) group else NULL,
                                    trim_blanks(input[[ns("bw")]] %||% "")),
        memory = list(variable = variable, group = group,
                      bw = input[[ns("bw")]] %||% "")
      )
    }
  )
}

discrete_plot_dialog <- function() {
  id <- "DiscretePlot"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(variable = NULL, group = "")

  dialog_spec(
    id = id, title = tr("Plot Discrete Numeric Variable"), help = "discretePlot",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        var_input(ns("variable"), tr("Variable (pick one)"),
                  discrete_numeric_variables(state), selected = m$variable),
        graph_group_input(ns("group"), state, m$group)
      )
    },
    on_ok = function(input, state) {
      variable <- input[[ns("variable")]] %||% ""
      if (!nzchar(variable)) return(list(error = tr("You must select a variable.")))
      group <- input[[ns("group")]] %||% ""
      list(
        commands = cmd_discrete_plot(active_dataset(state), variable,
                                     if (nzchar(group)) group else NULL),
        memory = list(variable = variable, group = group)
      )
    }
  )
}

symbox_dialog <- function() {
  id <- "Symbox"
  ns <- function(x) paste0(id, "_", x)

  dialog_spec(
    id = id, title = tr("Symmetry Boxplot"), help = "symbox",
    ui = function(state, memory) {
      var_input(ns("variable"), tr("Variable (pick one)"),
                graph_vars(state), selected = memory$variable)
    },
    on_ok = function(input, state) {
      variable <- input[[ns("variable")]] %||% ""
      if (!nzchar(variable)) return(list(error = tr("You must select a variable.")))
      list(commands = cmd_symbox(active_dataset(state), variable),
           memory = list(variable = variable))
    }
  )
}

palette_dialog <- function() {
  id <- "setPalette"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(colors = "black, red, green, blue")

  dialog_spec(
    id = id, title = tr("Color Palette"), help = "palette",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      entry_input(ns("colors"), tr("Colors (comma separated):"), m$colors)
    },
    on_ok = function(input, state) {
      text <- trim_blanks(input[[ns("colors")]] %||% "")
      if (!nzchar(text)) return(list(error = tr("You must specify colors.")))
      colors <- trimws(strsplit(text, ",", fixed = TRUE)[[1L]])
      list(commands = cmd_set_palette(colors),
           memory = list(colors = text))
    }
  )
}

# Distributions -------------------------------------------------------------

distribution_param_entries <- function(id, info, values, ns) {
  lapply(seq_along(info$params), function(i) {
    parameter <- info$params[[i]]
    entry_input(ns(parameter[[1L]]), tr(parameter[[2L]]),
                values[[i]] %||% parameter[[3L]])
  })
}

distribution_tail_input <- function(id, value = "lower") {
  radio_input(id, tr("Tail"),
              c("Lower tail" = "TRUE", "Upper tail" = "FALSE"),
              if (isTRUE(value)) "TRUE" else "FALSE", inline = TRUE)
}

distribution_dialog <- function(distribution, kind) {
  info <- distribution_info(distribution)
  if (is.null(info)) return(NULL)
  suffix <- switch(kind,
                   quantiles = "Quantiles",
                   probabilities = "Probabilities",
                   mass = "Mass",
                   plot = "DistributionPlot",
                   samples = "DistributionSamples")
  id <- paste0(distribution, suffix)
  ns <- function(x) paste0(id, "_", x)
  param_names <- vapply(info$params, `[[`, character(1), 1L)
  param_defaults <- lapply(info$params, `[[`, 3L)
  names(param_defaults) <- param_names

  defaults <- c(
    list(values = "", tail = TRUE, dataset = paste0(info$title, "Samples"),
         n = 100L, samples = 1L, type = "density", from = "", to = "",
         summary_mean = FALSE, summary_sd = FALSE),
    param_defaults
  )

  title <- paste(info$title, switch(
    kind, quantiles = "Quantiles", probabilities = "Probabilities",
    mass = "Probabilities", plot = "Distribution", samples = "Samples"
  ))

  dialog_spec(
    id = id, title = title,
    help = switch(kind, quantiles = paste0("q", info$fun),
                  probabilities = paste0("p", info$fun),
                  mass = paste0("d", info$fun),
                  plot = paste0("d", info$fun),
                  samples = paste0("r", info$fun)),
    help_package = info$requires,
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      values <- lapply(param_names, function(name) m[[name]])
      names(values) <- param_names
      entries <- distribution_param_entries(id, info, values, ns)

      if (identical(kind, "quantiles")) {
        return(htmltools::tagList(
          entry_input(ns("values"), tr("Probabilities (comma separated):"),
                      m$values),
          entries,
          distribution_tail_input(ns("tail"), m$tail)
        ))
      }
      if (identical(kind, "probabilities")) {
        return(htmltools::tagList(
          entry_input(ns("values"), tr("Variable value(s) (comma separated):"),
                      m$values),
          entries,
          distribution_tail_input(ns("tail"), m$tail)
        ))
      }
      if (identical(kind, "mass")) {
        return(htmltools::tagList(
          entry_input(ns("values"), tr("Values (comma separated):"), m$values),
          entries
        ))
      }
      if (identical(kind, "plot")) {
        return(htmltools::tagList(
          entries,
          radio_input(ns("type"), tr("Function"),
                      c("Density" = "density",
                        "Cumulative Probability" = "cdf"), m$type),
          entry_input(ns("from"), tr("From (optional):"), m$from),
          entry_input(ns("to"), tr("To (optional):"), m$to)
        ))
      }
      htmltools::tagList(
        entry_input(ns("dataset"), tr("Name for data set:"), m$dataset),
        spin_input(ns("n"), tr("Sample size:"), m$n, min = 1, max = 100000),
        spin_input(ns("samples"), tr("Number of samples:"), m$samples,
                   min = 1, max = 10000),
        entries,
        checkbox_input(ns("summary_mean"), tr("Add sample means"),
                       isTRUE(m$summary_mean)),
        checkbox_input(ns("summary_sd"), tr("Add sample standard deviations"),
                       isTRUE(m$summary_sd))
      )
    },
    on_ok = function(input, state) {
      params <- lapply(param_names, function(name) {
        value <- input[[ns(name)]]
        if (is.null(value) || is.na(value)) return("")
        format(value, scientific = FALSE, trim = TRUE)
      })
      names(params) <- param_names
      if (any(!nzchar(unlist(params)))) {
        return(list(error = tr("You must specify all distribution parameters.")))
      }
      if (identical(kind, "samples")) {
        dataset <- trim_blanks(input[[ns("dataset")]] %||% "")
        if (!is_valid_name(dataset)) {
          return(list(error = sprintf(tr('"%s" is not a valid name.'), dataset)))
        }
        n <- as.integer(input[[ns("n")]] %||% 100)
        samples <- as.integer(input[[ns("samples")]] %||% 1)
        if (is.na(n) || n <= 0) return(list(error = tr("Sample size must be positive.")))
        if (is.na(samples) || samples <= 0) {
          return(list(error = tr("Number of samples must be positive.")))
        }
        summaries <- c(if (isTRUE(input[[ns("summary_mean")]])) "mean",
                       if (isTRUE(input[[ns("summary_sd")]])) "sd")
        return(list(
          commands = cmd_distribution_samples(distribution, params, dataset,
                                             n, samples, summaries),
          activate_dataset = dataset,
          memory = list(dataset = dataset, n = n, samples = samples,
                        values = input[[ns("values")]] %||% "",
                        tail = isTRUE(input[[ns("tail")]]),
                        summary_mean = isTRUE(input[[ns("summary_mean")]]),
                        summary_sd = isTRUE(input[[ns("summary_sd")]]))
        ))
      }

      values_text <- trim_blanks(input[[ns("values")]] %||% "")
      if (identical(kind, "plot")) {
        return(list(
          commands = cmd_distribution_plot(
            distribution, params,
            type = input[[ns("type")]] %||% "density",
            from = trim_blanks(input[[ns("from")]] %||% ""),
            to = trim_blanks(input[[ns("to")]] %||% "")
          ),
          memory = list(type = input[[ns("type")]] %||% "density",
                        from = input[[ns("from")]] %||% "",
                        to = input[[ns("to")]] %||% "")
        ))
      }
      if (!nzchar(values_text)) {
        return(list(error = tr("No values specified.")))
      }
      values <- suppressWarnings(as.numeric(trimws(strsplit(
        values_text, ",", fixed = TRUE
      )[[1L]])))
      if (anyNA(values)) return(list(error = tr("Invalid numeric values.")))
      lower_tail <- isTRUE(as.logical(input[[ns("tail")]] %||% TRUE))
      commands <- switch(
        kind,
        quantiles = cmd_distribution_quantiles(distribution, values, params,
                                                lower_tail),
        probabilities = cmd_distribution_probabilities(distribution, values,
                                                        params, lower_tail),
        mass = cmd_distribution_mass(distribution, values, params)
      )
      list(
        commands = commands,
        memory = c(list(values = values_text, tail = lower_tail),
                   as.list(params))
      )
    }
  )
}

phase4_dialogs <- function() {
  graphs <- list(
    indexPlot = index_plot_dialog(),
    Histogram = histogram_dialog(),
    stemAndLeaf = stem_dialog(),
    boxPlot = boxplot_dialog(),
    DotPlot = dotplot_dialog(),
    scatterPlot = scatterplot_dialog(),
    scatterPlotMatrix = scatterplot_matrix_dialog(),
    barGraph = bar_graph_dialog(),
    pieChart = pie_chart_dialog(),
    linePlot = line_plot_dialog(),
    QQPlot = qq_plot_dialog(),
    PlotMeans = plot_means_dialog(),
    Scatter3D = scatter3d_dialog(),
    Xyplot = xyplot_dialog(),
    stripChart = stripchart_dialog(),
    DensityPlot = density_plot_dialog(),
    DiscretePlot = discrete_plot_dialog(),
    Symbox = symbox_dialog(),
    setPalette = palette_dialog()
  )

  distributions <- list()
  for (name in distribution_menu_names()) {
    for (kind in c("quantiles", "probabilities", "plot", "samples")) {
      spec <- distribution_dialog(name, kind)
      if (!is.null(spec)) distributions[[spec$id]] <- spec
    }
    if (isTRUE(distribution_info(name)$discrete)) {
      for (kind in "mass") {
        spec <- distribution_dialog(name, kind)
        if (!is.null(spec)) distributions[[spec$id]] <- spec
      }
    }
  }

  c(graphs, distributions,
    list(setRandomSeed = dialog_spec(
      id = "setRandomSeed", title = tr("Set Random Seed"), help = "set.seed",
      ui = function(state, memory) {
        spin_input("setRandomSeed_seed", tr("Seed:"),
                   memory$seed %||% 12345, min = 1, max = .Machine$integer.max)
      },
      on_ok = function(input, state) {
        seed <- as.integer(input[["setRandomSeed_seed"]] %||% 12345)
        if (is.na(seed)) return(list(error = tr("The seed must be an integer.")))
        list(commands = cmd_set_seed(seed), memory = list(seed = seed))
      }
    )))
}
