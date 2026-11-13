# Command generation for the Statistics menu ---------------------------------

stats_quote_vars <- function(x) {
  if (length(x) == 1L) paste0('"', x, '"') else
    paste0("c(", paste0('"', x, '"', collapse = ","), ")")
}

# Summaries -----------------------------------------------------------------

#' @keywords internal
cmd_frequency_table <- function(dataset, variable, goodness = FALSE,
                                probs = NULL) {
  command <- paste0(
    "local({\n  .Table <- with(", dataset, ", table(", variable, "))\n",
    '  cat("\\ncounts:\\n")\n  print(.Table)\n',
    '  cat("\\npercentages:\\n")\n',
    "  print(round(100*.Table/sum(.Table), 2))\n"
  )
  if (isTRUE(goodness)) {
    if (is.null(probs) || length(probs) == 0L) {
      command <- paste0(command, "\n  chisq.test(.Table)\n})")
    } else {
      command <- paste0(command,
                        "\n  .Probs <- c(", paste(probs, collapse = ","), ")",
                        "\n  chisq.test(.Table, p=.Probs)\n})")
    }
  } else {
    command <- paste0(command, "})")
  }
  command
}

#' @keywords internal
cmd_statistics_table <- function(dataset, response, groups, statistic = "mean") {
  paste0("Tapply(", response, " ~ ", paste(groups, collapse = " + "), ", ",
         statistic, ", na.action=na.omit, data=", dataset,
         ") # ", statistic, " by groups")
}

#' @keywords internal
cmd_correlation_matrix <- function(dataset, variables, type = "pearson",
                                   use = "complete", pvalues = FALSE) {
  vars <- paste0('"', variables, '"', collapse = ",")
  if (identical(type, "partial")) {
    return(paste0(
      "partial.cor(", dataset, "[,c(", vars, ")], ",
      if (isTRUE(pvalues)) "tests=TRUE, " else "",
      'use="', use, '")'
    ))
  }
  if (isTRUE(pvalues)) {
    return(paste0(
      "rcorr.adjust(", dataset, "[,c(", vars, ")], type=\"",
      tolower(type), "\", use=\"", use, "\")"
    ))
  }
  method <- if (identical(type, "spearman")) ', method="spearman"' else ""
  paste0("cor(", dataset, "[,c(", vars, ")]", method, ', use="', use, '")')
}

#' @keywords internal
cmd_correlation_test <- function(dataset, x, y, alternative = "two.sided",
                                 method = "pearson") {
  paste0("with(", dataset, ", cor.test(", x, ", ", y,
         ', alternative="', alternative, '", method="', method, '"))')
}

#' @keywords internal
cmd_count_missing <- function(dataset) {
  paste0("sapply(", dataset,
         ", function(x)(sum(is.na(x)))) # NA counts")
}

#' @keywords internal
cmd_normality_test <- function(dataset, variable, test = "shapiro.test",
                               groups = NULL, n_classes = NULL) {
  extra <- if (!is.null(n_classes) && nzchar(as.character(n_classes))) {
    paste0(", n.classes=", n_classes)
  } else {
    ""
  }
  if (is.null(groups)) {
    paste0("normalityTest(~", variable, ', test="', test,
           '", data=', dataset, extra, ")")
  } else {
    paste0("normalityTest(", variable, " ~ ", groups, ', test="', test,
           '", data=', dataset, extra, ")")
  }
}

#' @keywords internal
cmd_power_transform <- function(dataset, variables, family = "bcPower",
                                rhs = "1") {
  vars <- if (length(variables) > 1L) {
    paste0("cbind(", paste(variables, collapse = ", "), ")")
  } else {
    variables
  }
  if (!nzchar(trimws(rhs))) rhs <- "1"
  paste0("summary(powerTransform(", vars, " ~ ", rhs, ", data=", dataset,
         ', family="', family, '"))')
}

# Contingency tables --------------------------------------------------------

#' @keywords internal
cmd_two_way_table <- function(dataset, row, column, percents = "none",
                              chisq = TRUE, components = FALSE,
                              expected = FALSE, fisher = FALSE,
                              subset = NULL) {
  subset_code <- if (is.null(subset) || !nzchar(trimws(subset))) {
    ""
  } else {
    paste0(", subset=", subset)
  }
  command <- paste0(
    "local({\n  .Table <- xtabs(~", row, "+", column, ", data=", dataset,
    subset_code, ')\n  cat("\\nFrequency table:\\n")\n  print(.Table)'
  )
  if (identical(percents, "row")) {
    command <- paste0(command,
                      '\n  cat("\\nRow percentages:\\n")\n  print(rowPercents(.Table))')
  } else if (identical(percents, "column")) {
    command <- paste0(command,
                      '\n  cat("\\nColumn percentages:\\n")\n  print(colPercents(.Table))')
  } else if (identical(percents, "total")) {
    command <- paste0(command,
                      '\n  cat("\\nTotal percentages:\\n")\n  print(totPercents(.Table))')
  }
  if (isTRUE(chisq)) {
    command <- paste0(command, "\n  .Test <- chisq.test(.Table, correct=FALSE)",
                      "\n  print(.Test)")
    if (isTRUE(expected)) {
      command <- paste0(command,
                        '\n  cat("\\nExpected counts:\\n")\n  print(.Test$expected)')
    }
    if (isTRUE(components)) {
      command <- paste0(command,
                        '\n  cat("\\nChi-square components:\\n")\n  print(round(.Test$residuals^2, 2))')
    }
  }
  if (isTRUE(fisher)) {
    command <- paste0(command, "\n  print(fisher.test(.Table))")
  }
  paste0(command, "\n})")
}

#' @keywords internal
cmd_two_way_counts <- function(dataset, row, column, count,
                               percents = "none", chisq = TRUE,
                               components = FALSE, expected = FALSE,
                               fisher = FALSE) {
  command <- paste0(
    "local({\n  .Table <- xtabs(", count, "~", row, "+", column,
    ", data=", dataset, ')\n  cat("\\nFrequency table:\\n")\n',
    "  print(addmargins(.Table))\n"
  )
  if (identical(percents, "row")) {
    command <- paste0(command, '  cat("\\nRow percentages:\\n")\n  print(rowPercents(.Table))\n')
  } else if (identical(percents, "column")) {
    command <- paste0(command, '  cat("\\nColumn percentages:\\n")\n  print(colPercents(.Table))\n')
  } else if (identical(percents, "total")) {
    command <- paste0(command, '  cat("\\nTotal percentages:\\n")\n  print(totPercents(.Table))\n')
  }
  if (isTRUE(chisq) || isTRUE(expected) || isTRUE(components)) {
    command <- paste0(command, "  .Test <- chisq.test(.Table, correct=FALSE)\n")
  }
  if (isTRUE(chisq)) command <- paste0(command, "  print(.Test)\n")
  if (isTRUE(expected)) {
    command <- paste0(command, '  cat("\\nExpected counts:\\n")\n  print(.Test$expected)\n')
  }
  if (isTRUE(components)) {
    command <- paste0(command,
                      '\n  cat("\\nChi-square components:\\n")\n  print(round(.Test$residuals^2, 2))\n')
  }
  if (isTRUE(fisher)) command <- paste0(command, "  print(fisher.test(.Table))\n")
  paste0(command, "})")
}

#' @keywords internal
cmd_multi_way_table <- function(dataset, row, column, controls,
                                percents = "none", subset = NULL) {
  subset_code <- if (is.null(subset) || !nzchar(trimws(subset))) {
    ""
  } else {
    paste0(", subset=", subset)
  }
  command <- paste0(
    "local({\n  .Table <- xtabs(~", row, "+", column, "+",
    paste(controls, collapse = "+"), ", data=", dataset, subset_code,
    ')\n  cat("\\nFrequency table:\\n")\n  print(.Table)'
  )
  if (identical(percents, "row")) {
    command <- paste0(command,
                      '\n  cat("\\nRow percentages:\\n")\n  print(rowPercents(.Table))')
  } else if (identical(percents, "column")) {
    command <- paste0(command,
                      '\n  cat("\\nColumn percentages:\\n")\n  print(colPercents(.Table))')
  }
  paste0(command, "\n})")
}

#' @keywords internal
cmd_enter_table <- function(row_variable, column_variable, row_names,
                            column_names, counts, percents = "none",
                            chisq = TRUE, expected = FALSE,
                            components = FALSE, fisher = FALSE) {
  matrix_command <- paste0(
    ".Table <- matrix(c(", paste(counts, collapse = ","), "), ",
    length(row_names), ", ", length(column_names), ")"
  )
  dimnames_command <- paste0(
    'dimnames(.Table) <- list("', row_variable, '"=c(',
    paste0('"', row_names, '"', collapse = ", "), '), "',
    column_variable, '"=c(',
    paste0('"', column_names, '"', collapse = ", "), "))"
  )
  commands <- c(matrix_command, dimnames_command, ".Table  # Counts")
  if (identical(percents, "row")) {
    commands <- c(commands, "rowPercents(.Table) # Row Percentages")
  } else if (identical(percents, "column")) {
    commands <- c(commands, "colPercents(.Table) # Column Percentages")
  } else if (identical(percents, "total")) {
    commands <- c(commands, "totPercents(.Table) # Percentage of Total")
  }
  if (isTRUE(chisq) || isTRUE(expected) || isTRUE(components)) {
    commands <- c(commands, ".Test <- chisq.test(.Table, correct=FALSE)")
  }
  if (isTRUE(chisq)) commands <- c(commands, ".Test")
  if (isTRUE(expected)) commands <- c(commands, ".Test$expected # Expected Counts")
  if (isTRUE(components)) {
    commands <- c(commands, "round(.Test$residuals^2, 2) # Chi-square Components")
  }
  if (isTRUE(fisher)) commands <- c(commands, "fisher.test(.Table)")
  commands
}

# Means ---------------------------------------------------------------------

#' @keywords internal
cmd_independent_t <- function(dataset, response, group,
                              alternative = "two.sided",
                              conf_level = 0.95, var_equal = FALSE) {
  paste0("t.test(", response, "~", group, ", alternative='", alternative,
         "', conf.level=", conf_level, ", var.equal=", isTRUE(var_equal),
         ", data=", dataset, ")")
}

#' @keywords internal
cmd_paired_t <- function(dataset, x, y, alternative = "two.sided",
                         conf_level = 0.95) {
  paste0("with(", dataset, ", (t.test(", x, ", ", y,
         ", alternative='", alternative, "', conf.level=", conf_level,
         ", paired=TRUE)))")
}

#' @keywords internal
cmd_single_t <- function(dataset, x, alternative = "two.sided", mu = 0,
                         conf_level = 0.95) {
  paste0("with(", dataset, ", (t.test(", x, ", alternative='", alternative,
         "', mu=", mu, ", conf.level=", conf_level, ")))")
}

#' @keywords internal
cmd_one_way_anova <- function(dataset, model, response, group,
                              pairwise = FALSE, welch = FALSE,
                              conf_level = 0.95, alpha = NULL) {
  if (is.null(alpha)) alpha <- 1 - conf_level
  commands <- c(
    paste0(model, " <- aov(", response, " ~ ", group, ", data=", dataset, ")"),
    paste0("summary(", model, ")"),
    paste0("with(", dataset, ", numSummary(", response, ", groups=", group,
           ', statistics=c("mean", "sd")))')
  )
  if (isTRUE(pairwise)) {
    commands <- c(commands, paste0(
      "local({\n  .Pairs <- glht(", model, ", linfct = mcp(", group,
      " = \"Tukey\"))\n  print(summary(.Pairs)) # pairwise tests\n",
      "  print(confint(.Pairs, level=", conf_level, ")) # confidence intervals\n",
      "  print(cld(.Pairs, level=", alpha, ")) # compact letter display\n",
      "  old.oma <- par(oma=c(0, 5, 0, 0))\n  plot(confint(.Pairs))\n",
      "  par(old.oma)\n})"
    ))
  }
  if (isTRUE(welch)) {
    commands <- c(commands, paste0(
      "oneway.test(", response, " ~ ", group, ", data=", dataset,
      ") # Welch test"
    ))
  }
  commands
}

#' @keywords internal
cmd_multi_way_anova <- function(dataset, model, response, groups) {
  contrasts <- paste(paste(groups, '="contr.Sum"', sep = ""), collapse = ", ")
  c(
    paste0(model, " <- lm(", response, " ~ ", paste(groups, collapse = "*"),
           ", data=", dataset, ", contrasts=list(", contrasts, "))"),
    paste0("Anova(", model, ")"),
    paste0("Tapply(", response, " ~ ", paste(groups, collapse = " + "),
           ", mean, na.action=na.omit, data=", dataset, ") # means"),
    paste0("Tapply(", response, " ~ ", paste(groups, collapse = " + "),
           ", sd, na.action=na.omit, data=", dataset, ") # std. deviations"),
    paste0("xtabs(~ ", paste(groups, collapse = " + "), ", data=", dataset,
           ") # counts")
  )
}

#' @keywords internal
cmd_one_way_repeated <- function(dataset, responses, within_name, levels,
                                 between = NULL, test = "univariate",
                                 test_statistic = "Pillai") {
  lhs <- paste0("cbind(", paste(responses, collapse = ", "), ")")
  rhs <- if (is.null(between) || length(between) == 0L) "1" else
    paste(between, collapse = " + ")
  idata <- paste0("data.frame(", within_name, "=factor(c(",
                  paste0("'", levels, "'", collapse = ", "), ")))")
  if (identical(test, "multivariate")) {
    paste0("Anova(lm(", lhs, " ~ ", rhs, ", data=", dataset, "), idata=",
           idata, ", idesign = ~", within_name, ', test.statistic="',
           test_statistic, '")')
  } else {
    paste0("summary(Anova(lm(", lhs, " ~ ", rhs, ", data=", dataset,
           "), idata=", idata, ", idesign = ~", within_name,
           "), univariate=TRUE, multivariate=FALSE)")
  }
}

#' @keywords internal
cmd_two_way_repeated <- function(dataset, responses, row_name, row_levels,
                                 column_name, column_levels, between = NULL,
                                 test = "univariate",
                                 test_statistic = "Pillai") {
  lhs <- paste0("cbind(", paste(responses, collapse = ", "), ")")
  rhs <- if (is.null(between) || length(between) == 0L) "1" else
    paste(between, collapse = " + ")
  idata <- paste0(
    "data.frame(", row_name, " = factor(rep(c(",
    paste0("'", row_levels, "'", collapse = ", "), "),", length(column_levels),
    ")), ", column_name, " = factor(rep(c(",
    paste0("'", column_levels, "'", collapse = ", "), "), each=",
    length(row_levels), ")))"
  )
  idesign <- paste0("~", row_name, "*", column_name)
  if (identical(test, "multivariate")) {
    paste0("Anova(lm(", lhs, " ~ ", rhs, ", data=", dataset, "), idata=",
           idata, ", idesign = ", idesign, ', test.statistic="',
           test_statistic, '")')
  } else {
    paste0("summary(Anova(lm(", lhs, " ~ ", rhs, ", data=", dataset,
           "), idata=", idata, ", idesign = ", idesign,
           "), univariate=TRUE, multivariate=FALSE)")
  }
}

# Variances -----------------------------------------------------------------

#' @keywords internal
cmd_two_variances_f <- function(dataset, response, group,
                                alternative = "two.sided",
                                conf_level = 0.95) {
  c(
    paste0("Tapply(", response, " ~ ", group, ", var, na.action=na.omit, data=",
           dataset, ") # variances by group"),
    paste0("var.test(", response, " ~ ", group, ", alternative='",
           alternative, "', conf.level=", conf_level, ", data=", dataset, ")")
  )
}

#' @keywords internal
cmd_bartlett <- function(dataset, response, groups) {
  if (length(groups) == 1L) {
    c(
      paste0("Tapply(", response, " ~ ", groups, ", var, na.action=na.omit, data=",
             dataset, ") # variances by group"),
      paste0("bartlett.test(", response, " ~ ", groups, ", data=", dataset, ")")
    )
  } else {
    c(
      paste0("Tapply(", response, " ~ ", paste(groups, collapse = " + "),
             ", var, na.action=na.omit, data=", dataset, ") # variances"),
      paste0("bartlett.test(", response, " ~ interaction(",
             paste(groups, collapse = ", "), "), data=", dataset, ")")
    )
  }
}

#' @keywords internal
cmd_levene <- function(dataset, response, groups, center = "median") {
  if (length(groups) == 1L) {
    c(
      paste0("Tapply(", response, " ~ ", groups, ", var, na.action=na.omit, data=",
             dataset, ") # variances by group"),
      paste0("leveneTest(", response, " ~ ", groups, ", data=", dataset,
             ', center="', center, '")')
    )
  } else {
    c(
      paste0("Tapply(", response, " ~ ", paste(groups, collapse = " + "),
             ", var, na.action=na.omit, data=", dataset, ") # variances"),
      paste0("leveneTest(", response, " ~ ", paste(groups, collapse = "*"),
             ", data=", dataset, ', center="', center, '")')
    )
  }
}

#' @keywords internal
cmd_sigma_test <- function(dataset, x, alternative = "two.sided",
                           sigma_sq = 1, conf_level = 0.95) {
  paste0("with(na.omit(", dataset, "), sigma.test(", x, ", alternative='",
         alternative, "', sigmasq=", sigma_sq, ", conf.level=", conf_level,
         "))")
}

# Proportions ---------------------------------------------------------------

#' @keywords internal
cmd_single_proportion <- function(dataset, x, test = "normal",
                                  alternative = "two.sided", p = 0.5,
                                  conf_level = 0.95) {
  command <- paste0(
    "local({\n  .Table <- xtabs(~", x, ", data=", dataset,
    ')\n  cat("\\nFrequency counts (test is for first level):\\n")\n  print(.Table)'
  )
  if (identical(test, "binomial")) {
    call <- paste0("binom.test(rbind(.Table), alternative='", alternative,
                   "', p=", p, ", conf.level=", conf_level, ")")
  } else {
    call <- paste0("prop.test(rbind(.Table), alternative='", alternative,
                   "', p=", p, ", conf.level=", conf_level,
                   ", correct=", identical(test, "corrected"), ")")
  }
  paste0(command, "\n  ", call, "\n})")
}

#' @keywords internal
cmd_two_proportions <- function(dataset, groups, x, test = "normal",
                                alternative = "two.sided",
                                conf_level = 0.95) {
  command <- paste0(
    "local({  .Table <- xtabs(~", groups, "+", x, ", data=", dataset,
    ')\n  cat("\\nPercentage table:\\n")\n  print(rowPercents(.Table))'
  )
  paste0(command, "\n  prop.test(.Table, alternative='", alternative,
         "', conf.level=", conf_level, ", correct=",
         identical(test, "corrected"), ")\n})")
}

# Nonparametric -------------------------------------------------------------

#' @keywords internal
cmd_two_sample_wilcoxon <- function(dataset, response, group,
                                    alternative = "two.sided",
                                    test = "default") {
  commands <- paste0("Tapply(", response, " ~ ", group, ", median, ",
                     "na.action=na.omit, data=", dataset, ") # medians by group")
  call <- if (identical(test, "default")) {
    paste0("wilcox.test(", response, " ~ ", group, ', alternative="',
           alternative, '", data=', dataset, ")")
  } else {
    paste0("wilcox.test(", response, " ~ ", group, ", alternative='",
           alternative, "', exact=", identical(test, "exact"),
           ", correct=", identical(test, "correct"), ", data=", dataset, ")")
  }
  c(commands, call)
}

#' @keywords internal
cmd_paired_wilcoxon <- function(dataset, x, y, alternative = "two.sided",
                                test = "default") {
  commands <- paste0("with(", dataset, ", median(", x, " - ", y,
                     ", na.rm=TRUE)) # median difference")
  call <- if (identical(test, "default")) {
    paste0("with(", dataset, ", wilcox.test(", x, ", ", y,
           ", alternative='", alternative, "', paired=TRUE))")
  } else if (identical(test, "exact")) {
    paste0("with(", dataset, ", wilcox.test(", x, ", ", y,
           ", alternative='", alternative, "', exact=TRUE, paired=TRUE))")
  } else {
    paste0("with(", dataset, ", wilcox.test(", x, ", ", y,
           ", alternative='", alternative, "', correct=",
           identical(test, "correct"), ", exact=FALSE, paired=TRUE))")
  }
  c(commands, call)
}

#' @keywords internal
cmd_kruskal_wallis <- function(dataset, response, group) {
  c(
    paste0("Tapply(", response, " ~ ", group, ", median, na.action=na.omit, data=",
           dataset, ") # medians by group"),
    paste0("kruskal.test(", response, " ~ ", group, ", data=", dataset, ")")
  )
}

#' @keywords internal
cmd_friedman <- function(dataset, responses) {
  paste0(
    "local({\n  .Responses <- na.omit(with(", dataset, ", cbind(",
    paste(responses, collapse = ", "), ")))\n  cat(\"\\nMedians:\\n\")\n",
    "  print(apply(.Responses, 2, median))\n  friedman.test(.Responses)\n})"
  )
}

#' @keywords internal
cmd_one_sample_wilcoxon <- function(dataset, x, alternative = "two.sided",
                                    mu = 0, test = "default") {
  null <- paste0(", mu=", mu)
  commands <- c(
    paste0("with(", dataset, ", median(", x, ", na.rm=TRUE))"),
    paste0("with(", dataset, ", mean(", x, ", na.rm=TRUE))")
  )
  call <- if (identical(test, "default")) {
    paste0("with(", dataset, ", wilcox.test(", x, ", alternative='",
           alternative, "'", null, "))")
  } else if (identical(test, "exact")) {
    paste0("with(", dataset, ", wilcox.test(", x, ", alternative='",
           alternative, "'", null, ", exact=TRUE))")
  } else {
    paste0("with(", dataset, ", wilcox.test(", x, ", alternative='",
           alternative, "'", null, ", correct=", identical(test, "correct"),
           ", exact=FALSE))")
  }
  c(commands, call)
}

# Dimensional analysis ------------------------------------------------------

#' @keywords internal
cmd_reliability <- function(dataset, variables) {
  vars <- paste0('"', variables, '"', collapse = ",")
  paste0("reliability(cov(", dataset, "[,c(", vars,
         ')], use="complete.obs"))')
}

#' @keywords internal
cmd_pca <- function(dataset, variables, cor = FALSE, subset = NULL,
                    scree = FALSE) {
  subset_code <- if (is.null(subset) || !nzchar(trimws(subset))) ""
  else paste0(", subset=", subset)
  command <- paste0(
    "local({\n  .PC <- princomp(~", paste(variables, collapse = "+"),
    ", cor=", isTRUE(cor), ", data=", dataset, subset_code, ")\n",
    '  cat("\\nComponent loadings:\\n")\n  print(unclass(loadings(.PC)))\n',
    '  cat("\\nComponent variances:\\n")\n  print(.PC$sd^2)\n  cat("\\n")\n',
    "  print(summary(.PC))"
  )
  if (isTRUE(scree)) command <- paste0(command, "\n  screeplot(.PC)")
  paste0(command, "\n})")
}

#' @keywords internal
cmd_factor_analysis <- function(dataset, variables, factors = 2,
                                rotation = "varimax", scores = "none",
                                subset = NULL) {
  subset_code <- if (is.null(subset) || !nzchar(trimws(subset))) ""
  else paste0(", subset=", subset)
  paste0(
    "local({\n  .FA <- factanal(~", paste(variables, collapse = "+"),
    ", factors=", as.integer(factors), ', rotation="', rotation,
    '", scores="', scores, '", data=', dataset, subset_code, ")\n",
    "  print(.FA)\n})"
  )
}

#' @keywords internal
cmd_cfa <- function(dataset, model_text, model_name = "CFA.1", summary = TRUE) {
  commands <- c(
    paste0(".Model <- sem::specifyModel(text = ", deparse1(model_text), ")"),
    paste0(model_name, " <- sem::sem(.Model, data = ", dataset, ")")
  )
  if (isTRUE(summary)) commands <- c(commands, paste0("summary(", model_name, ")"))
  commands
}

# Cluster analysis ----------------------------------------------------------

#' @keywords internal
cmd_kmeans <- function(dataset, variables, centers = 3, iter_max = 10,
                       num_seeds = 10, summary = TRUE, plot = FALSE,
                       assign = NULL, subset = NULL) {
  dset <- if (is.null(subset) || !nzchar(trimws(subset))) dataset
  else paste0(dataset, "[", dataset, "$", subset, ", ]")
  xmat <- paste0("model.matrix(~-1 + ", paste(variables, collapse = " + "),
                 ", ", dset, ")")
  commands <- paste0(".cluster <- KMeans(", xmat, ", centers = ",
                     as.integer(centers), ", iter.max = ", as.integer(iter_max),
                     ", num.seeds = ", as.integer(num_seeds), ")")
  if (isTRUE(summary)) {
    commands <- c(commands,
                  ".cluster$size # Cluster Sizes",
                  ".cluster$centers # Cluster Centroids",
                  ".cluster$withinss # Within Cluster Sum of Squares",
                  ".cluster$tot.withinss # Total Within Cluster Sum of Squares",
                  ".cluster$betweenss # Between Cluster Sum of Squares")
  }
  if (isTRUE(plot)) {
    commands <- c(commands, paste0(
      "biplot(princomp(", xmat, "), xlabs = as.character(.cluster$cluster))"
    ))
  }
  if (!is.null(assign) && nzchar(assign)) {
    commands <- c(commands, paste0(dataset, "$", assign, " <- assignCluster(",
                                   xmat, ", ", dataset, ", .cluster$cluster)"))
  }
  c(commands, "remove(.cluster)")
}

#' @keywords internal
cmd_hclust <- function(dataset, solution, variables, method = "ward.D",
                       distance = "euc", dendro = TRUE, subset = NULL) {
  dset <- if (is.null(subset) || !nzchar(trimws(subset))) dataset
  else paste0(dataset, "[", dataset, "$", subset, ", ]")
  xmat <- paste0("model.matrix(~-1 + ", paste(variables, collapse = " + "),
                 ", ", dset, ")")
  dx <- switch(distance,
               euc = paste0("dist(", xmat, ")"),
               euc2 = paste0("dist(", xmat, ")^2"),
               city = paste0("dist(", xmat, ', method= "manhattan")'),
               xmat)
  command <- paste0(solution, " <- hclust(", dx, ' , method= "', method, '")')
  commands <- command
  if (isTRUE(dendro)) {
    commands <- c(commands, paste0('plot(', solution, ', main= "Cluster Dendrogram for Solution ',
                                   solution, '"', ')'))
  }
  commands
}

#' @keywords internal
cmd_hclust_summary <- function(solution, k = 3, summary = TRUE,
                               plot = FALSE) {
  cluster_var <- paste0("cutree(", solution, ", k = ", as.integer(k), ")")
  commands <- character()
  if (isTRUE(summary)) {
    commands <- c(commands,
                  paste0("summary(as.factor(", cluster_var, ")) # Cluster Sizes"))
  }
  if (isTRUE(plot)) {
    commands <- c(commands,
                  paste0("plot(", solution, ") # Dendrogram"))
  }
  if (length(commands) == 0L) {
    commands <- paste0(cluster_var)
  }
  commands
}

#' @keywords internal
cmd_append_hclust <- function(dataset, solution, k = 3, label = "cluster") {
  cluster_var <- paste0("cutree(", solution, ", k = ", as.integer(k), ")")
  paste0(dataset, "$", label, " <- factor(", cluster_var, ")")
}

# Models --------------------------------------------------------------------

#' @keywords internal
cmd_linear_regression <- function(dataset, model, response, predictors,
                                  subset = "", weights = "",
                                  remove_rows = "") {
  args <- ""
  if (nzchar(subset)) args <- paste0(args, ", subset=", subset)
  if (nzchar(weights)) args <- paste0(args, ", weights=", weights)
  if (nzchar(remove_rows)) args <- paste0(args, ", subset =", remove_rows)
  c(
    paste0(model, " <- lm(", response, "~",
           paste(predictors, collapse = "+"), ", data=", dataset, args, ")"),
    paste0("summary(", model, ")")
  )
}

#' @keywords internal
cmd_glm <- function(dataset, model, lhs, rhs, family = "binomial",
                    link = "logit", subset = "", weights = "",
                    remove_rows = "") {
  args <- ""
  if (nzchar(subset)) args <- paste0(args, ", subset=", subset)
  if (nzchar(weights)) args <- paste0(args, ", weights=", weights)
  if (nzchar(remove_rows)) args <- paste0(args, ", subset =", remove_rows)
  commands <- c(
    paste0(model, " <- glm(", lhs, " ~ ", rhs, ", family=", family, "(",
           link, "), data=", dataset, args, ")"),
    paste0("summary(", model, ")")
  )
  if (family %in% c("binomial", "quasibinomial") && identical(link, "logit")) {
    commands <- c(commands, paste0(
      'exp(coef(', model, '))  # Exponentiated coefficients ("odds ratios")'
    ))
  }
  if (family %in% c("poisson", "quasipoisson") && identical(link, "log")) {
    commands <- c(commands, paste0(
      "exp(coef(", model, "))  # Exponentiated coefficients"
    ))
  }
  commands
}

#' @keywords internal
cmd_polr <- function(dataset, model, lhs, rhs, method = "logistic",
                     subset = "", remove_rows = "") {
  args <- ""
  if (nzchar(subset)) args <- paste0(args, ", subset=", subset)
  if (nzchar(remove_rows)) args <- paste0(args, ", subset =", remove_rows)
  c(
    paste0(model, " <- polr(", lhs, " ~ ", rhs, ', method="', method,
           '", data=', dataset, args, ", Hess=TRUE)"),
    paste0("summary(", model, ")")
  )
}

#' @keywords internal
cmd_multinom <- function(dataset, model, lhs, rhs, subset = "",
                         remove_rows = "") {
  args <- ""
  if (nzchar(subset)) args <- paste0(args, ", subset=", subset)
  if (nzchar(remove_rows)) args <- paste0(args, ", subset =", remove_rows)
  c(
    paste0(model, " <- multinom(", lhs, " ~ ", rhs, ", data=", dataset,
           args, ", trace=FALSE)"),
    paste0("summary(", model, ", cor=FALSE, Wald=TRUE)")
  )
}

#' @keywords internal
cmd_lmer <- function(dataset, model, lhs, rhs, reml = TRUE, subset = "",
                     weights = "", remove_rows = "") {
  args <- ""
  if (nzchar(subset)) args <- paste0(args, ", subset=", subset)
  if (nzchar(weights)) args <- paste0(args, ", weights=", weights)
  if (nzchar(remove_rows)) args <- paste0(args, ", subset =", remove_rows)
  c(
    paste0(model, " <- lmer(", lhs, " ~ ", rhs, ", data=", dataset, args,
           ", REML=", isTRUE(reml), ")"),
    paste0("summary(", model, ")")
  )
}

#' @keywords internal
cmd_glmer <- function(dataset, model, lhs, rhs, family = "binomial",
                      link = "logit", subset = "", weights = "",
                      remove_rows = "") {
  args <- ""
  if (nzchar(subset)) args <- paste0(args, ", subset=", subset)
  if (nzchar(weights)) args <- paste0(args, ", weights=", weights)
  if (nzchar(remove_rows)) args <- paste0(args, ", subset =", remove_rows)
  commands <- c(
    paste0(model, " <- glmer(", lhs, " ~ ", rhs, ", family=", family, "(",
           link, "), data=", dataset, args, ")"),
    paste0("summary(", model, ")")
  )
  if (family %in% c("binomial", "quasibinomial") && identical(link, "logit")) {
    commands <- c(commands, paste0(
      'exp(coef(', model, '))  # Exponentiated coefficients ("odds ratios")'
    ))
  }
  if (family %in% c("poisson", "quasipoisson") && identical(link, "log")) {
    commands <- c(commands, paste0(
      "exp(coef(", model, "))  # Exponentiated coefficients"
    ))
  }
  commands
}
