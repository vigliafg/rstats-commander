test_that("the plugin registers the TeachStat menu", {
  RcmdrShiny::unload_plugins()
  on.exit(RcmdrShiny::unload_plugins(), add = TRUE)
  rcmdrshiny_plugin()
  leaves <- RcmdrShiny::menu_leaves(RcmdrShiny::menu_tree())
  expect_true(any(grepl("Basic Statistics", leaves$path)))
  expect_true(all(c("oneWayAnovaRE", "randomnessFTest", "randomnessNTest",
                    "Sindexnumbers", "Cindexnumbers", "BCindexnumbers",
                    "Pindexnumbers", "Deflation",
                    "resumenVariablesCualitativas", "resumenNumericoVContinua",
                    "normalDistrQuantiles", "binomialDistrMass",
                    "intervaloConfianzaMedia", "contrasteHipotesisMedia")
                  %in% leaves$command))
})

test_that("distribution builders produce R calls", {
  expect_match(ts_quantiles("normal", list(mean = 0, sd = 1)),
               "qnorm")
  expect_match(ts_probabilities("normal", list(mean = 0, sd = 1)),
               "pnorm")
  expect_match(ts_mass("binomial", list(size = 10, prob = .5)), "dbinom")
  expect_match(ts_plot("binomial", list(size = 10, prob = .5)), "plot")
  expect_match(ts_characteristics("normal", list(mean = 0, sd = 1)),
               "rnorm")
  expect_match(ts_samples("normal", list(mean = 0, sd = 1), 10, 42),
               "set.seed\\(42\\)")
})

test_that("inference builders produce R calls", {
  expect_match(ts_ci_mean("d", "x"), "t.test")
  expect_match(ts_ci_variance("d", "x"), "qchisq")
  expect_match(ts_ci_proportion(5, 10), "prop.test")
  expect_match(ts_ci_independent_means("d", "y", "g"), "t.test")
  expect_match(ts_ci_paired("d", "x", "y"), "paired = TRUE")
  expect_match(ts_ci_variance_ratio("d", "y", "g"), "var.test")
  expect_match(ts_ci_diff_proportions(1, 10, 2, 12), "prop.test")
  expect_match(ts_test_mean("d", "x", mu = 1), "mu = 1")
  expect_match(ts_test_variance("d", "x", sigma2 = 2), "pchisq")
  expect_match(ts_test_proportion(5, 10, p0 = .5), "p = 0.5")
})

test_that("descriptive and index builders produce R calls", {
  expect_match(ts_descriptive_factor("d", "g"), "table")
  expect_match(ts_descriptive_numeric("d", "x"), "numSummary")
  expect_match(ts_simple_index("d", "x", 2), "100 \\*")
  expect_match(ts_chain_index("d", "x"), "cumprod")
  expect_match(ts_price_index("d", "p", "q", 1), "100 \\*")
  expect_match(ts_deflation("d", "nominal", "price"), "100 \\*")
  expect_true(any(grepl("lmer", ts_random_anova("d", "y", "g"))))
})

test_that("a distribution dialog returns a command", {
  RcmdrShiny::unload_plugins()
  on.exit(RcmdrShiny::unload_plugins(), add = TRUE)
  rcmdrshiny_plugin()
  state <- RcmdrShiny::AppState(env = new.env())
  spec <- RcmdrShiny::get_dialog("normalDistrQuantiles")
  result <- spec$on_ok(list(normalDistrQuantiles_mean = 0,
                            normalDistrQuantiles_sd = 1,
                            normalDistrQuantiles_probs = "c(0.025, 0.975)"),
                       state)
  expect_match(result$commands, "qnorm")
})
