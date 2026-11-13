test_that("the help centre UI contains the search box and panes", {
  ui <- help_center_ui()
  html <- as.character(ui[[1L]])
  expect_match(html, "help_query")

  full <- paste(vapply(ui, as.character, character(1)), collapse = "\n")
  expect_match(full, "help_categories")
  expect_match(full, "help_results")
  expect_match(full, "help_topic")
  expect_match(full, "aria-live")
})

test_that("help links carry the topic id", {
  link <- help_topic_link("linear-model", "Linear model")
  expect_equal(link$attribs$`data-help-topic`, "linear-model")
  expect_match(as.character(link), "Linear model")
})

test_that("unknown related topics are skipped", {
  link <- help_topic_link_ui("definitely-not-a-topic")
  expect_null(link)
})

test_that("results and categories render their labels", {
  result <- help_result_ui(data.frame(
    id = "linear-model", title = "Linear model", category = "models",
    score = 10, snippet = "Fit a linear model", package = NA_character_,
    stringsAsFactors = FALSE
  ))
  html <- as.character(result)
  expect_match(html, "Linear model")
  expect_match(html, "help_open")
  expect_match(html, "Fit a linear model")

  category <- help_category_ui(data.frame(
    id = "models", title = "Models", order = 40L, count = 2L,
    stringsAsFactors = FALSE
  ))
  expect_match(as.character(category), "Models")
})

test_that("the inline dialog help panel exposes its actions", {
  help_unregister()
  on.exit(help_unregister(), add = TRUE)
  topic <- help_topic("linear-model")
  panel <- help_dialog_panel_ui(topic)
  html <- as.character(panel)
  expect_match(html, "Linear model")
  expect_match(html, "dialog_help_close")
  expect_match(html, "dialog_help_center")
})

test_that("dialog_spec stores the help topic", {
  spec <- dialog_spec(
    id = "demo", title = "Demo",
    ui = function(state, memory) NULL,
    on_ok = function(input, state) list(),
    help_topic = "linear-model"
  )
  expect_equal(spec$help_topic, "linear-model")
  expect_equal(help_topic_for_dialog(spec)$id, "linear-model")
})

test_that("the dialog modal offers Help when a topic exists", {
  help_unregister()
  on.exit(help_unregister(), add = TRUE)
  spec <- dialog_spec(
    id = "linearModel", title = "Linear model",
    ui = function(state, memory) NULL,
    on_ok = function(input, state) list()
  )
  html <- as.character(dialog_modal(spec))
  expect_match(html, "id=\"dialog_help\"")

  plain <- dialog_spec(
    id = "not-a-dialog", title = "Plain",
    ui = function(state, memory) NULL,
    on_ok = function(input, state) list()
  )
  expect_false(grepl("id=\"dialog_help\"", as.character(dialog_modal(plain))))
})
