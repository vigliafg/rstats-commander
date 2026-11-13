# EZR command builders --------------------------------------------------

ezr_num <- function(value, name) {
  number <- suppressWarnings(as.numeric(value))
  if (length(number) == 0L || is.na(number)) stop(sprintf("%s must be a number.", name))
  number
}

ezr_t_test <- function(kind, dataset, response, group = "", first = "",
                       second = "", mu = 0, level = 0.95,
                       alternative = "two.sided", equal_variance = FALSE) {
  if (identical(kind, "single")) {
    return(sprintf("t.test(%s$%s, mu = %s, alternative = '%s', conf.level = %s)",
                   dataset, response, ezr_num(mu, "Null mean"), alternative,
                   ezr_num(level, "Confidence level")))
  }
  if (identical(kind, "independent")) {
    return(sprintf("t.test(%s ~ %s, data = %s, mu = %s, alternative = '%s', conf.level = %s, var.equal = %s)",
                   response, group, dataset, ezr_num(mu, "Null mean"),
                   alternative, ezr_num(level, "Confidence level"),
                   if (isTRUE(equal_variance)) "TRUE" else "FALSE"))
  }
  if (identical(kind, "paired")) {
    return(sprintf("t.test(%s$%s, %s$%s, paired = TRUE, mu = %s, alternative = '%s', conf.level = %s)",
                   dataset, first, dataset, second, ezr_num(mu, "Null mean"),
                   alternative, ezr_num(level, "Confidence level")))
  }
  stop("Unknown t-test kind.")
}

ezr_prop_ci <- function(successes, n, level = 0.95) {
  sprintf("prop.test(%d, %d, conf.level = %s, correct = FALSE)",
          as.integer(ezr_num(successes, "Successes")),
          as.integer(ezr_num(n, "Sample size")),
          ezr_num(level, "Confidence level"))
}

ezr_prop_test <- function(successes, n, p0 = 0.5, alternative = "two.sided",
                          level = 0.95) {
  sprintf("prop.test(%d, %d, p = %s, alternative = '%s', conf.level = %s, correct = FALSE)",
          as.integer(ezr_num(successes, "Successes")),
          as.integer(ezr_num(n, "Sample size")), ezr_num(p0, "Null proportion"),
          alternative, ezr_num(level, "Confidence level"))
}

ezr_mean_ci <- function(dataset, response, level = 0.95,
                        alternative = "two.sided") {
  sprintf("t.test(%s$%s, conf.level = %s, alternative = '%s')",
          dataset, response, ezr_num(level, "Confidence level"), alternative)
}

ezr_correlation <- function(dataset, first, second, method = "pearson") {
  sprintf("cor.test(%s$%s, %s$%s, method = '%s')",
          dataset, first, dataset, second, method)
}

ezr_regression <- function(dataset, response, predictors, family = "gaussian") {
  rhs <- paste(predictors, collapse = " + ")
  if (identical(family, "binomial")) {
    c(sprintf(".model <- glm(%s ~ %s, data = %s, family = binomial)",
              response, rhs, dataset),
      "summary(.model)", "exp(cbind(OR = coef(.model), confint(.model)))")
  } else {
    c(sprintf(".model <- lm(%s ~ %s, data = %s)", response, rhs, dataset),
      "summary(.model)")
  }
}

ezr_anova <- function(dataset, response, factors, interaction = FALSE) {
  rhs <- if (isTRUE(interaction)) paste(factors, collapse = " * ") else {
    paste(factors, collapse = " + ")
  }
  c(sprintf(".model <- aov(%s ~ %s, data = %s)", response, rhs, dataset),
    "summary(.model)")
}

ezr_nonparam <- function(kind, dataset, response, group = "", first = "",
                         second = "") {
  switch(
    kind,
    mann = sprintf("wilcox.test(%s ~ %s, data = %s)", response, group, dataset),
    wilcox = sprintf("wilcox.test(%s$%s, %s$%s, paired = TRUE)",
                     dataset, first, dataset, second),
    kruskal = sprintf("kruskal.test(%s ~ %s, data = %s)", response, group, dataset),
    friedman = sprintf("friedman.test(as.matrix(%s[, c(%s)]))",
                       dataset, paste(sprintf('"%s"', response), collapse = ", ")),
    spearman = sprintf("cor.test(%s$%s, %s$%s, method = 'spearman')",
                       dataset, first, dataset, second)
  )
}

ezr_survival <- function(kind, dataset, time, event, group = "",
                         predictors = character()) {
  formula <- sprintf("survival::Surv(%s, %s)", time, event)
  if (identical(kind, "km")) {
    if (nzchar(group)) {
      formula <- paste(formula, "~", group)
    } else {
      formula <- paste(formula, "~ 1")
    }
    return(c(
      sprintf(".formula <- as.formula(%s)", deparse(formula)),
      sprintf(".fit <- survival::survfit(.formula, data = %s)", dataset),
      "plot(.fit, col = 1:6, lwd = 2, xlab = 'Time', ylab = 'Survival')",
      sprintf("survival::survdiff(.formula, data = %s)", dataset),
      "summary(.fit)"
    ))
  }
  formula <- paste(formula, "~", paste(predictors, collapse = " + "))
  c(sprintf(".cox <- survival::coxph(%s, data = %s)", formula, dataset),
    "summary(.cox)", "survival::cox.zph(.cox)")
}

ezr_roc <- function(dataset, response, predictor) {
  c(sprintf(".roc <- pROC::roc(%s ~ %s, data = %s)", response, predictor, dataset),
    "print(.roc)", "plot(.roc, print.auc = TRUE)")
}

ezr_histogram <- function(dataset, variable, bins = 20) {
  sprintf("hist(%s$%s, breaks = %d, col = 'lightblue', main = 'Histogram')",
          dataset, variable, as.integer(bins))
}

ezr_boxplot <- function(dataset, variable, group = "") {
  if (nzchar(group)) {
    sprintf("boxplot(%s ~ %s, data = %s, col = 'lightblue')",
            variable, group, dataset)
  } else {
    sprintf("boxplot(%s$%s, col = 'lightblue')", dataset, variable)
  }
}

ezr_barplot <- function(dataset, variable) {
  sprintf("barplot(table(%s$%s), col = 'lightblue', main = 'Frequencies')",
          dataset, variable)
}

ezr_scatter <- function(dataset, x, y, group = "") {
  if (nzchar(group)) {
    sprintf("car::scatterplot(%s ~ %s | %s, data = %s, smooth = TRUE)",
            y, x, group, dataset)
  } else {
    sprintf("car::scatterplot(%s ~ %s, data = %s, smooth = TRUE)",
            y, x, dataset)
  }
}

ezr_tableone <- function(dataset, variables, group = "") {
  if (nzchar(group)) {
    sprintf("tableone::CreateTableOne(vars = c(%s), strata = '%s', data = %s)",
            paste(sprintf('"%s"', variables), collapse = ", "), group, dataset)
  } else {
    sprintf("tableone::CreateTableOne(vars = c(%s), data = %s)",
            paste(sprintf('"%s"', variables), collapse = ", "), dataset)
  }
}

ezr_split <- function(dataset, name_train, name_test, proportion = 0.7) {
  c(
    sprintf("set.seed(123)"),
    sprintf(".n <- nrow(%s)", dataset),
    sprintf(".train <- sample(seq_len(.n), size = floor(%s * .n))",
            ezr_num(proportion, "Proportion")),
    sprintf("%s <- %s[.train, ]", name_train, dataset),
    sprintf("%s <- %s[-.train, ]", name_test, dataset)
  )
}

ezr_dummy <- function(dataset, variable, prefix = NULL) {
  if (is.null(prefix) || !nzchar(prefix)) prefix <- variable
  sprintf("model.matrix(~ %s - 1, data = %s)", variable, dataset)
}

ezr_na_group <- function(dataset, variable, label = "Missing") {
  sprintf("%s$%s <- ifelse(is.na(%s$%s), '%s', as.character(%s$%s))",
          dataset, variable, dataset, variable, label, dataset, variable)
}
