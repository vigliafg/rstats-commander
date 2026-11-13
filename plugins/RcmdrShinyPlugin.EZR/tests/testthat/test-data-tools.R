test_that("data builders generate the expected commands", {
  expect_equal(ezr_data_copy("D", "E"), "E <- D")
  expect_equal(ezr_data_rename("D", "E"),
               c("E <- D", "rm(D)"))
  expect_match(ezr_data_merge("a", "b"), "^a\\.merged <- merge\\(a, b\\)$")
  expect_match(ezr_data_merge("a", "b", "id"), 'by = "id"')
  expect_equal(ezr_data_load_workspace("w.RData"), 'load("w.RData")')
  expect_equal(
    ezr_data_read_cp932("d.csv", "D"),
    'D <- read.csv("d.csv", fileEncoding = "CP932")'
  )
  expect_match(
    ezr_data_export_stata("D", "D.dta"),
    'foreign::write.dta\\(D, "D.dta"\\)'
  )
})

test_that("binning uses left-closed intervals", {
  expect_equal(
    ezr_data_bin("D", "age", "ageGroup", "40, 65"),
    paste0('D$ageGroup <- cut(D$age, breaks = c(-Inf, 40, 65, Inf), ',
           'right = FALSE)')
  )
  expect_error(ezr_data_bin("D", "age", "g", "abc"), "at least one threshold")
})

test_that("log and factor conversion builders are explicit", {
  expect_equal(ezr_data_log("D", "x"), "D$x <- log(D$x)")
  expect_equal(ezr_data_log("D", "x", "logx"), "D$logx <- log(D$x)")
  expect_equal(
    ezr_data_factor_to_numeric("D", c("a", "b")),
    c("D$a <- as.numeric(as.character(D$a))",
      "D$b <- as.numeric(as.character(D$b))")
  )
})

test_that("dataset fields list data frames, not variables", {
  RcmdrShiny::unload_plugins()
  on.exit(RcmdrShiny::unload_plugins(), add = TRUE)
  rcmdrshiny_plugin()

  state <- RcmdrShiny::AppState(env = new.env())
  assign("one", data.frame(x = 1:3), envir = state$env)
  assign("two", data.frame(x = 1:3), envir = state$env)
  assign("model", lm(x ~ 1, data = data.frame(x = 1:3)), envir = state$env)

  spec <- RcmdrShiny::get_dialog("StatMedMergeDatasets")
  html <- as.character(spec$ui(state, NULL))
  expect_match(html, "one")
  expect_match(html, "two")
  expect_false(grepl("model", html))
})

test_that("the EZR data dialogs are registered and produce commands", {
  RcmdrShiny::unload_plugins()
  on.exit(RcmdrShiny::unload_plugins(), add = TRUE)
  rcmdrshiny_plugin()

  ids <- c("StatMedCopyDataset", "StatMedRenameDataset", "StatMedMergeDatasets",
           "StatMedLoadWorkspace", "StatMedLoadCP932DataSet",
           "StatMedRenewDataSet", "StatMedExportStata", "StatMedNewVar",
           "StatMedNewVar2", "StatMedLog", "StatMedFactorToNumeric")
  for (id in ids) {
    expect_false(is.null(RcmdrShiny::get_dialog(id)), info = id)
  }
  expect_true(all(ids %in% RcmdrShiny:::implemented_commands()))

  state <- RcmdrShiny::AppState(env = new.env())
  assign("D", data.frame(age = c(20, 50, 70), score = factor(c("1", "2", "3"))),
         envir = state$env)
  RcmdrShiny::active_dataset(state, "D")

  spec <- RcmdrShiny::get_dialog("StatMedNewVar")
  result <- spec$on_ok(list(StatMedNewVar_variable = "age",
                            StatMedNewVar_name = "ageGroup",
                            StatMedNewVar_thresholds = "40"), state)
  expect_null(result$error)
  expect_match(result$commands, "cut\\(D\\$age")
  expect_false(isTRUE(result$plot))
})
