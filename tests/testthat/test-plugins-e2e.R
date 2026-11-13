# Browser-level end-to-end coverage of the plugin families (F12).
#
# One flow per family: the menu is present, the dialog opens, the Help button
# shows the plugin topic, and OK writes the expected command to the Script tab.
#
#   RCMDRSHINY_E2E=1 Rscript -e 'testthat::test_file("tests/testthat/test-plugins-e2e.R")'

e2e_ready <- function() {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_if(Sys.getenv("RCMDRSHINY_E2E") != "1",
          "set RCMDRSHINY_E2E=1 to run the browser tests")
}

e2e_click_menu <- function(app, command) {
  leaves <- RcmdrShiny::menu_leaves(RcmdrShiny::menu_tree())
  label <- leaves$label[leaves$command == command]
  expect_gt(length(label), 0L)
  js_label <- jsonlite::toJSON(label[[1L]], auto_unbox = TRUE)
  app$run_js(sprintf(paste0(
    "(function(){",
    "var e=Array.from(document.querySelectorAll('.rcmdr-menu-item'))",
    ".find(function(x){return x.textContent.trim()===%s;});",
    "if(e) e.click();",
    "})();"
  ), js_label))
  app$wait_for_js("document.querySelector('.modal') !== null", timeout = 60000)
}

e2e_wait_input <- function(app, id) {
  app$wait_for_js(
    sprintf("document.getElementById(%s) !== null",
            jsonlite::toJSON(id, auto_unbox = TRUE)),
    timeout = 60000
  )
  app$wait_for_idle(timeout = 30000)
}

e2e_select_dataset <- function(app, dataset) {
  e2e_click_menu(app, "selectActiveDataSet")
  e2e_wait_input(app, "selectActiveDataSet_dataset")
  app$set_inputs(selectActiveDataSet_dataset = dataset, wait_ = FALSE)
  app$click("dialog_ok")
  app$wait_for_js("document.querySelector('.modal') === null", timeout = 60000)
  app$wait_for_idle(timeout = 30000)
}

e2e_flow <- function(plugin, env, dataset, command, inputs, expected,
                     help_pattern = NULL) {
  e2e_ready()
  skip_if_not_installed(plugin)

  RcmdrShiny::unload_plugins()
  on.exit(RcmdrShiny::unload_plugins(), add = TRUE)
  # The plugin is registered in this process so menu labels can be looked up,
  # and again inside the app process by the server wrapper below.
  RcmdrShiny::load_plugin_package(plugin)

  ui <- RcmdrShiny:::app_ui()
  server <- function(input, output, session) {
    RcmdrShiny::load_plugin_package(plugin)
    RcmdrShiny:::app_server(env)(input, output, session)
  }

  app <- shinytest2::AppDriver$new(
    shiny::shinyApp(ui = ui, server = server),
    name = paste0("plugin-", plugin),
    width = 1200, height = 1000,
    load_timeout = 90000
  )
  on.exit(app$stop(), add = TRUE)

  app$wait_for_js(
    "document.querySelectorAll('.rcmdr-menu-item').length > 0",
    timeout = 60000
  )

  if (!is.null(dataset)) e2e_select_dataset(app, dataset)

  e2e_click_menu(app, command)
  e2e_wait_input(app, names(inputs)[[1L]])

  if (!is.null(help_pattern)) {
    app$click("dialog_help")
    app$wait_for_js("document.querySelector('.rcmdr-help-inline') !== null",
                    timeout = 60000)
    expect_match(app$get_text(".rcmdr-help-inline"), help_pattern)
    app$click("dialog_help_close")
    app$wait_for_idle(timeout = 30000)
  }

  for (name in names(inputs)) {
    present <- app$get_js(sprintf("document.getElementById(%s) !== null",
                                  jsonlite::toJSON(name, auto_unbox = TRUE)))
    if (isTRUE(present)) {
      do.call(app$set_inputs,
              c(stats::setNames(list(inputs[[name]]), name),
                list(wait_ = FALSE)))
    }
  }
  app$wait_for_idle(timeout = 30000)
  app$click("dialog_ok")
  app$wait_for_idle(timeout = 60000)

  app$wait_for_js(
    sprintf("ace.edit(document.querySelector('.ace_editor')).getValue().includes(%s)",
            jsonlite::toJSON(expected, auto_unbox = TRUE)),
    timeout = 60000
  )
  script <- app$get_js(
    "ace.edit(document.querySelector('.ace_editor')).getValue()"
  )
  expect_match(script, expected, fixed = TRUE)
}

test_that("graphics family: HH scatterplot", {
  env <- new.env()
  env$mtcars <- mtcars
  env$mtcars$gear <- factor(env$mtcars$gear)

  e2e_flow(
    "RcmdrShinyPlugin.HH", env, "mtcars", "scatterPlot.HH",
    list(scatterPlot.HH_x = "mpg", scatterPlot.HH_y = "wt",
         scatterPlot.HH_group = ""),
    "car::scatterplot(wt ~ mpg", help_pattern = "Scatterplot"
  )
})

test_that("models family: survival Kaplan-Meier", {
  env <- new.env()
  env$survival_data <- data.frame(
    time = c(1, 2, 3, 4, 5, 6),
    event = c(1, 0, 1, 1, 0, 1),
    group = factor(c("a", "a", "b", "b", "a", "b"))
  )

  e2e_flow(
    "RcmdrShinyPlugin.survival", env, "survival_data", "Survfit",
    list(Survfit_time = "time", Survfit_event = "event",
         Survfit_strata = "group"),
    "survival::survfit", help_pattern = "survival"
  )
})

test_that("multivariate family: FactoMineR PCA", {
  env <- new.env()
  env$mtcars <- mtcars

  e2e_flow(
    "RcmdrShinyPlugin.FactoMineR", env, "mtcars", "FactoPCA",
    list(FactoPCA_variables = c("mpg", "disp", "hp")),
    "FactoMineR::PCA", help_pattern = "PCA"
  )
})

test_that("clinical family: ROC curve", {
  env <- new.env()
  data <- mtcars
  data$am <- factor(data$am)
  env$clinical <- data

  e2e_flow(
    "RcmdrShinyPlugin.ROC", env, "clinical", "fncvpROC",
    list(fncvpROC_prediction = "mpg", fncvpROC_label = "am",
         fncvpROC_plot = FALSE, fncvpROC_ci_compute = FALSE),
    "pROC::roc", help_pattern = "ROC"
  )
})

test_that("teaching family: central limit theorem", {
  env <- new.env()

  e2e_flow(
    "RcmdrShinyPlugin.TeachingDemos", env, NULL, "centralLimitTheorem",
    list(centralLimitTheorem_distribution = "normal",
         centralLimitTheorem_n = 30, centralLimitTheorem_reps = 100,
         centralLimitTheorem_statistic = "mean"),
    "hist", help_pattern = "Central"
  )
})
