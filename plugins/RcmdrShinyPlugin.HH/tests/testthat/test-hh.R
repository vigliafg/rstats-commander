test_that("the plugin registers its HH menus", {
  RcmdrShiny::unload_plugins()
  on.exit(RcmdrShiny::unload_plugins(), add = TRUE)
  rcmdrshiny_plugin()
  leaves <- RcmdrShiny::menu_leaves(RcmdrShiny::menu_tree())
  expected <- c("twoWayTable.HH", "enterTable.HH", "analyzeTwoWayTable.HH",
                "bestSubsetsRegressionModel.HH", "confidenceIntervalsPlot",
                "PredictModel", "scatterPlot.HH", "scatterPlotMatrix.HH",
                "Xyplot.HH", "Xyplot.HH2", "LikertFormula", "ResizeEtcDialog",
                "Interaction2wtRcmdr", "DotplottbRcmdr", "Regr1Plot",
                "QQPlot.HH", "Scatter3DDialog.HH", "anovaTableII.HH",
                "anovaTableI.HH", "normal.and.t.hypotheses.plot",
                "FHypothesesPlot", "ChisqHypothesesPlot", "Projector", "H600",
                "R_options", "MMCmenu")
  expect_true(all(expected %in% leaves$command))
})

test_that("HH command builders produce R commands", {
  expect_true(any(grepl("table\\(a, b\\)", build_hh_two_way("d", "a", "b"))))
  expect_true(any(grepl("matrix\\(c\\(1, 2, 3, 4\\)",
                        build_hh_enter_table(c(1,2,3,4), c("A","B"), c("X","Y")))))
  expect_true(any(grepl("leaps::regsubsets", build_hh_best_subsets("d", "y", c("x1","x2")))))
  expect_true(any(grepl("ci.plot", build_hh_ci_plot("d", "y", c("x1","x2")))))
  expect_match(build_hh_scatterplot("d", "x", "y", "g"), "scatterplot")
  expect_match(build_hh_scatterplot_matrix("d", c("x","y")),
               "scatterplotMatrix")
  expect_match(build_hh_xyplot("d", "x", "y", "g"), "xyplot")
  expect_match(build_hh_likert("d", c("a","b")), "likert")
  expect_match(build_hh_interaction("d", "y", c("a","b")), "interaction2wt")
  expect_match(build_hh_regr1("d", "x", "y"), "regr1.plot")
  expect_match(build_hh_qq("d", "x"), "qqPlot")
  expect_match(build_hh_scatter3d("d", "x", "y", "z"), "scatter3d")
  expect_match(build_hh_anova("m", "II"), "Anova")
  expect_match(build_hh_anova("m", "I"), "anova")
  expect_match(build_hh_hypothesis_plot("f", list(df1 = 3, df2 = 20)),
               "F.curve")
  expect_match(build_hh_mmc("m"), "mmc")
})

test_that("HH dialog UIs render", {
  RcmdrShiny::unload_plugins()
  on.exit(RcmdrShiny::unload_plugins(), add = TRUE)
  rcmdrshiny_plugin()
  state <- RcmdrShiny::AppState(env = new.env())
  assign("mtcars", mtcars, envir = state$env)
  RcmdrShiny::active_dataset(state, "mtcars")
  for (id in c("twoWayTable.HH", "bestSubsetsRegressionModel.HH",
               "scatterPlot.HH", "scatterPlotMatrix.HH", "R_options",
               "MMCmenu")) {
    spec <- RcmdrShiny::get_dialog(id)
    expect_s3_class(spec, "RcmdrShinyDialog")
    expect_silent(htmltools::renderTags(spec$ui(state, list())))
  }
})
