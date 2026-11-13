# sos command builder ---------------------------------------------------

sos_escape <- function(value) {
  gsub("'", "\\\\'", paste0(value))
}

sos_terms <- function(search) {
  search <- paste0(search)
  has_bar <- grepl("|", search, fixed = TRUE)
  has_amp <- grepl("&", search, fixed = TRUE)
  if (has_bar && has_amp) {
    stop('Please use only one separating operator per search, "|" or "&".',
         call. = FALSE)
  }
  separator <- if (has_bar) "|" else if (has_amp) "&" else ""
  terms <- if (nzchar(separator)) {
    trimws(strsplit(search, separator, fixed = TRUE)[[1L]])
  } else {
    trimws(search)
  }
  terms <- terms[nzchar(terms)]
  if (length(terms) == 0L) {
    stop("Please enter a non-blank search string.", call. = FALSE)
  }
  list(terms = utils::head(terms, 9L), separator = separator)
}

sos_find_call <- function(term, max_page = 20L) {
  max_page <- suppressWarnings(as.integer(max_page))
  suffix <- if (is.na(max_page) || max_page == 20L) {
    ""
  } else {
    sprintf(", maxPage=%d", max_page)
  }
  sprintf("findFn('%s'%s)", sos_escape(term), suffix)
}

sos_grep_call <- function(filter, column = "", ignore_case = TRUE) {
  column_arg <- if (identical(column, "Package") ||
                   identical(column, "Description")) {
    sprintf(", column='%s'", column)
  } else {
    ""
  }
  ignore_arg <- if (isTRUE(ignore_case)) ", ignore.case=TRUE" else ""
  sprintf("grepFn('%s', .sos%s%s)",
          sos_escape(filter), column_arg, ignore_arg)
}

build_sos_commands <- function(search, max_page = 20L, summary = FALSE,
                               xls = FALSE, filter = "", column = "",
                               ignore_case = TRUE) {
  parsed <- sos_terms(search)
  terms <- parsed$terms
  separator <- parsed$separator
  filter <- trimws(filter %||% "")

  calls <- vapply(terms, sos_find_call, character(1),
                  max_page = max_page, USE.NAMES = FALSE)

  if (length(terms) == 1L && !isTRUE(summary) && !isTRUE(xls) &&
      !nzchar(filter)) {
    return(calls)
  }

  commands <- character()
  if (length(terms) == 1L) {
    commands <- c(commands, paste0(".sos <- ", calls))
  } else {
    commands <- c(commands, paste0(".sos", seq_along(calls), " <- ", calls))
    union <- paste0(".sos", seq_along(calls), collapse = paste0(" ", separator, " "))
    commands <- c(commands, paste0(".sos <- ", union))
  }

  commands <- c(
    commands,
    if (nzchar(filter)) {
      sos_grep_call(filter, column, ignore_case)
    } else {
      ".sos"
    }
  )
  if (isTRUE(summary)) commands <- c(commands, "summary(.sos)")
  if (isTRUE(xls)) commands <- c(commands, "writeFindFn2xls(.sos)")

  if (length(terms) == 1L) {
    commands <- c(commands, "remove(.sos)")
  } else {
    commands <- c(
      commands,
      sprintf('remove(list=c(".sos", %s))',
              paste(sprintf('".sos%d"', seq_along(terms)), collapse = ", "))
    )
  }
  commands
}
