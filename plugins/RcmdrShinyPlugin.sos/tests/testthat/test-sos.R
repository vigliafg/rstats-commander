test_that("the plugin registers in the Help menu", {
  RcmdrShiny::unload_plugins()
  on.exit(RcmdrShiny::unload_plugins(), add = TRUE)

  rcmdrshiny_plugin()
  leaves <- RcmdrShiny::menu_leaves(RcmdrShiny::menu_tree())
  expect_true("sosInit" %in% leaves$command)
  expect_true(any(grepl("Search R help system", leaves$label)))
})

test_that("a simple search produces one findFn call", {
  commands <- build_sos_commands("regression")
  expect_equal(commands, "findFn('regression')")
})

test_that("maxPage is added only when it differs from the default", {
  expect_equal(build_sos_commands("lm", max_page = 50),
               "findFn('lm', maxPage=50)")
  expect_equal(build_sos_commands("lm", max_page = 20),
               "findFn('lm')")
})

test_that("multiple terms are combined with the chosen operator", {
  commands <- build_sos_commands("lm | regression")
  expect_equal(commands[1:2], c(".sos1 <- findFn('lm')",
                                ".sos2 <- findFn('regression')"))
  expect_equal(commands[3], ".sos <- .sos1 | .sos2")
  expect_equal(tail(commands, 1),
               'remove(list=c(".sos", ".sos1", ".sos2"))')

  intersection <- build_sos_commands("lm & regression")
  expect_equal(intersection[3], ".sos <- .sos1 & .sos2")
})

test_that("summary, spreadsheet and filter add the expected steps", {
  commands <- build_sos_commands(
    "lm", summary = TRUE, xls = TRUE, filter = "stats",
    column = "Package", ignore_case = TRUE
  )
  expect_true(".sos <- findFn('lm')" %in% commands)
  expect_true("grepFn('stats', .sos, column='Package', ignore.case=TRUE)" %in%
                commands)
  expect_true("summary(.sos)" %in% commands)
  expect_true("writeFindFn2xls(.sos)" %in% commands)
  expect_equal(tail(commands, 1), "remove(.sos)")
})

test_that("invalid searches are rejected", {
  expect_error(build_sos_commands("   "), "non-blank")
  expect_error(build_sos_commands("a | b & c"), "only one")
})

test_that("at most nine terms are used", {
  commands <- build_sos_commands(paste(letters[1:12], collapse = " | "))
  expect_true(".sos9 <- findFn('i')" %in% commands)
  expect_false(any(grepl(".sos10", commands, fixed = TRUE)))
})

test_that("the search dialog UI renders", {
  RcmdrShiny::unload_plugins()
  on.exit(RcmdrShiny::unload_plugins(), add = TRUE)
  rcmdrshiny_plugin()
  state <- RcmdrShiny::AppState(env = new.env())
  spec <- RcmdrShiny::get_dialog("sosInit")
  expect_s3_class(spec, "RcmdrShinyDialog")
  html <- htmltools::renderTags(spec$ui(state, list()))$html
  expect_match(html, "Search string")
})

test_that("the search dialog returns the generated commands", {
  RcmdrShiny::unload_plugins()
  on.exit(RcmdrShiny::unload_plugins(), add = TRUE)
  rcmdrshiny_plugin()
  state <- RcmdrShiny::AppState(env = new.env())
  spec <- RcmdrShiny::get_dialog("sosInit")
  result <- spec$on_ok(list(sosInit_search = "lm | regression",
                            sosInit_max_page = 20), state)
  expect_equal(result$commands[1], ".sos1 <- findFn('lm')")
  expect_equal(result$commands[3], ".sos <- .sos1 | .sos2")
})
