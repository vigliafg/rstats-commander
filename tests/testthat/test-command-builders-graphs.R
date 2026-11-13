test_that("Graph command builders reproduce Rcmdr calls", {
  expect_equal(
    RcmdrShiny:::cmd_index_plot("D", c("y", "x")),
    "indexplot(D[,c(\"y\",\"x\"), drop=FALSE], type='h')"
  )
  expect_equal(
    RcmdrShiny:::cmd_histogram("D", "y"),
    'with(D, Hist(y, scale="frequency", breaks="Sturges"))'
  )
  expect_equal(
    RcmdrShiny:::cmd_boxplot("D", c("y", "x")),
    'Boxplot(~ y + x, data=D, id=list(method="y"))'
  )
  expect_equal(
    RcmdrShiny:::cmd_boxplot("D", "y", response = "y", group = "g"),
    'Boxplot(y ~ g, data=D, id=list(method="y"))'
  )
  expect_equal(
    RcmdrShiny:::cmd_scatterplot("D", "x", "y"),
    "scatterplot(y~x, data=D, boxplots=FALSE)"
  )
  expect_equal(
    RcmdrShiny:::cmd_barplot("D", "g"),
    "with(D, Barplot(g))"
  )
  expect_equal(
    RcmdrShiny:::cmd_lineplot("D", "x", c("y", "z")),
    "with(D, lineplot(x, y, z))"
  )
  expect_equal(
    RcmdrShiny:::cmd_xyplot("D", "x", "y", "g"),
    'xyplot(y ~ x | g, data=D, type="p")'
  )
  expect_equal(
    RcmdrShiny:::cmd_density_plot("D", "y"),
    "densityPlot(~ y, data=D)"
  )
  expect_equal(
    RcmdrShiny:::cmd_set_palette(c("black", "red")),
    'palette(c("black", "red"))'
  )
})

test_that("Distribution builders cover the four generic operations", {
  expect_equal(
    RcmdrShiny:::cmd_distribution_quantiles("normal", c(0.25, 0.5),
                                             c(mean = 0, sd = 1)),
    "qnorm(c(0.25,0.5), mean=0, sd=1, lower.tail=TRUE)"
  )
  expect_equal(
    RcmdrShiny:::cmd_distribution_probabilities("normal", c(0, 1),
                                                 c(mean = 0, sd = 1)),
    "pnorm(c(0,1), mean=0, sd=1, lower.tail=TRUE)"
  )
  expect_equal(
    RcmdrShiny:::cmd_distribution_mass("binomial", c(0, 1),
                                       c(size = 5, prob = 0.5)),
    "dbinom(c(0,1), size=5, prob=0.5)"
  )
  expect_equal(
    RcmdrShiny:::cmd_distribution_plot("normal", c(mean = 0, sd = 1)),
    'curve(dnorm(x, mean=0, sd=1), xlab="x", ylab="Density")'
  )
  expect_equal(
    RcmdrShiny:::cmd_distribution_plot("binomial", c(size = 5, prob = 0.5),
                                       from = "0", to = "5"),
    'plot(0:5, dbinom(0:5, size=5, prob=0.5), type="h", xlab="x", ylab="Density")'
  )
  expect_equal(
    RcmdrShiny:::cmd_distribution_samples("normal", c(mean = 0, sd = 1),
                                          "N", 10, 2, "mean"),
    c(
      "N <- as.data.frame(matrix(rnorm(20, mean=0, sd=1), ncol=10))",
      'rownames(N) <- paste("sample", 1:2, sep="")',
      'colnames(N) <- paste("obs", 1:10, sep="")',
      "N <- within(N, {\n  mean <- rowMeans(N[,1:10])\n})"
    )
  )
})

test_that("graph commands execute and are captured as plots", {
  set.seed(1)
  env <- new.env()
  env$D <- data.frame(
    y = rnorm(30), x = rnorm(30), z = rnorm(30),
    g = factor(rep(c("a", "b"), 15)), d = rep(1:6, 5)
  )
  state <- AppState(env = env)
  active_dataset(state, "D")
  state$plot_dir <- tempfile("rcmdr-plots-")
  dir.create(state$plot_dir)
  state$plot_prefix <- "plots"
  on.exit(unlink(state$plot_dir, recursive = TRUE), add = TRUE)

  commands <- c(
    RcmdrShiny:::cmd_index_plot("D", "y"),
    RcmdrShiny:::cmd_histogram("D", "y"),
    RcmdrShiny:::cmd_boxplot("D", "y"),
    RcmdrShiny:::cmd_scatterplot("D", "x", "y"),
    RcmdrShiny:::cmd_barplot("D", "g"),
    RcmdrShiny:::cmd_qqplot("D", "y"),
    RcmdrShiny:::cmd_density_plot("D", "y"),
    RcmdrShiny:::cmd_distribution_plot("normal", c(mean = 0, sd = 1))
  )
  for (command in commands) {
    result <- run_command(state, command)
    expect_equal(result$status, "ok")
  }
  expect_equal(length(state$plots), length(commands))
  expect_true(all(file.exists(vapply(state$plots, `[[`, character(1), "file"))))
})
