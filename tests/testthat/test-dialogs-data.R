phase2_state <- function() {
  env <- new.env()
  env$D <- data.frame(
    y = 1:6,
    x = c(2, 4, 6, 8, 10, 12),
    g = factor(rep(c("a", "b"), 3)),
    s = letters[1:6],
    stringsAsFactors = FALSE
  )
  env$E <- data.frame(a = 1:6, b = letters[1:6], stringsAsFactors = FALSE)
  state <- AppState(env = env)
  active_dataset(state, "D")
  state
}

phase2_inputs <- function() {
  temp <- function(extension) {
    path <- tempfile(fileext = extension)
    file.create(path)
    path
  }
  list(
    newDataSet = list(newDataSet_name = "N", newDataSet_rows = 5,
                      newDataSet_columns = 2),
    selectActiveDataSet = list(selectActiveDataSet_dataset = "E"),
    readDataFromPackage = list(readDataFromPackage_package = "datasets",
                               readDataFromPackage_dataset = "mtcars"),
    importExcel = list(importExcel_dsname = "X", importExcel_file = temp(".xlsx"),
                       importExcel_sheet = "Sheet1", importExcel_header = TRUE,
                       importExcel_rownames = FALSE, importExcel_na = "",
                       importExcel_stringsAsFactors = FALSE),
    importSPSS = list(importSPSS_dsname = "X", importSPSS_file = temp(".sav"),
                      importSPSS_rownames = FALSE,
                      importSPSS_stringsAsFactors = TRUE,
                      importSPSS_tolower = TRUE),
    importSTATA = list(importSTATA_dsname = "X", importSTATA_file = temp(".dta"),
                       importSTATA_convert_dates = TRUE,
                       importSTATA_stringsAsFactors = TRUE,
                       importSTATA_rownames = FALSE),
    importSAS = list(importSAS_dsname = "X", importSAS_file = temp(".xpt")),
    importSASb7dat = list(importSASb7dat_dsname = "X",
                          importSASb7dat_file = temp(".sas7bdat"),
                          importSASb7dat_stringsAsFactors = TRUE,
                          importSASb7dat_rownames = FALSE),
    importMinitab = list(importMinitab_dsname = "X",
                         importMinitab_file = temp(".mtp")),
    Compute = list(Compute_name = "z", Compute_expression = "y + x"),
    deleteVariable = list(deleteVariable_variables = "s"),
    RecodeDialog = list(
      RecodeDialog_variables = "y", RecodeDialog_name = "ry",
      RecodeDialog_directives = "1=10;2=20", RecodeDialog_asFactor = FALSE,
      RecodeDialog_to.value = "=", RecodeDialog_interval = ":",
      RecodeDialog_separator = ";"
    ),
    numericToFactor = list(numericToFactor_variables = "y",
                           numericToFactor_levels = "numbers",
                           numericToFactor_labels = "",
                           numericToFactor_name = "<same as variables>"),
    characterToFactor = list(characterToFactor_variables = "s",
                             characterToFactor_name = "fs"),
    binVariable = list(binVariable_variable = "x", binVariable_new = "bx",
                       binVariable_bins = 3,
                       binVariable_method = "intervals",
                       binVariable_levels = "numbers",
                       binVariable_labels = ""),
    reorderFactor = list(reorderFactor_variable = "g",
                         reorderFactor_name = "g2",
                         reorderFactor_levels = "b, a",
                         reorderFactor_ordered = FALSE),
    standardize = list(standardize_variables = c("y", "x")),
    exportDataSet = list(exportDataSet_file = tempfile(fileext = ".csv"),
                         exportDataSet_sep = "commas",
                         exportDataSet_colnames = TRUE,
                         exportDataSet_rownames = FALSE,
                         exportDataSet_quotes = TRUE,
                         exportDataSet_na = "NA"),
    filterNA = list(filterNA_all = TRUE, filterNA_variables = NULL,
                    filterNA_name = "<same as active data set>"),
    subsetDataSet = list(subsetDataSet_all = FALSE,
                         subsetDataSet_variables = c("y", "x"),
                         subsetDataSet_cases = "y > 2",
                         subsetDataSet_name = "Dsub"),
    setCaseNames = list(setCaseNames_variable = "s"),
    renameVariables = list(renameVariables_variables = c("y", "x"),
                           renameVariables_names = "yy, xx"),
    setContrasts = list(setContrasts_variable = "g",
                        setContrasts_contrasts = "sum"),
    Stack = list(Stack_variables = c("y", "x"), Stack_dataset = "S",
                 Stack_variable = "value", Stack_factor = "variable"),
    RemoveRows = list(RemoveRows_cases = "1, 2", RemoveRows_name = "D4"),
    SelectRows = list(SelectRows_cases = "1, 3", SelectRows_name = "D5"),
    mergeDataSets = list(mergeDataSets_dataset = "M",
                         mergeDataSets_first = "D",
                         mergeDataSets_second = "E",
                         mergeDataSets_direction = "columns",
                         mergeDataSets_common = FALSE),
    Aggregate = list(Aggregate_dataset = "A",
                     Aggregate_variables = c("y", "x"),
                     Aggregate_by = "g", Aggregate_statistic = "mean",
                     Aggregate_other = ""),
    dropUnusedFactorLevels = list(dropUnusedFactorLevels_all = TRUE,
                                  dropUnusedFactorLevels_variables = NULL),
    sortDataSet = list(sortDataSet_keys = c("g", "y"),
                       sortDataSet_decreasing = FALSE,
                       sortDataSet_name = "D6"),
    reshapeLong2Wide = list(reshapeLong2Wide_id = "s",
                            reshapeLong2Wide_within = "g",
                            reshapeLong2Wide_varying = c("y", "x"),
                            reshapeLong2Wide_ignore = NULL,
                            reshapeLong2Wide_name = "W"),
    reshapeWide2Long = list(reshapeWide2Long_within = "time",
                            reshapeWide2Long_responses = c("y", "x"),
                            reshapeWide2Long_ignore = NULL,
                            reshapeWide2Long_id = "s",
                            reshapeWide2Long_name = "L")
  )
}

test_that("every Phase 2 dialog validates and returns a result", {
  inputs <- phase2_inputs()

  for (id in names(inputs)) {
    state <- phase2_state()
    spec <- get_dialog_spec(id)
    expect_false(is.null(spec))

    result <- tryCatch(
      spec$on_ok(inputs[[id]], state),
      error = function(e) list(error = conditionMessage(e))
    )
    expect_null(result$error)
    expect_true(
      length(result$commands %||% character()) > 0L ||
        !is.null(result$activate_dataset)
    )
  }
})

test_that("import dialogs reject missing files and invalid names", {
  state <- phase2_state()
  spec <- get_dialog_spec("importExcel")

  expect_match(
    spec$on_ok(list(importExcel_dsname = "X",
                    importExcel_file = "/does/not/exist.xlsx"),
               state)$error,
    "File not found"
  )
  expect_match(
    spec$on_ok(list(importExcel_dsname = "my data",
                    importExcel_file = tempfile()),
               state)$error,
    "not a valid name"
  )
})

test_that("data dialogs validate their required inputs", {
  state <- phase2_state()

  expect_match(
    get_dialog_spec("Compute")$on_ok(
      list(Compute_name = "1bad", Compute_expression = "y"), state)$error,
    "not a valid name"
  )
  expect_match(
    get_dialog_spec("Compute")$on_ok(
      list(Compute_name = "z", Compute_expression = ""), state)$error,
    "No expression specified"
  )
  expect_match(
    get_dialog_spec("subsetDataSet")$on_ok(
      list(subsetDataSet_all = TRUE, subsetDataSet_variables = NULL,
           subsetDataSet_cases = "", subsetDataSet_name = "X"), state)$error,
    "same as active data set"
  )
  expect_match(
    get_dialog_spec("renameVariables")$on_ok(
      list(renameVariables_variables = c("y", "x"),
           renameVariables_names = "only_one"), state)$error,
    "number of new names"
  )
  expect_match(
    get_dialog_spec("mergeDataSets")$on_ok(
      list(mergeDataSets_dataset = "M", mergeDataSets_first = "D",
           mergeDataSets_second = "D", mergeDataSets_direction = "rows",
           mergeDataSets_common = FALSE), state)$error,
    "itself"
  )
})
