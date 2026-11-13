test_that("data helpers build sequences and centered variables", {
  expect_equal(nb_sequence(1, 10, 2, "s"), "s <- data.frame(x = seq(1, 10, by = 2))")
  expect_error(nb_sequence(1, 10, 0, "s"), "cannot be zero")
  expect_equal(
    nb_mean_center("D", c("x", "y")),
    c("D$x_c <- D$x - mean(D$x, na.rm = TRUE)",
      "D$y_c <- D$y - mean(D$y, na.rm = TRUE)")
  )
  expect_error(nb_mean_center("D", character()), "at least one variable")
})

test_that("summarized z-tests produce statistics", {
  expect_match(nb_z_one_summary(5, 1, 30, 0), "pnorm")
  expect_match(nb_z_two_summary(5, 1, 30, 4, 1, 30), "sqrt\\(1\\^2 / 30")
  expect_error(nb_z_one_summary("x", 1, 30), "must be a number")
})

test_that("statistical builders produce valid calls", {
  expect_match(nb_covariance("D", c("x", "y"), "cor"), "^with\\(D, cor")
  expect_match(nb_cluster_variables("D", c("x", "y"), 2), "rect.hclust")
  expect_match(nb_relevant_components("D", c("x", "y"), 2),
               "psych::principal")
  expect_match(nb_simplex("D", "y", c("a", "b")), "lm\\(y ~ 0 \\+ a \\+ b")
  expect_match(nb_discriminant("D", "g", c("x"), "lda"), "MASS::lda")
  expect_match(nb_discriminant("D", "g", c("x"), "qda"), "MASS::qda")
  expect_match(nb_press("m"), "R2pred")
  expect_match(nb_inv_xtx("m"), "solve\\(crossprod")
  expect_match(nb_stepwise("m", "forward"), 'direction = "forward"')
})

test_that("graph builders produce valid calls", {
  expect_match(nb_fitted_line("D", "x", "y"), "abline\\(lm")
  expect_match(nb_pie_summary("a, b", "10, 20"), "pie\\(c\\(10, 20\\)")
  expect_error(nb_pie_summary("a", "10, 20"), "same length")
  expect_match(nb_simplex_plot("D", "a", "b", "c"), "asp = 1")
})

test_that("the remaining NMBU entries are registered", {
  RcmdrShiny::unload_plugins()
  on.exit(RcmdrShiny::unload_plugins(), add = TRUE)
  rcmdrshiny_plugin()

  ids <- c("auto.import.GUI", "onExport", "createSequence",
           "deleteActiveDataSet", "meanCenter", "covarianceMatrix",
           "twoSamplesZTest", "oneSamplesZTestSum", "twoSamplesZTestSum",
           "RelComp", "hierarchicalClusterVariable", "simplex.analysis",
           "discriminantAnalysis", "fittedLinePlot", "pieChartNMBU",
           "simplexGUI", "CIgrandMeanNMBU", "DA.coef", "hclust.list",
           "contrastGUI", "postHocGUI", "PRESS.GUI", "deviance_tests_GUI",
           "invXtXGUI", "principalComponentPlots", "discriminantPlot",
           "mixtureGUI", "backwardForward", "wideForwardAdd")
  implemented <- RcmdrShiny:::implemented_commands()
  expect_equal(setdiff(ids, implemented), character())
})

test_that("model-based dialogs require an active model", {
  RcmdrShiny::unload_plugins()
  on.exit(RcmdrShiny::unload_plugins(), add = TRUE)
  rcmdrshiny_plugin()

  spec <- RcmdrShiny::get_dialog("PRESS.GUI")
  result <- spec$on_ok(list(), RcmdrShiny::AppState(env = new.env()))
  expect_match(result$error, "Fit a model first")
})

test_that("createSequence returns a command and activates the data set", {
  RcmdrShiny::unload_plugins()
  on.exit(RcmdrShiny::unload_plugins(), add = TRUE)
  rcmdrshiny_plugin()

  state <- RcmdrShiny::AppState(env = new.env())
  spec <- RcmdrShiny::get_dialog("createSequence")
  result <- spec$on_ok(list(createSequence_from = 1, createSequence_to = 5,
                            createSequence_by = 1,
                            createSequence_name = "s"), state)
  expect_match(result$commands, "seq\\(1, 5")
  expect_equal(result$activate_dataset, "s")
})
