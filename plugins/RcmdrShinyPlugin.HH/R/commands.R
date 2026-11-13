# HH command builders ---------------------------------------------------

hh_quote <- function(value) gsub('"', '\\\\"', paste0(value))

build_hh_two_way <- function(dataset, row, col, chisq = TRUE, fisher = FALSE) {
  commands <- c(
    sprintf(".Table <- with(%s, table(%s, %s))", dataset, row, col),
    ".Table",
    if (isTRUE(chisq)) "chisq.test(.Table)" else character(),
    if (isTRUE(fisher)) "fisher.test(.Table)" else character()
  )
  commands
}

build_hh_enter_table <- function(counts, row_names, col_names,
                                 chisq = TRUE, fisher = FALSE) {
  rows <- length(row_names)
  cols <- length(col_names)
  commands <- c(
    sprintf(".Table <- matrix(c(%s), nrow = %d, byrow = TRUE)",
            paste(counts, collapse = ", "), rows),
    sprintf("dimnames(.Table) <- list(c(%s), c(%s))",
            paste(sprintf('"%s"', hh_quote(row_names)), collapse = ", "),
            paste(sprintf('"%s"', hh_quote(col_names)), collapse = ", ")),
    ".Table",
    if (isTRUE(chisq)) "chisq.test(.Table)" else character(),
    if (isTRUE(fisher)) "fisher.test(.Table)" else character()
  )
  commands
}

build_hh_analyze_table <- function(object, chisq = TRUE, fisher = FALSE) {
  c(
    object,
    if (isTRUE(chisq)) sprintf("chisq.test(%s)", object) else character(),
    if (isTRUE(fisher)) sprintf("fisher.test(%s)", object) else character()
  )
}

build_hh_best_subsets <- function(dataset, response, predictors,
                                  nbest = 1L, statistic = "bic") {
  if (length(predictors) == 0L) stop("Select at least one predictor.")
  formula <- paste(response, "~", paste(predictors, collapse = " + "))
  c(
    sprintf(".subsets <- leaps::regsubsets(%s, data = %s, nbest = %d)",
            formula, dataset, as.integer(nbest)),
    sprintf("plot(.subsets, scale = '%s')", statistic),
    "summary(.subsets)"
  )
}

build_hh_ci_plot <- function(dataset, response, predictors) {
  if (length(predictors) == 0L) stop("Select at least one predictor.")
  formula <- paste(response, "~", paste(predictors, collapse = " + "))
  c(
    sprintf(".model <- lm(%s, data = %s)", formula, dataset),
    "summary(.model)",
    "HH::ci.plot(.model)"
  )
}

build_hh_predict_existing <- function(model, dataset) {
  sprintf("%s$fitted.%s <- predict(%s, %s)", dataset, model, model, dataset)
}

build_hh_predict_new <- function(model, values) {
  fields <- vapply(names(values), function(name) {
    value <- values[[name]]
    if (is.character(value) || is.factor(value)) {
      sprintf('%s = "%s"', name, hh_quote(as.character(value)))
    } else {
      sprintf("%s = %s", name, format(value, trim = TRUE))
    }
  }, character(1))
  sprintf("predict(%s, newdata = data.frame(%s))",
          model, paste(fields, collapse = ", "))
}

build_hh_scatterplot <- function(dataset, x, y, group = "") {
  if (nzchar(group)) {
    sprintf("car::scatterplot(%s ~ %s | %s, data = %s, smooth = TRUE)",
            y, x, group, dataset)
  } else {
    sprintf("car::scatterplot(%s ~ %s, data = %s, smooth = TRUE)",
            y, x, dataset)
  }
}

build_hh_scatterplot_matrix <- function(dataset, variables) {
  sprintf("car::scatterplotMatrix(~ %s, data = %s)",
          paste(variables, collapse = " + "), dataset)
}

build_hh_xyplot <- function(dataset, x, y, group = "") {
  if (nzchar(group)) {
    sprintf("lattice::xyplot(%s ~ %s | %s, data = %s, type = c('p', 'g'))",
            y, x, group, dataset)
  } else {
    sprintf("lattice::xyplot(%s ~ %s, data = %s, type = c('p', 'g'))",
            y, x, dataset)
  }
}

build_hh_likert <- function(dataset, variables) {
  if (length(variables) < 2L) stop("Select at least two variables.")
  sprintf("HH::likert(%s[, c(%s)])", dataset,
          paste(sprintf('"%s"', variables), collapse = ", "))
}

build_hh_interaction <- function(dataset, response, factors) {
  if (length(factors) < 2L) stop("Select two factors.")
  sprintf("HH::interaction2wt(%s ~ %s, data = %s)",
          response, paste(factors, collapse = " * "), dataset)
}

build_hh_dotplot <- function(dataset, response, factor) {
  sprintf("lattice::dotplot(%s ~ %s, data = %s)",
          factor, response, dataset)
}

build_hh_regr1 <- function(dataset, x, y) {
  sprintf("HH::regr1.plot(%s$%s, %s$%s)", dataset, x, dataset, y)
}

build_hh_qq <- function(dataset, variable, distribution = "norm") {
  sprintf("car::qqPlot(%s$%s, distribution = '%s')",
          dataset, variable, distribution)
}

build_hh_scatter3d <- function(dataset, x, y, z) {
  sprintf("car::scatter3d(%s ~ %s + %s, data = %s)",
          x, y, z, dataset)
}

build_hh_anova <- function(model, type = c("II", "I")) {
  type <- match.arg(type)
  if (identical(type, "II")) sprintf("car::Anova(%s)", model) else {
    sprintf("anova(%s)", model)
  }
}

build_hh_hypothesis_plot <- function(kind, values = list()) {
  switch(
    kind,
    normal = paste(
      "plot.new()",
      sprintf("HH::normal.and.t.dist(mu.H0 = %s, std.dev = %s, alpha.right = %s)",
              values$mu %||% "0", values$sd %||% "1",
              values$alpha %||% "0.05"),
      sep = "\n"
    ),
    f = paste(
      "plot.new()",
      sprintf("HH::F.curve(df1 = %s, df2 = %s, alpha = %s)",
              values$df1 %||% "3", values$df2 %||% "20",
              values$alpha %||% "0.05"),
      sep = "\n"
    ),
    chisq = paste(
      "plot.new()",
      sprintf("HH::chisq.curve(df = %s, alpha = %s)",
              values$df %||% "3", values$alpha %||% "0.05"),
      sep = "\n"
    )
  )
}

build_hh_mmc <- function(model) {
  sprintf("HH::mmc(%s)", model)
}

hh_projector <- function() {
  c("trellis.par.set(fontsize = list(text = 16, points = 12))",
    "par(cex = 1.3)")
}

hh_h600 <- function() {
  c("trellis.par.set(fontsize = list(text = 8, points = 6))",
    "par(cex = 0.8)")
}

build_hh_options <- function(pch = 1, stars = TRUE) {
  c(sprintf("par(pch = %d)", as.integer(pch)),
    sprintf("options(show.signif.stars = %s)",
            if (isTRUE(stars)) "TRUE" else "FALSE"))
}
