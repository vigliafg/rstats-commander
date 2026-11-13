test_that("the plugin registers the ANOVA menus", {
  RcmdrShiny::unload_plugins()
  on.exit(RcmdrShiny::unload_plugins(), add = TRUE)
  rcmdrshiny_plugin()
  leaves <- RcmdrShiny::menu_leaves(RcmdrShiny::menu_tree())
  expect_true(all(c("oneWayAnova_", "multiWayAnova_", "repMeasAnovaSetup",
                    "generalizedLinearModel_") %in% leaves$command))
})

test_that("ANOVA builders produce calls", {
  expect_match(build_aov("d", "y", "g", FALSE)[[1]], "aov\\(y ~ g")
  expect_match(build_aov("d", "y", c("a", "b"), TRUE)[[1]], "a \\* b")
  repeated <- build_repeated_measures("d", c("v1", "v2"))
  expect_match(repeated, "reshape")
  expect_match(repeated, "Error\\(id/within\\)")
})

test_that("the one-way dialog returns a command", {
  RcmdrShiny::unload_plugins()
  on.exit(RcmdrShiny::unload_plugins(), add = TRUE)
  rcmdrshiny_plugin()
  state <- RcmdrShiny::AppState(env = new.env())
  data <- data.frame(y = c(1, 2, 3, 4), g = factor(c("a", "a", "b", "b")))
  assign("data", data, envir = state$env)
  RcmdrShiny::active_dataset(state, "data")
  spec <- RcmdrShiny::get_dialog("oneWayAnova_")
  result <- spec$on_ok(list(oneWayAnova__response = "y",
                            oneWayAnova__factor = "g"), state)
  expect_match(result$commands[[1]], "aov\\(y ~ g")
})
