# Command generation for the Models menu -------------------------------------

#' @keywords internal
cmd_summarize_model <- function(model) {
  paste0("summary(", model, ")")
}

#' @keywords internal
cmd_compare_coefficients <- function(models) {
  paste0("compareCoefs(", paste(models, collapse = ", "), ")")
}

#' @keywords internal
cmd_add_observation_statistics <- function(dataset, model, choices) {
  block <- paste0(dataset, " <- within(", dataset, ", {\n")
  mapping <- c(
    fitted = "fitted", residuals = "residuals",
    rstudent = "rstudent", hatvalues = "hatvalues",
    cookd = "cooks.distance"
  )
  for (choice in intersect(names(mapping), choices)) {
    block <- paste0(block, "  ", choice, ".", model, " <- ",
                    mapping[[choice]], "(", model, ")\n")
  }
  if ("obsNumbers" %in% choices) {
    block <- paste0(block, "  obsNumber <- 1:nrow(", dataset, ")\n")
  }
  paste0(block, "})")
}

#' @keywords internal
cmd_aic <- function(model) paste0("AIC(", model, ")")
#' @keywords internal
cmd_bic <- function(model) paste0("BIC(", model, ")")

#' @keywords internal
cmd_stepwise <- function(model, direction = "backward", criterion = "BIC") {
  paste0("stepwise(", model, ", direction='", direction, "', criterion='",
         criterion, "')")
}

#' @keywords internal
cmd_subset_regression <- function(dataset, response, predictors, nbest = 1) {
  paste0("plot(regsubsets(", response, " ~ ",
         paste(predictors, collapse = " + "), ", data=", dataset,
         ", nbest=", as.integer(nbest), "))")
}

#' @keywords internal
cmd_confidence_intervals <- function(model, level = 0.95, type = "LR") {
  paste0("Confint(", model, ", level=", level, ', type="', type, '")')
}

#' @keywords internal
cmd_bootstrap <- function(model, samples = 1000, level = 0.95,
                          type = "perc", method = "case") {
  c(
    paste0(".bs.samples <- Boot(", model, ", R=", as.integer(samples),
           ', method="', method, '")'),
    paste0("confint(.bs.samples, level=", level, ', type="', type, '")')
  )
}

#' @keywords internal
cmd_delta_method <- function(model, expression, level = 0.95) {
  paste0("DeltaMethod(", model, ', "', expression, '", level=', level, ")")
}

#' @keywords internal
cmd_anova_table <- function(model, type = "II", test = "F",
                            use_car = TRUE) {
  if (isTRUE(use_car)) {
    paste0("Anova(", model, ', type="', type, '", test="', test, '")')
  } else {
    paste0("anova(", model, ', test="', test, '")')
  }
}

#' @keywords internal
cmd_compare_models <- function(first, second, test = "F") {
  paste0("anova(", first, ", ", second, ', test="', test, '")')
}

#' @keywords internal
cmd_linear_hypothesis <- function(model, hypothesis, level = 0.95) {
  paste0("linearHypothesis(", model, ', "', hypothesis, '", level=', level, ")")
}

#' @keywords internal
cmd_vif <- function(model) {
  c(
    paste0("vif(", model, ")"),
    paste0("round(cov2cor(vcov(", model,
           ")), 3) # Correlations of parameter estimates")
  )
}

#' @keywords internal
cmd_bptest <- function(model, dataset, studentize = TRUE) {
  paste0("bptest(formula(", model, "), studentize=", isTRUE(studentize),
         ", data=", dataset, ")")
}

#' @keywords internal
cmd_dwtest <- function(model, dataset, alternative = "two.sided") {
  paste0("dwtest(formula(", model, '), alternative="', alternative,
         '", data=', dataset, ")")
}

#' @keywords internal
cmd_resettest <- function(model, dataset, power = "2:3", type = "fitted") {
  paste0("resettest(formula(", model, '), power=', power, ', type="', type,
         '", data=', dataset, ")")
}

#' @keywords internal
cmd_outlier_test <- function(model) {
  paste0("outlierTest(", model, ")")
}

#' @keywords internal
cmd_transform_response <- function(model, family = "bcPower") {
  paste0("summary(powerTransform(", model, ', family="', family, '"))')
}

#' @keywords internal
cmd_plot_model <- function(model) {
  c(
    "oldpar <- par(oma=c(0,0,3,0), mfrow=c(2,2))",
    paste0("plot(", model, ")"),
    "par(oldpar)"
  )
}

#' @keywords internal
cmd_residual_qq <- function(model, simulate = TRUE) {
  paste0("qqPlot(", model, ", simulate=", isTRUE(simulate), ")")
}

#' @keywords internal
cmd_crplots <- function(model, span = 0.5) {
  paste0("crPlots(", model, ", smooth=list(span=", span, "))")
}

#' @keywords internal
cmd_avplots <- function(model, method = "mahal", n = 2) {
  paste0("avPlots(", model, ', id=list(method="', method, '", n=', n, "))")
}

#' @keywords internal
cmd_influence_plot <- function(model, method = "noteworthy", n = 2) {
  paste0("influencePlot(", model, ', id=list(method="', method, '", n=',
         n, "))")
}

#' @keywords internal
cmd_influence_index <- function(model, method = "y", n = 2) {
  paste0("influenceIndexPlot(", model, ', id=list(method="', method,
         '", n=', n, "))")
}

#' @keywords internal
cmd_crplot3d <- function(model) paste0("crPlot3d(", model, ")")
#' @keywords internal
cmd_avplot3d <- function(model) paste0("avPlot3d(", model, ")")

#' @keywords internal
cmd_effect_plots <- function(model, predictors = NULL, all = TRUE,
                             style = "stacked", partial = FALSE,
                             span = 0.5) {
  style_code <- paste0(', axes=list(y=list(style="', style, '"))')
  if (isTRUE(all)) {
    suffix <- if (isTRUE(partial)) {
      paste0(", residuals=TRUE), partial.residuals=list(span=", span, "))")
    } else {
      "))"
    }
    paste0("plot(allEffects(", model, suffix)
  } else {
    if (is.null(predictors) || length(predictors) == 0L) return(character())
    quoted <- paste0('"', predictors, '"', collapse = ", ")
    suffix <- if (isTRUE(partial)) {
      paste0(", residuals=TRUE), partial.residuals=list(span=", span, "))")
    } else {
      "))"
    }
    paste0("plot(Effect(c(", quoted, "), ", model, suffix)
  }
}

#' @keywords internal
cmd_predictor_effects <- function(model, predictors = NULL, all = TRUE,
                                  style = "stacked", partial = FALSE,
                                  span = 0.5) {
  if (isTRUE(all)) {
    suffix <- if (isTRUE(partial)) {
      paste0(", residuals=TRUE), partial.residuals=list(span=", span, "))")
    } else {
      "))"
    }
    paste0("plot(predictorEffects(", model, suffix)
  } else {
    if (is.null(predictors) || length(predictors) == 0L) return(character())
    quoted <- paste0('"', predictors, '"', collapse = ", ")
    suffix <- if (isTRUE(partial)) {
      paste0(", residuals=TRUE), partial.residuals=list(span=", span, "))")
    } else {
      "))"
    }
    paste0("plot(predictorEffects(", model, ", c(", quoted, ")", suffix)
  }
}

# Tools ---------------------------------------------------------------------

#' @keywords internal
cmd_load_packages <- function(packages) {
  unname(vapply(packages, function(package) paste0("library(", package, ")"),
                character(1)))
}
