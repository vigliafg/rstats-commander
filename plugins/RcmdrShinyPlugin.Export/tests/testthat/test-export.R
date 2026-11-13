test_that("the plugin registers its menus and dialogs", {
  RcmdrShiny::unload_plugins()
  on.exit(RcmdrShiny::unload_plugins(), add = TRUE)

  rcmdrshiny_plugin()
  expect_true("RcmdrShinyPlugin.Export" %in% RcmdrShiny::list_plugins())

  leaves <- RcmdrShiny::menu_leaves(RcmdrShiny::menu_tree())
  expect_true(all(c("xtableExport", "latexExport", "formatdfExport") %in%
                    leaves$command))
  expect_true(any(grepl("Export", leaves$path)))
})

test_that("xtable commands retrieve the last output", {
  object <- structure(
    list(table = data.frame(a = 1:2, b = 3:4)),
    class = "numSummary"
  )
  command <- export_xtable_command(object, list(type = "LaTeX"))
  expect_match(command, "RcmdrShiny::popOutput\\(\\)", fixed = FALSE)
  expect_match(command, ".numSummary <- RcmdrShiny::popOutput", fixed = TRUE)
  expect_match(command, "xtable\\(as.table\\(\\.numSummary\\$table\\)\\)")
  expect_false(grepl("print\\(", command))
})

test_that("HTML xtable commands always print", {
  object <- data.frame(a = 1:2)
  command <- export_xtable_command(object, list(type = "HTML"))
  expect_match(command, 'print\\(xtable\\(\\.object\\)')
  expect_match(command, 'type="html"', fixed = TRUE)
})

test_that("latex commands include the file and title arguments", {
  object <- matrix(1:4, 2, 2)
  command <- export_latex_command(object, list(file = "table", append = TRUE))
  expect_match(command, 'file="table"', fixed = TRUE)
  expect_match(command, "append=TRUE", fixed = TRUE)
  expect_match(command, 'title=""', fixed = TRUE)
  expect_match(command, "latex\\(\\.object")
})

test_that("format.df commands honour the options", {
  command <- export_formatdf_command("mtcars", list(
    dec = "3", na_blank = TRUE, math_row = TRUE, double_slash = TRUE
  ))
  expect_match(command, "format.df\\(mtcars", fixed = FALSE)
  expect_match(command, ", dec=3", fixed = TRUE)
  expect_match(command, ", na.blank=TRUE", fixed = TRUE)
  expect_match(command, ", math.row.names=TRUE", fixed = TRUE)
  expect_match(command, ", double.slash=TRUE", fixed = TRUE)
})

test_that("the last printed object is available to the dialogs", {
  RcmdrShiny::unload_plugins()
  on.exit(RcmdrShiny::unload_plugins(), add = TRUE)
  state <- RcmdrShiny::AppState(env = new.env())
  RcmdrShiny::run_command(state, "summary(1:10)")
  object <- export_last_object()
  expect_false(identical(class(object)[[1L]], "logical"))
  expect_true(export_object_available(object))
})

test_that("the export dialog UI renders", {
  RcmdrShiny::unload_plugins()
  on.exit(RcmdrShiny::unload_plugins(), add = TRUE)
  rcmdrshiny_plugin()
  state <- RcmdrShiny::AppState(env = new.env())
  spec <- RcmdrShiny::get_dialog("xtableExport")
  expect_s3_class(spec, "RcmdrShinyDialog")
  html <- htmltools::renderTags(spec$ui(state, list()))$html
  expect_match(html, "Object class")
})

test_that("the xtable dialog produces an executable command", {
  RcmdrShiny::unload_plugins()
  on.exit(RcmdrShiny::unload_plugins(), add = TRUE)
  rcmdrshiny_plugin()
  state <- RcmdrShiny::AppState(env = new.env())
  RcmdrShiny::run_command(state, "head(mtcars)")
  spec <- RcmdrShiny::get_dialog("xtableExport")
  result <- spec$on_ok(list(xtableExport_type = "latex",
                            xtableExport_floating = TRUE), state)
  expect_match(result$commands, "xtable(.object)", fixed = TRUE)
  outcome <- RcmdrShiny::run_command(state, result$commands)
  expect_equal(outcome$status, "ok")
})
