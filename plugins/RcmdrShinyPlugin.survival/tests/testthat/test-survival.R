test_that("the plugin registers its survival menus", {
  RcmdrShiny::unload_plugins()
  on.exit(RcmdrShiny::unload_plugins(), add = TRUE)
  rcmdrshiny_plugin()
  leaves <- RcmdrShiny::menu_leaves(RcmdrShiny::menu_tree())
  expected <- c("Survfit", "Survdiff", "SurvivalData", "Unfold", "toDate",
                "CoxModel", "survregModel", "CoxZPH", "PlotCoxph",
                "TermPlots", "CoxDfbetas", "CoxDfbeta",
                "MartingalePlotsDialog", "PartialResPlots")
  expect_true(all(expected %in% leaves$command))
})

test_that("survival command builders produce calls", {
  commands <- build_survfit("d", "time", "event", c("group"))
  expect_true(any(grepl("survival::survfit", commands)))
  expect_true(any(grepl("quantile", commands)))
  expect_match(build_survdiff("d", "time", "event", "group"),
               "survdiff")
  cox <- build_coxph("model1", "d", "time", "event", c("x", "z"))
  expect_match(cox[[1L]], "coxph")
  expect_match(cox[[1L]], "Surv\\(time, event\\)")
  expect_match(build_survreg("model2", "d", "time", "event", "x")[[1L]],
               "survreg")
  expect_true(any(grepl("cox.zph", build_cox_zph("model1"))))
  expect_match(build_term_plot("model1"), "termplot")
  expect_match(build_cox_dfbetas("model1", "dfbeta"), "dfbeta")
  expect_match(build_martingale("model1"), "martingale")
})

test_that("the survival dialog returns a command", {
  RcmdrShiny::unload_plugins()
  on.exit(RcmdrShiny::unload_plugins(), add = TRUE)
  rcmdrshiny_plugin()
  state <- RcmdrShiny::AppState(env = new.env())
  data <- data.frame(time = c(1, 2, 3, 4), event = c(1, 0, 1, 1),
                     group = factor(c("a", "a", "b", "b")))
  assign("data", data, envir = state$env)
  RcmdrShiny::active_dataset(state, "data")
  spec <- RcmdrShiny::get_dialog("Survfit")
  result <- spec$on_ok(list(Survfit_time = "time", Survfit_event = "event",
                            Survfit_strata = "group"), state)
  expect_match(result$commands[[1L]], "survival::survfit")
})
