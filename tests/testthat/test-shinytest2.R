# Browser-level end-to-end test (Phase 0, P0.7).
#
# It is opt-in because it needs a working headless browser:
#   RCMDRSHINY_E2E=1 Rscript -e 'testthat::test_file("tests/testthat/test-shinytest2.R")'

test_that("the full Phase 0 flow works in a real browser", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_if(Sys.getenv("RCMDRSHINY_E2E") != "1",
          "set RCMDRSHINY_E2E=1 to run the browser test")

  csv <- tempfile(fileext = ".csv")
  writeLines(
    c("y,x,g", "1,2,a", "2,4,b", "3,6,a", "4,8,b", "5,10,a", "6,12,b"),
    csv
  )
  on.exit(unlink(csv), add = TRUE)

  env <- new.env()
  app <- shinytest2::AppDriver$new(
    RcmdrShiny::app(env = env),
    name = "phase0-flow",
    width = 1200,
    height = 1000,
    load_timeout = 60000
  )
  on.exit(app$stop(), add = TRUE)

  leaves <- menu_leaves(menu_tree())
  key <- function(command) leaves$key[leaves$command == command][[1L]]

  app$wait_for_js(
    "document.querySelectorAll('.rcmdr-menu-item').length > 0",
    timeout = 60000
  )

  click_menu <- function(command) {
    app$run_js(sprintf(
      "document.getElementById('%s').click();", key(command)
    ))
    app$wait_for_idle()
    app$wait_for_js(
      "document.querySelector('.modal') !== null",
      timeout = 60000
    )
  }

  click_menu("readDataSet")
  app$set_inputs(
    readDataSet_dsname = "Dataset",
    readDataSet_location = "local",
    readDataSet_path = csv,
    readDataSet_header = TRUE,
    readDataSet_stringsAsFactors = TRUE,
    readDataSet_delimiter = "commas",
    readDataSet_other = "",
    readDataSet_decimal = "period",
    readDataSet_missing = "NA"
  )
  app$click("dialog_ok")
  app$wait_for_idle()
  app$wait_for_js("document.querySelector('.modal') === null", timeout = 30000)

  expect_match(app$get_html("#dataset_badge"), "Dataset")

  click_menu("numericalSummaries")
  app$set_inputs(
    numericalSummaries_x = c("y", "x"),
    numericalSummaries_groups = "",
    numericalSummaries_mean = TRUE,
    numericalSummaries_sd = TRUE,
    numericalSummaries_se.mean = FALSE,
    numericalSummaries_var = FALSE,
    numericalSummaries_IQR = FALSE,
    numericalSummaries_cv = FALSE,
    numericalSummaries_counts = FALSE,
    numericalSummaries_skewness = FALSE,
    numericalSummaries_kurtosis = FALSE,
    numericalSummaries_quantiles = FALSE,
    numericalSummaries_quantiles_values = "0, .25, .5, .75, 1",
    numericalSummaries_type = "2"
  )
  app$click("dialog_ok")
  app$wait_for_idle()
  app$wait_for_js("document.querySelector('.modal') === null", timeout = 30000)

  app$wait_for_js(
    "document.querySelector('#output_text').innerText.includes('mean')",
    timeout = 30000
  )
  output <- app$get_text("#output_text")
  expect_match(output, "mean")
  expect_match(output, "sd")

  click_menu("linearModel")
  app$set_inputs(
    linearModel_model = "LinearModel.1",
    linearModel_lhs = "y",
    linearModel_rhs = "x",
    linearModel_subset = "",
    linearModel_weights = "",
    linearModel_remove = ""
  )
  app$click("dialog_ok")
  app$wait_for_idle()
  app$wait_for_js("document.querySelector('.modal') === null", timeout = 30000)

  expect_match(app$get_html("#model_badge"), "LinearModel.1")
  app$wait_for_js(
    "document.querySelector('#output_text').innerText.includes('Coefficients')",
    timeout = 30000
  )

  output <- app$get_text("#output_text")
  expect_match(output, "Coefficients")
  expect_match(output, "lm\\(formula = y ~ x")

  app$wait_for_js(
    "ace.edit(document.querySelector('.ace_editor')).getValue().includes('LinearModel.1 <- lm(')",
    timeout = 30000
  )
  script <- app$get_js(
    "ace.edit(document.querySelector('.ace_editor')).getValue()"
  )
  expect_match(script, "numSummary\\(")
  expect_match(script, "LinearModel.1 <- lm\\(")

  # -- Phase 3: independent-samples t-test ------------------------------
  click_menu("independentSamplesTTest")
  app$set_inputs(
    independentSamplesTTest_group = "g",
    independentSamplesTTest_response = "y",
    independentSamplesTTest_alternative = "two.sided",
    independentSamplesTTest_conf = 0.95,
    independentSamplesTTest_var_equal = FALSE,
    wait_ = FALSE
  )
  app$click("dialog_ok")
  app$wait_for_idle()
  app$wait_for_js("document.querySelector('.modal') === null", timeout = 30000)
  app$wait_for_js(
    "ace.edit(document.querySelector('.ace_editor')).getValue().includes(\"t.test(y~g\")",
    timeout = 30000
  )
  expect_match(
    app$get_js("ace.edit(document.querySelector('.ace_editor')).getValue()"),
    "t.test\\(y~g"
  )

  # -- Phase 2: compute a new variable ----------------------------------
  click_menu("Compute")
  app$set_inputs(Compute_name = "z", Compute_expression = "y + x")
  app$click("dialog_ok")
  app$wait_for_idle()
  app$wait_for_js("document.querySelector('.modal') === null", timeout = 30000)
  app$wait_for_js(
    "ace.edit(document.querySelector('.ace_editor')).getValue().includes('Dataset$z <- with(Dataset, y + x)')",
    timeout = 30000
  )
  expect_match(
    app$get_js("ace.edit(document.querySelector('.ace_editor')).getValue()"),
    "Dataset\\$z <- with\\(Dataset, y \\+ x\\)"
  )

  # -- Phase 4: histogram dialog ---------------------------------------
  click_menu("Histogram")
  app$set_inputs(
    Histogram_variable = "y",
    Histogram_group = "",
    Histogram_scale = "frequency",
    Histogram_breaks = "Sturges",
    wait_ = FALSE
  )
  app$click("dialog_ok")
  app$wait_for_idle()
  app$wait_for_js("document.querySelector('.modal') === null", timeout = 30000)

  # -- plot capture and history -----------------------------------------
  app$run_js("ace.edit(document.querySelector('.ace_editor')).setValue('with(Dataset, plot(y ~ x))')")
  Sys.sleep(1.5)
  app$click("run_all")
  app$wait_for_idle()

  switch_tab <- function(label) {
    app$run_js(sprintf(
      "Array.from(document.querySelectorAll('.nav-link')).find(function(a){return a.textContent.trim() === '%s';}).click();",
      label
    ))
    app$wait_for_idle()
  }
  switch_tab("Plots")
  app$wait_for_js(
    "document.querySelectorAll('.rcmdr-gallery img.rcmdr-thumb').length > 0",
    timeout = 30000
  )
  expect_equal(
    app$get_js("document.querySelectorAll('.rcmdr-gallery img.rcmdr-thumb').length"),
    2L
  )

  # -- data editor -------------------------------------------------------
  switch_tab("Data")
  app$set_inputs(data_mode = "edit")
  app$wait_for_js(
    "document.querySelector('#data_editor') !== null",
    timeout = 30000
  )
  expect_match(app$get_html(".rcmdr-sidebar"), "Statistics")

  # -- options dialog ----------------------------------------------------
  click_menu("Options")
  app$set_inputs(Options_digits = 4)
  app$click("dialog_ok")
  app$wait_for_idle()
  app$wait_for_js("document.querySelector('.modal') === null", timeout = 30000)

  # -- help centre -------------------------------------------------------
  switch_tab("Help")
  app$wait_for_js("document.querySelector('#help_query') !== null",
                  timeout = 30000)
  app$set_inputs(help_query = "numerical summaries")
  app$wait_for_idle()
  app$wait_for_js("document.querySelector('.rcmdr-help-result') !== null",
                  timeout = 30000)
  app$run_js("document.querySelector('.rcmdr-help-result').click()")
  app$wait_for_js(
    "document.querySelector('#help_topic_pane').innerText.includes('Numerical summaries')",
    timeout = 30000
  )
  expect_match(app$get_text("#help_topic_pane"), "numSummary")

  # -- inline help from a dialog -----------------------------------------
  click_menu("linearModel")
  app$click("dialog_help")
  app$wait_for_js("document.querySelector('.rcmdr-help-inline') !== null",
                  timeout = 30000)
  expect_match(app$get_text(".rcmdr-help-inline"), "Linear model")
  app$click("dialog_help_close")
  app$wait_for_idle()
  app$click("dialog_cancel")
  app$wait_for_idle()

  # -- about dialog ------------------------------------------------------
  click_menu("helpAboutCommander")
  expect_match(app$get_js("document.querySelector('.modal').innerText"), "RcmdrShiny")
  app$run_js("document.querySelector('.modal .btn').click()")
  app$wait_for_idle()
})
