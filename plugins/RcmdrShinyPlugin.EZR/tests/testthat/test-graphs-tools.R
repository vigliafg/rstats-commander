test_that("graph builders produce runnable commands", {
  expect_match(ezr_graph_violin("D", "x"), "^vioplot::vioplot\\(D\\$x")
  expect_match(ezr_graph_violin("D", "x", "g"), "^vioplot::vioplot\\(x ~ g")
  expect_match(ezr_graph_ordered("D", "g"), "barplot\\(sort\\(table\\(g\\)")
  expect_match(ezr_graph_swim("D", "id", "start", "end", "status"),
               "segments\\(")
  expect_match(ezr_graph_sankey("D", "a", "b"), "ggalluvial::geom_alluvium")
  expect_match(ezr_graph_consort(100, 20, 80, 76), "Screened:")
  expect_match(ezr_graph_adjusted_survival("D", "time", "event", "g"),
               "survival::survfit")
  expect_match(ezr_graph_adjusted_cuminc("D", "time", "status", "g"),
               "cmprsk::cuminc")
  expect_match(ezr_graph_stack_cuminc("D", "time", "status"), "polygon\\(")
  expect_equal(ezr_graph_options(1.2, 2, 2, "l"),
               'par(cex = 1.2, lwd = 2, las = 2, bty = "l")')
})

test_that("the summary table uses the active model when there is one", {
  state <- RcmdrShiny::AppState(env = new.env())
  assign("D", data.frame(y = 1:5, x = 1:5), envir = state$env)
  RcmdrShiny::active_dataset(state, "D")
  expect_equal(ezr_summary_results(state), "summary(D)")

  assign("m", lm(y ~ x, data = data.frame(y = 1:5, x = 1:5)),
         envir = state$env)
  RcmdrShiny::active_model(state, "m")
  expect_equal(ezr_summary_results(state), "summary(m)")
})

test_that("the ten graph entries are registered", {
  RcmdrShiny::unload_plugins()
  on.exit(RcmdrShiny::unload_plugins(), add = TRUE)
  rcmdrshiny_plugin()

  ids <- c("StatMedViolinPlot", "StatMedOrderedChart", "StatMedSwimPlot",
           "StatMedSankey", "StatMedConsort", "StatMedAdjustedSurvival",
           "StatMedAdjustedCumInc", "StatMedStackCumInc",
           "StatMedGraphOptions", "StatMedSummaryResults")
  for (id in ids) {
    expect_false(is.null(RcmdrShiny::get_dialog(id)), info = id)
  }
  expect_true(all(ids %in% RcmdrShiny:::implemented_commands()))
})

test_that("violin and CONSORT dialogs return commands", {
  RcmdrShiny::unload_plugins()
  on.exit(RcmdrShiny::unload_plugins(), add = TRUE)
  rcmdrshiny_plugin()

  state <- RcmdrShiny::AppState(env = new.env())
  assign("D", data.frame(x = rnorm(10), g = factor(rep(c("a", "b"), 5))),
         envir = state$env)
  RcmdrShiny::active_dataset(state, "D")

  violin <- RcmdrShiny::get_dialog("StatMedViolinPlot")
  result <- violin$on_ok(list(StatMedViolinPlot_variable = "x",
                              StatMedViolinPlot_group = "g"), state)
  expect_null(result$error)
  expect_match(result$commands, "vioplot")

  consort <- RcmdrShiny::get_dialog("StatMedConsort")
  result <- consort$on_ok(list(StatMedConsort_screened = 100,
                               StatMedConsort_excluded = 20,
                               StatMedConsort_randomised = 80,
                               StatMedConsort_analysed = 76), state)
  expect_match(result$commands, "plot.new")
})
