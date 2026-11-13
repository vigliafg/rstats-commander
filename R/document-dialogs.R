# Document dialogs -----------------------------------------------------------
#
# Open, save, create and knit R Markdown/knitr documents.  The dialog ids match
# the Rcmdr menu commands (`loadRmd`, `saveRmdAs`, `loadRnw`, `saveRnwAs`) plus
# the new `newRmd`, `newRnw`, `insertSection` and `compileRmd`.

document_roots <- function(state) {
  c(home = "~", wd = getwd(), root = "/")
}

document_open_dialog <- function(id, mode) {
  ns <- function(x) paste0(id, "_", x)
  title <- if (identical(mode, "rnw")) {
    tr("Open knitr file")
  } else {
    tr("Open R Markdown file")
  }
  filetypes <- if (identical(mode, "rnw")) {
    c("Rnw", "rnw", "tex")
  } else {
    c("Rmd", "rmd", "md")
  }

  dialog_spec(
    id = id, title = title, help_topic = "document-authoring",
    ui = function(state, memory) {
      htmltools::tagList(
        file_input(
          ns("path"), tr("Document file:"), memory$path %||% "",
          placeholder = if (identical(mode, "rnw")) {
            "/path/to/report.Rnw"
          } else {
            "/path/to/report.Rmd"
          },
          filetypes = filetypes
        ),
        help_text(if (identical(mode, "rnw")) {
          tr("The file is loaded in the Script tab in knitr mode.")
        } else {
          tr("The file is loaded in the Script tab in R Markdown mode.")
        })
      )
    },
    observers = function(input, output, session, state, refresh) {
      file_input_observers(
        input, session, ns("path"), document_roots(state),
        guard = function() identical(state$current_dialog, id),
        filetypes = filetypes
      )
    },
    on_ok = function(input, state) {
      path <- trim_blanks(input[[ns("path")]] %||% "")
      if (!nzchar(path)) return(list(error = tr("You must select a file.")))
      if (!file.exists(path)) {
        return(list(error = sprintf(tr("File not found: %s"), path)))
      }
      result <- tryCatch(document_open(state, path), error = function(e) e)
      if (inherits(result, "error")) {
        return(list(error = conditionMessage(result)))
      }
      list(
        script = document_text(state),
        tab = tr("Script"),
        memory = list(path = path),
        message = sprintf(tr("Opened %s."), basename(path))
      )
    }
  )
}

document_save_as_dialog <- function(id, mode) {
  ns <- function(x) paste0(id, "_", x)
  title <- if (identical(mode, "rnw")) {
    tr("Save knitr file as")
  } else {
    tr("Save R Markdown file as")
  }
  extension <- document_extension(mode)
  filetypes <- if (identical(mode, "rnw")) {
    c("Rnw", "rnw")
  } else {
    c("Rmd", "rmd")
  }

  dialog_spec(
    id = id, title = title, help_topic = "document-authoring",
    ui = function(state, memory) {
      default <- memory$path %||% document_path(state) %||%
        file.path(getwd(), paste0("report.", extension))
      htmltools::tagList(
        file_save_input(
          ns("path"), tr("Save as:"), default,
          filename = paste0("report.", extension),
          filetypes = filetypes
        ),
        help_text(tr(
          "The document contains the text of the Script tab, including its code chunks."
        ))
      )
    },
    observers = function(input, output, session, state, refresh) {
      file_save_observers(
        input, session, ns("path"), document_roots(state),
        guard = function() identical(state$current_dialog, id),
        filetypes = filetypes,
        defaultPath = document_path(state) %||% getwd()
      )
    },
    on_ok = function(input, state) {
      path <- trim_blanks(input[[ns("path")]] %||% "")
      if (!nzchar(path)) return(list(error = tr("You must choose a file name.")))
      if (!grepl(paste0("\\.", extension, "$"), path, ignore.case = TRUE)) {
        path <- paste0(path, ".", extension)
      }
      result <- tryCatch(document_save(state, path), error = function(e) e)
      if (inherits(result, "error")) {
        return(list(error = conditionMessage(result)))
      }
      list(
        memory = list(path = path),
        message = sprintf(tr("Saved %s."), basename(path))
      )
    }
  )
}

document_new_dialog <- function(id, mode) {
  ns <- function(x) paste0(id, "_", x)
  title <- if (identical(mode, "rnw")) {
    tr("New knitr document")
  } else {
    tr("New R Markdown document")
  }

  dialog_spec(
    id = id, title = title, help_topic = "document-authoring",
    ui = function(state, memory) {
      htmltools::tagList(
        entry_input(ns("title"), tr("Document title:"),
                    memory$title %||% "RcmdrShiny report"),
        help_text(tr(
          "The Script tab switches to document mode. The current content is replaced."
        ))
      )
    },
    on_ok = function(input, state) {
      title <- trim_blanks(input[[ns("title")]] %||% "")
      if (!nzchar(title)) title <- "RcmdrShiny report"
      document_new(state, mode, title)
      list(
        script = document_text(state),
        tab = tr("Script"),
        memory = list(title = title),
        message = tr("New document created.")
      )
    }
  )
}

insert_section_dialog <- function() {
  id <- "insertSection"
  ns <- function(x) paste0(id, "_", x)

  dialog_spec(
    id = id, title = tr("Insert section"), help_topic = "document-authoring",
    ui = function(state, memory) {
      htmltools::tagList(
        entry_input(ns("title"), tr("Section title:"),
                    memory$title %||% "Results"),
        radio_input(
          ns("level"), tr("Level"),
          c("Section" = "1", "Subsection" = "2", "Subsubsection" = "3"),
          memory$level %||% "2", inline = TRUE
        )
      )
    },
    on_ok = function(input, state) {
      title <- trim_blanks(input[[ns("title")]] %||% "")
      if (!nzchar(title)) {
        return(list(error = tr("You must enter a section title.")))
      }
      level <- as.integer(input[[ns("level")]] %||% 2L)
      result <- tryCatch(
        document_append_section(state, title, level),
        error = function(e) e
      )
      if (inherits(result, "error")) {
        return(list(error = conditionMessage(result)))
      }
      list(
        script = document_text(state),
        memory = list(title = title, level = as.character(level)),
        message = tr("Section inserted.")
      )
    }
  )
}

compile_document_dialog <- function() {
  id <- "compileRmd"
  ns <- function(x) paste0(id, "_", x)

  dialog_spec(
    id = id, title = tr("Knit document"), help_topic = "document-authoring",
    ui = function(state, memory) {
      mode <- document_mode(state)
      formats <- if (identical(mode, "rnw")) {
        c("PDF" = "pdf")
      } else {
        c("HTML" = "html", "PDF" = "pdf", "Word" = "word")
      }
      selected <- memory$format %||% formats[[1L]]
      htmltools::tagList(
        htmltools::tags$p(sprintf(
          tr("Document: %s"),
          if (is.null(document_path(state))) {
            tr("(not saved)")
          } else {
            basename(document_path(state))
          }
        )),
        radio_input(ns("format"), tr("Output format"), formats, selected),
        help_text(tr(
          "Knitting runs the code in the document in the current session. The result opens in the Report tab."
        )),
        help_text(tr(
          "PDF needs a LaTeX installation (pdflatex); Word needs Pandoc."
        ))
      )
    },
    on_ok = function(input, state) {
      format <- input[[ns("format")]] %||% "html"
      result <- tryCatch(
        document_knit(state, format),
        error = function(e) e
      )
      if (inherits(result, "error")) {
        return(list(error = conditionMessage(result)))
      }
      list(
        memory = list(format = format),
        tab = tr("Report"),
        message = sprintf(tr("Document knitted: %s."), basename(result$file))
      )
    }
  )
}

insert_chunk_dialog <- function() {
  id <- "insertChunk"
  ns <- function(x) paste0(id, "_", x)

  dialog_spec(
    id = id, title = tr("Insert chunk"), help_topic = "document-authoring",
    ui = function(state, memory) {
      htmltools::tagList(
        entry_input(ns("label"), tr("Chunk label (optional):"),
                    memory$label %||% ""),
        checkbox_input(ns("echo"), tr("Show the code in the document"),
                       isTRUE(memory$echo %||% TRUE)),
        checkbox_input(ns("warning"), tr("Show warnings"),
                       isTRUE(memory$warning %||% TRUE)),
        checkbox_input(ns("message"), tr("Show messages"),
                       isTRUE(memory$message %||% TRUE)),
        spin_input(ns("fig_width"), tr("Figure width (inches):"),
                   memory$fig_width %||% 6, min = 1, max = 20),
        spin_input(ns("fig_height"), tr("Figure height (inches):"),
                   memory$fig_height %||% 4, min = 1, max = 20)
      )
    },
    on_ok = function(input, state) {
      options <- c(
        if (!isTRUE(input[[ns("echo")]])) "echo=FALSE",
        if (!isTRUE(input[[ns("warning")]])) "warning=FALSE",
        if (!isTRUE(input[[ns("message")]])) "message=FALSE",
        sprintf("fig.width=%s", input[[ns("fig_width")]] %||% 6),
        sprintf("fig.height=%s", input[[ns("fig_height")]] %||% 4)
      )
      label <- trim_blanks(input[[ns("label")]] %||% "")
      document_append_chunk(
        state, "# Write code here", document_mode(state),
        label = label, options = options
      )
      list(
        script = document_text(state),
        memory = list(
          label = label,
          echo = isTRUE(input[[ns("echo")]]),
          warning = isTRUE(input[[ns("warning")]]),
          message = isTRUE(input[[ns("message")]]),
          fig_width = input[[ns("fig_width")]] %||% 6,
          fig_height = input[[ns("fig_height")]] %||% 4
        ),
        message = tr("Chunk inserted.")
      )
    }
  )
}

bibliography_dialog <- function() {
  id <- "setBibliography"
  ns <- function(x) paste0(id, "_", x)

  dialog_spec(
    id = id, title = tr("Document bibliography"),
    help_topic = "document-authoring",
    ui = function(state, memory) {
      htmltools::tagList(
        file_input(
          ns("path"), tr("BibTeX file:"), memory$path %||% "",
          placeholder = "/path/to/references.bib",
          filetypes = c("bib", "Bib", "BIB")
        ),
        help_text(tr(
          "The file is added to the YAML front matter as bibliography; citations use [@key]."
        ))
      )
    },
    observers = function(input, output, session, state, refresh) {
      file_input_observers(
        input, session, ns("path"), document_roots(state),
        guard = function() identical(state$current_dialog, id),
        filetypes = c("bib", "Bib", "BIB")
      )
    },
    on_ok = function(input, state) {
      path <- trim_blanks(input[[ns("path")]] %||% "")
      if (!nzchar(path)) return(list(error = tr("You must select a file.")))
      if (!file.exists(path)) {
        return(list(error = sprintf(tr("File not found: %s"), path)))
      }
      document_set_bibliography(state, path)
      list(
        script = document_text(state),
        memory = list(path = path),
        message = tr("Bibliography added to the document.")
      )
    }
  )
}

document_dialogs <- function() {
  list(
    loadRmd = document_open_dialog("loadRmd", "rmd"),
    loadRnw = document_open_dialog("loadRnw", "rnw"),
    saveRmdAs = document_save_as_dialog("saveRmdAs", "rmd"),
    saveRnwAs = document_save_as_dialog("saveRnwAs", "rnw"),
    newRmd = document_new_dialog("newRmd", "rmd"),
    newRnw = document_new_dialog("newRnw", "rnw"),
    insertSection = insert_section_dialog(),
    insertChunk = insert_chunk_dialog(),
    setBibliography = bibliography_dialog(),
    compileRmd = compile_document_dialog()
  )
}

# Direct commands ------------------------------------------------------------

document_save_current <- function(state, mode = document_mode(state)) {
  if (is.function(state$current_document_text)) state$current_document_text()
  if (identical(mode, "r")) return(invisible(FALSE))
  path <- document_path(state)
  if (is.null(path) || !nzchar(path)) {
    if (is.function(state$open_dialog)) {
      state$open_dialog(if (identical(mode, "rnw")) "saveRnwAs" else "saveRmdAs")
    }
    return(invisible(FALSE))
  }
  document_save(state, path)
  if (!is.null(state$session)) {
    showNotification(
      sprintf(tr("Saved %s."), basename(path)),
      type = "message", duration = 3
    )
  }
  invisible(TRUE)
}

document_open_current <- function(state, mode) {
  if (is.function(state$open_dialog)) {
    state$open_dialog(if (identical(mode, "rnw")) "loadRnw" else "loadRmd")
  }
  invisible(NULL)
}

document_knit_current <- function(state) {
  if (is.function(state$current_document_text)) state$current_document_text()
  if (identical(document_mode(state), "r")) {
    if (!is.null(state$session)) {
      showNotification(
        tr("Switch to an R Markdown or knitr document first."),
        type = "warning", duration = 5
      )
    }
    return(invisible(NULL))
  }
  if (is.function(state$open_dialog)) state$open_dialog("compileRmd")
  invisible(NULL)
}

document_remove_current_chunk <- function(state) {
  if (is.function(state$current_document_text)) state$current_document_text()
  if (identical(document_mode(state), "r")) return(invisible(FALSE))
  removed <- document_remove_last_chunk(state, document_mode(state))
  if (!isTRUE(removed) && !is.null(state$session)) {
    showNotification(tr("No code chunk to remove."),
                     type = "message", duration = 4)
  }
  invisible(removed)
}

document_remove_current_section <- function(state) {
  if (is.function(state$current_document_text)) state$current_document_text()
  if (identical(document_mode(state), "r")) return(invisible(FALSE))
  removed <- document_remove_last_section(state, document_mode(state))
  if (!isTRUE(removed) && !is.null(state$session)) {
    showNotification(tr("No section to remove."),
                     type = "message", duration = 4)
  }
  invisible(removed)
}
