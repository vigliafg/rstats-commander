# DoE import/export, inspection and analysis ------------------------------
#
# The import and inspection entries either move a design between the session
# and disk, edit its columns, or open the in-app guide.  Builders stay pure so
# the generated code is testable without attaching DoE.base.

doe_quote <- function(x) paste0('"', gsub('"', '\\\\"', x), '"')

doe_import_workspace <- function(object, name = "design") {
  if (!nzchar(object) || !nzchar(name)) {
    stop("Enter the object name and the design name.")
  }
  if (identical(object, name)) stop("The new name must differ from the object.")
  sprintf("%s <- %s", name, object)
}

doe_import_csv <- function(file, name = "design") {
  if (!nzchar(file)) stop("Enter the file name.")
  sprintf("%s <- read.csv(%s)", name, doe_quote(file))
}

doe_export_design <- function(design, file) {
  if (!nzchar(file)) stop("Enter the destination file.")
  sprintf("write.csv(%s, %s, row.names = FALSE)", design, doe_quote(file))
}

doe_load_catalogue <- function(entry) {
  if (!nzchar(entry)) stop("Enter a catalogue entry.")
  sprintf("utils::data(list = %s, package = \"FrF2\")", doe_quote(entry))
}

doe_candidate_design <- function(name, factors, levels = 2) {
  if (!nzchar(name)) stop("Enter a design name.")
  sprintf("%s <- DoE.base::fac.design(nfactors = %d, nlevels = %d, replications = 1)",
          name, as.integer(factors), as.integer(levels))
}

doe_parameter_design <- function(name, inner, outer) {
  if (!nzchar(inner) || !nzchar(outer)) {
    stop("Enter the inner and outer design names.")
  }
  sprintf("%s <- DoE.base::param.design(%s, %s)", name, inner, outer)
}

doe_tabulate <- function(design) {
  c(sprintf("summary(%s)", design), sprintf("table(%s)", design))
}

doe_select_responses <- function(design, responses) {
  responses <- responses[nzchar(responses)]
  if (length(responses) == 0L) stop("Choose at least one response.")
  sprintf("%s[, c(%s), drop = FALSE]", design,
          paste0('"', responses, '"', collapse = ", "))
}

doe_change_contrasts <- function(design, factor, type = "sum") {
  if (!nzchar(factor)) stop("Choose a factor.")
  code <- switch(type, sum = "contr.sum", helmert = "contr.helmert",
                 treatment = "contr.treatment", "contr.sum")
  sprintf('contrasts(%s$%s) <- "%s"', design, factor, code)
}

doe_long_to_wide <- function(design, id, time, response) {
  if (any(!nzchar(c(id, time, response)))) {
    stop("Choose the identifier, the time variable and the response.")
  }
  sprintf('reshape(%s, idvar = "%s", timevar = "%s", direction = "wide")',
          design, id, time)
}

doe_aggregate <- function(design, response) {
  if (!nzchar(response)) stop("Choose the response.")
  sprintf("aggregate(%s ~ ., data = %s, FUN = mean)", response, design)
}

doe_add_center <- function(design, points = 4) {
  points <- max(1L, as.integer(points))
  paste0(
    "local({\n",
    sprintf("  .center <- %s[rep(1, %d), , drop = FALSE]\n", design, points),
    "  for (.v in names(.center)) {\n",
    "    if (is.numeric(.center[[.v]])) .center[[.v]] <- 0\n",
    "  }\n",
    sprintf("  %s <- rbind(%s, .center)\n", design, design),
    "})"
  )
}

doe_pick_cube <- function(design) {
  sprintf("rsm::cube(%s)", design)
}

doe_augment_lhs <- function(design, points = 5) {
  sprintf("lhs::augmentLHS(%s, %d)", design, max(1L, as.integer(points)))
}

doe_effect_plots <- function(design) {
  paste0(
    "local({\n",
    sprintf("  DoE.base::MEPlot(%s)\n", design),
    sprintf("  DoE.base::IAPlot(%s)\n", design),
    "})"
  )
}

doe_steepest <- function(model, distance = 1) {
  sprintf("rsm::steepest(%s, dist = %s)", model, format(as.numeric(distance)))
}

# -- dialogs ----------------------------------------------------------------

doe_extra_dialogs <- function() {
  list(
    Menu.import = doe_dialog(
      "Menu.import", "Load experiment from R workspace",
      list(de("object", "Object name", "design"),
           de("name", "Design name", "design")),
      function(values, state) {
        doe_import_workspace(values$object, values$name)
      },
      help_topic = "doe-import-export"
    ),
    Menu.importrdacsv = doe_dialog(
      "Menu.importrdacsv", "Re-import experiment from a CSV file",
      list(de("file", "CSV file", "design.csv"),
           de("name", "Design name", "design")),
      function(values, state) doe_import_csv(values$file, values$name),
      help_topic = "doe-import-export"
    ),
    Menu.export = doe_dialog(
      "Menu.export", "Export experiment",
      list(de("file", "Destination file", "design.csv")),
      function(values, state) {
        design <- RcmdrShiny::active_dataset(state)
        if (is.null(design)) stop("No active design.")
        doe_export_design(design, values$file)
      },
      help_topic = "doe-import-export"
    ),
    Menu.loadcatlg = doe_dialog(
      "Menu.loadcatlg", "Load additional catalogue design",
      list(de("entry", "Catalogue entry", "catlg")),
      function(values, state) doe_load_catalogue(values$entry),
      help_topic = "doe-designs", plot = FALSE
    ),
    Menu.cand = doe_dialog(
      "Menu.cand", "Candidate design",
      list(de("name", "Design name", "candidates"),
           ds("factors", "Factors", 3), ds("levels", "Levels", 2)),
      function(values, state) {
        doe_candidate_design(values$name, values$factors, values$levels)
      },
      help_topic = "doe-designs"
    ),
    Menu.param = doe_dialog(
      "Menu.param", "Taguchi inner-outer array",
      list(de("name", "Design name", "param"),
           de("inner", "Inner design", "inner"),
           de("outer", "Outer design", "outer")),
      function(values, state) {
        doe_parameter_design(values$name, values$inner, values$outer)
      },
      help_topic = "doe-designs"
    ),
    Menu.tab = doe_dialog(
      "Menu.tab", "Tabulate active design", list(),
      function(values, state) {
        design <- RcmdrShiny::active_dataset(state)
        if (is.null(design)) stop("No active design.")
        doe_tabulate(design)
      },
      help_topic = "doe-analyse", plot = FALSE
    ),
    Menu.responses = doe_dialog(
      "Menu.responses", "Select response variables",
      list(dv("responses", "Response variables (comma separated)", "")),
      function(values, state) {
        design <- RcmdrShiny::active_dataset(state)
        if (is.null(design)) stop("No active design.")
        responses <- trimws(strsplit(values$responses %||% "", ",")[[1L]])
        doe_select_responses(design, responses)
      },
      help_topic = "doe-analyse", plot = FALSE
    ),
    Menu.changecontr = doe_dialog(
      "Menu.changecontr", "Change factor contrasts",
      list(de("factor", "Factor", ""),
           list(name = "type", label = "Contrasts", type = "combo",
                choices = c("Sum" = "sum", "Helmert" = "helmert",
                            "Treatment" = "treatment"), default = "sum")),
      function(values, state) {
        design <- RcmdrShiny::active_dataset(state)
        if (is.null(design)) stop("No active design.")
        doe_change_contrasts(design, values$factor, values$type)
      },
      help_topic = "doe-analyse", plot = FALSE
    ),
    Menu.wide = doe_dialog(
      "Menu.wide", "Change from long to wide format",
      list(de("id", "Identifier variable", "id"),
           de("time", "Time variable", "time"),
           de("response", "Response variable", "response")),
      function(values, state) {
        design <- RcmdrShiny::active_dataset(state)
        if (is.null(design)) stop("No active design.")
        doe_long_to_wide(design, values$id, values$time, values$response)
      },
      help_topic = "doe-analyse", plot = FALSE
    ),
    Menu.aggregate = doe_dialog(
      "Menu.aggregate", "Aggregate design",
      list(de("response", "Response variable", "response")),
      function(values, state) {
        design <- RcmdrShiny::active_dataset(state)
        if (is.null(design)) stop("No active design.")
        doe_aggregate(design, values$response)
      },
      help_topic = "doe-analyse", plot = FALSE
    ),
    Menu.addcenter = doe_dialog(
      "Menu.addcenter", "Add center points",
      list(ds("points", "Center points", 4)),
      function(values, state) {
        design <- RcmdrShiny::active_dataset(state)
        if (is.null(design)) stop("No active design.")
        doe_add_center(design, values$points)
      },
      help_topic = "doe-analyse"
    ),
    Menu.pickcube = doe_dialog(
      "Menu.pickcube", "Remove star portion from central composite design",
      list(),
      function(values, state) {
        design <- RcmdrShiny::active_dataset(state)
        if (is.null(design)) stop("No active design.")
        doe_pick_cube(design)
      },
      help_topic = "doe-analyse"
    ),
    Menu.augmentlhs = doe_dialog(
      "Menu.augmentlhs", "Augment Latin hypercube design",
      list(ds("points", "Additional points", 5)),
      function(values, state) {
        design <- RcmdrShiny::active_dataset(state)
        if (is.null(design)) stop("No active design.")
        doe_augment_lhs(design, values$points)
      },
      help_topic = "doe-designs"
    ),
    Menu.PlotMeansDoE = doe_dialog(
      "Menu.PlotMeansDoE", "Main effects and interaction plots",
      list(),
      function(values, state) {
        design <- RcmdrShiny::active_dataset(state)
        if (is.null(design)) stop("No active design.")
        doe_effect_plots(design)
      },
      help_topic = "doe-analyse"
    ),
    Menu.steepest = doe_dialog(
      "Menu.steepest", "Steepest slope",
      list(de("distance", "Distance", "1")),
      function(values, state) {
        model <- RcmdrShiny::active_model(state)
        if (is.null(model)) stop("No active model.")
        doe_steepest(model, values$distance)
      },
      help_topic = "doe-analyse", plot = FALSE
    )
  )
}
