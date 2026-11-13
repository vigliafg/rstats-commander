test_that("activation expressions follow the data set contents", {
  env <- new.env()
  state <- AppState(env = env)

  expect_false(evaluate_condition(state, "activeDataSetP()"))
  expect_false(evaluate_condition(state, "numericP()"))
  expect_false(evaluate_condition(state, "factorsP()"))

  env$Dataset <- data.frame(
    y = 1:6,
    x = c(2, 4, 6, 8, 10, 12),
    g = factor(c("a", "b", "a", "b", "a", "b")),
    d = rep(1:3, 2),
    label = letters[1:6]
  )
  active_dataset(state, "Dataset")

  expect_true(evaluate_condition(state, "activeDataSetP()"))
  expect_true(evaluate_condition(state, "numericP()"))
  expect_true(evaluate_condition(state, "numericP(2)"))
  expect_true(evaluate_condition(state, "numericP(3)"))
  expect_false(evaluate_condition(state, "numericP(4)"))
  expect_true(evaluate_condition(state, "factorsP()"))
  expect_true(evaluate_condition(state, "twoLevelFactorsP()"))
  expect_true(evaluate_condition(state, "characterP()"))
  expect_true(evaluate_condition(state, "discreteNumericP()"))
  expect_true(evaluate_condition(
    state, "numericP() && factorsP()"
  ))
})

test_that("empty and invalid activation expressions are handled", {
  state <- AppState(env = new.env())
  expect_true(evaluate_condition(state, ""))
  expect_false(evaluate_condition(state, "not_a_function()"))
})

test_that("command_status distinguishes enabled, porting, inactive and hidden", {
  env <- new.env()
  state <- AppState(env = env)

  expect_equal(command_status(state, "readDataSet"), "enabled")
  expect_equal(command_status(state, "GumbelQuantiles"), "porting")
  expect_equal(
    command_status(state, "numericalSummaries", activation = "numericP()"),
    "inactive"
  )
  expect_equal(
    command_status(
      state, "saveRmd", install = "getRcmdr('use.markdown')"
    ),
    "hidden"
  )

  env$Dataset <- data.frame(y = 1:5, x = 1:5)
  active_dataset(state, "Dataset")
  expect_equal(
    command_status(state, "numericalSummaries", activation = "numericP()"),
    "enabled"
  )
})

test_that("model capabilities match the Rcmdr table", {
  env <- new.env()
  env$Dataset <- data.frame(y = 1:10, x = rnorm(10))
  state <- AppState(env = env)
  active_dataset(state, "Dataset")
  run_command(state, "Model <- lm(y ~ x, data = Dataset)")
  active_model(state, "Model")

  expect_true(evaluate_condition(state, "activeModelP()"))
  expect_true(evaluate_condition(state, "modelsP()"))
  expect_true(evaluate_condition(state, "modelCapability('sum')"))
  expect_true(evaluate_condition(state, "modelCapability('aic')"))
  expect_false(evaluate_condition(state, "modelCapability('not-a-capability')"))
  expect_true(evaluate_condition(state, "CoefficientsP(2)"))
  expect_true(evaluate_condition(state, "PredictorsP(1, 'numeric')"))
})

test_that("model capabilities default to FALSE without a model", {
  state <- AppState(env = new.env())
  expect_false(evaluate_condition(state, "modelCapability('sum')"))
  expect_false(evaluate_condition(state, "activeModelP()"))
})

test_that("package and capability predicates work", {
  state <- AppState(env = new.env())
  expect_true(evaluate_condition(state, "packageAvailable('stats')"))
  expect_false(evaluate_condition(state, "packageAvailable('not-a-package')"))
  expect_true(isTRUE(get_rcmdr_option(state, "capabilities")$tktable))
})
