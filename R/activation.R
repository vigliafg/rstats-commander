# Menu activation -----------------------------------------------------------
#
# Rcmdr describes menu activation and availability as small R expressions in
# Rcmdr-menus.txt (for example "numericP() && factorsP()").  We evaluate those
# expressions in a sandbox whose parent is the base environment, providing the
# predicates Rcmdr uses.  No Tk code is involved.

model_classes <- c(
  "lm", "glm", "aov", "anova", "nls", "loess", "lmerMod", "glmerMod",
  "multinom", "polr", "coxph", "survreg", "prcomp", "factanal", "hclust",
  "nnet", "gamlss", "betareg", "tobit"
)

is_model_object <- function(x) inherits(x, model_classes)

#' @keywords internal
active_model_object <- function(state) {
  name <- state$active_model
  if (is.null(name) || !exists(name, envir = state$env, inherits = FALSE)) {
    return(NULL)
  }
  get(name, envir = state$env, inherits = FALSE)
}

#' @keywords internal
count_objects <- function(state, predicate) {
  objects <- ls(envir = state$env)
  if (length(objects) == 0L) return(0L)
  sum(vapply(objects, function(name) {
    predicate(get(name, envir = state$env, inherits = FALSE))
  }, logical(1)))
}

#' @keywords internal
list_all_models <- function(state) {
  objects <- ls(envir = state$env)
  objects[vapply(objects, function(name) {
    is_model_object(get(name, envir = state$env, inherits = FALSE))
  }, logical(1))]
}

#' @keywords internal
list_data_sets <- function(state) {
  objects <- ls(envir = state$env)
  objects[vapply(objects, function(name) {
    is.data.frame(get(name, envir = state$env, inherits = FALSE))
  }, logical(1))]
}

#' @keywords internal
rcmdr_capabilities <- function() {
  list(
    pdflatex = nzchar(Sys.which("pdflatex")),
    pandoc = tryCatch(
      requireNamespace("rmarkdown", quietly = TRUE) &&
        rmarkdown::pandoc_available(),
      error = function(e) FALSE
    ),
    tktable = requireNamespace("rhandsontable", quietly = TRUE)
  )
}

#' @keywords internal
get_rcmdr_option <- function(state, name) {
  switch(
    name,
    "use.markdown" = isTRUE(state$options$use_markdown),
    "use.knitr" = isTRUE(state$options$use_knitr),
    "editDataset.threshold" = state$options$edit_threshold %||% 10000,
    "capabilities" = state$options$capabilities %||% rcmdr_capabilities(),
    "Identify3d" = NULL,
    "sort.names" = TRUE,
    "retain.selections" = TRUE,
    "modelCapabilities" = model_capabilities(),
    NULL
  )
}

#' @keywords internal
model_capabilities <- function() {
  if (!is.null(.model_capabilities_cache$table)) {
    return(.model_capabilities_cache$table)
  }
  path <- system.file("etc", "Rcmdr-model-capabilities.txt",
                      package = "RcmdrShiny")
  table <- if (nzchar(path) && file.exists(path)) {
    tryCatch(
      utils::read.table(path, header = TRUE, comment.char = "#", fill = TRUE),
      error = function(e) NULL
    )
  } else {
    NULL
  }
  if (is.null(table)) {
    table <- data.frame(default = logical(0))
  }
  .model_capabilities_cache$table <- table
  table
}

.model_capabilities_cache <- new.env(parent = emptyenv())

#' @keywords internal
model_capability <- function(state, capability) {
  model <- active_model_object(state)
  if (is.null(model)) return(FALSE)
  table <- model_capabilities()
  if (!capability %in% names(table)) return(FALSE)
  class <- class(model)[[1L]]
  if (!class %in% rownames(table)) class <- "default"
  if (!class %in% rownames(table)) return(FALSE)
  value <- table[class, capability]
  if (length(value) == 0L || is.na(value)) {
    if ("default" %in% rownames(table)) {
      value <- table["default", capability]
    }
  }
  isTRUE(value)
}

#' @keywords internal
model_predictors <- function(state, type = NULL) {
  model <- active_model_object(state)
  if (is.null(model)) return(character())
  labels <- tryCatch(attr(stats::terms(model), "term.labels"),
                     error = function(e) character())
  if (is.null(type)) return(labels)
  frame <- tryCatch(stats::model.frame(model), error = function(e) NULL)
  if (is.null(frame)) return(character())
  labels[vapply(labels, function(label) {
    value <- tryCatch(frame[[label]], error = function(e) NULL)
    if (is.null(value)) return(FALSE)
    if (identical(type, "numeric")) is.numeric(value) else TRUE
  }, logical(1))]
}

#' Environment in which menu activation expressions are evaluated
#' @keywords internal
activation_environment <- function(state) {
  if (!is.null(state$activation_env) &&
      identical(state$activation_version, .plugin_registry$version)) {
    return(state$activation_env)
  }

  env <- new.env(parent = baseenv())

  env$activeDataSetP <- function() !is.null(state$active_dataset)
  env$activeModelP <- function() !is.null(state$active_model)
  env$dataSetsP <- function(n = 1) length(list_data_sets(state)) >= n
  env$numericP <- function(n = 1) length(numeric_variables(state)) >= n
  env$numericPositiveP <- function(n = 1) {
    df <- dataset(state)
    if (is.null(df)) return(FALSE)
    vars <- numeric_variables(state)
    positive <- vars[vapply(vars, function(v) {
      values <- df[[v]]
      !all(is.na(values)) && all(values > 0, na.rm = TRUE)
    }, logical(1))]
    length(positive) >= n
  }
  env$factorsP <- function(n = 1) length(factor_variables(state)) >= n
  env$nonFactorsP <- function(n = 1) length(numeric_variables(state)) >= n
  env$twoOrMoreLevelFactorsP <- function(n = 1) {
    df <- dataset(state)
    if (is.null(df)) return(FALSE)
    count <- sum(vapply(df, function(x) {
      (is.factor(x) || is.character(x) || is.logical(x)) &&
        length(unique(x[!is.na(x)])) >= 2L
    }, logical(1)))
    count >= n
  }
  env$characterP <- function(n = 1) {
    df <- dataset(state)
    if (is.null(df)) return(FALSE)
    length(names(df)[vapply(df, is.character, logical(1))]) >= n
  }
  env$twoLevelFactorsP <- function(n = 1) length(two_level_factors(state)) >= n
  env$discreteNumericP <- function(n = 1) {
    length(discrete_numeric_variables(state)) >= n
  }
  env$modelsP <- function(n = 1) length(list_all_models(state)) >= n
  env$glmP <- function() inherits(active_model_object(state), "glm")
  env$lmP <- function() inherits(active_model_object(state), "lm")
  env$aovModelsP <- function(n = 1) {
    count_objects(state, function(x) inherits(x, c("aov", "lm"))) >= n
  }
  env$AbscontDistrsP <- function(n = 1) {
    count_objects(state, function(x) inherits(x, "AbscontDistribution")) >= n
  }
  env$DiscreteDistrsP <- function(n = 1) {
    count_objects(state, function(x) inherits(x, "DiscreteDistribution")) >= n
  }
  env$hclustSolutionsP <- function(n = 1) {
    count_objects(state, function(x) inherits(x, "hclust")) >= n
  }
  env$modelCapability <- function(capability) {
    model_capability(state, capability)
  }
  env$CoefficientsP <- function(n = 1) {
    model <- active_model_object(state)
    if (is.null(model)) return(FALSE)
    length(tryCatch(stats::coef(model), error = function(e) NULL)) >= n
  }
  env$PredictorsP <- function(n = 1, type = "numeric") {
    length(model_predictors(state, type)) >= n
  }
  env$packageAvailable <- function(package) {
    package_available(package)
  }
  env$getRcmdr <- function(name) get_rcmdr_option(state, name)
  env$listPlugins <- function() character()
  env$rglLoaded <- function() "rgl" %in% loadedNamespaces()
  env$rgl.cur <- function() {
    if (!"rgl" %in% loadedNamespaces()) return(0L)
    tryCatch(rgl::rgl.cur(), error = function(e) 0L)
  }
  env$dev.cur <- function() if (length(state$plots) > 0L) 2L else 1L
  env$MarkdownP <- function() isTRUE(state$options$use_markdown)
  env$knitrP <- function() isTRUE(state$options$use_knitr)
  env$manualTranslationP <- function() FALSE

  predicates <- plugin_predicates()
  for (name in names(predicates)) {
    predicate <- predicates[[name]]
    env[[name]] <- if (length(formals(predicate)) == 0L) {
      predicate
    } else {
      local({
        fn <- predicate
        st <- state
        function() fn(st)
      })
    }
  }

  state$activation_env <- env
  state$activation_version <- .plugin_registry$version
  env
}

.package_available_cache <- new.env(parent = emptyenv())

package_available <- function(package) {
  if (!exists(package, envir = .package_available_cache, inherits = FALSE)) {
    assign(
      package,
      requireNamespace(package, quietly = TRUE),
      envir = .package_available_cache
    )
  }
  get(package, envir = .package_available_cache, inherits = FALSE)
}

.condition_cache <- new.env(parent = emptyenv())

parse_condition <- function(expression) {
  if (!exists(expression, envir = .condition_cache, inherits = FALSE)) {
    parsed <- tryCatch(parse(text = expression), error = function(e) e)
    assign(expression, parsed, envir = .condition_cache)
  }
  get(expression, envir = .condition_cache, inherits = FALSE)
}

#' Evaluate a menu activation or installation expression
#'
#' @param state Application state.
#' @param expression R expression from `Rcmdr-menus.txt`.  An empty string
#'   means "always available".
#' @return `TRUE` or `FALSE`.  Evaluation errors are treated as `FALSE`.
#' @export
evaluate_condition <- function(state, expression) {
  if (is.null(expression) || !nzchar(trimws(expression))) return(TRUE)
  parsed <- parse_condition(expression)
  if (inherits(parsed, "error")) return(FALSE)
  tryCatch(
    isTRUE(eval(parsed, envir = activation_environment(state))),
    error = function(e) FALSE
  )
}

#' Availability status of a menu command
#'
#' @return One of `"enabled"`, `"porting"`, `"inactive"` or `"hidden"`.
#' @keywords internal
command_status <- function(state, command, activation = "", install = "") {
  if (!evaluate_condition(state, install)) return("hidden")
  if (!is_implemented_command(command)) return("porting")
  # The plugin loader must remain reachable even when no plugin is installed.
  if (identical(command, "loadPlugins")) return("enabled")
  if (!evaluate_condition(state, activation)) return("inactive")
  "enabled"
}
