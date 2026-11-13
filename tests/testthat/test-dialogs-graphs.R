graph_state <- function() {
  set.seed(1)
  env <- new.env()
  env$D <- data.frame(
    y = rnorm(30), x = rnorm(30), z = rnorm(30),
    g = factor(rep(c("a", "b"), 15)), d = rep(1:6, 5)
  )
  state <- AppState(env = env)
  active_dataset(state, "D")
  state
}

test_that("all Phase 4 graph dialogs render and return commands", {
  inputs <- list(
    indexPlot = list(indexPlot_variables = c("y", "x"), indexPlot_type = "h"),
    Histogram = list(Histogram_variable = "y", Histogram_group = "",
                     Histogram_scale = "frequency", Histogram_breaks = "Sturges"),
    stemAndLeaf = list(stemAndLeaf_variable = "y"),
    boxPlot = list(boxPlot_variables = c("y", "x"), boxPlot_response = NULL,
                   boxPlot_group = ""),
    DotPlot = list(DotPlot_variable = "y", DotPlot_group = ""),
    scatterPlot = list(scatterPlot_x = "x", scatterPlot_y = "y",
                       scatterPlot_group = "", scatterPlot_smooth = TRUE,
                       scatterPlot_boxplots = FALSE, scatterPlot_log = ""),
    scatterPlotMatrix = list(scatterPlotMatrix_variables = c("y", "x", "z"),
                             scatterPlotMatrix_smooth = TRUE,
                             scatterPlotMatrix_density = TRUE),
    barGraph = list(barGraph_variable = "g", barGraph_group = ""),
    pieChart = list(pieChart_variable = "g"),
    linePlot = list(linePlot_x = "x", linePlot_y = c("y", "z")),
    QQPlot = list(QQPlot_variable = "y", QQPlot_group = ""),
    PlotMeans = list(PlotMeans_response = "y", PlotMeans_group = "g",
                     PlotMeans_error_bars = "se", PlotMeans_legend = TRUE),
    Scatter3D = list(Scatter3D_y = "y", Scatter3D_x1 = "x", Scatter3D_x2 = "z",
                     Scatter3D_group = ""),
    Xyplot = list(Xyplot_x = "x", Xyplot_y = "y", Xyplot_group = "g",
                  Xyplot_type = "p", Xyplot_layout = "1,2"),
    stripChart = list(stripChart_response = "y", stripChart_group = "g",
                      stripChart_method = "stack"),
    DensityPlot = list(DensityPlot_variable = "y", DensityPlot_group = "",
                       DensityPlot_bw = ""),
    DiscretePlot = list(DiscretePlot_variable = "d", DiscretePlot_group = ""),
    Symbox = list(Symbox_variable = "y"),
    setPalette = list(setPalette_colors = "black, red, blue")
  )

  for (id in names(inputs)) {
    state <- graph_state()
    spec <- get_dialog_spec(id)
    html <- htmltools::renderTags(spec$ui(state, NULL))$html
    expect_gt(nchar(html), 100)
    result <- spec$on_ok(inputs[[id]], state)
    expect_null(result$error)
    expect_true(length(result$commands %||% character()) > 0L)
  }
})

test_that("all distribution dialogs render and validate", {
  for (name in RcmdrShiny:::distribution_menu_names()) {
    info <- RcmdrShiny:::distribution_info(name)
    param_defaults <- lapply(info$params, `[[`, 3L)
    names(param_defaults) <- vapply(info$params, `[[`, character(1), 1L)
    param_defaults <- lapply(param_defaults, function(x) {
      if (!nzchar(x)) "1" else x
    })

    suffixes <- c("Quantiles", "Probabilities", "DistributionPlot",
                  "DistributionSamples")
    if (isTRUE(info$discrete)) suffixes <- c(suffixes, "Mass")

    for (suffix in suffixes) {
      id <- paste0(name, suffix)
      spec <- get_dialog_spec(id)
      expect_false(is.null(spec))
      state <- graph_state()
      html <- htmltools::renderTags(spec$ui(state, NULL))$html
      expect_gt(nchar(html), 50)

      inputs <- param_defaults
      if (suffix == "DistributionSamples") {
        inputs$values <- ""
        inputs$dataset <- paste0(name, "Samples")
        inputs$n <- 10
        inputs$samples <- 2
        inputs$summary_mean <- FALSE
        inputs$summary_sd <- FALSE
      } else if (suffix == "DistributionPlot") {
        inputs$values <- ""
        inputs$type <- "density"
        inputs$from <- ""
        inputs$to <- ""
      } else {
        inputs$values <- "0.25,0.5"
        if (suffix != "Mass") inputs$tail <- "TRUE"
      }
      names(inputs) <- paste0(id, "_", names(inputs))
      result <- spec$on_ok(inputs, state)
      expect_null(result$error)
      expect_true(length(result$commands %||% character()) > 0L)
    }
  }
})

test_that("random seed and palette dialogs work", {
  state <- graph_state()

  seed <- get_dialog_spec("setRandomSeed")$on_ok(
    list(setRandomSeed_seed = 42), state
  )
  expect_equal(seed$commands, "set.seed(42)")

  palette <- get_dialog_spec("setPalette")$on_ok(
    list(setPalette_colors = "black, red"), state
  )
  expect_equal(palette$commands, 'palette(c("black", "red"))')
})
