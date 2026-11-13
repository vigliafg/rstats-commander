# Robust PCA command builder --------------------------------------------

pca_robust_data <- function(dataset, variables) {
  sprintf(
    "data.matrix(%s[, c(%s)])",
    dataset,
    paste(sprintf('"%s"', variables), collapse = ", ")
  )
}

build_pca_robust_commands <- function(dataset, variables, alpha = 0.75,
                                      loadings = FALSE, scores = FALSE,
                                      screeplot = FALSE, biplot = FALSE,
                                      od_plot = FALSE, sd_plot = FALSE,
                                      diagnostic = FALSE) {
  if (length(variables) < 2L) {
    stop("Select at least two numeric variables.", call. = FALSE)
  }
  alpha <- suppressWarnings(as.numeric(alpha))
  if (is.na(alpha) || alpha < 0.5 || alpha > 1) {
    stop("The confidence level must be between 0.5 and 1.", call. = FALSE)
  }

  k <- length(variables)
  commands <- c(
    sprintf(".pcaRobust <- PcaHubert(%s, alpha=%s, k=%d, kmax=%d, mcd=TRUE)",
            pca_robust_data(dataset, variables), format(alpha, trim = TRUE),
            k, k),
    "summary(.pcaRobust)"
  )
  if (isTRUE(loadings)) commands <- c(commands, ".pcaRobust@loadings")
  if (isTRUE(scores)) commands <- c(commands, ".pcaRobust@scores")
  if (isTRUE(screeplot)) {
    commands <- c(commands, 'screeplot(.pcaRobust, type="lines", col=3)')
  }
  if (isTRUE(biplot)) {
    commands <- c(commands, "biplot(.pcaRobust, cex=0.8)")
  }
  if (isTRUE(od_plot)) {
    commands <- c(commands, paste(
      "{",
      "  .od <- .pcaRobust@od",
      "  .x <- seq_along(.od)",
      "  .shift <- (mean(.od) - min(.od)) / 5",
      '  plot(.x, .od + .shift, type="n", xlab="Number of objects", ylab="Orthogonal Distance")',
      "  text(.x, .od + .shift, .x, font=5, cex=0.6)",
      '  text(.x, .od, ".", font=5, cex=3.6, col=2)',
      "}",
      sep = "\n"
    ))
  }
  if (isTRUE(sd_plot)) {
    commands <- c(commands, paste(
      "{",
      "  .sd <- .pcaRobust@sd",
      "  .x <- seq_along(.sd)",
      "  .shift <- (mean(.sd) - min(.sd)) / 5",
      '  plot(.x, .sd + .shift, type="n", xlab="Number of objects", ylab="Score Distance")',
      "  text(.x, .sd + .shift, .x, font=5, cex=0.6)",
      '  text(.x, .sd, ".", font=5, cex=3.6, col=2)',
      "}",
      sep = "\n"
    ))
  }
  if (isTRUE(diagnostic)) {
    commands <- c(commands, paste(
      "{",
      "  .od <- .pcaRobust@od",
      "  .sd <- .pcaRobust@sd",
      "  .h <- .pcaRobust@cutoff.od",
      "  .v <- .pcaRobust@cutoff.sd",
      "  .shift <- (mean(.od) - min(.od)) / 5",
      '  plot(c(.v, .sd), c(.h, .od + .shift), type="n", xlab="Score Distance", ylab="Orthogonal Distance")',
      "  text(.sd, .od + .shift, seq_along(.od), font=5, cex=0.6)",
      '  text(.sd, .od, ".", font=5, cex=3.6, col=2)',
      '  abline(h=.h, v=.v, col="blue")',
      "}",
      sep = "\n"
    ))
  }
  commands
}
