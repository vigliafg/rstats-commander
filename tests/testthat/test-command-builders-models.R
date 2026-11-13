test_that("Models command builders reproduce Rcmdr calls", {
  expect_equal(RcmdrShiny:::cmd_summarize_model("M"), "summary(M)")
  expect_equal(RcmdrShiny:::cmd_compare_coefficients(c("M1", "M2")),
               "compareCoefs(M1, M2)")
  expect_equal(
    RcmdrShiny:::cmd_add_observation_statistics("D", "M",
      c("fitted", "residuals", "obsNumbers")),
    paste0(
      "D <- within(D, {\n  fitted.M <- fitted(M)\n",
      "  residuals.M <- residuals(M)\n  obsNumber <- 1:nrow(D)\n})"
    )
  )
  expect_equal(RcmdrShiny:::cmd_aic("M"), "AIC(M)")
  expect_equal(RcmdrShiny:::cmd_bic("M"), "BIC(M)")
  expect_equal(RcmdrShiny:::cmd_stepwise("M"),
               "stepwise(M, direction='backward', criterion='BIC')")
  expect_equal(
    RcmdrShiny:::cmd_subset_regression("D", "y", c("x", "z"), 2),
    "plot(regsubsets(y ~ x + z, data=D, nbest=2))"
  )
  expect_equal(RcmdrShiny:::cmd_confidence_intervals("M"),
               'Confint(M, level=0.95, type="LR")')
  expect_equal(
    RcmdrShiny:::cmd_bootstrap("M", 100, 0.95, "perc", "case"),
    c('.bs.samples <- Boot(M, R=100, method="case")',
      'confint(.bs.samples, level=0.95, type="perc")')
  )
  expect_equal(RcmdrShiny:::cmd_delta_method("M", "x"),
               'DeltaMethod(M, "x", level=0.95)')
  expect_equal(RcmdrShiny:::cmd_anova_table("M"),
               'Anova(M, type="II", test="F")')
  expect_equal(RcmdrShiny:::cmd_compare_models("M1", "M2"),
               'anova(M1, M2, test="F")')
  expect_equal(RcmdrShiny:::cmd_linear_hypothesis("M", "x = 0"),
               'linearHypothesis(M, "x = 0", level=0.95)')
  expect_equal(RcmdrShiny:::cmd_bptest("M", "D"),
               "bptest(formula(M), studentize=TRUE, data=D)")
  expect_equal(RcmdrShiny:::cmd_dwtest("M", "D"),
               'dwtest(formula(M), alternative="two.sided", data=D)')
  expect_equal(RcmdrShiny:::cmd_resettest("M", "D"),
               'resettest(formula(M), power=2:3, type="fitted", data=D)')
  expect_equal(RcmdrShiny:::cmd_outlier_test("M"), "outlierTest(M)")
  expect_equal(RcmdrShiny:::cmd_transform_response("M"),
               'summary(powerTransform(M, family="bcPower"))')
  expect_equal(RcmdrShiny:::cmd_plot_model("M"),
               c("oldpar <- par(oma=c(0,0,3,0), mfrow=c(2,2))",
                 "plot(M)", "par(oldpar)"))
  expect_equal(RcmdrShiny:::cmd_residual_qq("M"), "qqPlot(M, simulate=TRUE)")
  expect_equal(RcmdrShiny:::cmd_crplots("M", 0.5),
               "crPlots(M, smooth=list(span=0.5))")
  expect_equal(RcmdrShiny:::cmd_avplots("M"),
               'avPlots(M, id=list(method="mahal", n=2))')
  expect_equal(RcmdrShiny:::cmd_influence_plot("M"),
               'influencePlot(M, id=list(method="noteworthy", n=2))')
  expect_equal(RcmdrShiny:::cmd_influence_index("M"),
               'influenceIndexPlot(M, id=list(method="y", n=2))')
  expect_equal(RcmdrShiny:::cmd_effect_plots("M"),
               "plot(allEffects(M))")
  expect_equal(RcmdrShiny:::cmd_predictor_effects("M"),
               "plot(predictorEffects(M))")
  expect_equal(RcmdrShiny:::cmd_load_packages(c("MASS", "nnet")),
               c("library(MASS)", "library(nnet)"))
})

test_that("model commands execute on a fitted model", {
  set.seed(1)
  env <- new.env()
  env$D <- data.frame(y = rnorm(30), x = rnorm(30), z = rnorm(30))
  state <- AppState(env = env)
  active_dataset(state, "D")
  run_command(state, "M <- lm(y ~ x + z, data=D)")
  active_model(state, "M")

  for (command in c(
    RcmdrShiny:::cmd_summarize_model("M"),
    RcmdrShiny:::cmd_aic("M"),
    RcmdrShiny:::cmd_anova_table("M"),
    RcmdrShiny:::cmd_bptest("M", "D"),
    RcmdrShiny:::cmd_dwtest("M", "D"),
    RcmdrShiny:::cmd_vif("M")
  )) {
    expect_equal(run_command(state, command)$status, "ok")
  }
})

test_that("every Phase 5 dialog renders and validates", {
  set.seed(1)
  env <- new.env()
  env$D <- data.frame(y = rnorm(30), x = rnorm(30), z = rnorm(30))
  state <- AppState(env = env)
  active_dataset(state, "D")
  run_command(state, "M <- lm(y ~ x + z, data=D)")
  active_model(state, "M")

  for (id in names(RcmdrShiny:::phase5_dialogs())) {
    spec <- get_dialog_spec(id)
    html <- htmltools::renderTags(spec$ui(state, NULL))$html
    expect_gt(nchar(html), 100)
  }
})
