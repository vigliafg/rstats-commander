# Server-level integration test: drives the menu, import dialog, numerical
# summaries dialog and linear model dialog exactly as a user would.

set_input <- function(session, name, value) {
  do.call(session$setInputs, stats::setNames(list(value), name))
}

click <- function(session, name) {
  set_input(session, name, 0)
  set_input(session, name, 1)
}

test_that("the Phase 0 vertical slice works end to end", {
  skip_if_not_installed("shiny")

  csv <- tempfile(fileext = ".csv")
  writeLines(
    c("y,x,g", "1,2,a", "2,4,b", "3,6,a", "4,8,b", "5,10,a", "6,12,b"),
    csv
  )
  on.exit(unlink(csv), add = TRUE)

  env <- new.env()
  leaves <- menu_leaves(menu_tree())
  key <- function(command) leaves$key[leaves$command == command][[1L]]
  old_digits <- getOption("digits")
  on.exit(options(digits = old_digits), add = TRUE)

  shiny::testServer(app_server(env), {
    # -- import -----------------------------------------------------------
    click(session, key("readDataSet"))
    expect_match(class(output$dialog_body), "list")

    session$setInputs(
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
    click(session, "dialog_ok")

    expect_true(exists("Dataset", envir = env, inherits = FALSE))
    expect_equal(nrow(env$Dataset), 6L)
    expect_equal(as.character(env$Dataset$g),
                 c("a", "b", "a", "b", "a", "b"))

    # -- numerical summaries ---------------------------------------------
    click(session, key("numericalSummaries"))
    expect_match(class(output$dialog_body), "list")
    session$setInputs(
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
    click(session, "dialog_ok")

    text <- output$output_text
    expect_match(text, "mean")
    expect_match(text, "sd")
    expect_match(output$messages_text, "^$")

    # -- linear model -----------------------------------------------------
    click(session, key("linearModel"))
    expect_match(class(output$dialog_body), "list")
    session$setInputs(
      linearModel_model = "LinearModel.1",
      linearModel_lhs = "y",
      linearModel_rhs = "x",
      linearModel_subset = "",
      linearModel_weights = "",
      linearModel_remove = ""
    )
    click(session, "dialog_ok")

    expect_true(exists("LinearModel.1", envir = env, inherits = FALSE))
    expect_s3_class(env$LinearModel.1, "lm")
    expect_match(output$output_text, "Coefficients")
    expect_match(output$output_text, "lm\\(formula = y ~ x")

    # -- options dialog ---------------------------------------------------
    click(session, key("Options"))
    session$setInputs(
      Options_digits = 4,
      Options_width = 110,
      Options_edit_threshold = 10000,
      Options_stringsAsFactors = TRUE
    )
    click(session, "dialog_ok")
    expect_equal(getOption("digits"), 4)
    expect_equal(getOption("width"), 110)

    # -- data editor ------------------------------------------------------
    session$setInputs(data_mode = "edit")
    data_ui <- htmltools::renderTags(output$data_pane)$html
    expect_match(data_ui, "data_editor")

    # -- Phase 2 data dialogs --------------------------------------------
    click(session, key("Compute"))
    session$setInputs(Compute_name = "z", Compute_expression = "y + x")
    click(session, "dialog_ok")
    expect_true("z" %in% names(env$Dataset))
    expect_equal(env$Dataset$z, env$Dataset$y + env$Dataset$x)

    click(session, key("subsetDataSet"))
    session$setInputs(
      subsetDataSet_all = FALSE,
      subsetDataSet_variables = c("y", "x", "z", "g"),
      subsetDataSet_cases = "y > 2",
      subsetDataSet_name = "Subset"
    )
    click(session, "dialog_ok")
    expect_true(exists("Subset", envir = env, inherits = FALSE))
    expect_true(all(env$Subset$y > 2))
    expect_match(htmltools::renderTags(output$dataset_badge)$html, "Subset")

    click(session, key("Aggregate"))
    session$setInputs(
      Aggregate_dataset = "Aggregated",
      Aggregate_variables = c("y", "x"),
      Aggregate_by = "g",
      Aggregate_statistic = "mean",
      Aggregate_other = ""
    )
    click(session, "dialog_ok")
    expect_true(exists("Aggregated", envir = env, inherits = FALSE))
    expect_equal(nrow(env$Aggregated), 2L)
  })
})

test_that("the menus disable commands that need a data set", {
  skip_if_not_installed("shiny")
  env <- new.env()

  shiny::testServer(app_server(env), {
    html <- htmltools::renderTags(output$menus)$html
    expect_true(grepl("disabled", html, fixed = TRUE))
  })
})
