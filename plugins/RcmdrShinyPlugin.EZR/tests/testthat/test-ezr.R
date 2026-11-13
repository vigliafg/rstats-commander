test_that("the plugin registers the EZR statistical menu", {
  RcmdrShiny::unload_plugins()
  on.exit(RcmdrShiny::unload_plugins(), add = TRUE)
  rcmdrshiny_plugin()
  leaves <- RcmdrShiny::menu_leaves(RcmdrShiny::menu_tree())
  expect_true(all(c("StatMedSingleSampleTTest", "StatMedTtest",
                    "StatMedPairedTtest", "StatMedANOVA", "StatMedCorrelation",
                    "StatMedMannW", "StatMedKruWalli", "StatMedKaplanMeier",
                    "StatMedCoxRegression", "StatMedROC", "StatMedHistogram",
                    "StatMedBoxPlot", "StatMedScatterPlot") %in%
                    leaves$command))
})

test_that("EZR builders produce calls", {
  expect_match(ezr_t_test("single", "d", "x"), "t.test")
  expect_match(ezr_prop_ci(5, 10), "prop.test")
  expect_match(ezr_correlation("d", "x", "y"), "cor.test")
  expect_match(ezr_regression("d", "y", "x")[[1]], "lm")
  expect_match(ezr_anova("d", "y", "g")[[1]], "aov")
  expect_match(ezr_nonparam("mann", "d", "y", "g"), "wilcox.test")
  expect_match(ezr_survival("cox", "d", "time", "event", predictors = "x")[[1]],
               "coxph")
  expect_match(ezr_roc("d", "g", "x")[[1]], "pROC::roc")
  expect_match(ezr_histogram("d", "x"), "hist")
  expect_match(ezr_tableone("d", c("x", "y")), "CreateTableOne")
})

test_that("the EZR t-test dialog returns a command", {
  RcmdrShiny::unload_plugins()
  on.exit(RcmdrShiny::unload_plugins(), add = TRUE)
  rcmdrshiny_plugin()
  state <- RcmdrShiny::AppState(env = new.env())
  data <- data.frame(x = c(1, 2, 3, 4), g = factor(c("a", "a", "b", "b")),
                     y = c(2, 3, 4, 5))
  assign("data", data, envir = state$env)
  RcmdrShiny::active_dataset(state, "data")
  spec <- RcmdrShiny::get_dialog("StatMedSingleSampleTTest")
  result <- spec$on_ok(list(StatMedSingleSampleTTest_response = "x",
                            StatMedSingleSampleTTest_mu = 0,
                            StatMedSingleSampleTTest_level = "0.95",
                            StatMedSingleSampleTTest_alternative = "two.sided"),
                       state)
  expect_match(result$commands, "t.test")
})
