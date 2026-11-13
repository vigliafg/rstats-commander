# Shiny dialogs for KMggplot2 -------------------------------------------

kmg_dialog <- function(id, title, fields, build, help = NULL) {
  force(fields)
  force(build)
  force(title)
  ns <- function(x) paste0(id, "_", x)
  RcmdrShiny::plugin_dialog(
    id = id, title = title, help = help, help_package = "ggplot2",
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
          RcmdrShiny::var_input(
            ns(field$name), field$label, choices, value,
            multiple = isTRUE(field$multiple)
          )
        } else if (identical(field$type, "entry")) {
          RcmdrShiny::entry_input(ns(field$name), field$label, value)
        } else if (identical(field$type, "spin")) {
          RcmdrShiny::spin_input(ns(field$name), field$label, value)
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
      if (inherits(command, "error")) {
        return(list(error = conditionMessage(command)))
      }
      list(commands = command, memory = values, plot = TRUE)
    }
  )
}

kmg_common_fields <- function() {
  list(
    list(name = "xlab", label = "Horizontal axis label", type = "entry",
         default = ""),
    list(name = "ylab", label = "Vertical axis label", type = "entry",
         default = ""),
    list(name = "title", label = "Title", type = "entry", default = ""),
    list(name = "facet_row", label = "Facet variable in rows", type = "variable",
         kind = "factor", default = ""),
    list(name = "facet_col", label = "Facet variable in cols", type = "variable",
         kind = "factor", default = "")
  )
}

kmg_dialogs <- function() {
  dialogs <- list(
    windowKM = kmg_dialog(
      "windowKM", "Kaplan-Meier plot",
      list(
        list(name = "time", label = "Time variable", type = "variable",
             kind = "numeric", default = ""),
        list(name = "status", label = "Status variable", type = "variable",
             kind = "all", default = ""),
        list(name = "group", label = "Grouping variable", type = "variable",
             kind = "factor", default = "")
      ),
      function(values, state) {
        if (!nzchar(values$time %||% "")) stop("Select a time variable.")
        if (!nzchar(values$status %||% "")) stop("Select a status variable.")
        build_kmg_km(RcmdrShiny::active_dataset(state), values)
      }
    ),
    windowHist = kmg_dialog(
      "windowHist", "Histogram",
      c(
        list(
          list(name = "variable", label = "Variable", type = "variable",
               kind = "numeric", default = ""),
          list(name = "bins", label = "Number of bins", type = "spin",
               default = 30),
          list(name = "fill", label = "Fill colour", type = "entry",
               default = "#4C78A8")
        ),
        kmg_common_fields()
      ),
      function(values, state) build_kmg_histogram(RcmdrShiny::active_dataset(state), values)
    ),
    windowQQ = kmg_dialog(
      "windowQQ", "Q-Q plot",
      c(list(list(name = "variable", label = "Variable", type = "variable",
                  kind = "numeric", default = "")), kmg_common_fields()),
      function(values, state) build_kmg_qq(RcmdrShiny::active_dataset(state), values)
    ),
    windowBox = kmg_dialog(
      "windowBox", "Box plot / Violin plot / Confidence interval",
      c(
        list(
          list(name = "variable", label = "Y variable", type = "variable",
               kind = "numeric", default = ""),
          list(name = "group", label = "X variable", type = "variable",
               kind = "factor", default = ""),
          list(name = "type", label = "Plot type", type = "combo",
               choices = c("Box plot" = "boxplot", "Violin plot" = "violin",
                           "95% CI" = "ci"), default = "boxplot")
        ),
        kmg_common_fields()
      ),
      function(values, state) build_kmg_box(RcmdrShiny::active_dataset(state), values)
    ),
    windowScatter = kmg_dialog(
      "windowScatter", "Scatter plot",
      c(
        list(
          list(name = "x", label = "X variable", type = "variable",
               kind = "numeric", default = ""),
          list(name = "y", label = "Y variable", type = "variable",
               kind = "numeric", default = ""),
          list(name = "colour", label = "Colour variable", type = "variable",
               kind = "factor", default = "")
        ),
        kmg_common_fields()
      ),
      function(values, state) build_kmg_scatter(RcmdrShiny::active_dataset(state), values)
    ),
    windowScattermat = kmg_dialog(
      "windowScattermat", "Scatter matrix",
      list(list(name = "variables", label = "Variables", type = "variable",
                kind = "numeric", multiple = TRUE, default = character())),
      function(values, state) build_kmg_scattermatrix(RcmdrShiny::active_dataset(state), values)
    ),
    windowLine = kmg_dialog(
      "windowLine", "Line chart",
      c(
        list(
          list(name = "x", label = "X variable", type = "variable",
               kind = "numeric", default = ""),
          list(name = "y", label = "Y variable", type = "variable",
               kind = "numeric", default = ""),
          list(name = "colour", label = "Colour variable", type = "variable",
               kind = "factor", default = "")
        ),
        kmg_common_fields()
      ),
      function(values, state) build_kmg_line(RcmdrShiny::active_dataset(state), values)
    ),
    windowPie = kmg_dialog(
      "windowPie", "Pie chart",
      c(list(list(name = "variable", label = "Variable", type = "variable",
                  kind = "factor", default = "")), kmg_common_fields()),
      function(values, state) build_kmg_pie(RcmdrShiny::active_dataset(state), values)
    ),
    windowDiscretebar = kmg_dialog(
      "windowDiscretebar", "Bar chart for discrete variables",
      c(list(list(name = "variable", label = "Variable", type = "variable",
                  kind = "factor", default = "")), kmg_common_fields()),
      function(values, state) build_kmg_bar(RcmdrShiny::active_dataset(state), values)
    ),
    windowContour = kmg_dialog(
      "windowContour", "Contour plot",
      c(
        list(
          list(name = "x", label = "X variable", type = "variable",
               kind = "numeric", default = ""),
          list(name = "y", label = "Y variable", type = "variable",
               kind = "numeric", default = ""),
          list(name = "z", label = "Z variable", type = "variable",
               kind = "numeric", default = "")
        ),
        kmg_common_fields()
      ),
      function(values, state) build_kmg_contour(RcmdrShiny::active_dataset(state), values)
    ),
    windowFactorize = kmg_dialog(
      "windowFactorize", "Factorizing numeric variables",
      list(
        list(name = "variable", label = "Variable", type = "variable",
             kind = "numeric", default = ""),
        list(name = "new_name", label = "New variable name", type = "entry",
             default = ""),
        list(name = "breaks", label = "Number of intervals", type = "spin",
             default = 4)
      ),
      function(values, state) build_kmg_factorize(RcmdrShiny::active_dataset(state), values)
    )
  )
  distributions <- kmg_distribution_dialogs()
  for (name in names(distributions)) dialogs[[name]] <- distributions[[name]]
  dialogs
}

kmg_distribution_dialogs <- function() {
  specs <- list(
    Norm = list(family = "norm", title = "Normal distribution",
                fields = list(mean = 0, sd = 1)),
    T = list(family = "t", title = "t distribution", fields = list(df = 5)),
    Chisq = list(family = "chisq", title = "Chi-square distribution",
                 fields = list(df = 5)),
    F = list(family = "f", title = "F distribution",
             fields = list(df1 = 5, df2 = 10)),
    Exp = list(family = "exp", title = "Exponential distribution",
               fields = list(rate = 1)),
    Unif = list(family = "unif", title = "Uniform distribution",
                fields = list(min = 0, max = 1)),
    Beta = list(family = "beta", title = "Beta distribution",
                fields = list(shape1 = 2, shape2 = 2)),
    Cauchy = list(family = "cauchy", title = "Cauchy distribution",
                  fields = list(location = 0, scale = 1)),
    Logis = list(family = "logis", title = "Logistic distribution",
                 fields = list(location = 0, scale = 1)),
    Lnorm = list(family = "lnorm", title = "Log-normal distribution",
                 fields = list(meanlog = 0, sdlog = 1)),
    Gamma = list(family = "gamma", title = "Gamma distribution",
                 fields = list(shape = 2, rate = 1)),
    Weibull = list(family = "weibull", title = "Weibull distribution",
                   fields = list(shape = 2, scale = 1)),
    Binom = list(family = "binom", title = "Binomial distribution",
                 fields = list(size = 10, prob = 0.5)),
    Pois = list(family = "pois", title = "Poisson distribution",
                fields = list(lambda = 3)),
    Geom = list(family = "geom", title = "Geometric distribution",
                fields = list(prob = 0.3)),
    Hyper = list(family = "hyper", title = "Hypergeometric distribution",
                 fields = list(m = 10, n = 10, k = 5)),
    Nbinom = list(family = "nbinom", title = "Negative binomial distribution",
                  fields = list(size = 5, prob = 0.5))
  )
  dialogs <- list()
  for (suffix in names(specs)) {
    spec <- specs[[suffix]]
    id <- paste0("windowDist", suffix)
    fields <- lapply(names(spec$fields), function(name) {
      list(name = name, label = name, type = "entry",
           default = as.character(spec$fields[[name]]))
    })
    dialogs[[id]] <- kmg_dialog(
      id, spec$title, fields,
      local({
        family <- spec$family
        function(values, state) build_kmg_distribution(family, values)
      })
    )
  }
  dialogs
}
