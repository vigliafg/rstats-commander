test_that("the plugin registers NMBU menus", {
  RcmdrShiny::unload_plugins()
  on.exit(RcmdrShiny::unload_plugins(), add = TRUE)
  rcmdrshiny_plugin()
  leaves <- RcmdrShiny::menu_leaves(RcmdrShiny::menu_tree())
  expect_true(all(c("singleSampleTTestNMBU", "independentSamplesTTestNMBU",
                    "pairedTTestNMBU", "proportionTest", "twoProportionTest",
                    "oneWayAnovaNMBU", "multiWayAnovaNMBU",
                    "plsRegressionModel", "plotModelNMBU") %in% leaves$command))
})

test_that("NMBU builders produce calls", {
  expect_match(build_t_test("single", "d", "x", mu = 1), "t.test")
  expect_match(build_t_test("independent", "d", "y", "g"), "t.test")
  expect_match(build_t_test("paired", "d", "", first = "x", second = "y"),
               "paired = TRUE")
  expect_match(build_z_test("single", "d", "x"), "pnorm")
  expect_match(build_t_summary(1, 1, 10), "pt\\(")
  expect_match(build_proportion(5, 10), "prop.test")
  expect_match(build_two_proportion(5, 10, 6, 12), "prop.test")
  expect_match(build_power_t(), "power.t.test")
  expect_match(build_anova_nmbu("d", "y", "g")[[1]], "aov")
  expect_match(build_pls("d", "y", "x")[[1]], "plsr")
  expect_match(build_stepwise("m")[[1]], "stepAIC")
})

test_that("the NMBU dialog returns a command", {
  RcmdrShiny::unload_plugins()
  on.exit(RcmdrShiny::unload_plugins(), add = TRUE)
  rcmdrshiny_plugin()
  state <- RcmdrShiny::AppState(env = new.env())
  data <- data.frame(x = c(1, 2, 3, 4), g = factor(c("a", "a", "b", "b")),
                     y = c(2, 3, 4, 5))
  assign("data", data, envir = state$env)
  RcmdrShiny::active_dataset(state, "data")
  spec <- RcmdrShiny::get_dialog("singleSampleTTestNMBU")
  result <- spec$on_ok(list(singleSampleTTestNMBU_response = "x",
                            singleSampleTTestNMBU_mu = 0,
                            singleSampleTTestNMBU_level = "0.95",
                            singleSampleTTestNMBU_alternative = "two.sided"), state)
  expect_match(result$commands, "t.test")
})
