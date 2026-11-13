# F1: residual core commands and plugin command aliases.

f1_state <- function() {
  env <- new.env()
  env$D <- data.frame(
    y = c(1, 2, 3, 4),
    g = c("a", "b", "a", "b"),
    s = c("x", "y", "x", "y"),
    stringsAsFactors = FALSE
  )
  state <- AppState(env = env)
  active_dataset(state, "D")
  state
}

test_that("the Gumbel family exposes the four documented dialogs", {
  ids <- c("GumbelQuantiles", "GumbelProbabilities",
           "GumbelDistributionPlot", "GumbelDistributionSamples")
  for (id in ids) {
    spec <- get_dialog(id)
    expect_false(is.null(spec))
    expect_equal(spec$id, id)
    expect_equal(spec$help_package, "VGAM")
  }
})

test_that("Gumbel command builders use the VGAM namespace", {
  params <- list(location = "0", scale = "1")

  expect_equal(
    RcmdrShiny:::cmd_distribution_quantiles("Gumbel", c(0.5, 0.9), params),
    "VGAM::qgumbel(c(0.5,0.9), location=0, scale=1, lower.tail=TRUE)"
  )
  expect_equal(
    RcmdrShiny:::cmd_distribution_probabilities("Gumbel", c(1, 2), params),
    "VGAM::pgumbel(c(1,2), location=0, scale=1, lower.tail=TRUE)"
  )
  expect_equal(
    RcmdrShiny:::cmd_distribution_plot("Gumbel", params),
    'curve(VGAM::dgumbel(x, location=0, scale=1), xlab="x", ylab="Density")'
  )
  expect_match(
    RcmdrShiny:::cmd_distribution_samples("Gumbel", params, "Gs", 10, 1)[[1L]],
    "VGAM::rgumbel"
  )
})

test_that("a Gumbel dialog returns a runnable command", {
  spec <- get_dialog("GumbelQuantiles")
  result <- spec$on_ok(list(
    GumbelQuantiles_values = "0.5, 0.95",
    GumbelQuantiles_location = "20",
    GumbelQuantiles_scale = "4",
    GumbelQuantiles_tail = "TRUE"
  ), f1_state())

  expect_null(result$error)
  expect_match(result$commands[[1L]], "VGAM::qgumbel")
  expect_match(result$commands[[1L]], "location=20")
})

test_that("convertStrings2Factors converts character columns in place", {
  state <- f1_state()
  action <- RcmdrShiny:::direct_commands()[["convertStrings2Factors"]]
  expect_true(is.function(action))

  action(state)
  result <- get("D", envir = state$env)

  expect_true(is.factor(result$g))
  expect_true(is.factor(result$s))
  expect_true(is.numeric(result$y))
  expect_true(any(grepl("convertStrings2Factors|within", state$log)))
})

test_that("convertStrings2Factors notifies when there is nothing to convert", {
  env <- new.env()
  env$N <- data.frame(x = 1:3)
  state <- AppState(env = env)
  active_dataset(state, "N")

  action <- RcmdrShiny:::direct_commands()[["convertStrings2Factors"]]
  expect_silent(action(state))
  expect_length(state$log, 0L)
})

test_that("plugin aliases resolve to core dialogs and keep their id", {
  RcmdrShiny::unload_plugins()
  on.exit(RcmdrShiny::unload_plugins(), add = TRUE)

  RcmdrShiny::RcmdrShiny.plugin(
    name = "test-alias-plugin",
    aliases = c(pluginPie = "pieChart", pluginMissing = "notACoreCommand")
  )

  spec <- get_dialog("pluginPie")
  expect_false(is.null(spec))
  expect_equal(spec$id, "pluginPie")
  expect_equal(spec$title, get_dialog("pieChart")$title)

  expect_null(get_dialog("pluginMissing"))
})

test_that("plugin aliases count as implemented commands", {
  RcmdrShiny::unload_plugins()
  on.exit(RcmdrShiny::unload_plugins(), add = TRUE)

  RcmdrShiny::RcmdrShiny.plugin(
    name = "test-alias-plugin-2",
    aliases = c(pluginSummary = "summarizeDataSet")
  )

  expect_true("pluginSummary" %in% RcmdrShiny:::implemented_commands())
  commands <- RcmdrShiny:::direct_commands()
  expect_true("pluginSummary" %in% names(commands))
})

test_that("plugin aliases are validated", {
  expect_error(
    RcmdrShiny::RcmdrShiny.plugin(
      name = "test-alias-invalid",
      aliases = c("notNamed")
    ),
    "named character vector"
  )
})
