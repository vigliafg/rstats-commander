# ROC command builders --------------------------------------------------

roc_direction <- function(value) {
  switch(value, gt = ">", lt = "<", auto = "auto", value)
}

roc_logical <- function(value) if (isTRUE(value)) "TRUE" else "FALSE"

roc_number <- function(value, default) {
  if (is.null(value) || length(value) == 0L) return(default)
  value <- suppressWarnings(as.numeric(value))
  if (length(value) == 0L || is.na(value)) default else value
}

roc_text_arg <- function(name, value) {
  if (is.null(value) || !nzchar(value)) return("")
  sprintf(', %s="%s"', name, gsub('"', '\\\\"', value))
}

roc_legend <- function(value, label, prediction) {
  if (is.null(value) || !nzchar(value)) paste(label, "~", prediction) else value
}

roc_threshold <- function(value, custom) {
  if (identical(value, "custom")) custom else sprintf("'%s'", value)
}

roc_ci_args <- function(options) {
  sprintf(", conf.level=%s, method='%s', boot.n=%d, boot.stratified=%s",
          roc_number(options$ci_level, 0.95),
          options$ci_method %||% "bootstrap",
          as.integer(roc_number(options$ci_boot_n, 2000)),
          roc_logical(options$ci_boot_stratified))
}

build_roc_call <- function(dataset, prediction, label, options, name = "roc.obj") {
  partial <- if (isTRUE(options$partial_auc)) {
    sprintf("c(%s, %s)", roc_number(options$partial_from, 0),
            roc_number(options$partial_to, 1))
  } else {
    "FALSE"
  }
  sprintf(
    paste0(
      "%s <- pROC::roc(%s ~ %s, data=%s, na.rm=%s, percent=%s, ",
      "direction='%s', partial.auc=%s, partial.auc.focus='%s', ",
      "partial.auc.correct=%s, auc=%s, plot=FALSE, ci=TRUE, of='auc', ",
      "conf.level=%s, ci.method='%s', boot.n=%d, boot.stratified=%s)"
    ),
    name, label, prediction, dataset,
    roc_logical(options$na_rm), roc_logical(options$percent),
    roc_direction(options$direction %||% "auto"), partial,
    options$partial_focus %||% "specificity",
    roc_logical(options$partial_correct),
    roc_logical(options$auc), roc_number(options$ci_level, 0.95),
    options$ci_method %||% "bootstrap",
    as.integer(roc_number(options$ci_boot_n, 2000)),
    roc_logical(options$ci_boot_stratified)
  )
}

build_roc_plot <- function(name = "roc.obj", options, add = FALSE,
                           y_auc = 45, threshold_adj = "c(0,0.5)",
                           threshold = "no", custom_threshold = "c(0.5, 1, 10, 100)") {
  color <- options$color %||% "#1c61b6"
  args <- sprintf(
    paste0(
      ', print.auc=%s, auc.polygon=%s, max.auc.polygon=%s, ',
      "print.auc.x=ifelse(%s$percent, 50, .5), print.auc.y=ifelse(%s$percent, %d, .%02d), ",
      "print.auc.pattern='AUC: %%.2f (%%.2f, %%.2f)', ",
      "auc.polygon.col='%sAA', max.auc.polygon.col='%s22', ",
      "grid=%s, identity=%s, col='%s', lty='%s', print.thres=%s, ",
      "print.thres.adj=%s, print.thres.cex=0.7, ",
      "print.thres.pattern='%%.2f (%%.2f, %%.2f)'"
    ),
    roc_logical(options$print_auc), roc_logical(options$auc_polygon),
    roc_logical(options$max_auc_polygon), name, name, y_auc,
    as.integer(y_auc / 100 * 100),
    color, color, roc_logical(options$grid), roc_logical(options$identity),
    color, options$lty %||% "solid",
    roc_threshold(threshold, custom_threshold), threshold_adj
  )
  args <- paste0(
    args,
    roc_text_arg("xlab", options$xlab %||% ""),
    roc_text_arg("ylab", options$ylab %||% ""),
    roc_text_arg("main", options$main %||% "")
  )
  sprintf("plot(%s, add=%s%s)", name, roc_logical(add), args)
}

build_roc_ci_commands <- function(options, name = "roc.obj",
                                  ci_name = "roc.ci.obj",
                                  values = "seq(0, 1, 0.05)",
                                  custom = "c(0.5, 1, 10, 100)") {
  if (!isTRUE(options$ci_compute) || !isTRUE(options$ci_plot)) return(character())
  ci_type <- options$ci_type %||% "se"
  args <- roc_ci_args(options)
  commands <- character()

  if (identical(ci_type, "thresholds")) {
    threshold <- roc_threshold(options$ci_thresholds %||% "local maximas", custom)
    commands <- c(
      commands,
      sprintf("%s <- ci(%s, of='thresholds', thresholds=%s%s)",
              ci_name, name, threshold, args),
      sprintf("plot(%s, type='%s', col='%sAA')", ci_name,
              options$ci_plot_type %||% "shape", options$color %||% "#1c61b6")
    )
  } else {
    if (identical(ci_type, "auc")) {
      commands <- c(
        commands,
        sprintf("%s <- ci(%s, of='auc'%s)", ci_name, name, args),
        ci_name
      )
    } else {
      key <- if (identical(ci_type, "sp")) "sensitivities" else "specificities"
      commands <- c(
        commands,
        sprintf("%s <- ci(%s, of='%s', %s=%s%s)",
                ci_name, name, ci_type, key, values, args)
      )
    }
    commands <- c(
      commands,
      sprintf("plot(%s, type='%s', col='%sAA')", ci_name,
              options$ci_plot_type %||% "shape",
              options$color %||% "#1c61b6")
    )
  }
  commands
}

build_roc_smoothing <- function(options, name = "roc.obj") {
  if (!isTRUE(options$smooth)) return(character())
  method <- options$smoothing_method %||% "binormal"
  args <- ""
  if (identical(method, "density")) {
    bandwidth <- trimws(options$bandwidth %||% "")
    if (nzchar(bandwidth)) args <- paste0(", bw=", bandwidth)
  } else if (identical(method, "fitdistr")) {
    args <- sprintf(", density.cases='%s', density.controls='%s'",
                    options$distribution_cases %||% "normal",
                    options$distribution_controls %||% "normal")
  }
  sprintf("lines(smooth(%s, method = '%s'%s), col='%s', lty='dotdash')",
          name, method, args, options$color %||% "#1c61b6")
}

roc_values_commands <- function(name = "roc.obj") {
  c(sprintf("%s$sensitivities", name),
    sprintf("%s$specificities", name),
    sprintf("%s$thresholds", name))
}

roc_cleanup <- function(options, names) {
  cleanup <- paste0("remove(", names, ")")
  cleanup
}

build_roc_single_commands <- function(dataset, prediction, label,
                                      options = list()) {
  commands <- c(
    build_roc_call(dataset, prediction, label, options),
    if (isTRUE(options$plot)) {
      build_roc_plot(options = options,
                     threshold = options$print_thresholds %||% "no",
                     custom_threshold = options$custom_thresholds %||%
                       "c(0.5, 1, 10, 100)")
    } else {
      character()
    },
    "roc.obj$levels[1] # The controls are:",
    "roc.obj$levels[2] # The cases are:",
    build_roc_ci_commands(options),
    build_roc_smoothing(options),
    if (isTRUE(options$values)) roc_values_commands() else character(),
    "remove(roc.obj)"
  )
  if (isTRUE(options$ci_compute) && isTRUE(options$ci_plot)) {
    commands <- c(commands, "remove(roc.ci.obj)")
  }
  commands
}

build_roc_comparison_commands <- function(dataset, prediction1, prediction2,
                                          label1, label2 = NULL,
                                          paired = TRUE,
                                          options = list()) {
  if (is.null(label2) || !nzchar(label2)) label2 <- label1
  commands <- c(
    build_roc_call(dataset, prediction1, label1, options),
    if (isTRUE(options$plot)) {
      build_roc_plot(options = options, add = FALSE,
                     threshold = options$print_thresholds %||% "no",
                     custom_threshold = options$custom_thresholds %||%
                       "c(0.5, 1, 10, 100)")
    } else {
      character()
    },
    "roc.obj$levels[1] # The controls are:",
    "roc.obj$levels[2] # The cases are:",
    build_roc_call(dataset, prediction2, label2, options, name = "roc.obj2"),
    if (isTRUE(options$plot)) {
      build_roc_plot(name = "roc.obj2", options = options, add = TRUE,
                     y_auc = 40, threshold_adj = "c(1,0.5)",
                     threshold = options$print_thresholds %||% "no",
                     custom_threshold = options$custom_thresholds %||%
                       "c(0.5, 1, 10, 100)")
    } else {
      character()
    },
    "roc.obj2$levels[1] # The controls are:",
    "roc.obj2$levels[2] # The cases are:"
  )

  method <- options$test_method %||% "auto"
  method_arg <- if (identical(method, "auto")) "" else {
    sprintf(", method='%s'", method)
  }
  commands <- c(
    commands,
    sprintf(
      "roc.test.obj <- roc.test(roc.obj, roc.obj2, paired=%s%s, alternative='%s', boot.n=%d)",
      roc_logical(paired), method_arg,
      options$test_alternative %||% "two.sided",
      as.integer(roc_number(options$test_boot_n, 2000))
    ),
    if (isTRUE(options$pvalue)) {
      "text(ifelse(roc.obj$percent, 50, .5), ifelse(roc.obj$percent, 50, .5), labels=paste('p-value = ', format.pval(roc.test.obj$p.value), sep=''), adj=c(0, .5))"
    } else {
      character()
    },
    "roc.test.obj",
    sprintf("legend('bottomright', legend=c('%s', '%s'), col=c('%s', '%s'), lwd=2, lty=c('%s', '%s'))",
            gsub("'", "\\\\'", roc_legend(options$legend1, label1, prediction1)),
            gsub("'", "\\\\'", roc_legend(options$legend2, label2, prediction2)),
            options$color %||% "#1c61b6",
            options$color2 %||% "#008600",
            options$lty %||% "solid",
            options$lty2 %||% "solid")
  )

  if (isTRUE(options$ci_compute) && isTRUE(options$ci_plot)) {
    commands <- c(
      commands,
      build_roc_ci_commands(options, "roc.obj", "roc.ci.obj",
                            options$ci_values %||% "seq(0, 1, 0.05)",
                            options$custom_thresholds %||%
                              "c(0.5, 1, 10, 100)"),
      build_roc_ci_commands(options, "roc.obj2", "roc.ci.obj2",
                            options$ci_values2 %||% "seq(0, 1, 0.05)",
                            options$custom_thresholds %||%
                              "c(0.5, 1, 10, 100)")
    )
  }
  if (isTRUE(options$smooth)) {
    commands <- c(
      commands,
      build_roc_smoothing(options, "roc.obj"),
      build_roc_smoothing(options, "roc.obj2")
    )
  }
  if (isTRUE(options$values)) {
    commands <- c(commands, roc_values_commands("roc.obj"),
                  roc_values_commands("roc.obj2"))
  }
  commands <- c(commands, "remove(roc.obj)", "remove(roc.obj2)")
  if (isTRUE(options$ci_compute) && isTRUE(options$ci_plot)) {
    commands <- c(commands, "remove(roc.ci.obj)", "remove(roc.ci.obj2)")
  }
  commands
}

build_roc_lr_commands <- function(model, dataset, options = list()) {
  commands <- c(
    sprintf("summary(%s)", model),
    sprintf("glm.prediction <- predict(%s, type=c('response'))", model),
    sprintf(".depname <- as.character((attr(%s$terms, 'variables')[2]))", model),
    sprintf(".outcome <- ifelse(%s$.depname == levels(as.factor(%s$.depname))[2], 1, 0)",
            dataset, dataset),
    build_roc_call(dataset, "glm.prediction", ".outcome", options)
  )
  commands <- c(
    commands,
    if (isTRUE(options$plot)) {
      build_roc_plot(options = options,
                     threshold = options$print_thresholds %||% "no",
                     custom_threshold = options$custom_thresholds %||%
                       "c(0.5, 1, 10, 100)")
    } else {
      character()
    },
    "roc.obj$levels[1] # The controls are:",
    "roc.obj$levels[2] # The cases are:",
    build_roc_ci_commands(options),
    build_roc_smoothing(options),
    if (isTRUE(options$values)) roc_values_commands() else character(),
    "remove(roc.obj)", "remove(glm.prediction)", "remove(.depname)",
    "remove(.outcome)"
  )
  if (isTRUE(options$ci_compute) && isTRUE(options$ci_plot)) {
    commands <- c(commands, "remove(roc.ci.obj)")
  }
  commands
}

build_hosmer_lemeshow_commands <- function(model, dataset, bins = 10L,
                                           classification = TRUE,
                                           percent_correct = TRUE) {
  bins <- as.integer(roc_number(bins, 10L))
  commands <- c(
    sprintf(".depname <- as.character((attr(%s$terms, 'variables')[2]))", model),
    sprintf(".outcome <- ifelse(%s$.depname == levels(as.factor(%s$.depname))[2], 1, 0)",
            dataset, dataset),
    sprintf(".matrix <- cbind(.outcome, fitted(%s))", model),
    ".matrix <- .matrix[complete.cases(.matrix),]",
    sprintf(".hl <- hoslem.test(.matrix[,1], .matrix[,2], %d)", bins),
    ".hl",
    ".threshold <- 0.5",
    sprintf(".predictedBinary <- cut(fitted(%s), breaks=c(-Inf, .threshold, Inf), labels=c('low', 'high'))",
            model),
    ".tableClassif <- table(.outcome, .predictedBinary) # Classification table:"
  )
  if (isTRUE(classification)) commands <- c(commands, ".tableClassif")
  if (isTRUE(percent_correct)) {
    commands <- c(
      commands,
      ".percentageCorrect <- round(sum(diag(.tableClassif)) * 100 / sum(.tableClassif), 2) # Overall percentage correct:",
      ".percentageCorrect"
    )
  }
  commands <- c(commands, "remove(.depname)", "remove(.outcome)",
                "remove(.matrix)", "remove(.hl)")
  if (isTRUE(classification)) commands <- c(commands, "remove(.tableClassif)")
  if (isTRUE(percent_correct)) {
    commands <- c(commands, "remove(.percentageCorrect)")
  }
  commands
}
