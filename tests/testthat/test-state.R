test_that("a fresh state has no active data set or model", {
  state <- AppState(env = new.env())
  expect_s3_class(state, "RcmdrShinyState")
  expect_null(active_dataset(state))
  expect_null(active_model(state))
  expect_equal(state$log, character())
  expect_equal(state$model_number, 0L)
})

test_that("active data set is validated", {
  env <- new.env()
  env$Dataset <- data.frame(x = 1:3, y = letters[1:3])
  env$not_a_data_frame <- 1:3
  state <- AppState(env = env)

  expect_error(active_dataset(state, "missing"), "does not exist")
  expect_error(active_dataset(state, "not_a_data_frame"), "not a data frame")
  active_dataset(state, "Dataset")
  expect_equal(active_dataset(state), "Dataset")
  expect_equal(nrow(dataset(state)), 3L)
})

test_that("variable helpers classify columns like Rcmdr", {
  env <- new.env()
  env$Dataset <- data.frame(
    num = c(1, 2, 3),
    int = 1:3,
    fac = factor(c("a", "b", "a")),
    chr = c("x", "y", "x"),
    logi = c(TRUE, FALSE, TRUE)
  )
  state <- AppState(env = env)
  active_dataset(state, "Dataset")

  expect_setequal(numeric_variables(state), c("num", "int"))
  expect_setequal(factor_variables(state), c("fac", "chr", "logi"))
  expect_setequal(discrete_numeric_variables(state), c("num", "int"))
})

test_that("changing data set clears the active model", {
  env <- new.env()
  env$D1 <- data.frame(x = 1:3)
  env$D2 <- data.frame(y = 1:3)
  state <- AppState(env = env)
  active_dataset(state, "D1")
  active_model(state, "D1")
  expect_equal(active_model(state), "D1")

  active_dataset(state, "D2")
  expect_null(active_model(state))
})

test_that("model numbers are incremented safely", {
  state <- AppState(env = new.env())
  expect_equal(update_model_number(state), 1L)
  expect_equal(update_model_number(state), 2L)
  expect_equal(update_model_number(state, -10L), 1L)
})

test_that("valid names follow R syntax", {
  expect_true(is_valid_name("Dataset"))
  expect_true(is_valid_name("LinearModel.1"))
  expect_false(is_valid_name(""))
  expect_false(is_valid_name("my data"))
  expect_false(is_valid_name("1x"))
  expect_false(is_valid_name("if"))
})

test_that("dialog memory is stored per dialog", {
  state <- AppState(env = new.env())
  set_dialog_memory(state, "a", list(x = 1))
  set_dialog_memory(state, "b", list(x = 2))
  expect_equal(get_dialog_memory(state, "a")$x, 1)
  clear_dialog_memory(state, "a")
  expect_null(get_dialog_memory(state, "a"))
  expect_equal(get_dialog_memory(state, "b")$x, 2)
})
