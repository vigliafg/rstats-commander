test_that("run_command captures printed output and value", {
  state <- AppState(env = new.env())
  result <- run_command(state, "1 + 1")

  expect_equal(result$status, "ok")
  expect_equal(result$output, "[1] 2")
  expect_equal(result$value, 2)
  expect_equal(state$log, "1 + 1")
  expect_equal(state$output, "[1] 2")
})

test_that("run_command records warnings and messages separately", {
  state <- AppState(env = new.env())
  result <- run_command(state, "warning('careful'); message('note'); 2 + 2")

  expect_equal(result$status, "ok")
  expect_equal(result$output, "[1] 4")
  expect_equal(state$warnings, "careful")
  expect_true(any(grepl("careful", state$messages)))
  expect_true(any(grepl("note", state$messages)))
})

test_that("run_command reports errors and keeps the session alive", {
  state <- AppState(env = new.env())
  result <- run_command(state, "stop('boom')")

  expect_equal(result$status, "error")
  expect_equal(result$error, "boom")
  expect_equal(state$last_error, "boom")
  expect_true(any(grepl("Error: boom", state$messages)))

  # The state is still usable.
  expect_equal(run_command(state, "3 + 3")$value, 6)
})

test_that("run_command handles parse errors", {
  state <- AppState(env = new.env())
  result <- run_command(state, "1 +")
  expect_equal(result$status, "error")
  expect_true(any(grepl("Error:", state$messages)))
})

test_that("commands can be run without being logged", {
  state <- AppState(env = new.env())
  run_command(state, "x <- 1", log = FALSE)
  expect_equal(state$log, character())
  expect_equal(state$env$x, 1)
})

test_that("assigning a data frame activates it", {
  state <- AppState(env = new.env())
  run_command(state, "Dataset <- data.frame(x = 1:3)")
  expect_equal(active_dataset(state), "Dataset")
  expect_equal(nrow(dataset(state)), 3L)
})

test_that("assigning a model activates it", {
  state <- AppState(env = new.env())
  run_command(state, "Dataset <- data.frame(x = 1:5, y = 1:5 + rnorm(5))")
  run_command(state, "Model <- lm(y ~ x, data = Dataset)")
  expect_equal(active_model(state), "Model")
})

test_that("plot commands produce a PNG and are added to the history", {
  state <- AppState(env = new.env())
  result <- run_command(state, "plot(1:10)")

  expect_equal(result$status, "ok")
  expect_equal(length(state$plots), 1L)
  plot <- state$plots[[1L]]
  expect_true(file.exists(plot$file))
  expect_gt(file.info(plot$file)$size, 1000)
  expect_equal(plot$code, "plot(1:10)")
})

test_that("assignment_name recognises <- and = assignment", {
  expect_equal(assignment_name(quote(a <- 1)), "a")
  expect_equal(assignment_name(str2lang("a = 1")), "a")
  expect_null(assignment_name(quote(f(a))))
})

test_that("plot detection is conservative", {
  expect_true(is_plot_command("plot(1:10)"))
  expect_true(is_plot_command("hist(mtcars$mpg)"))
  expect_true(is_plot_command("boxplot(y ~ x, data = d)"))
  expect_false(is_plot_command("summary(mtcars)"))
  expect_false(is_plot_command("p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt))"))
})
