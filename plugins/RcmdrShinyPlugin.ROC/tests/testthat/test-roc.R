test_that("the plugin registers the ROC menu", {
  RcmdrShiny::unload_plugins()
  on.exit(RcmdrShiny::unload_plugins(), add = TRUE)

  rcmdrshiny_plugin()
  leaves <- RcmdrShiny::menu_leaves(RcmdrShiny::menu_tree())
  expect_true(all(c("fncvpROC", "fncPairedpROC", "fncUnpairedpROC",
                    "fndHosmerLemeshow", "fncLRpROC") %in% leaves$command))
})

test_that("a single ROC command uses pROC and the selected variables", {
  commands <- build_roc_single_commands(
    "mtcars", "mpg", "am",
    list(direction = "auto", na_rm = TRUE, percent = FALSE, auc = TRUE,
         ci_compute = TRUE, ci_level = "0.95", ci_method = "bootstrap",
         ci_boot_n = "2000", plot = FALSE)
  )
  expect_match(commands[[1L]], "pROC::roc\\(am ~ mpg")
  expect_match(commands[[1L]], "data=mtcars")
  expect_match(commands[[1L]], "na.rm=TRUE")
  expect_match(commands[[1L]], "direction='auto'")
  expect_true("remove(roc.obj)" %in% commands)
})

test_that("paired and unpaired comparisons differ in roc.test", {
  options <- list(plot = FALSE, ci_compute = FALSE, ci_plot = FALSE)
  paired <- build_roc_comparison_commands(
    "mtcars", "mpg", "disp", "am", paired = TRUE, options = options
  )
  expect_true(any(grepl("paired=TRUE", paired, fixed = TRUE)))

  unpaired <- build_roc_comparison_commands(
    "mtcars", "mpg", "disp", "am", "vs", paired = FALSE, options = options
  )
  expect_true(any(grepl("paired=FALSE", unpaired, fixed = TRUE)))
  expect_true(any(grepl("roc.obj2 <- pROC::roc\\(vs ~ disp", unpaired)))
})

test_that("plot options are reflected in the command", {
  plot <- build_roc_plot(
    options = list(print_auc = TRUE, auc_polygon = TRUE, grid = TRUE,
                   identity = FALSE, color = "red", lty = "dashed"),
    threshold = "no"
  )
  expect_match(plot, "print.auc=TRUE")
  expect_match(plot, "auc.polygon=TRUE")
  expect_match(plot, "grid=TRUE")
  expect_match(plot, "identity=FALSE")
  expect_match(plot, "col='red'")
  expect_match(plot, "lty='dashed'")
})

test_that("logistic ROC commands use the active model", {
  commands <- build_roc_lr_commands(
    "model1", "mtcars",
    list(plot = FALSE, ci_compute = FALSE, ci_plot = FALSE)
  )
  expect_match(commands[[1L]], "summary\\(model1\\)")
  expect_match(commands[[2L]], "predict\\(model1, type=c\\('response'\\)\\)")
  expect_true(any(grepl("\\.outcome ~ glm.prediction", commands)))
})

test_that("Hosmer-Lemeshow commands include the test and cleanup", {
  commands <- build_hosmer_lemeshow_commands(
    "model1", "mtcars", bins = 10, classification = TRUE,
    percent_correct = TRUE
  )
  expect_true(any(grepl("hoslem.test\\(.matrix", commands)))
  expect_true(".hl" %in% commands)
  expect_true(".tableClassif" %in% commands)
  expect_true(".percentageCorrect" %in% commands)
  expect_true("remove(.hl)" %in% commands)
})

test_that("the ROC dialog UIs render", {
  RcmdrShiny::unload_plugins()
  on.exit(RcmdrShiny::unload_plugins(), add = TRUE)
  rcmdrshiny_plugin()
  state <- RcmdrShiny::AppState(env = new.env())
  assign("mtcars", mtcars, envir = state$env)
  RcmdrShiny::active_dataset(state, "mtcars")
  for (id in c("fncvpROC", "fncPairedpROC", "fncUnpairedpROC",
               "fndHosmerLemeshow", "fncLRpROC")) {
    spec <- RcmdrShiny::get_dialog(id)
    expect_s3_class(spec, "RcmdrShinyDialog")
    expect_silent(htmltools::renderTags(spec$ui(state, list())))
  }
})

test_that("the single ROC dialog returns a command", {
  RcmdrShiny::unload_plugins()
  on.exit(RcmdrShiny::unload_plugins(), add = TRUE)
  rcmdrshiny_plugin()
  state <- RcmdrShiny::AppState(env = new.env())
  data <- mtcars
  data$am <- factor(data$am)
  assign("data", data, envir = state$env)
  RcmdrShiny::active_dataset(state, "data")
  spec <- RcmdrShiny::get_dialog("fncvpROC")
  result <- spec$on_ok(list(fncvpROC_prediction = "mpg",
                            fncvpROC_label = "am",
                            fncvpROC_plot = FALSE,
                            fncvpROC_ci_compute = FALSE), state)
  expect_match(result$commands[[1L]], "pROC::roc\\(am ~ mpg")
})
