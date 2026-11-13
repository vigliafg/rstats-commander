stats_state <- function() {
  set.seed(1)
  env <- new.env()
  env$D <- data.frame(
    y = rnorm(30), x = rnorm(30), z = rnorm(30),
    g = factor(rep(c("a", "b", "c"), 10)),
    h = factor(rep(c("u", "v"), 15)),
    s = letters[rep(1:5, 6)]
  )
  env$D$y2 <- env$D$y + rnorm(30)
  env$D$y3 <- env$D$y + rnorm(30)
  state <- AppState(env = env)
  active_dataset(state, "D")
  state
}

stats_inputs <- function() {
  list(
    frequencyDistribution = list(frequencyDistribution_variables = "g",
                                 frequencyDistribution_goodness = FALSE,
                                 frequencyDistribution_probs = ""),
    statisticsTable = list(statisticsTable_groups = "g",
                           statisticsTable_responses = c("y", "x"),
                           statisticsTable_statistic = "mean",
                           statisticsTable_other = ""),
    correlationMatrix = list(correlationMatrix_variables = c("y", "x"),
                             correlationMatrix_type = "Pearson",
                             correlationMatrix_use = "complete",
                             correlationMatrix_pvalues = FALSE),
    correlationTest = list(correlationTest_variables = c("y", "x"),
                           correlationTest_method = "pearson",
                           correlationTest_alternative = "two.sided"),
    NormalityTest = list(NormalityTest_variable = "y",
                         NormalityTest_test = "shapiro.test",
                         NormalityTest_groups = "",
                         NormalityTest_nclasses = ""),
    transformVariables = list(transformVariables_variables = c("y", "x"),
                              transformVariables_family = "bcPower",
                              transformVariables_rhs = ""),
    twoWayTable = list(twoWayTable_row = "g", twoWayTable_column = "h",
                       twoWayTable_percents = "none",
                       twoWayTable_tests_chisq = TRUE,
                       twoWayTable_tests_components = FALSE,
                       twoWayTable_tests_expected = FALSE,
                       twoWayTable_tests_fisher = FALSE,
                       twoWayTable_subset = ""),
    twoWayTableFromCounts = list(
      twoWayTableFromCounts_row = "g", twoWayTableFromCounts_column = "h",
      twoWayTableFromCounts_count = "y",
      twoWayTableFromCounts_percents = "none",
      twoWayTableFromCounts_tests_chisq = TRUE,
      twoWayTableFromCounts_tests_components = FALSE,
      twoWayTableFromCounts_tests_expected = FALSE,
      twoWayTableFromCounts_tests_fisher = FALSE,
      twoWayTableFromCounts_subset = ""
    ),
    multiWayTable = list(multiWayTable_row = "g", multiWayTable_column = "h",
                         multiWayTable_controls = "s",
                         multiWayTable_percents = "none",
                         multiWayTable_subset = ""),
    enterTable = list(enterTable_rowvar = "row", enterTable_colvar = "col",
                      enterTable_rownames = "A,B",
                      enterTable_colnames = "X,Y",
                      enterTable_counts = "1,2,3,4",
                      enterTable_percents = "none",
                      enterTable_tests_chisq = TRUE,
                      enterTable_tests_components = FALSE,
                      enterTable_tests_expected = FALSE,
                      enterTable_tests_fisher = FALSE,
                      enterTable_subset = ""),
    independentSamplesTTest = list(
      independentSamplesTTest_group = "h",
      independentSamplesTTest_response = "y",
      independentSamplesTTest_alternative = "two.sided",
      independentSamplesTTest_conf = 0.95,
      independentSamplesTTest_var_equal = FALSE
    ),
    pairedTTest = list(pairedTTest_x = "y", pairedTTest_y = "x",
                       pairedTTest_alternative = "two.sided",
                       pairedTTest_conf = 0.95),
    singleSampleTTest = list(singleSampleTTest_x = "y",
                             singleSampleTTest_alternative = "two.sided",
                             singleSampleTTest_mu = 0,
                             singleSampleTTest_conf = 0.95),
    oneWayAnova = list(oneWayAnova_model = "A1", oneWayAnova_group = "g",
                       oneWayAnova_response = "y",
                       oneWayAnova_pairwise = FALSE,
                       oneWayAnova_conf = 0.95,
                       oneWayAnova_welch = FALSE),
    multiWayAnova = list(multiWayAnova_model = "A2",
                         multiWayAnova_groups = c("g", "h"),
                         multiWayAnova_response = "y"),
    oneWayRepeatedMeasures = list(
      oneWayRepeatedMeasures_responses = c("y", "y2", "y3"),
      oneWayRepeatedMeasures_within = "time",
      oneWayRepeatedMeasures_levels = "t1,t2,t3",
      oneWayRepeatedMeasures_between = NULL,
      oneWayRepeatedMeasures_test = "univariate"
    ),
    twoWayRepeatedMeasures = list(
      twoWayRepeatedMeasures_responses = c("y", "x", "y2", "y3"),
      twoWayRepeatedMeasures_rowname = "row",
      twoWayRepeatedMeasures_rowlevels = "r1,r2",
      twoWayRepeatedMeasures_colname = "col",
      twoWayRepeatedMeasures_collevels = "c1,c2",
      twoWayRepeatedMeasures_between = NULL,
      twoWayRepeatedMeasures_test = "univariate"
    ),
    twoVariancesFTest = list(twoVariancesFTest_group = "h",
                             twoVariancesFTest_response = "y",
                             twoVariancesFTest_alternative = "two.sided",
                             twoVariancesFTest_conf = 0.95),
    BartlettTest = list(BartlettTest_response = "y",
                        BartlettTest_groups = "g",
                        BartlettTest_center = "median"),
    LeveneTest = list(LeveneTest_response = "y",
                      LeveneTest_groups = "g",
                      LeveneTest_center = "median"),
    sigmaTestMenu = list(sigmaTestMenu_x = "y",
                         sigmaTestMenu_alternative = "two.sided",
                         sigmaTestMenu_sigma = 1,
                         sigmaTestMenu_conf = 0.95),
    singleProportionTest = list(
      singleProportionTest_x = "g",
      singleProportionTest_test = "normal",
      singleProportionTest_alternative = "two.sided",
      singleProportionTest_p = 0.5,
      singleProportionTest_conf = 0.95
    ),
    twoSampleProportionsTest = list(
      twoSampleProportionsTest_groups = "h",
      twoSampleProportionsTest_response = "s",
      twoSampleProportionsTest_test = "normal",
      twoSampleProportionsTest_alternative = "two.sided",
      twoSampleProportionsTest_conf = 0.95
    ),
    twoSampleWilcoxonTest = list(
      twoSampleWilcoxonTest_group = "h",
      twoSampleWilcoxonTest_response = "y",
      twoSampleWilcoxonTest_test = "default",
      twoSampleWilcoxonTest_alternative = "two.sided"
    ),
    pairedWilcoxonTest = list(
      pairedWilcoxonTest_x = "y", pairedWilcoxonTest_y = "x",
      pairedWilcoxonTest_test = "default",
      pairedWilcoxonTest_alternative = "two.sided"
    ),
    KruskalWallisTest = list(KruskalWallisTest_group = "g",
                             KruskalWallisTest_response = "y"),
    FriedmanTest = list(FriedmanTest_responses = c("y", "x", "z")),
    onesampleWilcoxonTest = list(
      onesampleWilcoxonTest_x = "y",
      onesampleWilcoxonTest_test = "default",
      onesampleWilcoxonTest_alternative = "two.sided",
      onesampleWilcoxonTest_mu = 0
    ),
    Reliability = list(Reliability_variables = c("y", "x", "z")),
    principalComponents = list(
      principalComponents_variables = c("y", "x", "z"),
      principalComponents_correlations = TRUE,
      principalComponents_scree = FALSE,
      principalComponents_subset = ""
    ),
    factorAnalysis = list(
      factorAnalysis_variables = c("y", "x", "z"),
      factorAnalysis_factors = 1, factorAnalysis_rotation = "varimax",
      factorAnalysis_scores = "none", factorAnalysis_subset = ""
    ),
    CFA = list(CFA_model = "F1 -> y, NA, 1\nF1 -> x, lam1, NA\nF1 -> z, lam2, NA",
               CFA_name = "CFA.1"),
    kmeansClustering = list(
      kmeansClustering_variables = c("y", "x"),
      kmeansClustering_centers = 2, kmeansClustering_iter = 10,
      kmeansClustering_seeds = 10, kmeansClustering_summary = TRUE,
      kmeansClustering_plot = FALSE, kmeansClustering_assign = "",
      kmeansClustering_subset = ""
    ),
    hierarchicalCluster = list(
      hierarchicalCluster_solution = "H1",
      hierarchicalCluster_variables = c("y", "x"),
      hierarchicalCluster_method = "ward.D",
      hierarchicalCluster_distance = "euc",
      hierarchicalCluster_dendro = FALSE,
      hierarchicalCluster_subset = ""
    ),
    hclustSummary = list(hclustSummary_solution = "H1",
                         hclustSummary_clusters = 2,
                         hclustSummary_summary = TRUE,
                         hclustSummary_plot = FALSE),
    appendHclustGroup = list(appendHclustGroup_solution = "H1",
                             appendHclustGroup_clusters = 2,
                             appendHclustGroup_label = "cluster"),
    linearRegressionModel = list(
      linearRegressionModel_model = "M1",
      linearRegressionModel_response = "y",
      linearRegressionModel_predictors = c("x", "z"),
      linearRegressionModel_subset = "",
      linearRegressionModel_weights = "",
      linearRegressionModel_remove = ""
    ),
    generalizedLinearModel = list(
      generalizedLinearModel_model = "G1",
      generalizedLinearModel_lhs = "h",
      generalizedLinearModel_rhs = "y",
      generalizedLinearModel_subset = "",
      generalizedLinearModel_weights = "",
      generalizedLinearModel_remove = "",
      generalizedLinearModel_family = "binomial",
      generalizedLinearModel_link = "logit"
    ),
    multinomialLogitModel = list(
      multinomialLogitModel_model = "MN1",
      multinomialLogitModel_lhs = "g",
      multinomialLogitModel_rhs = "y",
      multinomialLogitModel_subset = "",
      multinomialLogitModel_remove = ""
    ),
    ordinalRegressionModel = list(
      ordinalRegressionModel_model = "O1",
      ordinalRegressionModel_lhs = "s",
      ordinalRegressionModel_rhs = "y",
      ordinalRegressionModel_subset = "",
      ordinalRegressionModel_remove = "",
      ordinalRegressionModel_method = "logistic"
    ),
    linearMixedModel = list(
      linearMixedModel_model = "L1",
      linearMixedModel_lhs = "y",
      linearMixedModel_rhs = "x + (1 | g)",
      linearMixedModel_subset = "",
      linearMixedModel_remove = "",
      linearMixedModel_reml = TRUE
    ),
    generalizedLinearMixedModel = list(
      generalizedLinearMixedModel_model = "GL1",
      generalizedLinearMixedModel_lhs = "h",
      generalizedLinearMixedModel_rhs = "y + (1 | g)",
      generalizedLinearMixedModel_subset = "",
      generalizedLinearMixedModel_remove = "",
      generalizedLinearMixedModel_family = "binomial",
      generalizedLinearMixedModel_link = "logit"
    )
  )
}

test_that("every Statistics dialog validates and returns commands", {
  inputs <- stats_inputs()
  for (id in names(inputs)) {
    state <- stats_state()
    if (id %in% c("hclustSummary", "appendHclustGroup")) {
      run_command(state, cmd_hclust("D", "H1", c("y", "x"), dendro = FALSE))
    }
    spec <- get_dialog_spec(id)
    result <- tryCatch(
      spec$on_ok(inputs[[id]], state),
      error = function(e) list(error = conditionMessage(e))
    )
    expect_null(result$error)
    expect_true(length(result$commands %||% character()) > 0L)
  }
})

test_that("Statistics dialogs reject invalid selections", {
  state <- stats_state()

  expect_match(
    get_dialog_spec("correlationTest")$on_ok(
      list(correlationTest_variables = "y"), state)$error,
    "exactly two"
  )
  expect_match(
    get_dialog_spec("independentSamplesTTest")$on_ok(
      list(independentSamplesTTest_group = "", independentSamplesTTest_response = "y"),
      state)$error,
    "groups variable"
  )
  expect_match(
    get_dialog_spec("oneWayAnova")$on_ok(
      list(oneWayAnova_model = "1bad", oneWayAnova_group = "g",
           oneWayAnova_response = "y"), state)$error,
    "not a valid name"
  )
  expect_match(
    get_dialog_spec("twoWayTable")$on_ok(
      list(twoWayTable_row = "g", twoWayTable_column = "g"), state)$error,
    "same"
  )
})
