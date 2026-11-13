# Command builders for the Export plugin --------------------------------
#
# The generated commands follow RcmdrPlugin.Export 0.3-1.  The one deliberate
# difference is that the last printed object is retrieved with
# RcmdrShiny::popOutput() so the command also works when RcmdrShiny is loaded
# with `::` and is not attached.

export_string <- function(value) {
  value <- paste0(value)
  value <- gsub("\\\\", "\\\\\\\\", value)
  gsub('"', '\\\\"', value)
}

export_caption_args <- function(caption, caption_place = "bottom",
                                name = "caption.placement",
                                add_place = "top") {
  caption <- caption %||% ""
  if (!nzchar(caption)) return("")
  args <- paste0(', caption="', export_string(caption), '"')
  if (identical(caption_place, add_place)) {
    args <- paste0(args, ', ', name, '="', caption_place, '"')
  }
  args
}

export_file_args <- function(file, extension, append = FALSE) {
  file <- file %||% ""
  if (!nzchar(file)) return("")
  args <- paste0(', file="', export_string(file), ".", extension, '"')
  if (isTRUE(append)) args <- paste0(args, ", append=TRUE")
  args
}

export_default_digits <- function(columns, offset = 1L) {
  if (is.null(columns) || length(columns) == 0L || is.na(columns)) {
    return("2")
  }
  columns <- max(1L, as.integer(columns))
  paste0("c(", paste(rep("2", columns + offset), collapse = ","), ")")
}

export_object_columns <- function(object, object_class) {
  columns <- tryCatch({
    if (identical(object_class, "numSummary")) {
      ncol(object$table)
    } else if (identical(object_class, "summary.lm")) {
      ncol(object$coefficients)
    } else if (identical(object_class, "rcorr")) {
      ncol(object$r)
    } else if (identical(object_class, "rcorr.adjust")) {
      ncol(object$R$r)
    } else if (identical(object_class, "confint.glht")) {
      ncol(object$confint)
    } else if (identical(object_class, "factanal")) {
      ncol(object$loadings)
    } else if (identical(object_class, "reliability")) {
      ncol(object$rel.matrix)
    } else if (identical(object_class, "summary.aov") &&
               length(object) == 1L) {
      ncol(object[[1L]])
    } else if (identical(object_class, "summary.princomp")) {
      length(object$sdev)
    } else {
      ncol(object)
    }
  }, error = function(e) NULL)
  if (is.null(columns) || length(columns) == 0L || is.na(columns)) {
    NULL
  } else {
    as.integer(columns)
  }
}

export_xtable_plan <- function(object) {
  object_class <- class(object)[[1L]]
  object_name <- paste0(".", object_class)
  repeat_count <- 1L
  expressions <- NULL

  if (identical(object_class, "numSummary")) {
    expressions <- paste0("as.table(", object_name, "$table)")
  } else if (identical(object_class, "summary.multinom")) {
    expressions <- c(
      paste0("as.data.frame(", object_name, "$coefficients)"),
      paste0("as.data.frame(", object_name, "$standard.errors)")
    )
    repeat_count <- 2L
  } else if (identical(object_class, "polr")) {
    expressions <- c(
      paste0("as.data.frame(", object_name, "$coefficients)"),
      paste0("as.data.frame(", object_name, "$zeta)")
    )
    repeat_count <- 2L
  } else if (identical(object_class, "summary.polr")) {
    expressions <- paste0(object_name, "$coefficients")
  } else if (identical(object_class, "reliability")) {
    expressions <- paste0(object_name, "$rel.matrix")
  } else if (identical(object_class, "confint.glht")) {
    expressions <- paste0(object_name, "$confint")
  } else if (identical(object_class, "factanal")) {
    expressions <- paste0("as.table(", object_name, "$loadings)")
  } else if (identical(object_class, "outlier.test")) {
    expressions <- paste0("as.matrix(", object_name, "$test)")
  } else if (object_class %in% c("array", "integer", "character", "numeric")) {
    expressions <- paste0("as.data.frame(", object_name, ")")
  } else if (identical(object_class, "rcorr")) {
    expressions <- paste0(object_name, c("$r", "$n", "$P"))
    repeat_count <- 3L
  } else if (identical(object_class, "rcorr.adjust")) {
    expressions <- paste0(object_name, c("$R$r", "$R$n", "$R$P", "$P"))
    repeat_count <- 4L
  } else if (identical(object_class, "by") && is.list(object)) {
    repeat_count <- length(object)
    expressions <- vapply(seq_len(repeat_count), function(i) {
      paste0("as.matrix(", object_name, "[[", i, "]])")
    }, character(1))
  } else if (identical(object_class, "summary.princomp")) {
    expressions <- paste0("as.matrix(", object_name, "$sdev)")
  } else {
    object_name <- ".object"
    expressions <- ".object"
  }

  list(
    object_name = object_name,
    expressions = expressions,
    repeat_count = repeat_count,
    default_digits = export_default_digits(
      export_object_columns(object, object_class), offset = 1L
    )
  )
}

export_latex_plan <- function(object) {
  object_class <- class(object)[[1L]]
  object_name <- paste0(".", object_class)
  repeat_count <- 1L
  expressions <- NULL
  function_name <- "latex"

  if (identical(object_class, "numSummary")) {
    expressions <- paste0(object_name, "$table")
  } else if (identical(object_class, "summary.lm")) {
    expressions <- paste0(object_name, "$coefficients")
  } else if (identical(object_class, "summary.multinom")) {
    expressions <- c(
      paste0("as.data.frame(", object_name, "$coefficients)"),
      paste0("as.data.frame(", object_name, "$standard.errors)")
    )
    repeat_count <- 2L
  } else if (identical(object_class, "polr")) {
    expressions <- c(
      paste0("as.data.frame(", object_name, "$coefficients)"),
      paste0("as.data.frame(", object_name, "$zeta)")
    )
    repeat_count <- 2L
  } else if (identical(object_class, "summary.polr")) {
    expressions <- paste0(object_name, "$coefficients")
  } else if (identical(object_class, "reliability")) {
    expressions <- paste0(object_name, "$rel.matrix")
  } else if (identical(object_class, "confint.glht")) {
    expressions <- paste0(object_name, "$confint")
  } else if (identical(object_class, "factanal")) {
    expressions <- paste0("as.table(", object_name, "$loadings)")
  } else if (identical(object_class, "outlier.test")) {
    expressions <- paste0("as.matrix(", object_name, "$test)")
  } else if (object_class %in% c("array", "integer", "character", "numeric")) {
    expressions <- paste0("as.data.frame(", object_name, ")")
  } else if (identical(object_class, "rcorr")) {
    expressions <- object_name
    function_name <- "latex.list"
  } else if (identical(object_class, "rcorr.adjust")) {
    expressions <- paste0(object_name, c("$R$r", "$R$n", "$R$P", "$P"))
    repeat_count <- 4L
  } else if (identical(object_class, "by") && is.list(object)) {
    repeat_count <- length(object)
    expressions <- vapply(seq_len(repeat_count), function(i) {
      paste0("as.matrix(", object_name, "[[", i, "]])")
    }, character(1))
  } else if (identical(object_class, "table")) {
    expressions <- paste0("as.matrix(", object_name, ")")
  } else if (identical(object_class, "summary.aov") && length(object) == 1L) {
    expressions <- paste0(object_name, "[[1]]")
  } else if (identical(object_class, "summary.princomp")) {
    expressions <- paste0(object_name, "$sdev")
  } else {
    object_name <- ".object"
    expressions <- ".object"
  }

  list(
    object_name = object_name,
    expressions = expressions,
    repeat_count = repeat_count,
    function_name = function_name,
    default_digits = export_default_digits(
      export_object_columns(object, object_class), offset = 0L
    ),
    sanitize = identical(object_class, "numSummary") ||
      (identical(object_class, "matrix") &&
         any(grepl("%", colnames(object), fixed = TRUE)))
  )
}

export_xtable_command <- function(object, options = list()) {
  plan <- export_xtable_plan(object)
  type <- options$type %||% "LaTeX"
  caption <- options$caption %||% ""
  caption_place <- options$caption_place %||% "bottom"
  label <- options$label %||% ""
  align <- options$align %||% ""
  digits <- options$digits %||% ""
  display <- options$display %||% ""
  size <- options$size %||% "normal"
  na <- options$na %||% ""
  file <- options$file %||% ""
  append <- isTRUE(options$append)
  floating <- !identical(options$floating, FALSE)
  tab_env <- options$tab_env %||% "tabular"

  args <- export_caption_args(caption, caption_place,
                              name = "caption.placement", add_place = "top")
  if (nzchar(label)) args <- paste0(args, ', label="', export_string(label), '"')
  if (nzchar(align)) args <- paste0(args, ', align="', export_string(align), '"')
  if (nzchar(digits) && !identical(digits, "2") &&
      !identical(digits, plan$default_digits)) {
    args <- paste0(args, ", digits=", digits)
  }
  if (nzchar(display)) {
    args <- paste0(args, ', display="', export_string(display), '"')
  }
  if (nzchar(size) && !identical(size, "normal")) {
    args <- paste0(args, ', size="', export_string(size), '"')
  }
  if (nzchar(na)) args <- paste0(args, ', NA.string="', export_string(na), '"')
  file_args <- export_file_args(file,
                                if (identical(type, "HTML")) "html" else "tex",
                                append)
  args <- paste0(args, file_args)
  if (!floating) args <- paste0(args, ", floating=FALSE")
  if (identical(tab_env, "longtable")) {
    args <- paste0(args, ', tabular.environment="longtable"')
  }

  extended <- nzchar(size) && !identical(size, "normal") ||
    nzchar(na) || nzchar(file) ||
    (nzchar(caption) && identical(caption_place, "top")) ||
    !floating || identical(tab_env, "longtable") ||
    plan$repeat_count > 1L

  use_print <- identical(type, "HTML") || extended
  print_type <- if (identical(type, "HTML")) {
    ', type="html"'
  } else if (extended) {
    ', type="latex"'
  } else {
    ""
  }

  calls <- vapply(plan$expressions, function(expression) {
    call <- paste0(
      if (use_print) "print(" else "",
      "xtable(", expression, args, ")",
      if (use_print) print_type else ""
    )
    paste0("  ", call)
  }, character(1))

  paste0(
    "local({\n",
    "  ## retrieve the last printed object\n",
    "  ", plan$object_name, " <- RcmdrShiny::popOutput()\n",
    paste(calls, collapse = "\n"),
    "\n})"
  )
}

export_latex_command <- function(object, options = list()) {
  plan <- export_latex_plan(object)
  caption <- options$caption %||% ""
  caption_place <- options$caption_place %||% "bottom"
  label <- options$label %||% ""
  digits <- options$digits %||% ""
  size <- options$size %||% "normal"
  center <- options$center %||% "center"
  blank_na <- !identical(options$blank_na, FALSE)
  file <- options$file %||% ""
  append <- isTRUE(options$append)
  preview <- isTRUE(options$preview)
  longtable <- isTRUE(options$longtable)
  table_env <- !identical(options$table_env, FALSE)
  landscape <- isTRUE(options$landscape)
  booktabs <- isTRUE(options$booktabs)
  ctable <- isTRUE(options$ctable)
  vbar <- isTRUE(options$vbar)
  nomargins <- !identical(options$nomargins, FALSE)

  args <- export_caption_args(caption, caption_place,
                              name = "caption.loc", add_place = "bottom")
  if (nzchar(label)) args <- paste0(args, ', label="', export_string(label), '"')
  if (nzchar(digits) && !identical(digits, "2") &&
      !identical(digits, plan$default_digits)) {
    args <- paste0(args, ", cdec=", digits)
  }
  if (nzchar(size) && !identical(size, "normal")) {
    args <- paste0(args, ', size="', export_string(size), '"')
  }
  if (!blank_na) args <- paste0(args, ", na.blank=FALSE")
  if (longtable) args <- paste0(args, ", longtable=TRUE")
  if (!table_env) args <- paste0(args, ", table.env=FALSE")
  if (landscape) args <- paste0(args, ", landscape=TRUE")
  if (booktabs) args <- paste0(args, ", booktabs=TRUE")
  if (ctable) args <- paste0(args, ", ctable=TRUE")
  if (vbar) args <- paste0(args, ", vbar=TRUE")
  if (!nomargins) args <- paste0(args, ", nomargins=FALSE")
  if (nzchar(center) && !identical(center, "center")) {
    args <- paste0(args, ', center="', export_string(center), '"')
  }
  args <- paste0(args, ', title=""')
  file_args <- if (nzchar(file)) {
    paste0(', file="', export_string(file), '"',
           if (append) ", append=TRUE" else "")
  } else {
    ', file=""'
  }

  sanitize <- ""
  if (isTRUE(plan$sanitize)) {
    sanitize <- paste0(
      "  ## escape strings for LaTeX\n",
      "  colnames(", plan$expressions[[1L]], ") <- \n",
      "    latexTranslate(colnames(", plan$expressions[[1L]], "))"
    )
  }

  make_calls <- function(file_arguments) {
    vapply(plan$expressions, function(expression) {
      paste0(
        "  ", plan$function_name, "(", expression, file_arguments, args, ")"
      )
    }, character(1))
  }

  calls <- make_calls(file_args)
  if (preview && !nzchar(file)) {
    preview_calls <- make_calls("")
    if (plan$repeat_count > 1L) {
      preview_calls <- paste0("print(", trimws(preview_calls), ")")
    }
    calls <- c(
      calls,
      "  ## DVI preview",
      preview_calls
    )
  }

  paste0(
    "local({\n",
    "  ## retrieve the last printed object\n",
    "  ", plan$object_name, " <- RcmdrShiny::popOutput()\n",
    if (nzchar(sanitize)) paste0(sanitize, "\n") else "",
    paste(calls, collapse = "\n"),
    "\n})"
  )
}

export_formatdf_command <- function(object_name, options = list()) {
  dec <- options$dec %||% "2"
  cdec <- options$cdec %||% ""
  numeric_dollar <- !identical(options$numeric_dollar, FALSE)
  na_blank <- isTRUE(options$na_blank)
  na_dot <- isTRUE(options$na_dot)
  blank_dot <- isTRUE(options$blank_dot)
  col_just <- options$col_just %||% ""
  cdot <- isTRUE(options$cdot)
  scientific <- options$scientific %||% "c(-4,4)"
  math_row <- isTRUE(options$math_row)
  math_col <- isTRUE(options$math_col)
  double_slash <- isTRUE(options$double_slash)

  args <- ""
  if (nzchar(dec)) args <- paste0(args, ", dec=", dec)
  if (nzchar(cdec)) args <- paste0(args, ", cdec=", cdec)
  if (!numeric_dollar) args <- paste0(args, ", numeric.dollar=FALSE")
  if (na_blank) args <- paste0(args, ", na.blank=TRUE")
  if (na_dot) args <- paste0(args, ", na.dot=TRUE")
  if (blank_dot) args <- paste0(args, ", blank.dot=TRUE")
  if (nzchar(col_just)) args <- paste0(args, ", col.just=", col_just)
  if (cdot) args <- paste0(args, ", cdot=TRUE")
  if (nzchar(scientific) && !identical(scientific, "c(-4,4)")) {
    args <- paste0(args, ", scientific=", scientific)
  }
  if (math_row) args <- paste0(args, ", math.row.names=TRUE")
  if (math_col) args <- paste0(args, ", math.col.names=TRUE")
  if (double_slash) args <- paste0(args, ", double.slash=TRUE")

  paste0("format.df(", object_name, args, ")")
}

export_last_object <- function() {
  RcmdrShiny::popOutput(keep = TRUE)
}

export_object_class <- function(object) {
  if (is.null(object)) return("NULL")
  paste(class(object)[[1L]], collapse = "")
}

export_object_available <- function(object) {
  !is.null(object) && length(object) > 0L &&
    !inherits(object, "try-error") &&
    !identical(export_object_class(object), "logical")
}

export_tables <- function(state) {
  objects <- ls(envir = state$env)
  if (length(objects) == 0L) return(character())
  keep <- vapply(objects, function(name) {
    object <- get(name, envir = state$env, inherits = FALSE)
    is.data.frame(object) || is.matrix(object)
  }, logical(1))
  sort(objects[keep])
}
