# Shiny dialogs for DoE -------------------------------------------------

doe_dialog <- function(id, title, fields, build, help = NULL, plot = TRUE,
                       help_topic = NULL) {
  ns <- function(x) paste0(id, "_", x)
  RcmdrShiny::plugin_dialog(
    id = id, title = title, help = help, help_topic = help_topic,
    ui = function(state, memory) {
      htmltools::tagList(lapply(fields, function(field) {
        value <- if (is.null(memory)) NULL else memory[[field$name]]
        if (is.null(value)) value <- field$default
        if (identical(field$type, "entry")) {
          RcmdrShiny::entry_input(ns(field$name), field$label, value)
        } else if (identical(field$type, "spin")) {
          RcmdrShiny::spin_input(ns(field$name), field$label, value)
        } else if (identical(field$type, "variable")) {
          RcmdrShiny::var_input(ns(field$name), field$label,
                                RcmdrShiny::variables(state), value)
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
      list(commands = command, memory = values, plot = plot,
           activate_dataset = values$name %||% NULL)
    }
  )
}

de <- function(name, label, default = "") {
  list(name = name, label = label, type = "entry", default = default)
}
ds <- function(name, label, default = 1) {
  list(name = name, label = label, type = "spin", default = default)
}
dv <- function(name, label, default = "") {
  list(name = name, label = label, type = "variable", default = default)
}

doe_dialogs <- function() {
  dialogs <- list(
    Menu.pb2level = doe_dialog(
      "Menu.pb2level", "Screening design",
      list(de("name", "Design name", "design"), ds("factors", "Factors", 7),
           ds("runs", "Runs", 8)),
      function(values, state) build_screening(values$name, values$factors,
                                              values$runs)
    ),
    Menu.FrF2level = doe_dialog(
      "Menu.FrF2level", "Regular fractional factorial",
      list(de("name", "Design name", "design"), ds("factors", "Factors", 5),
           ds("runs", "Runs", 16), ds("resolution", "Resolution", 3)),
      function(values, state) build_fractional(values$name, values$factors,
                                               values$runs, values$resolution)
    ),
    Menu.fac = doe_dialog(
      "Menu.fac", "General full factorial",
      list(de("name", "Design name", "design"), ds("factors", "Factors", 3),
           ds("levels", "Levels", 2), ds("replications", "Replications", 1)),
      function(values, state) build_full_factorial(
        values$name, values$factors, values$levels, values$replications
      )
    ),
    Menu.oa = doe_dialog(
      "Menu.oa", "General orthogonal array",
      list(de("name", "Design name", "design"), ds("factors", "Factors", 3),
           ds("levels", "Levels", 2), ds("runs", "Runs", 8)),
      function(values, state) build_orthogonal_array(
        values$name, values$factors, values$levels, values$runs
      )
    ),
    Menu.ccd = doe_dialog(
      "Menu.ccd", "Central composite design",
      list(de("name", "Design name", "design"), ds("factors", "Factors", 3),
           ds("ncenter", "Center points", 4),
           list(name = "alpha", label = "Alpha", type = "combo",
                choices = c("rotatable" = "rotatable", "orthogonal" = "orthogonal",
                            "face" = "face"), default = "rotatable")),
      function(values, state) build_ccd(values$name, values$factors,
                                        values$ncenter, values$alpha)
    ),
    Menu.bbd = doe_dialog(
      "Menu.bbd", "Box-Behnken design",
      list(de("name", "Design name", "design"), ds("factors", "Factors", 3),
           ds("ncenter", "Center points", 4)),
      function(values, state) build_bbd(values$name, values$factors,
                                        values$ncenter)
    ),
    Menu.lhs = doe_dialog(
      "Menu.lhs", "Latin hypercube design",
      list(de("name", "Design name", "design"), ds("factors", "Factors", 3),
           ds("n", "Runs", 20)),
      function(values, state) build_lhs(values$name, values$factors, values$n)
    ),
    Menu.Dopt = doe_dialog(
      "Menu.Dopt", "D-optimal design",
      list(de("name", "Design name", "design"),
           dv("candidates", "Candidate design", "design"),
           de("terms", "Model terms", "~ ."), ds("n", "Trials", 12)),
      function(values, state) build_doptimal(values$name, values$candidates,
                                             values$terms, values$n)
    ),
    Menu.display = doe_dialog(
      "Menu.display", "Display active design", list(),
      function(values, state) {
        design <- RcmdrShiny::active_dataset(state)
        if (is.null(design)) stop("No active design.")
        design
      }
    ),
    summarize.design = doe_dialog(
      "summarize.design", "Summarize active design", list(),
      function(values, state) {
        design <- RcmdrShiny::active_dataset(state)
        if (is.null(design)) stop("No active design.")
        build_design_summary(design)
      }
    ),
    Menu.plot = doe_dialog(
      "Menu.plot", "Plot active design", list(),
      function(values, state) {
        design <- RcmdrShiny::active_dataset(state)
        if (is.null(design)) stop("No active design.")
        build_design_plot(design)
      }
    ),
    design.info.design = doe_dialog(
      "design.info.design", "Design information", list(),
      function(values, state) {
        design <- RcmdrShiny::active_dataset(state)
        if (is.null(design)) stop("No active design.")
        sprintf("DoE.base::design.info(%s)", design)
      }
    ),
    Menu.addresponse = doe_dialog(
      "Menu.addresponse", "Add response variable", list(
        de("name", "Response name", "response")
      ),
      function(values, state) {
        design <- RcmdrShiny::active_dataset(state)
        if (is.null(design)) stop("No active design.")
        build_add_response(design, values$name)
      }
    ),
    Menu.colremove = doe_dialog(
      "Menu.colremove", "Remove column", list(
        de("column", "Column name", "")
      ),
      function(values, state) {
        design <- RcmdrShiny::active_dataset(state)
        if (is.null(design)) stop("No active design.")
        build_remove_column(design, values$column)
      }
    ),
    Menu.model = doe_dialog(
      "Menu.model", "Default linear model", list(
        de("response", "Response variable", "response")
      ),
      function(values, state) {
        design <- RcmdrShiny::active_dataset(state)
        if (is.null(design)) stop("No active design.")
        c(build_design_model(design, values$response), "summary(.model)")
      }
    ),
    Menu.rsmmodel = doe_dialog(
      "Menu.rsmmodel", "Response surface model", list(
        de("response", "Response variable", "response"),
        de("factors", "Factor names (comma separated)", "")
      ),
      function(values, state) {
        design <- RcmdrShiny::active_dataset(state)
        if (is.null(design)) stop("No active design.")
        factors <- trimws(strsplit(values$factors, ",")[[1L]])
        c(build_design_rsm(design, values$response, factors), "summary(.model)")
      }
    ),
    Menu.EffectPlots = doe_dialog(
      "Menu.EffectPlots", "Effects normal plot", list(),
      function(values, state) {
        model <- RcmdrShiny::active_model(state)
        if (is.null(model)) stop("No active model.")
        build_effects_plot(model)
      }
    ),
    Menu.IAPlot = doe_dialog(
      "Menu.IAPlot", "Main effects and interaction plots", list(),
      function(values, state) {
        design <- RcmdrShiny::active_dataset(state)
        if (is.null(design)) stop("No active design.")
        build_main_effects(design)
      }
    ),
    Menu.contour = doe_dialog(
      "Menu.contour", "Response surface plots", list(),
      function(values, state) {
        model <- RcmdrShiny::active_model(state)
        if (is.null(model)) stop("No active model.")
        sprintf("rsm::contour.lm(%s, ~ x1 + x2)", model)
      }
    ),
    loadworkspace = doe_dialog(
      "loadworkspace", "Load R workspace",
      list(de("file", "Workspace file", "workspace.RData")),
      function(values, state) sprintf("load(%s)", doe_quote(values$file)),
      help_topic = "doe-import-export", plot = FALSE
    )
  )
  c(dialogs, doe_extra_dialogs())
}
