# Shiny dialogs for the Export plugin -----------------------------------

export_dialog_id <- function(name) paste0("export_", name)

export_xtable_dialog <- function() {
  id <- "xtableExport"
  ns <- function(x) paste0(id, "_", x)

  RcmdrShiny::plugin_dialog(
    id = id,
    title = "Export objects using xtable()",
    help = "xtable",
    help_package = "xtable",
    ui = function(state, memory) {
      object <- export_last_object()
      htmltools::tagList(
        htmltools::tags$p(
          htmltools::tags$strong("Object class: "),
          export_object_class(object)
        ),
        if (!export_object_available(object)) {
          htmltools::tags$p(
            class = "text-danger",
            "No printable object is available. Run a command that prints an object first."
          )
        },
        RcmdrShiny::radio_input(
          ns("type"), "Export format",
          c("LaTeX" = "latex", "HTML" = "html"),
          memory$type %||% "latex"
        ),
        RcmdrShiny::entry_input(ns("caption"), "Caption:", memory$caption %||% ""),
        RcmdrShiny::radio_input(
          ns("caption_place"), "Caption place",
          c("Top" = "top", "Bottom" = "bottom"),
          memory$caption_place %||% "bottom"
        ),
        RcmdrShiny::entry_input(ns("label"), "Label:", memory$label %||% ""),
        RcmdrShiny::entry_input(ns("align"), "Align:", memory$align %||% ""),
        RcmdrShiny::entry_input(ns("digits"), "Digits:", memory$digits %||% ""),
        RcmdrShiny::entry_input(ns("display"), "Display:", memory$display %||% ""),
        RcmdrShiny::entry_input(ns("size"), "Size:", memory$size %||% "normal"),
        RcmdrShiny::entry_input(ns("na"), "NA string:", memory$na %||% ""),
        RcmdrShiny::entry_input(ns("file"), "File (without extension):",
                                memory$file %||% ""),
        RcmdrShiny::checkbox_input(ns("append"), "Append",
                                   memory$append %||% FALSE),
        RcmdrShiny::checkbox_input(ns("floating"), "Floating",
                                   memory$floating %||% TRUE),
        RcmdrShiny::radio_input(
          ns("tab_env"), "Tabular environment",
          c("tabular" = "tabular", "longtable" = "longtable"),
          memory$tab_env %||% "tabular"
        )
      )
    },
    on_ok = function(input, state) {
      object <- export_last_object()
      if (!export_object_available(object)) {
        return(list(error = "No printable object is available."))
      }
      options <- list(
        type = input[[ns("type")]] %||% "latex",
        caption = input[[ns("caption")]] %||% "",
        caption_place = input[[ns("caption_place")]] %||% "bottom",
        label = input[[ns("label")]] %||% "",
        align = input[[ns("align")]] %||% "",
        digits = input[[ns("digits")]] %||% "",
        display = input[[ns("display")]] %||% "",
        size = input[[ns("size")]] %||% "normal",
        na = input[[ns("na")]] %||% "",
        file = input[[ns("file")]] %||% "",
        append = isTRUE(input[[ns("append")]]),
        floating = isTRUE(input[[ns("floating")]]),
        tab_env = input[[ns("tab_env")]] %||% "tabular"
      )
      options$type <- if (identical(options$type, "html")) "HTML" else "LaTeX"
      command <- tryCatch(
        export_xtable_command(object, options),
        error = function(e) e
      )
      if (inherits(command, "error")) {
        return(list(error = conditionMessage(command)))
      }
      list(commands = command, memory = options)
    }
  )
}

export_latex_dialog <- function() {
  id <- "latexExport"
  ns <- function(x) paste0(id, "_", x)

  RcmdrShiny::plugin_dialog(
    id = id,
    title = "Export objects using latex()",
    help = "latex",
    help_package = "Hmisc",
    ui = function(state, memory) {
      object <- export_last_object()
      htmltools::tagList(
        htmltools::tags$p(
          htmltools::tags$strong("Object class: "),
          export_object_class(object)
        ),
        if (!export_object_available(object)) {
          htmltools::tags$p(
            class = "text-danger",
            "No printable object is available. Run a command that prints an object first."
          )
        },
        RcmdrShiny::entry_input(ns("caption"), "Caption:", memory$caption %||% ""),
        RcmdrShiny::radio_input(
          ns("caption_place"), "Caption location",
          c("Top" = "top", "Bottom" = "bottom"),
          memory$caption_place %||% "top"
        ),
        RcmdrShiny::entry_input(ns("label"), "Label:", memory$label %||% ""),
        RcmdrShiny::entry_input(ns("digits"), "Digits:", memory$digits %||% ""),
        RcmdrShiny::entry_input(ns("size"), "Size:", memory$size %||% "normal"),
        RcmdrShiny::entry_input(ns("center"), "Center:", memory$center %||% "center"),
        RcmdrShiny::entry_input(ns("file"), "File (without extension):",
                                memory$file %||% ""),
        RcmdrShiny::checkbox_input(ns("append"), "Append",
                                   memory$append %||% TRUE),
        RcmdrShiny::checkbox_input(ns("preview"), "Preview",
                                   memory$preview %||% FALSE),
        RcmdrShiny::checkbox_input(ns("longtable"), "Use longtable",
                                   memory$longtable %||% FALSE),
        RcmdrShiny::checkbox_input(ns("table_env"), "Table environment",
                                   memory$table_env %||% TRUE),
        RcmdrShiny::checkbox_input(ns("landscape"), "Landscape",
                                   memory$landscape %||% FALSE),
        RcmdrShiny::checkbox_input(ns("booktabs"), "Use booktabs",
                                   memory$booktabs %||% FALSE),
        RcmdrShiny::checkbox_input(ns("ctable"), "Use ctable",
                                   memory$ctable %||% FALSE),
        RcmdrShiny::checkbox_input(ns("vbar"), "Vertical bar",
                                   memory$vbar %||% FALSE),
        RcmdrShiny::checkbox_input(ns("nomargins"), "No margins",
                                   memory$nomargins %||% TRUE),
        RcmdrShiny::checkbox_input(ns("blank_na"), "Blank NA",
                                   memory$blank_na %||% TRUE)
      )
    },
    on_ok = function(input, state) {
      object <- export_last_object()
      if (!export_object_available(object)) {
        return(list(error = "No printable object is available."))
      }
      options <- list(
        caption = input[[ns("caption")]] %||% "",
        caption_place = input[[ns("caption_place")]] %||% "top",
        label = input[[ns("label")]] %||% "",
        digits = input[[ns("digits")]] %||% "",
        size = input[[ns("size")]] %||% "normal",
        center = input[[ns("center")]] %||% "center",
        file = input[[ns("file")]] %||% "",
        append = isTRUE(input[[ns("append")]]),
        preview = isTRUE(input[[ns("preview")]]),
        longtable = isTRUE(input[[ns("longtable")]]),
        table_env = isTRUE(input[[ns("table_env")]]),
        landscape = isTRUE(input[[ns("landscape")]]),
        booktabs = isTRUE(input[[ns("booktabs")]]),
        ctable = isTRUE(input[[ns("ctable")]]),
        vbar = isTRUE(input[[ns("vbar")]]),
        nomargins = isTRUE(input[[ns("nomargins")]]),
        blank_na = isTRUE(input[[ns("blank_na")]])
      )
      command <- tryCatch(
        export_latex_command(object, options),
        error = function(e) e
      )
      if (inherits(command, "error")) {
        return(list(error = conditionMessage(command)))
      }
      list(commands = command, memory = options)
    }
  )
}

export_formatdf_dialog <- function() {
  id <- "formatdfExport"
  ns <- function(x) paste0(id, "_", x)

  RcmdrShiny::plugin_dialog(
    id = id,
    title = "Format for LaTeX or HTML export",
    help = "format.df",
    help_package = "Hmisc",
    ui = function(state, memory) {
      tables <- export_tables(state)
      htmltools::tagList(
        if (length(tables) == 0L) {
          htmltools::tags$p(
            class = "text-danger",
            "There are no available data frames or matrices."
          )
        } else {
          RcmdrShiny::var_input(
            ns("object"), "Data frame or matrix",
            tables, memory$object %||% tables[[1L]]
          )
        },
        RcmdrShiny::entry_input(ns("dec"), "Decimals:", memory$dec %||% "2"),
        RcmdrShiny::entry_input(ns("cdec"), "Column decimals:",
                                memory$cdec %||% ""),
        RcmdrShiny::checkbox_input(ns("numeric_dollar"), "Numeric dollar",
                                   memory$numeric_dollar %||% TRUE),
        RcmdrShiny::checkbox_input(ns("na_blank"), "Blank NA",
                                   memory$na_blank %||% FALSE),
        RcmdrShiny::checkbox_input(ns("na_dot"), "Dot NA",
                                   memory$na_dot %||% FALSE),
        RcmdrShiny::checkbox_input(ns("blank_dot"), "Dot blank",
                                   memory$blank_dot %||% FALSE),
        RcmdrShiny::entry_input(ns("col_just"), "Column justify:",
                                memory$col_just %||% ""),
        RcmdrShiny::checkbox_input(ns("cdot"), "Centered dot",
                                   memory$cdot %||% FALSE),
        RcmdrShiny::entry_input(ns("scientific"), "Scientific notation:",
                                memory$scientific %||% "c(-4,4)"),
        RcmdrShiny::checkbox_input(ns("math_row"), "Math row names",
                                   memory$math_row %||% FALSE),
        RcmdrShiny::checkbox_input(ns("math_col"), "Math column names",
                                   memory$math_col %||% FALSE),
        RcmdrShiny::checkbox_input(ns("double_slash"), "Escape backslashes",
                                   memory$double_slash %||% FALSE)
      )
    },
    on_ok = function(input, state) {
      object <- input[[ns("object")]] %||% ""
      if (!nzchar(object)) return(list(error = "Please select an object."))
      if (!exists(object, envir = state$env, inherits = FALSE)) {
        return(list(error = sprintf("Object '%s' does not exist.", object)))
      }
      options <- list(
        object = object,
        dec = input[[ns("dec")]] %||% "2",
        cdec = input[[ns("cdec")]] %||% "",
        numeric_dollar = isTRUE(input[[ns("numeric_dollar")]]),
        na_blank = isTRUE(input[[ns("na_blank")]]),
        na_dot = isTRUE(input[[ns("na_dot")]]),
        blank_dot = isTRUE(input[[ns("blank_dot")]]),
        col_just = input[[ns("col_just")]] %||% "",
        cdot = isTRUE(input[[ns("cdot")]]),
        scientific = input[[ns("scientific")]] %||% "c(-4,4)",
        math_row = isTRUE(input[[ns("math_row")]]),
        math_col = isTRUE(input[[ns("math_col")]]),
        double_slash = isTRUE(input[[ns("double_slash")]])
      )
      command <- tryCatch(
        export_formatdf_command(object, options),
        error = function(e) e
      )
      if (inherits(command, "error")) {
        return(list(error = conditionMessage(command)))
      }
      list(commands = command, memory = options)
    }
  )
}

export_dialogs <- function() {
  list(
    xtableExport = export_xtable_dialog(),
    latexExport = export_latex_dialog(),
    formatdfExport = export_formatdf_dialog()
  )
}
