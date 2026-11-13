# Data, variable and import/export tools for EZR ---------------------------
#
# The core already provides the general dialogs; EZR adds clinical shortcuts
# with its own defaults.  Every command is a pure builder so the dialogs stay
# thin and the tests can check the generated code.

ezr_quote <- function(x) paste0('"', gsub('"', '\\\\"', x), '"')

ezr_data_copy <- function(dataset, name) {
  if (!nzchar(name)) stop("The new name is required.")
  if (identical(name, dataset)) stop("The new name must differ from the current one.")
  sprintf("%s <- %s", name, dataset)
}

ezr_data_rename <- function(dataset, name) {
  if (!nzchar(name)) stop("The new name is required.")
  if (identical(name, dataset)) stop("The new name must differ from the current one.")
  c(sprintf("%s <- %s", name, dataset), sprintf("rm(%s)", dataset))
}

ezr_data_merge <- function(first, second, by = "") {
  if (identical(first, second)) stop("Choose two different data sets.")
  if (nzchar(by)) {
    sprintf("%s <- merge(%s, %s, by = %s)", paste0(first, ".merged"),
            first, second, ezr_quote(by))
  } else {
    sprintf("%s <- merge(%s, %s)", paste0(first, ".merged"), first, second)
  }
}

ezr_data_load_workspace <- function(file) {
  if (!nzchar(file)) stop("The workspace file is required.")
  sprintf("load(%s)", ezr_quote(file))
}

ezr_data_read_cp932 <- function(file, name) {
  if (!nzchar(file)) stop("The file name is required.")
  if (!nzchar(name)) stop("The data set name is required.")
  sprintf('%s <- read.csv(%s, fileEncoding = "CP932")', name, ezr_quote(file))
}

ezr_data_export_stata <- function(dataset, file) {
  if (!nzchar(file)) stop("The destination file is required.")
  sprintf("foreign::write.dta(%s, %s)", dataset, ezr_quote(file))
}

ezr_data_bin <- function(dataset, variable, name, thresholds) {
  if (!nzchar(variable)) stop("Choose a numeric variable.")
  if (!nzchar(name)) stop("The new variable name is required.")
  values <- suppressWarnings(as.numeric(trimws(strsplit(
    as.character(thresholds), ",", fixed = TRUE
  )[[1L]])))
  values <- values[!is.na(values)]
  if (length(values) == 0L) stop("Enter at least one threshold.")
  breaks <- paste(c("-Inf", format(values, scientific = FALSE), "Inf"),
                  collapse = ", ")
  sprintf("%s$%s <- cut(%s$%s, breaks = c(%s), right = FALSE)",
          dataset, name, dataset, variable, breaks)
}

ezr_data_log <- function(dataset, variable, name = NULL) {
  if (!nzchar(variable)) stop("Choose a numeric variable.")
  target <- if (is.null(name) || !nzchar(name)) variable else name
  sprintf("%s$%s <- log(%s$%s)", dataset, target, dataset, variable)
}

ezr_data_factor_to_numeric <- function(dataset, variables) {
  variables <- variables[nzchar(variables)]
  if (length(variables) == 0L) stop("Choose at least one variable.")
  vapply(variables, function(variable) {
    sprintf("%s$%s <- as.numeric(as.character(%s$%s))",
            dataset, variable, dataset, variable)
  }, character(1), USE.NAMES = FALSE)
}

ezr_data_dialogs <- function() {
  list(
    StatMedCopyDataset = ezr_dialog(
      "StatMedCopyDataset", "Copy data set",
      list(ee("name", "Name of the copy", "Dataset.copy")),
      function(values, state) {
        ezr_data_copy(RcmdrShiny::active_dataset(state), values$name)
      },
      help_topic = "ezr-data-tools", plot = FALSE,
      activate = function(values, state) values$name
    ),
    StatMedRenameDataset = ezr_dialog(
      "StatMedRenameDataset", "Rename data set",
      list(ee("name", "New name", "Dataset")),
      function(values, state) {
        ezr_data_rename(RcmdrShiny::active_dataset(state), values$name)
      },
      help_topic = "ezr-data-tools", plot = FALSE,
      activate = function(values, state) values$name
    ),
    StatMedMergeDatasets = ezr_dialog(
      "StatMedMergeDatasets", "Merge data sets",
      list(ev("first", "First data set", "dataset", FALSE),
           ev("second", "Second data set", "dataset", FALSE),
           ee("by", "Merge by variable (optional)", "")),
      function(values, state) {
        ezr_data_merge(values$first, values$second,
                       if (is.null(values$by)) "" else values$by)
      },
      help_topic = "ezr-data-tools", plot = FALSE,
      activate = function(values, state) paste0(values$first, ".merged")
    ),
    StatMedLoadWorkspace = ezr_dialog(
      "StatMedLoadWorkspace", "Load work space file",
      list(ee("file", "Workspace file", "workspace.RData")),
      function(values, state) ezr_data_load_workspace(values$file),
      help_topic = "ezr-data-tools", plot = FALSE
    ),
    StatMedLoadCP932DataSet = ezr_dialog(
      "StatMedLoadCP932DataSet", "Load CP932 data set",
      list(ee("file", "CSV file", "data.csv"),
           ee("name", "Data set name", "Dataset")),
      function(values, state) ezr_data_read_cp932(values$file, values$name),
      help_topic = "ezr-data-tools", plot = FALSE,
      activate = function(values, state) values$name
    ),
    StatMedRenewDataSet = ezr_dialog(
      "StatMedRenewDataSet", "Renew active data set",
      list(ee("file", "CSV file to re-read", "data.csv"),
           ee("name", "Data set name", "")),
      function(values, state) {
        name <- values$name
        if (is.null(name) || !nzchar(name)) name <- RcmdrShiny::active_dataset(state)
        ezr_data_read_cp932(values$file, name)
      },
      help_topic = "ezr-data-tools", plot = FALSE,
      activate = function(values, state) {
        name <- values$name
        if (is.null(name) || !nzchar(name)) RcmdrShiny::active_dataset(state) else name
      }
    ),
    StatMedExportStata = ezr_dialog(
      "StatMedExportStata", "Export active data set (Stata)",
      list(ee("file", "Destination file", "Dataset.dta")),
      function(values, state) {
        ezr_data_export_stata(RcmdrShiny::active_dataset(state), values$file)
      },
      help_topic = "ezr-data-tools", plot = FALSE
    ),
    StatMedNewVar = ezr_dialog(
      "StatMedNewVar", "Bin a numeric variable with specified threshold",
      list(ev("variable", "Numeric variable", "numeric", FALSE),
           ee("name", "New variable name", "binned"),
           ee("thresholds", "Thresholds (comma separated)", "0")),
      function(values, state) {
        ezr_data_bin(RcmdrShiny::active_dataset(state), values$variable,
                     values$name, values$thresholds)
      },
      help_topic = "ezr-data-tools", plot = FALSE
    ),
    StatMedNewVar2 = ezr_dialog(
      "StatMedNewVar2", "Bin a numeric variable with specified thresholds",
      list(ev("variable", "Numeric variable", "numeric", FALSE),
           ee("name", "New variable name", "binned"),
           ee("thresholds", "Thresholds (comma separated)", "0, 10")),
      function(values, state) {
        ezr_data_bin(RcmdrShiny::active_dataset(state), values$variable,
                     values$name, values$thresholds)
      },
      help_topic = "ezr-data-tools", plot = FALSE
    ),
    StatMedLog = ezr_dialog(
      "StatMedLog", "Logarithmic transformation",
      list(ev("variable", "Numeric variable", "numeric", FALSE),
           ee("name", "New variable name (optional)", "")),
      function(values, state) {
        ezr_data_log(RcmdrShiny::active_dataset(state), values$variable,
                     if (is.null(values$name)) "" else values$name)
      },
      help_topic = "ezr-data-tools", plot = FALSE
    ),
    StatMedFactorToNumeric = ezr_dialog(
      "StatMedFactorToNumeric",
      "Convert factors or character variables to numeric",
      list(ev("variables", "Variables", "all", TRUE)),
      function(values, state) {
        ezr_data_factor_to_numeric(RcmdrShiny::active_dataset(state),
                                   if (is.null(values$variables)) character() else values$variables)
      },
      help_topic = "ezr-data-tools", plot = FALSE
    )
  )
}
