# Survival command builders ---------------------------------------------

surv_response <- function(time, event = "", type = "right") {
  parts <- c(time, if (nzchar(event)) event else NULL)
  suffix <- if (!identical(type, "right")) sprintf(', type = "%s"', type) else ""
  sprintf("survival::Surv(%s%s)", paste(parts, collapse = ", "), suffix)
}

surv_formula <- function(time, event = "", strata = character(),
                         type = "right") {
  response <- surv_response(time, event, type)
  if (length(strata) > 0L) {
    paste(response, "~", paste(strata, collapse = " + "))
  } else {
    paste(response, "~ 1")
  }
}

build_survfit <- function(dataset, time, event = "", strata = character(),
                          conf_type = "log", conf_int = 0.95,
                          detail = "default", quantiles = "c(0.25, 0.5, 0.75)",
                          mark_time = TRUE) {
  conf_type <- conf_type %||% "log"
  conf_int <- conf_int %||% 0.95
  detail <- detail %||% "default"
  quantiles <- quantiles %||% "c(0.25, 0.5, 0.75)"
  formula <- surv_formula(time, event, strata)
  commands <- c(
    sprintf('.Survfit <- survival::survfit(%s, conf.type = "%s", conf.int = %s, data = %s)',
            formula, conf_type, conf_int, dataset),
    if (identical(detail, "detailed")) "summary(.Survfit)" else ".Survfit",
    if (length(strata) == 0L) {
      sprintf("plot(.Survfit, mark.time = %s)",
              if (isTRUE(mark_time)) "TRUE" else "FALSE")
    } else {
      paste(
        sprintf("plot(.Survfit, col = 1:length(.Survfit$strata), lty = 1:length(.Survfit$strata), mark.time = %s)",
                if (isTRUE(mark_time)) "TRUE" else "FALSE"),
        'legend("bottomleft", legend = names(.Survfit$strata), col = 1:length(.Survfit$strata), lty = 1:length(.Survfit$strata), bty = "n")',
        sep = "\n"
      )
    },
    sprintf("quantile(.Survfit, probs = %s)", quantiles)
  )
  commands
}

build_survdiff <- function(dataset, time, event, strata, rho = 0) {
  formula <- surv_formula(time, event, strata)
  sprintf("survival::survdiff(%s, rho = %s, data = %s)",
          formula, rho, dataset)
}

build_coxph <- function(model, dataset, time, event, predictors,
                        strata = character(), cluster = character(),
                        ties = "efron", type = "right") {
  if (length(predictors) == 0L) stop("Select at least one predictor.")
  formula <- surv_response(time, event, type)
  rhs <- paste(predictors, collapse = " + ")
  if (length(strata) > 0L) rhs <- paste0(rhs, " + survival::strata(",
                                         paste(strata, collapse = ", "), ")")
  if (length(cluster) > 0L) rhs <- paste0(rhs, " + survival::cluster(",
                                          paste(cluster, collapse = ", "), ")")
  formula <- paste(formula, "~", rhs)
  c(
    sprintf("%s <- survival::coxph(%s, method = \"%s\", data = %s)",
            model, formula, ties, dataset),
    sprintf("summary(%s)", model)
  )
}

build_survreg <- function(model, dataset, time, event, predictors,
                          distribution = "weibull", strata = character()) {
  if (length(predictors) == 0L) stop("Select at least one predictor.")
  formula <- surv_response(time, event)
  rhs <- paste(predictors, collapse = " + ")
  if (length(strata) > 0L) {
    rhs <- paste0(rhs, " + survival::strata(",
                  paste(strata, collapse = ", "), ")")
  }
  formula <- paste(formula, "~", rhs)
  c(
    sprintf("%s <- survival::survreg(%s, dist = \"%s\", data = %s)",
            model, formula, distribution, dataset),
    sprintf("summary(%s)", model)
  )
}

build_cox_zph <- function(model) {
  c(sprintf(".zph <- survival::cox.zph(%s)", model), ".zph")
}

build_cox_plot <- function(model, dataset = NULL) {
  sprintf("plot(survival::survfit(%s), col = 1:6, lwd = 2)", model)
}

build_term_plot <- function(model) {
  sprintf("termplot(%s, se = TRUE, partial.resid = TRUE)", model)
}

build_cox_dfbetas <- function(model, type = "dfbetas") {
  sprintf("plot(residuals(%s, type = '%s'))", model, type)
}

build_martingale <- function(model) {
  sprintf("plot(fitted(%s), residuals(%s, type = 'martingale'), xlab = 'Fitted', ylab = 'Martingale')",
          model, model)
}

build_partial_residuals <- function(model) {
  sprintf("termplot(%s, se = TRUE, partial.resid = TRUE)", model)
}

build_survival_data <- function(dataset, time, event = "", strata = character(),
                                type = "right") {
  commands <- c(
    sprintf('attr(%s, "time1") <- "%s"', dataset, time),
    if (nzchar(event)) sprintf('attr(%s, "event") <- "%s"', dataset, event) else
      sprintf('attr(%s, "event") <- NULL', dataset),
    if (length(strata) > 0L) {
      sprintf('attr(%s, "strata") <- c(%s)', dataset,
              paste(sprintf('"%s"', strata), collapse = ", "))
    } else {
      sprintf('attr(%s, "strata") <- NULL', dataset)
    },
    sprintf('attr(%s, "survtype") <- "%s"', dataset, type)
  )
  commands
}

build_to_date <- function(dataset, variable, format = "%Y-%m-%d") {
  sprintf('%s$%s <- as.Date(%s$%s, format = "%s")',
          dataset, variable, dataset, variable, format)
}

build_unfold <- function(dataset, id, time_vars, timevar = "time",
                         v.names = "response") {
  sprintf(
    'reshape(%s, varying = c(%s), v.names = "%s", timevar = "%s", times = 1:%d, direction = "long")',
    dataset, paste(sprintf('"%s"', time_vars), collapse = ", "),
    v.names, timevar, length(time_vars)
  )
}
