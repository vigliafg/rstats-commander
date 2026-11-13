# Report generation ----------------------------------------------------------
#
# The report collects what the session already produced: the command log, the
# captured output and the plots.  Nothing is re-evaluated when the R Markdown
# file is rendered, so no new code runs.  The Rmd file is always available; the
# HTML version needs rmarkdown and knitr.

#' Check whether HTML reports can be rendered
#' @return `TRUE` when `rmarkdown` and `knitr` are installed.
#' @keywords internal
report_html_available <- function() {
  requireNamespace("rmarkdown", quietly = TRUE) &&
    requireNamespace("knitr", quietly = TRUE) &&
    tryCatch(rmarkdown::pandoc_available(), error = function(e) FALSE)
}

report_escape <- function(x) {
  x <- paste(x, collapse = "\n")
  gsub("```", "``\\`", x, fixed = TRUE)
}

report_plot_paths <- function(state) {
  plots <- state$plots %||% list()
  paths <- vapply(plots, function(plot) {
    if (is.null(plot$file) || !file.exists(plot$file)) "" else {
      normalizePath(plot$file, winslash = "/", mustWork = FALSE)
    }
  }, character(1))
  paths[nzchar(paths)]
}

#' Build the R Markdown report source
#'
#' @param state Application state.
#' @param title Report title.
#' @param include_plots Embed the session plots.
#' @return A character vector with the R Markdown document.
#' @export
report_rmd <- function(state, title = "RcmdrShiny report",
                       include_plots = TRUE) {
  lines <- c(
    "---",
    sprintf('title: "%s"', gsub('"', '\\\\"', title)),
    sprintf('date: "%s"', Sys.Date()),
    "output: html_document",
    "---",
    "",
    "```{r setup, include=FALSE}",
    "knitr::opts_chunk$set(echo = FALSE, message = FALSE, warning = FALSE)",
    "```",
    "",
    "## Commands",
    "",
    "```{r, eval=FALSE}",
    report_escape(state$log %||% ""),
    "```",
    "",
    "## Output",
    "",
    "```",
    report_escape(state$output %||% ""),
    "```"
  )

  messages <- state$messages %||% character()
  if (length(messages) > 0L) {
    lines <- c(
      lines, "",
      "## Messages",
      "",
      "```",
      report_escape(messages),
      "```"
    )
  }

  if (isTRUE(include_plots)) {
    paths <- report_plot_paths(state)
    if (length(paths) > 0L) {
      lines <- c(
        lines, "",
        "## Plots",
        "",
        "```{r, echo=FALSE, out.width=\"100%\"}",
        sprintf("knitr::include_graphics(c(%s))",
                paste0('"', paths, '"', collapse = ", ")),
        "```"
      )
    }
  }

  lines
}

#' Write the R Markdown report to a file
#'
#' @param state Application state.
#' @param file Destination path.
#' @param title Report title.
#' @return The path, invisibly.
#' @export
write_report_rmd <- function(state, file, title = "RcmdrShiny report") {
  writeLines(report_rmd(state, title = title), file, useBytes = TRUE)
  invisible(file)
}

#' Render the report to HTML
#'
#' @param state Application state.
#' @param file Destination path.
#' @param title Report title.
#' @return The path, invisibly.
#' @export
write_report_html <- function(state, file, title = "RcmdrShiny report") {
  if (!report_html_available()) {
    stop("The 'rmarkdown' and 'knitr' packages are required for HTML reports.",
         call. = FALSE)
  }
  directory <- tempfile("rcmdrshiny-report-")
  dir.create(directory, recursive = TRUE, showWarnings = FALSE)
  source <- file.path(directory, "report.Rmd")
  write_report_rmd(state, source, title = title)
  rmarkdown::render(source, output_file = basename(file),
                    output_dir = dirname(file), quiet = TRUE,
                    envir = new.env(parent = globalenv()))
  invisible(file)
}

#' Dialog that exports the session report
#' @keywords internal
export_report_dialog <- function() {
  id <- "exportReport"
  ns <- function(x) paste0(id, "_", x)

  dialog_spec(
    id = id, title = tr("Export report"),
    help_topic = "exporting-results",
    ui = function(state, memory) {
      htmltools::tagList(
        entry_input(ns("title"), tr("Report title:"),
                    memory$title %||% "RcmdrShiny report"),
        radio_input(
          ns("format"), tr("Format"),
          c("R Markdown" = "rmd", "HTML" = "html"),
          memory$format %||% if (report_html_available()) "html" else "rmd"
        ),
        help_text(tr(
          "The report contains the command log, the output and the plots of this session. Commands are not re-executed."
        )),
        if (!report_html_available()) {
          help_text(tr("Install rmarkdown and knitr to enable the HTML format."))
        }
      )
    },
    on_ok = function(input, state) {
      title <- trim_blanks(input[[ns("title")]] %||% "")
      if (!nzchar(title)) title <- "RcmdrShiny report"
      format <- input[[ns("format")]] %||% "rmd"
      if (identical(format, "html") && !report_html_available()) {
        return(list(error = tr(
          "The 'rmarkdown' and 'knitr' packages are required for HTML reports."
        )))
      }
      list(
        memory = list(title = title, format = format),
        message = tr("The report is being prepared."),
        tab = "Script",
        report = list(format = format, title = title)
      )
    }
  )
}
