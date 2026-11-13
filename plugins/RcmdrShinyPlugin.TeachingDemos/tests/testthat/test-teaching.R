test_that("the plugin registers its menus", {
  RcmdrShiny::unload_plugins()
  on.exit(RcmdrShiny::unload_plugins(), add = TRUE)
  rcmdrshiny_plugin()
  leaves <- RcmdrShiny::menu_leaves(RcmdrShiny::menu_tree())
  expect_true(all(c("centralLimitTheorem", "simulateConfidenceIntervals",
                    "powerExample", "flipCoin", "rollDie",
                    "linearRegressionExample", "correlationExample",
                    "visBinom", "visNormal", "vist", "visGamma") %in%
                    leaves$command))
  expect_true(any(grepl("Visualize distributions", leaves$path)))
})

test_that("the command builders produce executable plots", {
  expect_match(build_clt_command("normal", 30, 100), "replicate")
  expect_match(build_ci_simulation_command(0, 1, 30, 0.95, 20),
               "t.test")
  expect_match(build_power_command(0.5, 30, 0.05), "qt")
  expect_match(build_coin_command(100, 0.5), "rbinom")
  expect_match(build_die_command(100), "sample\\(1:6")
  expect_match(build_regression_demo_command(30, 0, 1, 1), "lm\\(")
  expect_match(build_correlation_demo_command(100, 0.7), "cor\\(")
  expect_match(build_distribution_plot_command("binom", list(size = 10, prob = .5)),
               "dbinom")
  expect_match(build_distribution_plot_command("norm", list(mean = 0, sd = 1)),
               "dnorm")
  expect_match(build_distribution_plot_command("t", list(df = 5)), "dt\\(")
  expect_match(build_distribution_plot_command("gamma", list(shape = 2, rate = 1)),
               "dgamma")
})

test_that("the demo dialog returns a plot command", {
  RcmdrShiny::unload_plugins()
  on.exit(RcmdrShiny::unload_plugins(), add = TRUE)
  rcmdrshiny_plugin()
  state <- RcmdrShiny::AppState(env = new.env())
  spec <- RcmdrShiny::get_dialog("centralLimitTheorem")
  result <- spec$on_ok(list(centralLimitTheorem_distribution = "normal",
                            centralLimitTheorem_n = 30,
                            centralLimitTheorem_reps = 100,
                            centralLimitTheorem_statistic = "mean"), state)
  expect_match(result$commands, "hist")
  expect_true(isTRUE(result$plot))
})
