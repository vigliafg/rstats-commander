#!/usr/bin/env Rscript
# Capture screenshots used by the vignettes and the help topics.
#
# Usage:
#   RCMDRSHINY_SCREENSHOTS=1 Rscript tools/help_screenshots.R
#
# The script drives the real application with shinytest2, so it needs a
# headless browser (chromote).  Images are written to
# inst/help-topics/assets/screenshots/ and copied to vignettes/figures/.

args <- commandArgs(trailingOnly = FALSE)
hit <- grep("^--file=", args, value = TRUE)
root <- if (length(hit) == 0L) getwd() else {
  dirname(dirname(normalizePath(sub("^--file=", "", hit[[1L]]))))
}
setwd(root)

if (!identical(Sys.getenv("RCMDRSHINY_SCREENSHOTS"), "1")) {
  cat("Set RCMDRSHINY_SCREENSHOTS=1 to capture the screenshots.\n")
  quit(status = 0L)
}
if (!requireNamespace("shinytest2", quietly = TRUE) ||
    !requireNamespace("chromote", quietly = TRUE)) {
  cat("shinytest2 and chromote are required.\n")
  quit(status = 0L)
}

suppressPackageStartupMessages(library(RcmdrShiny))

asset_dir <- file.path("inst", "help-topics", "assets", "screenshots")
figure_dir <- file.path("vignettes", "figures")
dir.create(asset_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(figure_dir, recursive = TRUE, showWarnings = FALSE)

env <- new.env()
env$mtcars <- mtcars
env$mtcars$cyl <- factor(env$mtcars$cyl)

ui <- RcmdrShiny:::app_ui()
server <- function(input, output, session) {
  RcmdrShiny:::app_server(env)(input, output, session)
}

app <- shinytest2::AppDriver$new(
  shiny::shinyApp(ui = ui, server = server),
  name = "help-screenshots", width = 1280, height = 960,
  load_timeout = 90000
)
on.exit(app$stop(), add = TRUE)

app$wait_for_js("document.querySelectorAll('.rcmdr-menu-item').length > 0",
                timeout = 60000)

capture <- function(name, path = NULL) {
  destination <- file.path(asset_dir, paste0(name, ".png"))
  if (file.exists(destination)) unlink(destination)
  if (file.exists(file.path(figure_dir, paste0(name, ".png")))) {
    unlink(file.path(figure_dir, paste0(name, ".png")))
  }
  app$get_screenshot(destination)
  file.copy(destination, file.path(figure_dir, paste0(name, ".png")),
            overwrite = TRUE)
  cat("captured", name, "\n")
}

switch_tab <- function(label) {
  app$run_js(sprintf(paste0(
    "(function(){var e=Array.from(document.querySelectorAll('.nav-link'))",
    ".find(function(a){return a.textContent.trim()===%s;}); if(e)e.click();})();"
  ), jsonlite::toJSON(label, auto_unbox = TRUE)))
  app$wait_for_idle(timeout = 30000)
}

click_menu <- function(label) {
  app$run_js(sprintf(paste0(
    "(function(){var e=Array.from(document.querySelectorAll('.rcmdr-menu-item'))",
    ".find(function(x){return x.textContent.trim()===%s;}); if(e)e.click();})();"
  ), jsonlite::toJSON(label, auto_unbox = TRUE)))
  app$wait_for_js("document.querySelector('.modal') !== null", timeout = 60000)
}

# Main window.
switch_tab("Script")
capture("app-main")

# Data selection and view.
click_menu("Select active data set...")
app$wait_for_js("document.getElementById('selectActiveDataSet_dataset') !== null",
                timeout = 60000)
app$set_inputs(selectActiveDataSet_dataset = "mtcars", wait_ = FALSE)
app$click("dialog_ok")
app$wait_for_js("document.querySelector('.modal') === null", timeout = 60000)
app$wait_for_idle()

switch_tab("Data")
capture("app-data")

# Import dialog.
click_menu("from text file, clipboard, or URL...")
app$wait_for_idle()
capture("dialog-import")
app$click("dialog_cancel")
app$wait_for_idle()

# Histogram dialog and plot.
click_menu("Histogram...")
app$wait_for_idle()
capture("dialog-histogram")
app$set_inputs(Histogram_variable = "mpg", wait_ = FALSE)
app$wait_for_idle()
app$click("dialog_ok")
app$wait_for_idle(timeout = 60000)
switch_tab("Plots")
app$wait_for_idle()
capture("app-plots")

# Help tab.
switch_tab("Help")
app$set_inputs(help_query = "regression", wait_ = FALSE)
app$wait_for_idle()
app$wait_for_js("document.querySelector('.rcmdr-help-result') !== null",
                timeout = 60000)
capture("app-help")

# Document mode.
app$set_inputs(document_mode = "rmd", wait_ = FALSE)
app$wait_for_idle(timeout = 30000)
app$run_js(paste0(
  "ace.edit(document.querySelector('.ace_editor')).setValue(",
  jsonlite::toJSON(paste(
    "---", 'title: "RcmdrShiny report"', 'output: html_document', "---", "",
    "## Analysis", "",
    "```{r}", "summary(mtcars)", "```", "",
    sep = "\n"
  ), auto_unbox = TRUE),
  ", 1);"
))
app$wait_for_idle()
capture("app-document")

cat("Screenshots written to", asset_dir, "and", figure_dir, "\n")
