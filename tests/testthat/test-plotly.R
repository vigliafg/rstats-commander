test_that("the interactive code builders emit plotly calls", {
  expect_match(plotly_code_scatter("D", "x", "y"), "plotly::plot_ly")
  expect_match(plotly_code_scatter("D", "x", "y", "g"), "color = ~g")
  expect_match(plotly_code_scatter("D", "x", "y", log = "xy"),
               "type = \"log\"")
  expect_match(plotly_code_histogram("D", "v"), "type = \"histogram\"")
  expect_match(plotly_code_boxplot("D", c("a", "b")), "add_boxplot")
  expect_match(plotly_code_boxplot("D", "a", "a", "g"), "color = ~g")
  expect_match(plotly_code_line("D", "x", c("a", "b")), "add_lines")
})

test_that("the four graph dialogs offer an interactive version", {
  env <- new.env()
  env$D <- data.frame(x = 1:10, y = 1:10, g = factor(rep(c("a", "b"), 5)),
                      v = 1:10)
  state <- AppState(env = env)
  active_dataset(state, "D")

  scatter <- get_dialog("scatterPlot")$on_ok(list(
    scatterPlot_x = "x", scatterPlot_y = "y", scatterPlot_group = "",
    scatterPlot_smooth = FALSE, scatterPlot_boxplots = FALSE,
    scatterPlot_log = ""
  ), state)
  expect_match(scatter$interactive, "plotly::plot_ly")

  histogram <- get_dialog("Histogram")$on_ok(list(
    Histogram_variable = "v", Histogram_group = "", Histogram_scale = "frequency",
    Histogram_breaks = "Sturges"
  ), state)
  expect_match(histogram$interactive, "histogram")

  box <- get_dialog("boxPlot")$on_ok(list(
    boxPlot_variables = "v", boxPlot_response = NULL, boxPlot_group = ""
  ), state)
  expect_match(box$interactive, "add_boxplot")

  line <- get_dialog("linePlot")$on_ok(list(
    linePlot_x = "x", linePlot_y = "y"
  ), state)
  expect_match(line$interactive, "add_lines")
})

test_that("apply_dialog_result stores the widget only when plotly is present", {
  skip_if_not_installed("plotly")
  env <- new.env()
  env$D <- data.frame(x = 1:5, y = 1:5)
  state <- AppState(env = env)
  active_dataset(state, "D")

  apply_dialog_result(state, list(
    commands = "plot(D$x, D$y)",
    plot = TRUE,
    interactive = "plotly::plot_ly(data = D, x = ~x, y = ~y)"
  ))
  expect_false(is.null(state$plotly_widget))
  expect_s3_class(state$plotly_widget, "plotly")
})
