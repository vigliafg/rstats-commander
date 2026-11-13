test_that("the plugin registers its menus and quality-control dialogs", {
  RcmdrShiny::unload_plugins()
  on.exit(RcmdrShiny::unload_plugins(), add = TRUE)

  rcmdrshiny_plugin()
  leaves <- RcmdrShiny::menu_leaves(RcmdrShiny::menu_tree())
  expected <- c(
    "sigmaTest", "randomnessFTest", "randomnessNTest", "input2predict",
    "predict4dataset", "paretochartMenu", "pchart1Menu", "pchart2Menu",
    "pchartpMenu", "npchart1Menu", "npchart2Menu", "npchartpMenu",
    "uchart1Menu", "uchart2Menu", "uchartpMenu", "cchart1Menu",
    "cchart2Menu", "cchartpMenu", "xbar1mcMenu", "xbar2mcMenu",
    "xbarpmcMenu", "R1mcMenu", "R2mcMenu", "RpmcMenu", "S1mcMenu",
    "S2mcMenu", "SpmcMenu"
  )
  expect_true(all(expected %in% leaves$command))
  expect_true(any(grepl("Quality Control", leaves$path)))
})

test_that("phase I p-chart commands use qcc with sizes", {
  command <- build_qcc_command(
    "pistonrings", "p", "1", x1 = "diameter", n1 = "sample",
    subset = "sample > 0", title = "p-chart\nfor"
  )
  expect_match(command, "with\\(pistonrings, qcc::qcc\\(")
  expect_match(command, "data = diameter\\[sample > 0\\]", fixed = FALSE)
  expect_match(command, "sizes = sample\\[sample > 0\\]", fixed = FALSE)
  expect_match(command, 'type = "p"', fixed = TRUE)
  expect_match(command, "title = \"p-chart", fixed = TRUE)
  expect_match(command, "for diameter", fixed = TRUE)
})

test_that("phase II commands include newdata and chart.all", {
  command <- build_qcc_command(
    "data1", "xbar", "2",
    x1 = c("a", "b"), x2 = c("c", "d"),
    title = "xbar-chart\nfor"
  )
  expect_match(command, "data = cbind\\(a, b\\)")
  expect_match(command, "newdata = cbind\\(c, d\\)")
  expect_match(command, "chart.all = FALSE", fixed = TRUE)
  expect_match(command, 'type = "xbar"', fixed = TRUE)
})

test_that("phase II from parameters uses center and standard deviation", {
  command <- build_qcc_command(
    "data1", "R", "p", x2 = c("a", "b"), center = 10,
    stddev = 2, title = "R-chart\nfor"
  )
  expect_match(command, "center = 10", fixed = TRUE)
  expect_match(command, "std.dev = 2", fixed = TRUE)
  expect_match(command, "data = cbind\\(a, b\\)")
})

test_that("validation catches missing variables", {
  expect_error(build_qcc_command("d", "p", "1"), "Phase I")
  expect_error(build_qcc_command("d", "xbar", "1", x1 = "a"),
               "two variables")
})

test_that("the teaching tests produce the expected commands", {
  expect_match(
    build_sigma_command("d", "x", "less", "2", "0.9"),
    "TeachingDemos::sigma.test\\(x\\[!is.na\\(x\\)\\]"
  )
  expect_match(build_randomness_command("d", "f", "factor"),
               "tseries::runs.test\\(f\\)")
  expect_match(build_randomness_command("d", "x", "numeric"),
               "randtests::runs.test\\(x\\)")
  expect_match(build_pareto_command("d", "f"), "qicharts2::paretochart\\(f\\)")
})

test_that("prediction commands support existing and new data", {
  expect_equal(
    build_predict_existing_command("model1", "newdata"),
    "newdata$fitted.model1 <- predict(model1, newdata)"
  )
  expect_equal(
    build_predict_new_command("model1", list(x = 1, g = "a")),
    'predict(model1, newdata=data.frame(x = 1, g = "a"))'
  )
})

test_that("the UCA dialog UIs render", {
  RcmdrShiny::unload_plugins()
  on.exit(RcmdrShiny::unload_plugins(), add = TRUE)
  rcmdrshiny_plugin()
  state <- RcmdrShiny::AppState(env = new.env())
  assign("mtcars", mtcars, envir = state$env)
  RcmdrShiny::active_dataset(state, "mtcars")
  for (id in c("sigmaTest", "randomnessFTest", "randomnessNTest",
               "paretochartMenu", "predict4dataset", "input2predict",
               "pchart1Menu", "pchart2Menu", "pchartpMenu",
               "xbar1mcMenu", "xbar2mcMenu", "xbarpmcMenu")) {
    spec <- RcmdrShiny::get_dialog(id)
    expect_s3_class(spec, "RcmdrShinyDialog")
    expect_silent(htmltools::renderTags(spec$ui(state, list())))
  }
})

test_that("a QC dialog returns a qcc command", {
  RcmdrShiny::unload_plugins()
  on.exit(RcmdrShiny::unload_plugins(), add = TRUE)
  rcmdrshiny_plugin()
  state <- RcmdrShiny::AppState(env = new.env())
  assign("mtcars", mtcars, envir = state$env)
  RcmdrShiny::active_dataset(state, "mtcars")
  spec <- RcmdrShiny::get_dialog("pchart1Menu")
  result <- spec$on_ok(list(pchart1Menu_x1 = "mpg",
                            pchart1Menu_n1 = "cyl"), state)
  expect_match(result$commands, "qcc::qcc")
  expect_match(result$commands, 'type = "p"', fixed = TRUE)
})
