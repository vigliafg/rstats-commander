# Command generation for the Data menu --------------------------------------
#
# These builders mirror the R code produced by Rcmdr's data-menu.R dialogs.
# They are pure functions so that parity can be tested without Shiny.

quote_vars_data <- function(x) quote_vars(x)

#' @keywords internal
cmd_new_dataset <- function(name, rows = 10L, columns = 3L) {
  n <- max(1L, as.integer(rows))
  p <- max(1L, as.integer(columns))
  names <- paste0("V", seq_len(p))
  columns_code <- vapply(names, function(variable) {
    sprintf("%s = rep(NA_real_, %d)", variable, n)
  }, character(1))
  sprintf("%s <- data.frame(%s)", name, paste(columns_code, collapse = ", "))
}

#' @keywords internal
cmd_compute <- function(dataset, variable, expression) {
  sprintf("%s$%s <- with(%s, %s)", dataset, variable, dataset, expression)
}

#' @keywords internal
cmd_delete_variables <- function(dataset, variables) {
  lines <- vapply(variables, function(variable) {
    sprintf("  %s <- NULL", variable)
  }, character(1))
  paste0(
    dataset, " <- within(", dataset, ", {\n",
    paste(lines, collapse = "\n"),
    "\n})"
  )
}

#' @keywords internal
cmd_numeric_to_factor <- function(dataset, variables, name = NULL,
                                  labels = NULL) {
  commands <- character()
  same <- is.null(name) || !nzchar(name) || identical(name, "<same as variables>")
  for (variable in variables) {
    target <- if (same) {
      variable
    } else if (length(variables) == 1L) {
      name
    } else {
      paste0(name, variable)
    }
    rhs <- if (!is.null(labels) && length(labels) > 0L) {
      sprintf("factor(%s, labels=c(%s))", variable,
              paste0("'", labels, "'", collapse = ","))
    } else {
      sprintf("as.factor(%s)", variable)
    }
    commands <- c(commands, sprintf("%s <- within(%s, {\n  %s <- %s\n})",
                                    dataset, dataset, target, rhs))
  }
  commands
}

#' @keywords internal
cmd_character_to_factor <- function(dataset, variables, name = NULL) {
  cmd_numeric_to_factor(dataset, variables, name = name, labels = NULL)
}

# Rcmdr's convertStrings2Factors() converts every character column in place.
#' @keywords internal
cmd_convert_strings_to_factors <- function(dataset, variables) {
  variables <- variables[nzchar(variables)]
  if (length(variables) == 0L) return(character())
  cmd_numeric_to_factor(dataset, variables, name = NULL, labels = NULL)
}

#' @keywords internal
cmd_bin_variable <- function(dataset, variable, new_variable, bins = 3L,
                             method = "intervals", labels = NULL) {
  labels_code <- if (is.null(labels)) {
    "FALSE"
  } else if (identical(labels, "ranges")) {
    "NULL"
  } else {
    sprintf("c(%s)", paste0("'", labels, "'", collapse = ","))
  }
  sprintf(
    "%s$%s <- with(%s, binVariable(%s, bins=%d, method='%s', labels=%s))",
    dataset, new_variable, dataset, variable, as.integer(bins),
    method, labels_code
  )
}

#' @keywords internal
cmd_reorder_factor <- function(dataset, variable, name, levels,
                               ordered = FALSE) {
  sprintf(
    "%s$%s <- with(%s, factor(%s, levels=c(%s)%s))",
    dataset, name, dataset, variable,
    paste0("'", levels, "'", collapse = ","),
    if (isTRUE(ordered)) ", ordered=TRUE" else ""
  )
}

#' @keywords internal
cmd_standardize <- function(dataset, variables) {
  quoted <- paste0('"', variables, '"', collapse = ",")
  assignments <- vapply(rev(seq_along(variables)), function(i) {
    sprintf("    Z.%s <- .Z[,%d]", variables[[i]], i)
  }, character(1))
  paste0(
    dataset, " <- local({\n",
    "  .Z <- scale(", dataset, "[,c(", quoted, ")])\n",
    "  within(", dataset, ", {\n",
    paste(assignments, collapse = "\n"),
    "\n  })\n})"
  )
}

#' @keywords internal
cmd_recode <- function(dataset, variables, name, directives,
                       as_factor = FALSE, to_value = "=",
                       interval = ":", separator = ";") {
  directives <- gsub("'", '"', directives)
  directives <- gsub("\n", paste0(separator, " "), directives)
  directives <- sub(paste0(" *", separator, " *$"), "", directives)
  process <- function(recode) {
    parts <- strsplit(recode, "=", fixed = TRUE)[[1L]]
    if (grepl(",", parts[[1L]], fixed = TRUE)) {
      paste0("c(", parts[[1L]], ") = ", paste(parts[-1L], collapse = "="))
    } else {
      paste(parts, collapse = "=")
    }
  }
  pieces <- strsplit(directives, separator, fixed = TRUE)[[1L]]
  pieces <- vapply(pieces, process, character(1))
  directives <- paste(pieces, collapse = separator)

  multiple <- length(variables) > 1L
  lines <- vapply(rev(variables), function(variable) {
    target <- if (multiple) paste0(name, variable) else name
    sprintf(
      "  %s <- Recode(%s, '%s', as.factor=%s, to.value=\"%s\", interval=\"%s\", separator=\"%s\")",
      target, variable, directives, isTRUE(as_factor), to_value,
      interval, separator
    )
  }, character(1))

  paste0(dataset, " <- within(", dataset, ", {\n",
         paste(lines, collapse = "\n"), "\n})")
}

#' @keywords internal
cmd_export_data <- function(dataset, file, sep = ",",
                            col_names = TRUE, row_names = FALSE,
                            quote = TRUE, na = "NA") {
  sprintf(
    "write.table(%s, \"%s\", sep=\"%s\", col.names=%s, row.names=%s, quote=%s, na=\"%s\")",
    dataset, file, sep, isTRUE(col_names), isTRUE(row_names),
    isTRUE(quote), na
  )
}

#' @keywords internal
cmd_filter_na <- function(dataset, new_name, variables = NULL) {
  if (is.null(variables) || length(variables) == 0L) {
    sprintf("%s <- na.omit(%s)", new_name, dataset)
  } else {
    sprintf("%s <- na.omit(%s[,c(%s)])", new_name, dataset,
            paste0('"', variables, '"', collapse = ","))
  }
}

#' @keywords internal
cmd_subset_dataset <- function(dataset, new_name, variables = NULL,
                               cases = NULL) {
  select <- if (is.null(variables) || length(variables) == 0L) {
    ""
  } else {
    paste0(", select=c(", paste(variables, collapse = ","), ")")
  }
  subset <- if (is.null(cases) || !nzchar(trimws(cases))) {
    ""
  } else {
    paste0(", subset=", cases)
  }
  sprintf("%s <- subset(%s%s%s)", new_name, dataset, subset, select)
}

#' @keywords internal
cmd_set_case_names <- function(dataset, variable) {
  c(
    sprintf('row.names(%s) <- as.character(%s$%s)', dataset, dataset, variable),
    sprintf("%s$%s <- NULL", dataset, variable)
  )
}

#' @keywords internal
cmd_rename_variables_at <- function(dataset, positions, new) {
  sprintf(
    'names(%s)[c(%s)] <- c(%s)',
    dataset, paste(positions, collapse = ","),
    paste0('"', new, '"', collapse = ",")
  )
}

#' @keywords internal
cmd_set_contrasts <- function(dataset, variable, type) {
  sprintf('contrasts(%s$%s) <- "%s"', dataset, variable, type)
}

#' @keywords internal
cmd_stack <- function(dataset, variables, new_dataset,
                      variable_name = "variable", factor_name = "factor") {
  c(
    sprintf('%s <- stack(%s[, c(%s)])', new_dataset, dataset,
            paste0('"', variables, '"', collapse = ",")),
    sprintf('names(%s) <- c("%s", "%s")',
            new_dataset, variable_name, factor_name)
  )
}

#' @keywords internal
cases_select <- function(dataset, df, cases) {
  tokens <- scan(text = gsub(",", " ", cases), what = "", quiet = TRUE)
  if (length(tokens) == 0L) return(list(error = tr("No rows to select")))

  numbers <- suppressWarnings(as.numeric(tokens))
  if (!anyNA(numbers)) {
    bad <- numbers[!numbers %in% seq_len(nrow(df))]
    if (length(bad) > 0L) {
      return(list(error = paste(tr("bad row numbers:"),
                                paste(bad, collapse = ", "))))
    }
  } else {
    bad <- tokens[!tokens %in% rownames(df)]
    if (length(bad) > 0L) {
      return(list(error = paste(tr("bad row names:"),
                                paste(bad, collapse = ", "))))
    }
  }
  list(value = paste0("c(", paste0("'", tokens, "'", collapse = ", "), ")"))
}

#' @keywords internal
cmd_remove_rows <- function(dataset, new_name, remove_rows) {
  sprintf("%s <- %s[%s,]", new_name, dataset, remove_rows)
}

#' @keywords internal
cmd_select_rows <- function(dataset, new_name, select_rows, ncol) {
  suffix <- if (ncol == 1L) ", drop = FALSE" else ""
  sprintf("%s <- %s[%s, %s]", new_name, dataset, select_rows, suffix)
}

#' @keywords internal
cmd_merge <- function(first, second, new_name, direction = "rows",
                      common = FALSE) {
  if (identical(direction, "rows")) {
    sprintf("%s <- mergeRows(%s, %s, common.only=%s)",
            new_name, first, second, isTRUE(common))
  } else {
    c(
      sprintf('%s <- merge(%s, %s, all=%s, by="row.names")',
              new_name, first, second, !isTRUE(common)),
      sprintf("rownames(%s) <- %s$Row.names", new_name, new_name),
      sprintf("%s$Row.names <- NULL", new_name)
    )
  }
}

#' @keywords internal
cmd_aggregate <- function(dataset, new_name, variables, by, fun = "mean") {
  response <- if (length(variables) > 1L) {
    paste0("cbind(", paste(variables, collapse = ", "), ")")
  } else {
    variables
  }
  sprintf('%s <- aggregate(%s ~ %s, data=%s, FUN=%s)',
          new_name, response, paste(by, collapse = " + "), dataset, fun)
}

#' @keywords internal
cmd_drop_levels <- function(dataset, variables = NULL) {
  if (is.null(variables) || length(variables) == 0L) {
    sprintf("%s <- droplevels(%s)", dataset, dataset)
  } else {
    lines <- vapply(variables, function(variable) {
      sprintf("  %s <- droplevels(%s)", variable, variable)
    }, character(1))
    paste0(dataset, " <- within(", dataset, ", {\n",
           paste(lines, collapse = "\n"), "\n})")
  }
}

#' @keywords internal
cmd_sort <- function(dataset, new_name, keys, decreasing = FALSE) {
  sprintf("%s <- with(%s, %s[order(%s, decreasing=%s), ])",
          new_name, dataset, dataset, paste(keys, collapse = ", "),
          isTRUE(decreasing))
}

#' @keywords internal
cmd_reshape_long2wide <- function(dataset, new_name, id, within,
                                  varying, ignore = NULL) {
  quote1 <- function(x) {
    if (length(x) == 1L) paste0('"', x, '"')
    else paste0("c(", paste0('"', x, '"', collapse = ", "), ")")
  }
  ignore_code <- if (is.null(ignore) || length(ignore) == 0L) {
    ""
  } else {
    paste0(", ignore=", quote1(ignore))
  }
  sprintf('%s <- reshapeL2W(%s, within=%s, id="%s", varying=%s%s)',
          new_name, dataset, quote1(within), id, quote1(varying), ignore_code)
}

#' @keywords internal
cmd_reshape_wide2long <- function(dataset, new_name, within, responses,
                                  levels = NULL, ignore = NULL,
                                  id = "id") {
  if (is.null(levels)) levels <- paste0("Level-", seq_along(responses))
  ignore_code <- if (is.null(ignore) || length(ignore) == 0L) {
    ""
  } else {
    paste0(", ignore=", paste0('c(', paste0('"', ignore, '"', collapse = ", "), ')'))
  }
  sprintf(
    '%s <- reshapeW2L(%s, within="%s", levels=list(%s=c(%s)), varying=list(%s=c(%s))%s, id="%s")',
    new_name, dataset, within, within,
    paste0('"', levels, '"', collapse = ", "),
    within, paste0('"', responses, '"', collapse = ", "),
    ignore_code, id
  )
}

#' @keywords internal
cmd_read_package <- function(dataset, package) {
  sprintf('data(%s, package="%s")', dataset, package)
}

#' @keywords internal
cmd_add_obs_numbers <- function(dataset, nrow) {
  sprintf("%s$ObsNumber <- 1:%d", dataset, as.integer(nrow))
}

# Import commands -----------------------------------------------------------

#' @keywords internal
cmd_import_excel <- function(dataset, file, sheet = 1, header = TRUE,
                             rownames = FALSE, na = "", stringsAsFactors = FALSE) {
  sheet_code <- if (is.numeric(sheet)) as.character(as.integer(sheet)) else paste0('"', sheet, '"')
  sprintf(
    'readXL("%s", rownames=%s, header=%s, na="%s", sheet=%s, stringsAsFactors=%s)',
    file, isTRUE(rownames), isTRUE(header), na, sheet_code,
    isTRUE(stringsAsFactors)
  )
}

#' @keywords internal
cmd_import_sas <- function(dataset, file, stringsAsFactors = TRUE, rownames = FALSE) {
  sprintf('readSAS("%s", stringsAsFactors=%s, rownames=%s)',
          file, isTRUE(stringsAsFactors), isTRUE(rownames))
}

#' @keywords internal
cmd_import_spss <- function(dataset, file, rownames = TRUE,
                            stringsAsFactors = TRUE, tolower = TRUE) {
  sprintf('readSPSS("%s", rownames=%s, stringsAsFactors=%s, tolower=%s)',
          file, isTRUE(rownames), isTRUE(stringsAsFactors), isTRUE(tolower))
}

#' @keywords internal
cmd_import_stata <- function(dataset, file, convert_dates = TRUE,
                             stringsAsFactors = TRUE, rownames = FALSE) {
  sprintf('readStata("%s", convert.dates=%s, stringsAsFactors=%s, rownames=%s)',
          file, isTRUE(convert_dates), isTRUE(stringsAsFactors), isTRUE(rownames))
}

#' @keywords internal
cmd_import_minitab <- function(dataset, file) {
  sprintf('%s <- as.data.frame(read.mtp("%s"))', dataset, file)
}

#' @keywords internal
cmd_import_sas_xport <- function(dataset, file) {
  c(
    sprintf('.Datasets <- read.xport("%s")', file),
    sprintf('%s <- .Datasets[[1]]', dataset),
    "remove(.Datasets)"
  )
}
