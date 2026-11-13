# Last printed objects -------------------------------------------------------
#
# Rcmdr keeps a stack of printed objects so that plugins (notably Export) can
# retrieve the object behind the last output.  The stack is mirrored in the
# application state and in a package-level environment used by popOutput(),
# which generated commands call at run time.

.output_stack <- new.env(parent = emptyenv())
.output_stack$values <- list()

#' Retrieve the last printed object
#'
#' Mirrors Rcmdr's `popOutput()`: returns the most recent object printed by
#' [run_command()] and optionally removes it from the stack.
#'
#' @param keep Keep the object in the stack.
#' @return The last printed object, or `NA` when the stack is empty.
#' @export
popOutput <- function(keep = FALSE) {
  stack <- .output_stack$values
  if (length(stack) == 0L) return(NA)
  value <- stack[[1L]]
  if (!isTRUE(keep)) {
    .output_stack$values <- c(stack[-1L], list(NA))
  }
  value
}

#' @keywords internal
push_output <- function(state, value) {
  if (is.null(value)) return(invisible(NULL))
  limit <- state$options$output_stack_length %||% 10L
  stack <- c(list(value), state$output_stack %||% list())
  state$output_stack <- utils::head(stack, limit)
  .output_stack$values <- state$output_stack
  invisible(NULL)
}

# Command runner ------------------------------------------------------------
#
# This is the Shiny counterpart of Rcmdr's doItAndPrint()/justDoIt(): the
# command is appended to the log, evaluated in the session environment, and
# stdout, messages, warnings and errors are captured and stored in the state.

#' Run an R command
#'
#' Evaluates `code` in `state$env`, appends it to the command log and captures
#' its output, messages, warnings and errors.  This is the engine counterpart
#' of Rcmdr's `doItAndPrint()`.
#'
#' @param state Application state created by [AppState()].
#' @param code Character string (or vector of lines) of R code.
#' @param log Append the command to the command log.
#' @param echo Reserved: include the command in the output.
#' @param plot If `TRUE`, capture the resulting plot as a PNG.  The default
#'   `"auto"` captures only commands that look like plotting calls.
#' @return Invisibly, a list with components `status`, `code`, `output`,
#'   `warnings`, `messages`, `error` and `value`.
#' @export
run_command <- function(state, code, log = TRUE, echo = TRUE, plot = "auto") {
  if (!is_app_state(state)) {
    stop("`state` must be created with AppState().", call. = FALSE)
  }

  code <- paste(code, collapse = "\n")
  if (!nzchar(trimws(code))) {
    return(invisible(list(status = "empty", code = code)))
  }

  if (isTRUE(log)) state$log <- c(state$log, code)

  packages <- required_packages(code)
  if (length(packages) > 0L) attach_packages(packages)

  if (is_rgl_command(code)) {
    return(invisible(run_rgl_command(state, code, echo = echo)))
  }

  if (identical(plot, "auto")) plot <- is_plot_command(code)
  if (isTRUE(plot)) {
    return(invisible(run_plot_command(state, code, echo = echo)))
  }

  result <- eval_code(state, code, echo = echo)
  state_touch(state)
  invisible(result)
}

# Evaluate code and capture everything that a console would show.
eval_code <- function(state, code, echo = TRUE) {
  exprs <- tryCatch(parse(text = code), error = identity)

  if (inherits(exprs, "error")) {
    message <- conditionMessage(exprs)
    state$messages <- c(state$messages, paste0("Error: ", message))
    state$last_error <- message
    return(list(
      status = "error", code = code, output = character(),
      warnings = character(), messages = paste0("Error: ", message),
      error = message, value = NULL
    ))
  }

  output <- character()
  warnings <- character()
  messages <- character()
  error <- NULL
  value <- NULL
  visible <- FALSE

  for (expr in exprs) {
    captured <- character()
    local_value <- NULL
    local_visible <- FALSE
    local_error <- NULL

    captured <- tryCatch(
      withCallingHandlers(
        utils::capture.output({
          local_value <- withVisible(eval(expr, envir = state$env))
          local_visible <- local_value$visible
          if (local_visible) print(local_value$value)
        }),
        warning = function(w) {
          warnings <<- c(warnings, conditionMessage(w))
          invokeRestart("muffleWarning")
        },
        message = function(m) {
          messages <<- c(messages, conditionMessage(m))
          invokeRestart("muffleMessage")
        }
      ),
      error = function(e) {
        local_error <<- conditionMessage(e)
        character()
      }
    )

    output <- c(output, captured)
    if (!is.null(local_error)) {
      error <- local_error
      break
    }

    if (!is.null(local_value)) {
      value <- local_value$value
      visible <- local_visible
      remember_assignment(state, expr, value, visible)
      if (isTRUE(visible)) push_output(state, value)
    }
  }

  if (length(warnings) > 0L) {
    state$warnings <- c(state$warnings, warnings)
    state$messages <- c(state$messages, paste0("Warning: ", warnings))
  }
  if (length(messages) > 0L) {
    state$messages <- c(state$messages, messages)
  }
  if (!is.null(error)) {
    state$messages <- c(state$messages, paste0("Error: ", error))
    state$last_error <- error
  }

  state$output <- c(state$output, output)
  trim_state(state)

  list(
    status = if (is.null(error)) "ok" else "error",
    code = code,
    output = output,
    warnings = warnings,
    messages = messages,
    error = error,
    value = value,
    visible = visible
  )
}

# When the user assigns a data frame or a model, make it the active object,
# as Rcmdr does for models created from its dialogs.
remember_assignment <- function(state, expr, value, visible) {
  if (isTRUE(visible) || is.null(value)) return(invisible(NULL))
  name <- assignment_name(expr)
  if (is.null(name)) return(invisible(NULL))

  if (is.data.frame(value)) {
    state$active_dataset <- name
    state$active_model <- NULL
  } else if (inherits(value, "lm") || inherits(value, "glm")) {
    state$active_model <- name
  }
  invisible(NULL)
}

assignment_name <- function(expr) {
  if (!is.call(expr) || length(expr) < 3L) return(NULL)
  if (!identical(expr[[1L]], as.name("<-")) && !identical(expr[[1L]], as.name("="))) {
    return(NULL)
  }
  if (!is.name(expr[[2L]])) return(NULL)
  as.character(expr[[2L]])
}

# Keep memory bounded for very long sessions.  The command log is intentionally
# not trimmed because the script pane uses its indices.
trim_state <- function(state) {
  limit <- state$options$max_output_lines %||% 20000L
  if (length(state$output) > limit) {
    state$output <- utils::tail(state$output, limit)
  }
  if (length(state$messages) > limit) {
    state$messages <- utils::tail(state$messages, limit)
  }
  invisible(NULL)
}

trim_plots <- function(state) {
  limit <- state$options$max_plots %||% 50L
  if (length(state$plots) <= limit) return(invisible(NULL))
  drop <- seq_len(length(state$plots) - limit)
  for (plot in state$plots[drop]) {
    if (!is.null(plot$file) && file.exists(plot$file)) {
      unlink(plot$file)
    }
    if (!is.null(plot$url)) {
      # The served copy is also removed when possible.
      prefix <- state$plot_prefix
      if (!is.null(prefix)) {
        name <- sub(paste0("^", prefix, "/"), "", plot$url)
        path <- file.path(state$plot_dir, name)
        if (file.exists(path)) unlink(path)
      }
    }
  }
  state$plots <- utils::tail(state$plots, limit)
  invisible(NULL)
}

# Packages assumed attached by Rcmdr-generated commands.  They are attached
# lazily, only when a command actually uses one of their functions.
required_packages <- function(code) {
  packages <- character()
  if (grepl(
    "\\b(numSummary|binnedCounts|discreteCounts|mergeRows|binVariable|reshapeL2W|reshapeW2L|readXL|readSPSS|readStata|readSAS|reliability|KMeans|assignCluster|rowPercents|colPercents|totPercents|Tapply|partial\\.cor|rcorr\\.adjust)\\s*\\(",
    code
  )) {
    packages <- c(packages, "RcmdrMisc")
  }
  if (grepl("\\b(Recode|recode|Anova|leveneTest|normalityTest|powerTransform|scatterplot|scatterplotMatrix|avPlots|crPlots|influencePlot|influenceIndexPlot|Confint|Boot|DeltaMethod|compareCoefs|linearHypothesis|vif|outlierTest|crPlot3d|avPlot3d)\\s*\\(",
            code)) {
    packages <- c(packages, "car")
  }
  if (grepl("\\b(allEffects|Effect|predictorEffects)\\s*\\(", code)) {
    packages <- c(packages, "effects")
  }
  if (grepl("\\bregsubsets\\s*\\(", code)) {
    packages <- c(packages, "leaps")
  }
  if (grepl("\\b(bptest|dwtest|resettest)\\s*\\(", code)) {
    packages <- c(packages, "lmtest")
  }
  if (grepl("\\b(read\\.mtp|read\\.xport)\\s*\\(", code)) {
    packages <- c(packages, "foreign")
  }
  if (grepl("\\b(lmer|glmer)\\s*\\(", code)) {
    packages <- c(packages, "lme4")
  }
  if (grepl("\\bpolr\\s*\\(", code)) {
    packages <- c(packages, "MASS")
  }
  if (grepl("\\bmultinom\\s*\\(", code)) {
    packages <- c(packages, "nnet")
  }
  if (grepl("sem::", code, fixed = TRUE)) {
    packages <- c(packages, "sem")
  }
  if (grepl("\\bxtable\\s*\\(", code)) {
    packages <- c(packages, "xtable")
  }
  if (grepl("\\b(latex|latex\\.list|format\\.df|latexTranslate)\\s*\\(", code)) {
    packages <- c(packages, "Hmisc")
  }
  if (grepl("\\b(findFn|grepFn|writeFindFn2xls)\\s*\\(", code)) {
    packages <- c(packages, "sos")
  }
  if (grepl("\\bPcaHubert\\s*\\(", code)) {
    packages <- c(packages, "rrcov")
  }
  if (grepl("\\bhoslem\\.test\\s*\\(", code)) {
    packages <- c(packages, "ResourceSelection")
  }
  if (grepl("\\b(glht|cld)\\s*\\(", code)) {
    packages <- c(packages, "multcomp")
  }
  if (grepl("\\b(indexplot|Hist|Dotplot|Barplot|piechart|lineplot|plotMeans|discretePlot|stepwise|plotBoot|DeltaMethod)\\s*\\(",
            code)) {
    packages <- c(packages, "RcmdrMisc")
  }
  if (grepl("\\b(Boxplot|scatterplot|scatterplotMatrix|qqPlot|scatter3d|symbox|densityPlot)\\s*\\(",
            code)) {
    packages <- c(packages, "car")
  }
  if (grepl("\\bstem\\.leaf\\s*\\(", code)) {
    packages <- c(packages, "aplpack")
  }
  if (grepl("\\bxyplot\\s*\\(", code)) {
    packages <- c(packages, "lattice")
  }
  if (grepl("\\bscatter3d\\s*\\(", code)) {
    packages <- c(packages, "rgl")
  }
  unique(packages)
}

# Plot capture --------------------------------------------------------------

plot_call_pattern <- paste0(
  "\\b(",
  "plot|plot\\.default|hist|Hist|boxplot|Boxplot|barplot|Barplot|barplot2|pie|piechart|curve|",
  "density|densityPlot|dotchart|Dotplot|matplot|pairs|image|contour|persp|qqnorm|qqline|qqPlot|",
  "stripchart|stem|stem\\.leaf|scatterplot|scatterplotMatrix|plotMeans|plotmeans|indexplot|lineplot|",
  "xyplot|bwplot|densityplot|histogram|qqplot|qplot|ggplot|discretePlot|symbox|",
  "scatter3d|rgl\\.(points|lines|planes|spheres|surface3d)|monitor|",
  "plotModel|crPlots|avPlots|influencePlot|screeplot|biplot|qcc|paretochart",
  ")[[:space:]]*\\("
)

#' @keywords internal
is_plot_command <- function(code) {
  # Assigning a ggplot/lattice object does not draw anything yet.
  if (grepl("^[[:space:]]*[A-Za-z.][A-Za-z0-9._]*[[:space:]]*<-", code) &&
      !grepl("print[[:space:]]*\\(", code)) {
    return(FALSE)
  }
  any(grepl(plot_call_pattern, code, perl = TRUE))
}

run_plot_command <- function(state, code, echo = TRUE) {
  file <- tempfile("RcmdrShiny-plot-", fileext = ".png")
  grDevices::png(filename = file, width = 800, height = 600, res = 96)
  device <- grDevices::dev.cur()
  on.exit({
    if (device %in% grDevices::dev.list()) {
      try(grDevices::dev.off(device), silent = TRUE)
    }
  }, add = TRUE)

  result <- eval_code(state, code, echo = echo)
  recorded <- tryCatch(grDevices::recordPlot(), error = function(e) NULL)
  if (device %in% grDevices::dev.list()) grDevices::dev.off(device)

  index <- length(state$plots) + 1L
  url <- NULL
  if (!is.null(state$plot_dir)) {
    name <- sprintf("plot-%04d.png", index)
    destination <- file.path(state$plot_dir, name)
    if (isTRUE(file.copy(file, destination, overwrite = TRUE))) {
      url <- paste0(state$plot_prefix, "/", name)
    }
  }

  state$plots <- c(state$plots, list(list(
    file = file,
    url = url,
    code = code,
    recorded = recorded,
    time = Sys.time()
  )))
  trim_plots(state)
  state_touch(state)

  result$plot <- file
  result
}

# 3D graphics through rgl ---------------------------------------------------

is_rgl_command <- function(code) {
  grepl(
    "\\b(plot3d|scatter3d|persp3d|points3d|lines3d|segments3d|spheres3d|surface3d|triangles3d|bg3d|aspect3d|axes3d|title3d|play3d|movie3d|rgl\\.)",
    code, perl = TRUE
  )
}

run_rgl_command <- function(state, code, echo = TRUE) {
  if (!requireNamespace("rgl", quietly = TRUE)) {
    result <- eval_code(state, code, echo = echo)
    state_touch(state)
    return(result)
  }

  rgl::rgl.useNULL()
  result <- eval_code(state, code, echo = echo)

  if (isTRUE(rgl::rgl.cur() != 0L)) {
    state$rgl_scene <- tryCatch(rgl::scene3d(), error = function(e) NULL)
    state$rgl_widget <- tryCatch(rgl::rglwidget(), error = function(e) NULL)
  }

  state_touch(state)
  result
}
