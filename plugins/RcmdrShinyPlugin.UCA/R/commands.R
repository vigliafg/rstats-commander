# Command builders for the UCA plugin ----------------------------------

uca_trim_subset <- function(subset) {
  subset <- trimws(subset %||% "")
  if (identical(subset, "<all valid cases>")) "" else subset
}

uca_data_expression <- function(variables, multicolumn, subset = "") {
  if (length(variables) == 0L) return("")
  data <- if (isTRUE(multicolumn)) {
    paste0("cbind(", paste(variables, collapse = ", "), ")")
  } else {
    variables[[1L]]
  }
  subset <- uca_trim_subset(subset)
  if (nzchar(subset)) {
    data <- paste0(data, "[", subset, if (isTRUE(multicolumn)) ", " else "", "]")
  }
  data
}

uca_sizes_expression <- function(variable, subset = "") {
  subset <- uca_trim_subset(subset)
  if (!nzchar(variable)) return("")
  if (nzchar(subset)) paste0(variable, "[", subset, "]") else variable
}

uca_graph_title <- function(title, variables, multicolumn, subset = "") {
  variables <- if (isTRUE(multicolumn)) {
    paste0("(", paste(variables, collapse = ","), ")")
  } else {
    paste(variables, collapse = ",")
  }
  title <- paste(title, variables)
  subset <- uca_trim_subset(subset)
  if (nzchar(subset)) {
    title <- paste0(title, "[", subset, if (isTRUE(multicolumn)) ", " else "", "]")
  }
  title <- gsub("\n", "\\\\n", title)
  gsub('"', '\\\\"', title)
}

build_qcc_command <- function(dataset, type, phase = c("1", "2", "p"),
                              x1 = character(), n1 = "",
                              subset = "", x2 = character(), n2 = "",
                              subset2 = "", center = "", stddev = "",
                              title = "Control chart", plot_all = FALSE,
                              renumber = FALSE) {
  phase <- match.arg(phase)
  multicolumn <- type %in% c("R", "S", "xbar")
  with_sizes <- type %in% c("c", "np", "p", "u")

  if (length(x1) == 0L && phase %in% c("1", "2")) {
    stop("No data variable was selected (Phase I).", call. = FALSE)
  }
  if (length(x2) == 0L && phase %in% c("2", "p")) {
    stop("No data variable was selected (Phase II).", call. = FALSE)
  }
  if (with_sizes && phase %in% c("1", "2") && !nzchar(n1)) {
    stop("No sample size variable was selected (Phase I).", call. = FALSE)
  }
  if (with_sizes && phase %in% c("2", "p") && !nzchar(n2)) {
    stop("No sample size variable was selected (Phase II).", call. = FALSE)
  }
  if (phase %in% c("1", "2") && multicolumn && length(x1) < 2L) {
    stop("Select at least two variables (Phase I).", call. = FALSE)
  }
  if (phase %in% c("2", "p") && multicolumn && length(x2) < 2L) {
    stop("Select at least two variables (Phase II).", call. = FALSE)
  }
  if (identical(phase, "p")) {
    center <- suppressWarnings(as.numeric(center))
    if (is.na(center)) {
      stop("No valid numeric value has been provided for the center parameter.",
           call. = FALSE)
    }
  }

  data1 <- uca_data_expression(x1, multicolumn, subset)
  data2 <- uca_data_expression(x2, multicolumn, subset2)
  sizes1 <- uca_sizes_expression(n1, subset)
  sizes2 <- uca_sizes_expression(n2, subset2)

  args <- character()
  if (phase %in% c("1", "2")) {
    args <- c(args, paste0("data = ", data1))
    if (with_sizes) args <- c(args, paste0("sizes = ", sizes1))
  }
  if (identical(phase, "2")) {
    args <- c(args, paste0("newdata = ", data2))
    if (with_sizes) args <- c(args, paste0("new.sizes = ", sizes2))
  }
  if (identical(phase, "p")) {
    args <- c(args, paste0("data = ", data2))
    if (with_sizes) args <- c(args, paste0("sizes = ", sizes2))
    args <- c(args, paste0("center = ", format(center, trim = TRUE)))
    stddev <- trimws(stddev %||% "")
    if (nzchar(stddev)) args <- c(args, paste0("std.dev = ", stddev))
  }
  args <- c(args, sprintf('type = "%s"', type))
  title <- uca_graph_title(
    title, if (identical(phase, "1")) x1 else x2, multicolumn,
    if (identical(phase, "1")) subset else subset2
  )
  args <- c(args, sprintf('title = "%s"', title))
  if (identical(phase, "2") && !isTRUE(plot_all)) {
    args <- c(args, "chart.all = FALSE")
  }
  if (isTRUE(renumber) && phase %in% c("2", "p")) {
    data <- if (identical(phase, "2")) data2 else data2
    size <- if (multicolumn) paste0("nrow(", data, ")") else {
      paste0("length(", data, ")")
    }
    args <- c(args, paste0("newlabel = 1:", size))
  }

  sprintf("with(%s, qcc::qcc(%s))", dataset, paste(args, collapse = ", "))
}

build_sigma_command <- function(dataset, variable, alternative = "two.sided",
                                sigma = "1.0", level = "0.95") {
  sprintf(
    "with(%s, TeachingDemos::sigma.test(%s[!is.na(%s)], alternative='%s', sigmasq=%s, conf.level=%s))",
    dataset, variable, variable, alternative, sigma, level
  )
}

build_randomness_command <- function(dataset, variable, type = "numeric") {
  if (identical(type, "factor")) {
    sprintf("with(%s, tseries::runs.test(%s))", dataset, variable)
  } else {
    sprintf("with(%s, randtests::runs.test(%s))", dataset, variable)
  }
}

build_pareto_command <- function(dataset, variable) {
  sprintf("with(%s, qicharts2::paretochart(%s))", dataset, variable)
}

build_predict_existing_command <- function(model, dataset) {
  sprintf("%s$fitted.%s <- predict(%s, %s)", dataset, model, model, dataset)
}

build_predict_new_command <- function(model, values) {
  if (length(values) == 0L) {
    stop("No predictor values were provided.", call. = FALSE)
  }
  fields <- vapply(names(values), function(name) {
    value <- values[[name]]
    if (is.character(value) || is.factor(value)) {
      sprintf('%s = "%s"', name, gsub('"', '\\\\"', as.character(value)))
    } else {
      sprintf("%s = %s", name, format(value, trim = TRUE))
    }
  }, character(1))
  sprintf("predict(%s, newdata=data.frame(%s))",
          model, paste(fields, collapse = ", "))
}

uca_model_predictors <- function(state) {
  model <- RcmdrShiny::active_model(state)
  if (is.null(model)) return(character())
  object <- get(model, envir = state$env, inherits = FALSE)
  terms <- tryCatch(stats::terms(object), error = function(e) NULL)
  if (is.null(terms)) return(character())
  all.vars(stats::delete.response(terms))
}
