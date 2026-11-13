test_that("long output is trimmed but the command log is retained", {
  state <- AppState(env = new.env())
  state$options$max_output_lines <- 5L
  run_command(state, "1:20")
  expect_lte(length(state$output), 5L)
  expect_equal(length(state$log), 1L)
})

test_that("plot history is capped and old files are removed", {
  state <- AppState(env = new.env())
  state$options$max_plots <- 2L
  state$plot_dir <- tempfile("rcmdr-plots-")
  dir.create(state$plot_dir)
  state$plot_prefix <- "test-plots"
  on.exit(unlink(state$plot_dir, recursive = TRUE), add = TRUE)

  for (i in 1:3) {
    run_command(state, sprintf("plot(1:%d)", i + 2))
  }
  expect_equal(length(state$plots), 2L)
  expect_equal(vapply(state$plots, `[[`, character(1), "url"),
               c("test-plots/plot-0002.png", "test-plots/plot-0003.png"))
  expect_false(file.exists(file.path(state$plot_dir, "plot-0001.png")))
})

test_that("the application UI has accessibility landmarks", {
  ui <- app_ui()
  html <- htmltools::renderTags(ui)$html

  expect_match(html, "Skip to main content")
  expect_match(html, "id=\"main-content\"")
  expect_match(html, "role=\"main\"")
  expect_match(html, "role=\"navigation\"")
  expect_match(html, "aria-live=\"polite\"")
  expect_match(html, "aria-label")
  expect_match(as.character(app_js()), "document.documentElement.lang")
})

test_that("visual regression tests are opt-in", {
  skip_if_not_installed("vdiffr")
  skip_if(Sys.getenv("RCMDRSHINY_VISUAL") != "1",
          "set RCMDRSHINY_VISUAL=1 to run visual tests")
  vdiffr::expect_doppelganger("base-scatter", function() plot(1:10))
})
