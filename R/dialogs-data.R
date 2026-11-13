# Data menu dialogs ---------------------------------------------------------
#
# Phase 2 dialogs.  The UI is deliberately simpler than Rcmdr's Tk dialogs but
# the generated R code follows the original builders exactly.

data_active <- function(state) active_dataset(state)

data_default_name <- function(state, suffix = "") {
  base <- active_dataset(state) %||% "Dataset"
  paste0(base, suffix)
}

data_validate_name <- function(name) {
  if (!nzchar(name)) return(tr("You must enter the name of a data set."))
  if (!is_valid_name(name)) {
    return(sprintf(tr('"%s" is not a valid name.'), name))
  }
  NULL
}

data_require_active <- function(state) {
  if (is.null(active_dataset(state))) tr("There is no active data set.") else NULL
}

data_file_observers <- function(id, state, filetypes) {
  function(input, output, session, state, refresh) {
    roots <- c(home = "~", wd = getwd(), root = "/")
    file_input_observers(
      input, session, paste0(id, "_file"), roots,
      guard = function() identical(state$current_dialog, id),
      filetypes = filetypes
    )
  }
}

# New / select / load -------------------------------------------------------

new_dataset_dialog <- function() {
  id <- "newDataSet"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(name = "Dataset", rows = 10L, columns = 3L)

  dialog_spec(
    id = id, title = tr("New Data Set"), help = "data.frame",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        entry_input(ns("name"), tr("Enter name for data set:"), m$name),
        spin_input(ns("rows"), tr("Initial rows:"), m$rows, min = 1, max = 10000),
        spin_input(ns("columns"), tr("Initial columns:"), m$columns, min = 1, max = 100),
        help_text(tr("The new data set is editable in the Data tab."))
      )
    },
    on_ok = function(input, state) {
      name <- trim_blanks(input[[ns("name")]] %||% "")
      error <- data_validate_name(name)
      if (!is.null(error)) return(list(error = error))
      list(
        commands = cmd_new_dataset(
          name,
          rows = input[[ns("rows")]] %||% 10,
          columns = input[[ns("columns")]] %||% 3
        ),
        activate_dataset = name,
        tab = "Data",
        memory = list(
          name = name,
          rows = input[[ns("rows")]] %||% 10,
          columns = input[[ns("columns")]] %||% 3
        )
      )
    }
  )
}

select_active_dataset_dialog <- function() {
  id <- "selectActiveDataSet"
  ns <- function(x) paste0(id, "_", x)

  dialog_spec(
    id = id, title = tr("Select Data Set"), help = "data.frame",
    ui = function(state, memory) {
      choices <- list_data_sets(state)
      selected <- active_dataset(state)
      htmltools::tagList(
        combo_input(
          ns("dataset"), tr("Data Sets (pick one)"),
          stats::setNames(choices, choices),
          selected = if (!is.null(selected)) selected else NULL
        )
      )
    },
    on_ok = function(input, state) {
      selection <- input[[ns("dataset")]] %||% ""
      if (!nzchar(selection)) {
        return(list(error = tr("There are no data sets from which to choose.")))
      }
      list(activate_dataset = selection, memory = list(dataset = selection))
    }
  )
}

read_data_from_package_dialog <- function() {
  id <- "readDataFromPackage"
  ns <- function(x) paste0(id, "_", x)

  packages_with_data <- function() {
    candidates <- setdiff(.packages(), c("base", "stats"))
    candidates[vapply(candidates, function(package) {
      nrow(utils::data(package = package)$results) > 0L
    }, logical(1))]
  }
  datasets_in <- function(package) {
    result <- utils::data(package = package)$results
    if (is.null(result) || nrow(result) == 0L) return(character())
    items <- result[, 3L]
    items[vapply(items, is_valid_name, logical(1))]
  }

  dialog_spec(
    id = id, title = tr("Read Data From Package"), help = "data",
    ui = function(state, memory) {
      packages <- packages_with_data()
      package <- if (!is.null(memory$package) && memory$package %in% packages) {
        memory$package
      } else {
        packages[[1L]]
      }
      datasets <- datasets_in(package)
      htmltools::tagList(
        combo_input(ns("package"), tr("Package"),
                    stats::setNames(packages, packages), selected = package),
        combo_input(ns("dataset"), tr("Data set"),
                    stats::setNames(datasets, datasets),
                    selected = datasets[[1L]] %||% NULL),
        help_text(tr("Data sets are loaded with data()."))
      )
    },
    observers = function(input, output, session, state, refresh) {
      observeEvent(input[[ns("package")]], {
        if (!identical(state$current_dialog, id)) return()
        datasets <- datasets_in(input[[ns("package")]])
        updateSelectInput(session, ns("dataset"),
                          choices = stats::setNames(datasets, datasets),
                          selected = datasets[[1L]] %||% character())
      }, ignoreInit = TRUE)
    },
    on_ok = function(input, state) {
      package <- input[[ns("package")]] %||% ""
      dataset <- input[[ns("dataset")]] %||% ""
      if (!nzchar(package)) return(list(error = tr("You must select a package.")))
      if (!nzchar(dataset)) return(list(error = tr("You must select a data set.")))
      list(
        commands = cmd_read_package(dataset, package),
        activate_dataset = dataset,
        memory = list(package = package, dataset = dataset)
      )
    }
  )
}

# Imports -------------------------------------------------------------------

import_dialog <- function(id, title, help, filetypes, command,
                          defaults, extra_ui = NULL) {
  ns <- function(x) paste0(id, "_", x)

  dialog_spec(
    id = id, title = title, help = help,
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        entry_input(ns("dsname"), tr("Enter name for data set:"),
                    m$dsname %||% "Dataset"),
        file_input(ns("file"), tr("File:"), m$file %||% "",
                   filetypes = filetypes),
        if (!is.null(extra_ui)) extra_ui(m, ns)
      )
    },
    observers = function(input, output, session, state, refresh) {
      roots <- c(home = "~", wd = getwd(), root = "/")
      file_input_observers(
        input, session, ns("file"), roots,
        guard = function() identical(state$current_dialog, id),
        filetypes = filetypes
      )
    },
    on_ok = function(input, state) {
      dsname <- trim_blanks(input[[ns("dsname")]] %||% "")
      file <- trim_blanks(input[[ns("file")]] %||% "")
      error <- data_validate_name(dsname)
      if (!is.null(error)) return(list(error = error))
      if (!nzchar(file)) return(list(error = tr("You must select a file.")))
      if (!file.exists(file)) {
        return(list(error = sprintf(tr("File not found: %s"), file)))
      }
      if (exists(dsname, envir = state$env, inherits = FALSE)) {
        return(list(error = sprintf(
          tr("An object named '%s' already exists. Choose another name."), dsname
        )))
      }
      list(
        commands = command(input, ns, dsname, file),
        activate_dataset = dsname,
        memory = list(dsname = dsname, file = file)
      )
    }
  )
}

import_excel_dialog <- function() {
  import_dialog(
    "importExcel", tr("Import Excel Data Set"), "readXL",
    c("xlsx", "xls", "XLSX", "XLS"),
    function(input, ns, dsname, file) {
      paste0(dsname, " <- ", cmd_import_excel(
        dsname, file,
        sheet = trim_blanks(input[[ns("sheet")]] %||% "Sheet1"),
        header = isTRUE(input[[ns("header")]]),
        rownames = isTRUE(input[[ns("rownames")]]),
        na = input[[ns("na")]] %||% "",
        stringsAsFactors = isTRUE(input[[ns("stringsAsFactors")]])
      ))
    },
    defaults = list(dsname = "Dataset", file = "", sheet = "Sheet1",
                    header = TRUE, rownames = FALSE, na = "",
                    stringsAsFactors = FALSE),
    extra_ui = function(m, ns) {
      htmltools::tagList(
        entry_input(ns("sheet"), tr("Worksheet name:"), m$sheet),
        checkbox_input(ns("header"), tr("Variable names in first row"), m$header),
        checkbox_input(ns("rownames"), tr("Row names in first column"), m$rownames),
        entry_input(ns("na"), tr("Missing value indicator:"), m$na),
        checkbox_input(ns("stringsAsFactors"),
                       tr("Convert character variables to factors"),
                       m$stringsAsFactors)
      )
    }
  )
}

import_spss_dialog <- function() {
  import_dialog(
    "importSPSS", tr("Import SPSS Data Set"), "readSPSS",
    c("sav", "SAV"),
    function(input, ns, dsname, file) {
      paste0(dsname, " <- ", cmd_import_spss(
        dsname, file,
        rownames = isTRUE(input[[ns("rownames")]]),
        stringsAsFactors = isTRUE(input[[ns("stringsAsFactors")]]),
        tolower = isTRUE(input[[ns("tolower")]])
      ))
    },
    defaults = list(dsname = "Dataset", file = "", rownames = FALSE,
                    stringsAsFactors = TRUE, tolower = TRUE),
    extra_ui = function(m, ns) {
      htmltools::tagList(
        checkbox_input(ns("rownames"), tr("First column contains row names"), m$rownames),
        checkbox_input(ns("stringsAsFactors"),
                       tr("Convert character variables to factors"),
                       m$stringsAsFactors),
        checkbox_input(ns("tolower"), tr("Convert variable names to lower case"),
                       m$tolower)
      )
    }
  )
}

import_stata_dialog <- function() {
  import_dialog(
    "importSTATA", tr("Import Stata Data Set"), "readStata",
    c("dta", "DTA"),
    function(input, ns, dsname, file) {
      paste0(dsname, " <- ", cmd_import_stata(
        dsname, file,
        convert_dates = isTRUE(input[[ns("convert_dates")]]),
        stringsAsFactors = isTRUE(input[[ns("stringsAsFactors")]]),
        rownames = isTRUE(input[[ns("rownames")]])
      ))
    },
    defaults = list(dsname = "Dataset", file = "", convert_dates = TRUE,
                    stringsAsFactors = TRUE, rownames = FALSE),
    extra_ui = function(m, ns) {
      htmltools::tagList(
        checkbox_input(ns("convert_dates"), tr("Convert dates to R format"),
                       m$convert_dates),
        checkbox_input(ns("stringsAsFactors"),
                       tr("Convert character variables to factors"),
                       m$stringsAsFactors),
        checkbox_input(ns("rownames"), tr("First column contains row names"), m$rownames)
      )
    }
  )
}

import_sas_dialog <- function() {
  import_dialog(
    "importSAS", tr("Import SAS xport Data Set"), "read.xport",
    c("xpt", "XPT"),
    function(input, ns, dsname, file) {
      cmd_import_sas_xport(dsname, file)
    },
    defaults = list(dsname = "Dataset", file = ""),
    extra_ui = function(m, ns) {
      help_text(tr("The first data set in the xport file is imported."))
    }
  )
}

import_sas_b7dat_dialog <- function() {
  import_dialog(
    "importSASb7dat", tr("Import SAS b7dat Data Set"), "readSAS",
    c("sas7bdat", "SAS7BDAT", "sas7bcat", "SAS7BCAT"),
    function(input, ns, dsname, file) {
      paste0(dsname, " <- ", cmd_import_sas(
        dsname, file,
        stringsAsFactors = isTRUE(input[[ns("stringsAsFactors")]]),
        rownames = isTRUE(input[[ns("rownames")]])
      ))
    },
    defaults = list(dsname = "Dataset", file = "", stringsAsFactors = TRUE,
                    rownames = FALSE),
    extra_ui = function(m, ns) {
      htmltools::tagList(
        checkbox_input(ns("stringsAsFactors"),
                       tr("Convert character variables to factors"),
                       m$stringsAsFactors),
        checkbox_input(ns("rownames"), tr("First column contains row names"), m$rownames)
      )
    }
  )
}

import_minitab_dialog <- function() {
  import_dialog(
    "importMinitab", tr("Import Minitab Data Set"), "read.mtp",
    c("mtp", "MTP"),
    function(input, ns, dsname, file) cmd_import_minitab(dsname, file),
    defaults = list(dsname = "Dataset", file = "")
  )
}

# Variables -----------------------------------------------------------------

compute_dialog <- function() {
  id <- "Compute"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(name = "variable", expression = "")

  dialog_spec(
    id = id, title = tr("Compute New Variable"), help = "Compute",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        entry_input(ns("name"), tr("New variable name"), m$name),
        entry_input(ns("expression"), tr("Expression to compute"), m$expression),
        help_text(tr("The expression is evaluated with the active data set."))
      )
    },
    on_ok = function(input, state) {
      error <- data_require_active(state)
      if (!is.null(error)) return(list(error = error))
      name <- trim_blanks(input[[ns("name")]] %||% "")
      expression <- trim_blanks(input[[ns("expression")]] %||% "")
      if (!is_valid_name(name)) {
        return(list(error = sprintf(tr('"%s" is not a valid name.'), name)))
      }
      if (!nzchar(expression)) {
        return(list(error = tr("No expression specified.")))
      }
      list(
        commands = cmd_compute(active_dataset(state), name, expression),
        activate_dataset = active_dataset(state),
        memory = list(name = name, expression = expression)
      )
    }
  )
}

delete_variables_dialog <- function() {
  id <- "deleteVariable"
  ns <- function(x) paste0(id, "_", x)

  dialog_spec(
    id = id, title = tr("Delete Variables"), help = "NULL",
    ui = function(state, memory) {
      var_input(ns("variables"), tr("Variable(s) to delete (pick one or more)"),
                variables(state), selected = memory$variables, multiple = TRUE)
    },
    on_ok = function(input, state) {
      variables <- input[[ns("variables")]]
      if (length(variables) == 0L) {
        return(list(error = tr("You must select one or more variables.")))
      }
      list(
        commands = cmd_delete_variables(active_dataset(state), variables),
        activate_dataset = active_dataset(state),
        memory = list(variables = variables)
      )
    }
  )
}

recode_dialog <- function() {
  id <- "RecodeDialog"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(variables = NULL, name = "variable", directives = "",
                   asFactor = TRUE, to.value = "=", interval = ":",
                   separator = ";")

  dialog_spec(
    id = id, title = tr("Recode Variables"), help = "Recode",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        var_input(ns("variables"), tr("Variables to recode (pick one or more)"),
                  variables(state), selected = m$variables, multiple = TRUE),
        entry_input(ns("name"),
                    tr("New variable name or prefix for multiple recodes:"),
                    m$name),
        checkbox_input(ns("asFactor"), tr("Make (each) new variable a factor"),
                       m$asFactor),
        htmltools::tags$div(
          class = "row g-2",
          htmltools::div(class = "col-4",
                         entry_input(ns("to.value"), tr("Old/new values assignment"),
                                     m$to.value)),
          htmltools::div(class = "col-4",
                         entry_input(ns("interval"), tr("Recode interval"),
                                     m$interval)),
          htmltools::div(class = "col-4",
                         entry_input(ns("separator"), tr("Recode separator"),
                                     m$separator))
        ),
        text_area(ns("directives"), tr("Enter recode directives"),
                  m$directives, rows = 5L)
      )
    },
    on_ok = function(input, state) {
      variables <- input[[ns("variables")]]
      if (length(variables) == 0L) {
        return(list(error = tr("You must select a variable.")))
      }
      name <- trim_blanks(input[[ns("name")]] %||% "")
      directives <- trim_blanks(input[[ns("directives")]] %||% "")
      if (!nzchar(directives)) {
        return(list(error = tr("No recode directives specified.")))
      }
      if (grepl("'", directives, fixed = TRUE)) {
        return(list(error = tr('Use only double-quotes (" ") in recode directives')))
      }
      targets <- if (length(variables) > 1L) paste0(name, variables) else name
      if (any(!vapply(targets, is_valid_name, logical(1)))) {
        return(list(error = tr("One or more new variable names are not valid.")))
      }
      list(
        commands = cmd_recode(
          active_dataset(state), variables, name, directives,
          as_factor = isTRUE(input[[ns("asFactor")]]),
          to_value = input[[ns("to.value")]] %||% "=",
          interval = input[[ns("interval")]] %||% ":",
          separator = input[[ns("separator")]] %||% ";"
        ),
        activate_dataset = active_dataset(state),
        memory = list(
          variables = variables, name = name, directives = directives,
          asFactor = isTRUE(input[[ns("asFactor")]]),
          to.value = input[[ns("to.value")]] %||% "=",
          interval = input[[ns("interval")]] %||% ":",
          separator = input[[ns("separator")]] %||% ";"
        )
      )
    }
  )
}

numeric_to_factor_dialog <- function() {
  id <- "numericToFactor"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(variables = NULL, name = "<same as variables>",
                   levels = "numbers", labels = "")

  dialog_spec(
    id = id, title = tr("Convert Numeric Variables to Factors"), help = "factor",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        var_input(ns("variables"), tr("Variables (pick one or more)"),
                  numeric_variables(state), selected = m$variables,
                  multiple = TRUE),
        radio_input(
          ns("levels"), tr("Factor Levels"),
          c("Use numbers" = "numbers", "Supply level names" = "names"),
          m$levels
        ),
        entry_input(ns("labels"), tr("Level names (comma separated):"), m$labels),
        entry_input(ns("name"), tr("New variable name or prefix:"), m$name)
      )
    },
    on_ok = function(input, state) {
      variables <- input[[ns("variables")]]
      if (length(variables) == 0L) {
        return(list(error = tr("You must select a variable.")))
      }
      levels <- input[[ns("levels")]] %||% "numbers"
      labels <- NULL
      if (identical(levels, "names")) {
        if (length(variables) > 1L) {
          return(list(error = tr("Level names can be supplied for one variable at a time.")))
        }
        text <- trim_blanks(input[[ns("labels")]] %||% "")
        if (!nzchar(text)) {
          return(list(error = tr("A level name is empty.")))
        }
        labels <- trimws(strsplit(text, ",", fixed = TRUE)[[1L]])
        df <- dataset(state)
        if (length(labels) != length(unique(df[[variables]]))) {
          return(list(error = tr("The number of level names does not match the number of levels.")))
        }
      }
      name <- trim_blanks(input[[ns("name")]] %||% "")
      same <- !nzchar(name) || identical(name, "<same as variables>")
      targets <- if (same) variables else if (length(variables) == 1L) name else paste0(name, variables)
      if (any(!vapply(targets, is_valid_name, logical(1)))) {
        return(list(error = tr("One or more new variable names are not valid.")))
      }
      list(
        commands = cmd_numeric_to_factor(active_dataset(state), variables,
                                         name = name, labels = labels),
        activate_dataset = active_dataset(state),
        memory = list(variables = variables, name = name,
                      levels = levels, labels = input[[ns("labels")]] %||% "")
      )
    }
  )
}

character_to_factor_dialog <- function() {
  id <- "characterToFactor"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(variables = NULL, name = "<same as variables>")

  dialog_spec(
    id = id, title = tr("Convert Character Variables to Factors"), help = "factor",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        var_input(ns("variables"), tr("Variables (pick one or more)"),
                  names(dataset(state))[vapply(dataset(state), is.character, logical(1))],
                  selected = m$variables, multiple = TRUE),
        entry_input(ns("name"), tr("New variable name or prefix:"), m$name)
      )
    },
    on_ok = function(input, state) {
      variables <- input[[ns("variables")]]
      if (length(variables) == 0L) {
        return(list(error = tr("You must select a variable.")))
      }
      name <- trim_blanks(input[[ns("name")]] %||% "")
      same <- !nzchar(name) || identical(name, "<same as variables>")
      targets <- if (same) variables else if (length(variables) == 1L) name else paste0(name, variables)
      if (any(!vapply(targets, is_valid_name, logical(1)))) {
        return(list(error = tr("One or more new variable names are not valid.")))
      }
      list(
        commands = cmd_character_to_factor(
          active_dataset(state), variables, name = name
        ),
        activate_dataset = active_dataset(state),
        memory = list(variables = variables,
                      name = trim_blanks(input[[ns("name")]] %||% ""))
      )
    }
  )
}

bin_variable_dialog <- function() {
  id <- "binVariable"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(variable = NULL, new = "variable", bins = 3L,
                   method = "intervals", levels = "numbers", labels = "")

  dialog_spec(
    id = id, title = tr("Bin a Numeric Variable"), help = "binVariable",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        var_input(ns("variable"), tr("Variable to bin (pick one)"),
                  numeric_variables(state), selected = m$variable),
        entry_input(ns("new"), tr("New variable name"), m$new),
        slider_input(ns("bins"), tr("Number of bins"), 2, 20, m$bins),
        radio_input(ns("method"), tr("Binning Method"),
                    c("Equal-width bins" = "intervals",
                      "Equal-count bins" = "proportions",
                      "Natural breaks" = "natural"), m$method),
        radio_input(ns("levels"), tr("Level Names"),
                    c("Numbers" = "numbers", "Ranges" = "ranges",
                      "Specify names" = "specify"), m$levels),
        entry_input(ns("labels"), tr("Level names (comma separated):"), m$labels)
      )
    },
    on_ok = function(input, state) {
      variable <- input[[ns("variable")]] %||% ""
      if (!nzchar(variable)) {
        return(list(error = tr("You must select a variable.")))
      }
      new <- trim_blanks(input[[ns("new")]] %||% "")
      if (!is_valid_name(new)) {
        return(list(error = sprintf(tr('"%s" is not a valid name.'), new)))
      }
      levels <- input[[ns("levels")]] %||% "numbers"
      labels <- switch(levels,
                       numbers = NULL,
                       ranges = "ranges",
                       specify = {
                         text <- trim_blanks(input[[ns("labels")]] %||% "")
                         if (!nzchar(text)) {
                           return(list(error = tr("A level name is empty.")))
                         }
                         trimws(strsplit(text, ",", fixed = TRUE)[[1L]])
                       })
      list(
        commands = cmd_bin_variable(
          active_dataset(state), variable, new,
          bins = input[[ns("bins")]] %||% 3,
          method = input[[ns("method")]] %||% "intervals",
          labels = labels
        ),
        activate_dataset = active_dataset(state),
        memory = list(variable = variable, new = new,
                      bins = input[[ns("bins")]] %||% 3,
                      method = input[[ns("method")]] %||% "intervals",
                      levels = levels, labels = input[[ns("labels")]] %||% "")
      )
    }
  )
}

reorder_factor_dialog <- function() {
  id <- "reorderFactor"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(variable = NULL, name = "", levels = "", ordered = FALSE)

  dialog_spec(
    id = id, title = tr("Reorder Factor Levels"), help = "factor",
    ui = function(state, memory) {
      factors <- factor_variables(state)
      variable <- memory$variable %||% factors[[1L]] %||% ""
      current_levels <- if (nzchar(variable) && variable %in% names(dataset(state))) {
        levels(as.factor(dataset(state)[[variable]]))
      } else {
        character()
      }
      m <- utils::modifyList(
        defaults,
        memory %||% list(name = variable,
                         levels = paste(current_levels, collapse = ", "))
      )
      htmltools::tagList(
        var_input(ns("variable"), tr("Factor (pick one)"), factors,
                  selected = variable),
        entry_input(ns("name"), tr("Name for factor"), m$name),
        entry_input(ns("levels"), tr("Levels in the new order (comma separated):"),
                    m$levels),
        checkbox_input(ns("ordered"), tr("Make ordered factor"), m$ordered)
      )
    },
    on_ok = function(input, state) {
      variable <- input[[ns("variable")]] %||% ""
      if (!nzchar(variable)) {
        return(list(error = tr("You must select a variable.")))
      }
      name <- trim_blanks(input[[ns("name")]] %||% "")
      if (!nzchar(name)) name <- variable
      if (!is_valid_name(name)) {
        return(list(error = sprintf(tr('"%s" is not a valid name.'), name)))
      }
      text <- trim_blanks(input[[ns("levels")]] %||% "")
      levels <- trimws(strsplit(text, ",", fixed = TRUE)[[1L]])
      if (length(levels) == 0L || any(!nzchar(levels))) {
        return(list(error = tr("You must specify the factor levels.")))
      }
      list(
        commands = cmd_reorder_factor(
          active_dataset(state), variable, name, levels,
          ordered = isTRUE(input[[ns("ordered")]])
        ),
        activate_dataset = active_dataset(state),
        memory = list(variable = variable, name = name,
                      levels = text, ordered = isTRUE(input[[ns("ordered")]]))
      )
    }
  )
}

standardize_dialog <- function() {
  id <- "standardize"
  ns <- function(x) paste0(id, "_", x)

  dialog_spec(
    id = id, title = tr("Standardize Variables"), help = "scale",
    ui = function(state, memory) {
      var_input(ns("variables"), tr("Variables (pick one or more)"),
                numeric_variables(state), selected = memory$variables,
                multiple = TRUE)
    },
    on_ok = function(input, state) {
      variables <- input[[ns("variables")]]
      if (length(variables) == 0L) {
        return(list(error = tr("You must select one or more variables.")))
      }
      list(
        commands = cmd_standardize(active_dataset(state), variables),
        activate_dataset = active_dataset(state),
        memory = list(variables = variables)
      )
    }
  )
}

# Active data set operations ------------------------------------------------

export_dataset_dialog <- function() {
  id <- "exportDataSet"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(file = "", sep = "commas", colnames = TRUE,
                   rownames = FALSE, quotes = TRUE, na = "NA")

  dialog_spec(
    id = id, title = tr("Export Active Data Set"), help = "write.table",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        file_input(ns("file"), tr("File:"), m$file,
                   filetypes = c("csv", "txt", "dat", "CSV", "TXT", "DAT")),
        radio_input(ns("sep"), tr("Field Separator"),
                    c("Commas [,]" = "commas", "Spaces" = "spaces",
                      "Tabs" = "tabs", "Semicolons [;]" = "semicolons"),
                    m$sep),
        checkbox_input(ns("colnames"), tr("Write variable names"), m$colnames),
        checkbox_input(ns("rownames"), tr("Write row names"), m$rownames),
        checkbox_input(ns("quotes"), tr("Quotes around character values"),
                       m$quotes),
        entry_input(ns("na"), tr("Missing values:"), m$na)
      )
    },
    observers = function(input, output, session, state, refresh) {
      roots <- c(home = "~", wd = getwd(), root = "/")
      file_input_observers(
        input, session, ns("file"), roots,
        guard = function() identical(state$current_dialog, id),
        filetypes = c("csv", "txt", "dat", "CSV", "TXT", "DAT")
      )
    },
    on_ok = function(input, state) {
      file <- trim_blanks(input[[ns("file")]] %||% "")
      if (!nzchar(file)) return(list(error = tr("You must select a file.")))
      sep <- switch(input[[ns("sep")]] %||% "commas",
                    commas = ",", spaces = " ", tabs = "\\t",
                    semicolons = ";", ",")
      list(
        commands = cmd_export_data(
          active_dataset(state), file, sep = sep,
          col_names = isTRUE(input[[ns("colnames")]]),
          row_names = isTRUE(input[[ns("rownames")]]),
          quote = isTRUE(input[[ns("quotes")]]),
          na = input[[ns("na")]] %||% "NA"
        ),
        memory = list(
          file = file, sep = input[[ns("sep")]] %||% "commas",
          colnames = isTRUE(input[[ns("colnames")]]),
          rownames = isTRUE(input[[ns("rownames")]]),
          quotes = isTRUE(input[[ns("quotes")]]),
          na = input[[ns("na")]] %||% "NA"
        )
      )
    }
  )
}

filter_na_dialog <- function() {
  id <- "filterNA"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(all = TRUE, variables = NULL,
                   name = "<same as active data set>")

  dialog_spec(
    id = id, title = tr("Remove Missing Data"), help = "na.omit",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        checkbox_input(ns("all"), tr("Include all variables"), m$all),
        var_input(ns("variables"), tr("Variables (select one or more)"),
                  variables(state), selected = m$variables, multiple = TRUE),
        entry_input(ns("name"), tr("Name for new data set"), m$name)
      )
    },
    on_ok = function(input, state) {
      name <- trim_blanks(input[[ns("name")]] %||% "")
      if (identical(name, "<same as active data set>")) {
        name <- active_dataset(state)
      }
      error <- data_validate_name(name)
      if (!is.null(error)) return(list(error = error))
      variables <- NULL
      if (!isTRUE(input[[ns("all")]])) {
        variables <- input[[ns("variables")]]
        if (length(variables) == 0L) {
          return(list(error = tr("No variables were selected.")))
        }
      }
      list(
        commands = cmd_filter_na(active_dataset(state), name, variables),
        activate_dataset = name,
        memory = list(all = isTRUE(input[[ns("all")]]),
                      variables = variables,
                      name = input[[ns("name")]] %||% "<same as active data set>")
      )
    }
  )
}

subset_dataset_dialog <- function() {
  id <- "subsetDataSet"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(all = TRUE, variables = NULL, cases = "",
                   name = "<same as active data set>")

  dialog_spec(
    id = id, title = tr("Subset Data Set"), help = "subset",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        checkbox_input(ns("all"), tr("Include all variables"), m$all),
        var_input(ns("variables"), tr("Variables (select one or more)"),
                  variables(state), selected = m$variables, multiple = TRUE),
        subset_input(ns("cases"), tr("Subset expression:"), m$cases),
        entry_input(ns("name"), tr("Name for new data set"), m$name)
      )
    },
    on_ok = function(input, state) {
      name <- trim_blanks(input[[ns("name")]] %||% "")
      if (identical(name, "<same as active data set>")) {
        name <- active_dataset(state)
      }
      error <- data_validate_name(name)
      if (!is.null(error)) return(list(error = error))
      variables <- NULL
      if (!isTRUE(input[[ns("all")]])) {
        variables <- input[[ns("variables")]]
        if (length(variables) == 0L) {
          return(list(error = tr("No variables were selected.")))
        }
      }
      cases <- trim_blanks(input[[ns("cases")]] %||% "")
      if (is.null(variables) && !nzchar(cases)) {
        return(list(error = tr("New data set same as active data set.")))
      }
      list(
        commands = cmd_subset_dataset(active_dataset(state), name,
                                      variables, cases),
        activate_dataset = name,
        memory = list(all = isTRUE(input[[ns("all")]]),
                      variables = variables, cases = cases,
                      name = input[[ns("name")]] %||% "<same as active data set>")
      )
    }
  )
}

set_case_names_dialog <- function() {
  id <- "setCaseNames"
  ns <- function(x) paste0(id, "_", x)

  dialog_spec(
    id = id, title = tr("Set Case Names"), help = "row.names",
    ui = function(state, memory) {
      var_input(ns("variable"), tr("Select variable containing row names"),
                variables(state), selected = memory$variable)
    },
    on_ok = function(input, state) {
      variable <- input[[ns("variable")]] %||% ""
      if (!nzchar(variable)) {
        return(list(error = tr("You must select a variable.")))
      }
      values <- dataset(state)[[variable]]
      if (anyDuplicated(values)) {
        return(list(error = tr("Case names must be unique.")))
      }
      list(
        commands = cmd_set_case_names(active_dataset(state), variable),
        activate_dataset = active_dataset(state),
        memory = list(variable = variable)
      )
    }
  )
}

rename_variables_dialog <- function() {
  id <- "renameVariables"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(variables = NULL, names = "")

  dialog_spec(
    id = id, title = tr("Rename Variables"), help = "names",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        var_input(ns("variables"), tr("Variables (pick one or more)"),
                  variables(state), selected = m$variables, multiple = TRUE),
        entry_input(ns("names"), tr("New names (comma separated):"), m$names)
      )
    },
    on_ok = function(input, state) {
      variables <- input[[ns("variables")]]
      if (length(variables) == 0L) {
        return(list(error = tr("No variables selected.")))
      }
      text <- trim_blanks(input[[ns("names")]] %||% "")
      new <- trimws(strsplit(text, ",", fixed = TRUE)[[1L]])
      if (length(new) != length(variables)) {
        return(list(error = tr("The number of new names must match the number of variables.")))
      }
      if (any(!vapply(new, is_valid_name, logical(1)))) {
        return(list(error = tr("One or more variable names are not valid.")))
      }
      positions <- match(variables, names(dataset(state)))
      list(
        commands = cmd_rename_variables_at(active_dataset(state), positions, new),
        activate_dataset = active_dataset(state),
        memory = list(variables = variables, names = text)
      )
    }
  )
}

set_contrasts_dialog <- function() {
  id <- "setContrasts"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(variable = NULL, contrasts = "treatment")

  dialog_spec(
    id = id, title = tr("Set Contrasts for Factor"), help = "contrasts",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        var_input(ns("variable"), tr("Factor (pick one)"),
                  names(dataset(state))[vapply(dataset(state), is.factor, logical(1))],
                  selected = m$variable),
        radio_input(
          ns("contrasts"), tr("Contrasts"),
          c("Treatment (dummy) contrasts" = "treatment",
            "Sum (deviation) contrasts" = "sum",
            "Helmert contrasts" = "helmert",
            "Polynomial contrasts" = "poly"),
          m$contrasts
        )
      )
    },
    on_ok = function(input, state) {
      variable <- input[[ns("variable")]] %||% ""
      if (!nzchar(variable)) {
        return(list(error = tr("You must select a variable.")))
      }
      contrasts <- input[[ns("contrasts")]] %||% "treatment"
      list(
        commands = cmd_set_contrasts(active_dataset(state), variable, contrasts),
        activate_dataset = active_dataset(state),
        memory = list(variable = variable, contrasts = contrasts)
      )
    }
  )
}

stack_dialog <- function() {
  id <- "Stack"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(variables = NULL, dataset = "StackedData",
                   variable = "variable", factor = "factor")

  dialog_spec(
    id = id, title = tr("Stack Variables"), help = "stack",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        var_input(ns("variables"), tr("Variables (pick two or more)"),
                  numeric_variables(state), selected = m$variables,
                  multiple = TRUE),
        entry_input(ns("dataset"), tr("Name for stacked data set:"), m$dataset),
        entry_input(ns("variable"), tr("Name for variable:"), m$variable),
        entry_input(ns("factor"), tr("Name for factor:"), m$factor)
      )
    },
    on_ok = function(input, state) {
      variables <- input[[ns("variables")]]
      if (length(variables) < 2L) {
        return(list(error = tr("You must select at least two variables.")))
      }
      dataset <- trim_blanks(input[[ns("dataset")]] %||% "")
      error <- data_validate_name(dataset)
      if (!is.null(error)) return(list(error = error))
      list(
        commands = cmd_stack(
          active_dataset(state), variables, dataset,
          variable_name = trim_blanks(input[[ns("variable")]] %||% "variable"),
          factor_name = trim_blanks(input[[ns("factor")]] %||% "factor")
        ),
        activate_dataset = dataset,
        memory = list(variables = variables, dataset = dataset,
                      variable = input[[ns("variable")]] %||% "variable",
                      factor = input[[ns("factor")]] %||% "factor")
      )
    }
  )
}

remove_rows_dialog <- function() {
  id <- "RemoveRows"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(cases = "", name = "<same as active data set>")

  dialog_spec(
    id = id, title = tr("Remove Rows from Active Data Set"), help = "RemoveRows",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        entry_input(ns("cases"), tr("Indices or names of row(s) to remove"),
                    m$cases),
        entry_input(ns("name"), tr("Name for new data set"), m$name)
      )
    },
    on_ok = function(input, state) {
      name <- trim_blanks(input[[ns("name")]] %||% "")
      if (identical(name, "<same as active data set>")) {
        name <- active_dataset(state)
      }
      error <- data_validate_name(name)
      if (!is.null(error)) return(list(error = error))
      cases <- trim_blanks(input[[ns("cases")]] %||% "")
      if (!nzchar(cases)) return(list(error = tr("No rows to remove")))
      subset <- cases_subset(active_dataset(state), dataset(state), cases)
      if (!is.null(subset$error)) return(list(error = subset$error))
      list(
        commands = cmd_remove_rows(active_dataset(state), name, subset$value),
        activate_dataset = name,
        memory = list(cases = cases, name = input[[ns("name")]] %||% "<same as active data set>")
      )
    }
  )
}

select_rows_dialog <- function() {
  id <- "SelectRows"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(cases = "", name = "<same as active data set>")

  dialog_spec(
    id = id, title = tr("Select Rows from Active Data Set"), help = "SelectRows",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        entry_input(ns("cases"), tr("Indices or names of row(s) to select"),
                    m$cases),
        entry_input(ns("name"), tr("Name for new data set"), m$name)
      )
    },
    on_ok = function(input, state) {
      name <- trim_blanks(input[[ns("name")]] %||% "")
      if (identical(name, "<same as active data set>")) {
        name <- active_dataset(state)
      }
      error <- data_validate_name(name)
      if (!is.null(error)) return(list(error = error))
      cases <- trim_blanks(input[[ns("cases")]] %||% "")
      if (!nzchar(cases)) return(list(error = tr("No rows to select")))
      subset <- cases_select(active_dataset(state), dataset(state), cases)
      if (!is.null(subset$error)) return(list(error = subset$error))
      list(
        commands = cmd_select_rows(active_dataset(state), name,
                                   subset$value, ncol(dataset(state))),
        activate_dataset = name,
        memory = list(cases = cases, name = input[[ns("name")]] %||% "<same as active data set>")
      )
    }
  )
}

merge_datasets_dialog <- function() {
  id <- "mergeDataSets"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(dataset = "MergedDataset", first = NULL, second = NULL,
                   direction = "rows", common = FALSE)

  dialog_spec(
    id = id, title = tr("Merge Data Sets"), help = "mergeRows",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      choices <- list_data_sets(state)
      htmltools::tagList(
        entry_input(ns("dataset"), tr("Name for merged data set:"), m$dataset),
        combo_input(ns("first"), tr("First Data Set (pick one)"),
                    stats::setNames(choices, choices), selected = m$first),
        combo_input(ns("second"), tr("Second Data Set (pick one)"),
                    stats::setNames(choices, choices), selected = m$second),
        radio_input(ns("direction"), tr("Direction of Merge"),
                    c("Merge rows" = "rows", "Merge columns" = "columns"),
                    m$direction),
        checkbox_input(ns("common"), tr("Merge only common rows or columns"),
                       m$common)
      )
    },
    on_ok = function(input, state) {
      dataset <- trim_blanks(input[[ns("dataset")]] %||% "")
      error <- data_validate_name(dataset)
      if (!is.null(error)) return(list(error = error))
      first <- input[[ns("first")]] %||% ""
      second <- input[[ns("second")]] %||% ""
      if (!nzchar(first) || !nzchar(second)) {
        return(list(error = tr("You must select a data set.")))
      }
      if (identical(first, second)) {
        return(list(error = tr("You cannot merge a data set with itself.")))
      }
      list(
        commands = cmd_merge(first, second, dataset,
                             direction = input[[ns("direction")]] %||% "rows",
                             common = isTRUE(input[[ns("common")]])),
        activate_dataset = dataset,
        memory = list(dataset = dataset, first = first, second = second,
                      direction = input[[ns("direction")]] %||% "rows",
                      common = isTRUE(input[[ns("common")]]))
      )
    }
  )
}

aggregate_dialog <- function() {
  id <- "Aggregate"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(dataset = "AggregatedData", variables = NULL, by = NULL,
                   statistic = "mean", other = "")

  dialog_spec(
    id = id, title = tr("Aggregate Observations"), help = "aggregate",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        entry_input(ns("dataset"), tr("Name for aggregated data set:"),
                    m$dataset),
        var_input(ns("variables"), tr("Variables to aggregate (pick one or more)"),
                  variables(state), selected = m$variables, multiple = TRUE),
        var_input(ns("by"), tr("Aggregate by (pick one or more)"),
                  factor_variables(state), selected = m$by, multiple = TRUE),
        radio_input(ns("statistic"), tr("Statistic"),
                    c("Mean" = "mean", "Sum" = "sum", "Other" = "other"),
                    m$statistic),
        entry_input(ns("other"), tr("Other statistic:"), m$other)
      )
    },
    on_ok = function(input, state) {
      dataset <- trim_blanks(input[[ns("dataset")]] %||% "")
      error <- data_validate_name(dataset)
      if (!is.null(error)) return(list(error = error))
      variables <- input[[ns("variables")]]
      by <- input[[ns("by")]]
      if (length(variables) == 0L) {
        return(list(error = tr("You must select at least one variable to aggregate.")))
      }
      if (length(by) == 0L) {
        return(list(error = tr("You must select at least one variable to aggregate by.")))
      }
      if (any(by %in% variables)) {
        return(list(error = tr("Variables to aggregate and those to aggregate by must be different.")))
      }
      statistic <- input[[ns("statistic")]] %||% "mean"
      if (identical(statistic, "other")) {
        statistic <- trim_blanks(input[[ns("other")]] %||% "")
        if (!nzchar(statistic)) {
          return(list(error = tr("You must specify a statistic.")))
        }
      }
      list(
        commands = cmd_aggregate(active_dataset(state), dataset,
                                 variables, by, statistic),
        activate_dataset = dataset,
        memory = list(dataset = dataset, variables = variables, by = by,
                      statistic = input[[ns("statistic")]] %||% "mean",
                      other = input[[ns("other")]] %||% "")
      )
    }
  )
}

drop_levels_dialog <- function() {
  id <- "dropUnusedFactorLevels"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(all = TRUE, variables = NULL)

  dialog_spec(
    id = id, title = tr("Drop Unused Factor Levels"), help = "droplevels",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        checkbox_input(ns("all"), tr("All factor variables"), m$all),
        var_input(ns("variables"), tr("Factors (select one or more)"),
                  factor_variables(state), selected = m$variables,
                  multiple = TRUE)
      )
    },
    on_ok = function(input, state) {
      variables <- NULL
      if (!isTRUE(input[[ns("all")]])) {
        variables <- input[[ns("variables")]]
        if (length(variables) == 0L) {
          return(list(error = tr("No variables were selected.")))
        }
      }
      list(
        commands = cmd_drop_levels(active_dataset(state), variables),
        activate_dataset = active_dataset(state),
        memory = list(all = isTRUE(input[[ns("all")]]), variables = variables)
      )
    }
  )
}

sort_dataset_dialog <- function() {
  id <- "sortDataSet"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(keys = NULL, decreasing = FALSE,
                   name = "<same as active data set>")

  dialog_spec(
    id = id, title = tr("Sort Active Data Set"), help = "order",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      htmltools::tagList(
        var_input(ns("keys"), tr("Sort keys (pick one or more)"),
                  variables(state), selected = m$keys, multiple = TRUE),
        checkbox_input(ns("decreasing"), tr("Decreasing order"), m$decreasing),
        entry_input(ns("name"), tr("Name for new data set"), m$name)
      )
    },
    on_ok = function(input, state) {
      keys <- input[[ns("keys")]]
      if (length(keys) == 0L) {
        return(list(error = tr("You must select at least one sort key.")))
      }
      name <- trim_blanks(input[[ns("name")]] %||% "")
      if (identical(name, "<same as active data set>")) {
        name <- active_dataset(state)
      }
      error <- data_validate_name(name)
      if (!is.null(error)) return(list(error = error))
      list(
        commands = cmd_sort(active_dataset(state), name, keys,
                            isTRUE(input[[ns("decreasing")]])),
        activate_dataset = name,
        memory = list(keys = keys, decreasing = isTRUE(input[[ns("decreasing")]]),
                      name = input[[ns("name")]] %||% "<same as active data set>")
      )
    }
  )
}

# Reshape -------------------------------------------------------------------

reshape_long2wide_dialog <- function() {
  id <- "reshapeLong2Wide"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(id = NULL, within = NULL, varying = NULL, ignore = NULL,
                   name = "")

  dialog_spec(
    id = id, title = tr("Reshape Data Set from Long to Wide Format"),
    help = "reshapeL2W",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      if (!nzchar(m$name)) m$name <- data_default_name(state, "Wide")
      htmltools::tagList(
        var_input(ns("id"), tr("ID variable"), variables(state),
                  selected = m$id),
        var_input(ns("within"), tr("Within-subject factor(s)"),
                  variables(state), selected = m$within, multiple = TRUE),
        var_input(ns("varying"), tr("Occasion-varying variables"),
                  variables(state), selected = m$varying, multiple = TRUE),
        var_input(ns("ignore"), tr("Variables to ignore"),
                  variables(state), selected = m$ignore, multiple = TRUE),
        entry_input(ns("name"), tr("Name for wide data set:"), m$name)
      )
    },
    on_ok = function(input, state) {
      id_var <- input[[ns("id")]] %||% ""
      within <- input[[ns("within")]]
      varying <- input[[ns("varying")]]
      name <- trim_blanks(input[[ns("name")]] %||% "")
      if (!nzchar(id_var)) return(list(error = tr("You must select an ID variable.")))
      if (length(within) == 0L) {
        return(list(error = tr("You must select one or more within-subjects factors.")))
      }
      if (length(varying) == 0L) {
        return(list(error = tr("You must select one or more occasion-varying variables.")))
      }
      error <- data_validate_name(name)
      if (!is.null(error)) return(list(error = error))
      list(
        commands = cmd_reshape_long2wide(
          active_dataset(state), name, id_var, within, varying,
          ignore = input[[ns("ignore")]]
        ),
        activate_dataset = name,
        memory = list(id = id_var, within = within, varying = varying,
                      ignore = input[[ns("ignore")]], name = name)
      )
    }
  )
}

reshape_wide2long_dialog <- function() {
  id <- "reshapeWide2Long"
  ns <- function(x) paste0(id, "_", x)
  defaults <- list(within = "time", responses = NULL, ignore = NULL,
                   name = "", id = "id")

  dialog_spec(
    id = id, title = tr("Reshape Data Set from Wide to Long Format"),
    help = "reshapeW2L",
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())
      if (!nzchar(m$name)) m$name <- data_default_name(state, "Long")
      htmltools::tagList(
        entry_input(ns("within"), tr("Within-subject factor name:"), m$within),
        var_input(ns("responses"), tr("Response variables (wide columns)"),
                  variables(state), selected = m$responses, multiple = TRUE),
        var_input(ns("ignore"), tr("Variables to ignore"),
                  variables(state), selected = m$ignore, multiple = TRUE),
        entry_input(ns("id"), tr("ID variable name:"), m$id),
        entry_input(ns("name"), tr("Name for long data set:"), m$name)
      )
    },
    on_ok = function(input, state) {
      within <- trim_blanks(input[[ns("within")]] %||% "")
      responses <- input[[ns("responses")]]
      name <- trim_blanks(input[[ns("name")]] %||% "")
      id_var <- trim_blanks(input[[ns("id")]] %||% "id")
      if (!is_valid_name(within)) {
        return(list(error = sprintf(tr('"%s" is not a valid name.'), within)))
      }
      if (length(responses) < 2L) {
        return(list(error = tr("at least 2 responses must be specified")))
      }
      error <- data_validate_name(name)
      if (!is.null(error)) return(list(error = error))
      list(
        commands = cmd_reshape_wide2long(
          active_dataset(state), name, within, responses,
          ignore = input[[ns("ignore")]], id = id_var
        ),
        activate_dataset = name,
        memory = list(within = within, responses = responses,
                      ignore = input[[ns("ignore")]], name = name,
                      id = id_var)
      )
    }
  )
}

# Refresh the dialog catalog with the Phase 2 dialogs.
phase2_dialogs <- function() {
  list(
    newDataSet = new_dataset_dialog(),
    selectActiveDataSet = select_active_dataset_dialog(),
    readDataFromPackage = read_data_from_package_dialog(),
    importExcel = import_excel_dialog(),
    importSPSS = import_spss_dialog(),
    importSTATA = import_stata_dialog(),
    importSAS = import_sas_dialog(),
    importSASb7dat = import_sas_b7dat_dialog(),
    importMinitab = import_minitab_dialog(),
    Compute = compute_dialog(),
    deleteVariable = delete_variables_dialog(),
    RecodeDialog = recode_dialog(),
    numericToFactor = numeric_to_factor_dialog(),
    characterToFactor = character_to_factor_dialog(),
    binVariable = bin_variable_dialog(),
    reorderFactor = reorder_factor_dialog(),
    standardize = standardize_dialog(),
    exportDataSet = export_dataset_dialog(),
    filterNA = filter_na_dialog(),
    subsetDataSet = subset_dataset_dialog(),
    setCaseNames = set_case_names_dialog(),
    renameVariables = rename_variables_dialog(),
    setContrasts = set_contrasts_dialog(),
    Stack = stack_dialog(),
    RemoveRows = remove_rows_dialog(),
    SelectRows = select_rows_dialog(),
    mergeDataSets = merge_datasets_dialog(),
    Aggregate = aggregate_dialog(),
    dropUnusedFactorLevels = drop_levels_dialog(),
    sortDataSet = sort_dataset_dialog(),
    reshapeLong2Wide = reshape_long2wide_dialog(),
    reshapeWide2Long = reshape_wide2long_dialog()
  )
}
