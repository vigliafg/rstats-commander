test_that("the plugin registers in the dimensional analysis menu", {
  RcmdrShiny::unload_plugins()
  on.exit(RcmdrShiny::unload_plugins(), add = TRUE)

  rcmdrshiny_plugin()
  leaves <- RcmdrShiny::menu_leaves(RcmdrShiny::menu_tree())
  expect_true("pcaRobust" %in% leaves$command)
  expect_true(any(grepl("Dimensional analysis", leaves$path)))
})

test_that("the command uses PcaHubert with the selected variables", {
  commands <- build_pca_robust_commands(
    "mtcars", c("mpg", "disp"), alpha = 0.75,
    loadings = TRUE, scores = TRUE
  )
  expect_match(commands[[1L]], "PcaHubert\\(data.matrix\\(mtcars")
  expect_match(commands[[1L]], 'c\\("mpg", "disp"\\)')
  expect_match(commands[[1L]], "alpha=0.75")
  expect_match(commands[[1L]], "k=2, kmax=2, mcd=TRUE")
  expect_true(".pcaRobust@loadings" %in% commands)
  expect_true(".pcaRobust@scores" %in% commands)
})

test_that("plot commands are generated on request", {
  commands <- build_pca_robust_commands(
    "mtcars", c("mpg", "disp"), screeplot = TRUE, biplot = TRUE,
    od_plot = TRUE, sd_plot = TRUE, diagnostic = TRUE
  )
  expect_true(any(grepl("screeplot", commands)))
  expect_true(any(grepl("biplot", commands)))
  expect_true(any(grepl("Orthogonal Distance", commands)))
  expect_true(any(grepl("Score Distance", commands)))
  expect_true(any(grepl("abline", commands)))
})

test_that("invalid inputs are rejected", {
  expect_error(build_pca_robust_commands("mtcars", "mpg"), "two numeric")
  expect_error(build_pca_robust_commands("mtcars", c("mpg", "disp"), alpha = 2),
               "between 0.5 and 1")
})

test_that("the robust PCA dialog UI renders", {
  RcmdrShiny::unload_plugins()
  on.exit(RcmdrShiny::unload_plugins(), add = TRUE)
  rcmdrshiny_plugin()
  state <- RcmdrShiny::AppState(env = new.env())
  assign("mtcars", mtcars, envir = state$env)
  RcmdrShiny::active_dataset(state, "mtcars")
  spec <- RcmdrShiny::get_dialog("pcaRobust")
  expect_s3_class(spec, "RcmdrShinyDialog")
  html <- htmltools::renderTags(spec$ui(state, list()))$html
  expect_match(html, "Variables")
  result <- spec$on_ok(list(pcaRobust_variables = c("mpg", "disp")), state)
  expect_match(result$commands[[1L]], "PcaHubert")
})
