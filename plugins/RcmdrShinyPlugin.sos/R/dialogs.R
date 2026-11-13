# Shiny dialog for sos --------------------------------------------------

sos_dialog <- function() {
  id <- "sosInit"
  ns <- function(x) paste0(id, "_", x)

  RcmdrShiny::plugin_dialog(
    id = id,
    title = "Search R help pages",
    help = "findFn",
    help_package = "sos",
    ui = function(state, memory) {
      htmltools::tagList(
        htmltools::tags$p(
          "Separate up to nine terms with | (union) or & (intersection). ",
          "Use only one operator per search."
        ),
        RcmdrShiny::entry_input(
          ns("search"), "Search string:", memory$search %||% ""
        ),
        RcmdrShiny::spin_input(
          ns("max_page"), "Maximum pages:", memory$max_page %||% 20,
          min = 1, max = 99, step = 1
        ),
        RcmdrShiny::checkbox_input(
          ns("summary"), "Summary", memory$summary %||% FALSE
        ),
        RcmdrShiny::checkbox_input(
          ns("xls"), "Write to spreadsheet", memory$xls %||% FALSE
        ),
        htmltools::tags$hr(),
        RcmdrShiny::entry_input(
          ns("filter"), "Filter results:", memory$filter %||% ""
        ),
        RcmdrShiny::combo_input(
          ns("column"), "Filter column",
          c("Package" = "Package", "Function" = "",
            "Description" = "Description"),
          memory$column %||% ""
        ),
        RcmdrShiny::checkbox_input(
          ns("ignore_case"), "Ignore case",
          memory$ignore_case %||% TRUE
        )
      )
    },
    on_ok = function(input, state) {
      options <- list(
        search = input[[ns("search")]] %||% "",
        max_page = input[[ns("max_page")]] %||% 20,
        summary = isTRUE(input[[ns("summary")]]),
        xls = isTRUE(input[[ns("xls")]]),
        filter = input[[ns("filter")]] %||% "",
        column = input[[ns("column")]] %||% "",
        ignore_case = isTRUE(input[[ns("ignore_case")]])
      )
      commands <- tryCatch(
        build_sos_commands(
          options$search, options$max_page, options$summary, options$xls,
          options$filter, options$column, options$ignore_case
        ),
        error = function(e) e
      )
      if (inherits(commands, "error")) {
        return(list(error = conditionMessage(commands)))
      }
      list(commands = commands, memory = options)
    }
  )
}

sos_dialogs <- function() {
  list(sosInit = sos_dialog())
}
