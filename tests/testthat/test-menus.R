test_that("the Rcmdr menu file is installed and parsed", {
  path <- system.file("etc", "Rcmdr-menus.txt", package = "RcmdrShiny")
  expect_true(file.exists(path))

  definitions <- read_rcmdr_menus(path)
  expect_s3_class(definitions, "data.frame")
  expect_gt(nrow(definitions), 300)
  expect_setequal(
    unique(definitions$type),
    c("menu", "item")
  )
})

test_that("the menu tree has the Rcmdr top-level menus", {
  tree <- menu_tree()
  labels <- vapply(tree, function(node) node$label, character(1))

  expect_true(all(c(
    "File", "Edit", "Data", "Statistics", "Graphs", "Models",
    "Distributions", "Tools", "Help"
  ) %in% labels))
})

test_that("menu leaves have unique HTML-safe keys", {
  leaves <- menu_leaves(menu_tree())
  expect_gt(nrow(leaves), 250)
  expect_false(anyDuplicated(leaves$key) > 0L)
  expect_false(any(grepl("[[:space:]]", leaves$key)))
  expect_true("readDataSet" %in% leaves$command)
  expect_true("numericalSummaries" %in% leaves$command)
  expect_true("linearModel" %in% leaves$command)
})

test_that("the three Phase 0 commands are enabled only when appropriate", {
  env <- new.env()
  state <- AppState(env = env)

  expect_true(command_enabled(state, "readDataSet"))
  expect_false(command_enabled(state, "numericalSummaries"))
  expect_false(command_enabled(state, "linearModel"))

  env$Dataset <- data.frame(y = 1:5, x = 1:5)
  active_dataset(state, "Dataset")
  expect_true(command_enabled(state, "numericalSummaries"))
  expect_true(command_enabled(state, "linearModel"))
})

test_that("unimplemented commands stay disabled", {
  state <- AppState(env = new.env())
  expect_false(command_enabled(state, "CloseCommander"))
  expect_false(is_implemented_command("CloseCommander"))
})

test_that("menu rendering marks unavailable entries as disabled", {
  state <- AppState(env = new.env())
  html <- as.character(menu_ui(menu_tree(), function(node) {
    command_status(state, node$command, node$activation, node$install)
  }))

  expect_true(grepl("rcmdr-menu-item", html, fixed = TRUE))
  expect_true(grepl("disabled", html, fixed = TRUE))
  expect_true(grepl("menu_item_", html, fixed = TRUE))
  expect_true(grepl("In porting", html, fixed = TRUE))
})

test_that("the parser keeps labels containing spaces", {
  row <- RcmdrShiny:::parse_menu_line(
    '    item    fileMenu        command         "Change working directory..."   Setwd   ""   ""'
  )
  expect_equal(row$label, "Change working directory...")
  expect_equal(row$command, "Setwd")
})
