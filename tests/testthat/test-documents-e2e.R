# Browser flow for document authoring (D1-D5).
#
#   RCMDRSHINY_E2E=1 Rscript -e 'testthat::test_file("tests/testthat/test-documents-e2e.R")'

documents_ready <- function() {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_if(Sys.getenv("RCMDRSHINY_E2E") != "1",
          "set RCMDRSHINY_E2E=1 to run the browser test")
}

documents_click_menu <- function(app, label) {
  js_label <- jsonlite::toJSON(label, auto_unbox = TRUE)
  app$run_js(sprintf(paste0(
    "(function(){",
    "var e=Array.from(document.querySelectorAll('.rcmdr-menu-item'))",
    ".find(function(x){return x.textContent.trim()===%s;});",
    "if(e) e.click();",
    "})();"
  ), js_label))
}

documents_ace <- function(app, value = NULL) {
  if (!is.null(value)) {
    app$run_js(sprintf(
      "ace.edit(document.querySelector('.ace_editor')).setValue(%s, 1);",
      jsonlite::toJSON(value, auto_unbox = TRUE)
    ))
    app$wait_for_idle(timeout = 30000)
  }
  app$get_js("ace.edit(document.querySelector('.ace_editor')).getValue()")
}

test_that("the document workflow works in a browser", {
  documents_ready()

  env <- new.env()
  env$mtcars <- mtcars
  ui <- RcmdrShiny:::app_ui()
  server <- function(input, output, session) {
    RcmdrShiny:::app_server(env)(input, output, session)
  }
  app <- shinytest2::AppDriver$new(
    shiny::shinyApp(ui = ui, server = server),
    name = "documents", width = 1280, height = 1000,
    load_timeout = 90000
  )
  on.exit(app$stop(), add = TRUE)

  app$wait_for_js(
    "document.querySelectorAll('.rcmdr-menu-item').length > 0",
    timeout = 60000
  )

  # Select the data set so the analysis menus are active.
  documents_click_menu(app, "Select active data set...")
  app$wait_for_js("document.getElementById('selectActiveDataSet_dataset') !== null",
                  timeout = 60000)
  app$set_inputs(selectActiveDataSet_dataset = "mtcars", wait_ = FALSE)
  app$click("dialog_ok")
  app$wait_for_js("document.querySelector('.modal') === null", timeout = 60000)
  app$wait_for_idle()

  # R Markdown mode with a chunk at a known line.
  app$set_inputs(document_mode = "rmd", wait_ = FALSE)
  app$wait_for_idle()
  documents_ace(app, paste(
    "---", "title: \"E2E\"", "output: html_document", "---", "",
    "```{r}", "summary(mtcars$mpg)", "```", "",
    sep = "\n"
  ))
  app$run_js(
    "var e=ace.edit(document.querySelector('.ace_editor')); e.gotoLine(7, 1); e.focus();"
  )
  app$wait_for_idle()
  app$run_js("rcmdrRunChunk();")
  app$wait_for_idle(timeout = 30000)
  expect_match(app$get_text("#output_text"), "Min\\.")

  # A dialog command becomes a chunk.
  documents_click_menu(app, "Active data set")
  app$wait_for_idle(timeout = 30000)
  value <- documents_ace(app)
  expect_match(value, "```\\{r\\}")
  expect_match(value, "summary\\(mtcars\\)")

  # Insert a section and remove the last chunk.
  app$click("document_section")
  app$wait_for_js("document.getElementById('insertSection_title') !== null",
                  timeout = 60000)
  app$set_inputs(insertSection_title = "Methods",
                 insertSection_level = "1", wait_ = FALSE)
  app$click("dialog_ok")
  app$wait_for_js("document.querySelector('.modal') === null", timeout = 60000)
  app$wait_for_idle()
  expect_match(documents_ace(app), "(?m)^# Methods$", perl = TRUE)

  documents_click_menu(app, "Remove last Markdown command block")
  app$wait_for_idle(timeout = 30000)
  expect_false(grepl("summary(mtcars)", documents_ace(app), fixed = TRUE))

  # Knit to HTML.
  skip_if_not(RcmdrShiny:::document_format_available("html", "rmd"),
              "Pandoc or rmarkdown not available")
  documents_ace(app, paste(
    "---", "title: \"E2E\"", "output: html_document", "---", "",
    "```{r}", "summary(mtcars$mpg)", "```", "",
    sep = "\n"
  ))
  app$click("document_knit")
  app$wait_for_js("document.getElementById('compileRmd_format') !== null",
                  timeout = 60000)
  app$set_inputs(compileRmd_format = "html", wait_ = FALSE)
  app$click("dialog_ok")
  app$wait_for_js("document.querySelector('.modal') === null", timeout = 120000)
  app$wait_for_js("document.querySelector('#report_pane iframe') !== null",
                  timeout = 120000)
  expect_match(
    app$get_js("document.querySelector('#report_pane iframe').src"),
    "document.html"
  )

  # Save as.
  path <- tempfile(fileext = ".Rmd")
  on.exit(unlink(path), add = TRUE)
  app$click("document_save_as")
  app$wait_for_js("document.getElementById('saveRmdAs_path') !== null",
                  timeout = 60000)
  app$set_inputs(saveRmdAs_path = path, wait_ = FALSE)
  app$click("dialog_ok")
  app$wait_for_js("document.querySelector('.modal') === null", timeout = 60000)
  app$wait_for_idle()
  expect_true(file.exists(path))
  expect_match(paste(readLines(path, warn = FALSE), collapse = "\n"),
               "summary\\(mtcars")
})
