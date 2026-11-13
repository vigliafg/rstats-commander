# Document authoring (D1-D5).

document_test_state <- function() {
  env <- new.env()
  env$mtcars <- mtcars
  state <- AppState(env = env)
  state
}

test_that("the document modes and extensions are consistent", {
  expect_equal(document_modes(), c("r", "rmd", "rnw"))
  expect_equal(document_extension("r"), "R")
  expect_equal(document_extension("rmd"), "Rmd")
  expect_equal(document_extension("rnw"), "Rnw")
  expect_equal(document_detect_mode("report.Rmd"), "rmd")
  expect_equal(document_detect_mode("report.Rnw"), "rnw")
  expect_equal(document_detect_mode("script.R"), "r")
  expect_equal(document_ace_mode("rmd"), "markdown")
  expect_equal(document_ace_mode("rnw"), "latex")
})

test_that("templates have valid front matter and engines", {
  rmd <- document_template("rmd", "My report")
  expect_equal(rmd[[1L]], "---")
  expect_true(any(grepl("^title: \"My report\"$", rmd)))
  expect_true(any(grepl("^output: html_document$", rmd)))
  expect_true(any(grepl("^## Analysis$", rmd)))

  rnw <- document_template("rnw", "My report")
  expect_true(any(grepl("\\\\documentclass", rnw)))
  expect_true(any(grepl("\\\\begin\\{document\\}", rnw)))
  expect_true(any(grepl("\\\\section\\{Analysis\\}", rnw)))
  expect_true(any(grepl("\\\\end\\{document\\}", rnw)))
})

test_that("chunks are appended, found and removed", {
  state <- document_test_state()
  document_new(state, "rmd", "Test")
  document_append_chunk(state, "summary(mtcars)")
  document_append_section(state, "Results", 2)
  document_append_chunk(state, c("plot(mtcars$mpg)", "abline(h = 20)"))

  text <- document_text(state)
  bounds <- document_chunk_bounds(text, "rmd")
  expect_equal(nrow(bounds), 2L)
  expect_match(text, "## Results")

  chunk <- document_chunk_at(text, bounds$start[[1L]], "rmd")
  expect_match(chunk, "summary\\(mtcars\\)")

  expect_true(document_remove_last_chunk(state, "rmd"))
  text <- document_text(state)
  expect_equal(nrow(document_chunk_bounds(text, "rmd")), 1L)
  expect_match(text, "summary\\(mtcars\\)")

  expect_true(document_remove_last_section(state, "rmd"))
  expect_false(grepl("## Results", document_text(state), fixed = TRUE))
})

test_that("chunks and sections are not confused inside other chunks", {
  text <- paste(
    "---", "title: T", "---", "",
    "## Real section", "",
    "```{r}", "## not a section", "```", "",
    "```{r}", "x <- 1", "```", "",
    sep = "\n"
  )
  expect_equal(length(document_section_lines(text, "rmd")), 1L)
})

test_that("the script is extracted from chunks", {
  state <- document_test_state()
  document_new(state, "rmd", "Test")
  document_append_chunk(state, "a <- 1")
  document_append_section(state, "More")
  document_append_chunk(state, "b <- 2")
  script <- document_script_from_chunks(document_text(state), "rmd")
  expect_equal(script, "a <- 1\n\nb <- 2")
})

test_that("switching modes preserves the code", {
  state <- document_test_state()
  document_set_text(state, "summary(mtcars)")
  document_switch_mode(state, "rmd")
  expect_equal(document_mode(state), "rmd")
  expect_match(document_text(state), "```\\{r\\}")
  expect_match(document_text(state), "summary\\(mtcars\\)")
  expect_true(isTRUE(state$options$use_markdown))

  document_switch_mode(state, "r")
  expect_equal(document_mode(state), "r")
  expect_equal(trimws(document_text(state)), "summary(mtcars)")

  document_switch_mode(state, "rnw")
  expect_equal(document_mode(state), "rnw")
  expect_match(document_text(state), "<<>>=")
  expect_true(isTRUE(state$options$use_knitr))
})

test_that("documents open and save without losing text", {
  state <- document_test_state()
  path <- tempfile(fileext = ".Rmd")
  document_new(state, "rmd", "Round trip")
  document_append_chunk(state, "summary(mtcars)")
  document_save(state, path)
  expect_true(file.exists(path))

  other <- document_test_state()
  document_open(other, path)
  expect_equal(document_mode(other), "rmd")
  expect_match(document_text(other), "summary\\(mtcars\\)")
  expect_equal(document_path(other), path)
})

test_that("the document dialogs are registered", {
  ids <- c("loadRmd", "loadRnw", "saveRmdAs", "saveRnwAs",
           "newRmd", "newRnw", "insertSection", "compileRmd")
  for (id in ids) {
    expect_false(is.null(get_dialog(id)), info = id)
  }
  implemented <- RcmdrShiny:::implemented_commands()
  expect_true(all(ids %in% implemented))
  expect_true(all(c("saveRmd", "saveRnw", "editMarkdown", "editKnitr",
                    "removeLastRmdBlock", "removeLastRmdSection",
                    "removeLastRnwBlock") %in% implemented))
})

test_that("the new-document and section dialogs update the buffer", {
  state <- document_test_state()
  spec <- get_dialog("newRmd")
  result <- spec$on_ok(list(newRmd_title = "From dialog"), state)
  expect_match(result$script, "From dialog")
  expect_equal(document_mode(state), "rmd")

  section <- get_dialog("insertSection")
  result <- section$on_ok(list(insertSection_title = "Methods",
                               insertSection_level = "1"), state)
  expect_match(result$script, "(?m)^# Methods$", perl = TRUE)
})

test_that("knitting produces HTML when Pandoc is available", {
  skip_if_not(document_format_available("html", "rmd"),
              "Pandoc or rmarkdown not available")
  state <- document_test_state()
  state$knit_dir <- tempfile("knit-")
  dir.create(state$knit_dir)
  document_new(state, "rmd", "Knit test")
  document_append_chunk(state, "summary(mtcars$mpg)")
  result <- document_knit(state, "html")
  expect_true(file.exists(result$file))
  expect_equal(tools::file_ext(result$file), "html")
  expect_equal(result$format, "html")
  expect_false(is.null(state$knit_result))
})

test_that("knitting an empty or plain script is refused", {
  state <- document_test_state()
  expect_error(document_knit(state, "html"), "Switch to")
  document_new(state, "rmd", "Empty")
  document_set_text(state, "")
  expect_error(document_knit(state, "html"), "empty")
})

test_that("the compile dialog validates the format", {
  skip_if_not(document_format_available("html", "rmd"),
              "Pandoc or rmarkdown not available")
  state <- document_test_state()
  document_new(state, "rmd", "Dialog knit")
  document_append_chunk(state, "1 + 1")
  spec <- get_dialog("compileRmd")
  result <- spec$on_ok(list(compileRmd_format = "html"), state)
  expect_null(result$error)
  expect_equal(result$tab, "Report")
  expect_false(is.null(state$knit_result))
})

test_that("knitr chunks use the Rnw markers and stay before the end", {
  state <- document_test_state()
  document_new(state, "rnw", "Rnw test")
  document_append_chunk(state, "summary(mtcars)")
  text <- document_text(state)
  expect_match(text, "<<>>=")
  expect_match(text, "(?m)^@$", perl = TRUE)
  expect_true(regexpr("summary\\(mtcars\\)", text) <
                regexpr("\\\\end\\{document\\}", text))
  expect_equal(document_script_from_chunks(text, "rnw"), "summary(mtcars)")
  expect_equal(length(document_section_lines(text, "rnw")), 1L)
})

test_that("converting between Rmd and Rnw keeps the code and uses the template", {
  state <- document_test_state()
  document_new(state, "rmd", "Convert")
  document_append_chunk(state, "summary(mtcars)")
  document_switch_mode(state, "rnw")
  text <- document_text(state)
  expect_equal(document_mode(state), "rnw")
  expect_match(text, "\\\\documentclass")
  expect_match(text, "<<>>=")
  expect_match(text, "summary\\(mtcars\\)")
  expect_false(grepl("output: html_document", text, fixed = TRUE))
})

test_that("chunks can carry labels and options", {
  state <- document_test_state()
  document_new(state, "rmd", "Options")
  document_append_chunk(state, "plot(mtcars$mpg)", "rmd",
                        label = "fig1",
                        options = c("echo=FALSE", "fig.width=6"))
  expect_match(document_text(state),
               "```\\{r fig1, echo=FALSE, fig.width=6\\}")
})

test_that("the insert-chunk dialog writes the selected options", {
  state <- document_test_state()
  document_new(state, "rmd", "Options")
  spec <- get_dialog("insertChunk")
  result <- spec$on_ok(list(
    insertChunk_label = "setup",
    insertChunk_echo = FALSE,
    insertChunk_warning = FALSE,
    insertChunk_message = FALSE,
    insertChunk_fig_width = 6,
    insertChunk_fig_height = 4
  ), state)
  expect_match(result$script,
               "```\\{r setup, echo=FALSE, warning=FALSE, message=FALSE, fig.width=6, fig.height=4\\}")
})

test_that("the bibliography is inserted once and replaced", {
  state <- document_test_state()
  document_new(state, "rmd", "Bibliography")
  document_set_bibliography(state, "first.bib")
  text <- document_text(state)
  expect_match(text, 'bibliography: "first.bib"')
  expect_equal(length(grep("^bibliography:", document_lines(text))), 1L)

  document_set_bibliography(state, "second.bib")
  text <- document_text(state)
  expect_match(text, 'bibliography: "second.bib"')
  expect_false(grepl("first.bib", text, fixed = TRUE))
  expect_equal(length(grep("^bibliography:", document_lines(text))), 1L)
})

test_that("the bibliography dialog requires an existing file", {
  state <- document_test_state()
  document_new(state, "rmd", "Bibliography")
  spec <- get_dialog("setBibliography")
  result <- spec$on_ok(list(setBibliography_path = ""), state)
  expect_match(result$error, "select a file")
  result <- spec$on_ok(list(setBibliography_path = tempfile()), state)
  expect_match(result$error, "not found")
})
