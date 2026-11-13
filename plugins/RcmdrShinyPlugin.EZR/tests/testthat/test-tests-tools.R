test_that("proportion and table test builders produce valid calls", {
  expect_match(ezr_test_prob_diff(10, 20, 15, 20), "^prop\\.test\\(c\\(10, 15\\)")
  expect_match(ezr_test_prob_diff(10, 20, 15, 20), "conf.int")
  expect_match(ezr_test_prob_ratio(10, 20, 15, 20), "log\\(\\.p1 / \\.p2\\)")
  expect_error(ezr_test_prob_ratio(0, 20, 15, 20), "at least one success")
  expect_match(ezr_test_cochran_q(c(10, 12, 15), c(20, 20, 20)),
               "pchisq")
  expect_match(ezr_test_trend(c(10, 15, 20), c(20, 20, 20)),
               "^prop\\.trend\\.test")
  expect_error(ezr_test_trend(c(10, 15), c(20, 20)), "three groups")
})

test_that("continuous test builders produce valid calls", {
  expect_match(ezr_test_modified_poisson("D", "y", c("x", "g")),
               "sandwich::vcovHC")
  expect_match(ezr_test_grubbs("D", "x"), "pt\\(\\.t")
  expect_match(ezr_test_ks("D", "x"), 'ks.test\\(D\\$x, "pnorm"')
  expect_match(ezr_test_variances("D", "y", "g"), "var.test\\(y ~ g")
  expect_match(ezr_test_ancova("D", "y", "g", "x"), "car::Anova")
  expect_match(ezr_test_jonckheere("D", "y", "g"),
               "clinfun::jonckheere.test")
})

test_that("accuracy builders produce valid calls", {
  expect_match(ezr_test_predictive(30, 10, 5, 55), "PPV")
  expect_match(ezr_test_roc_compare("D", "y", "a", "b"), "pROC::roc.test")
  expect_match(ezr_test_survival_roc("D", "time", "status", "m", 12),
               "timeROC::timeROC")
  expect_match(ezr_test_reliability("D", c("a", "b", "c")),
               "psych::alpha")
  expect_error(ezr_test_reliability("D", "a"), "at least two")
})

test_that("the fourteen test entries are registered", {
  RcmdrShiny::unload_plugins()
  on.exit(RcmdrShiny::unload_plugins(), add = TRUE)
  rcmdrshiny_plugin()

  ids <- c("StatMedProbDiffCI", "StatMedProbRatioCI", "StatMedCochranQ",
           "StatMedPropTrend", "StatMedModifiedPoissonRegression", "StatMedSG",
           "StatMedKS", "StatMedFTest", "StatMedANCOVA", "StatMedJT",
           "StatMedPredictiveValue", "StatMedROCtest", "StatMedSurvivalROC",
           "StatMedReliability")
  for (id in ids) {
    expect_false(is.null(RcmdrShiny::get_dialog(id)), info = id)
  }
  expect_true(all(ids %in% RcmdrShiny:::implemented_commands()))
})

test_that("a discrete test dialog returns a command", {
  RcmdrShiny::unload_plugins()
  on.exit(RcmdrShiny::unload_plugins(), add = TRUE)
  rcmdrshiny_plugin()

  state <- RcmdrShiny::AppState(env = new.env())
  spec <- RcmdrShiny::get_dialog("StatMedProbDiffCI")
  result <- spec$on_ok(list(StatMedProbDiffCI_x1 = 10,
                            StatMedProbDiffCI_n1 = 20,
                            StatMedProbDiffCI_x2 = 15,
                            StatMedProbDiffCI_n2 = 20,
                            StatMedProbDiffCI_level = "0.95"), state)
  expect_null(result$error)
  expect_match(result$commands, "prop.test")
})
