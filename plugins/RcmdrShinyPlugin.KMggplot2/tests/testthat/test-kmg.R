test_that("the plugin registers its plot menus", {
  RcmdrShiny::unload_plugins()
  on.exit(RcmdrShiny::unload_plugins(), add = TRUE)
  rcmdrshiny_plugin()
  leaves <- RcmdrShiny::menu_leaves(RcmdrShiny::menu_tree())
  expect_true(all(c("windowKM", "windowHist", "windowQQ", "windowBox",
                    "windowScatter", "windowScattermat", "windowLine",
                    "windowPie", "windowDiscretebar", "windowContour",
                    "windowFactorize", "windowDistNorm", "windowDistBinom",
                    "windowDistNbinom") %in% leaves$command))
})

test_that("ggplot commands are generated", {
  expect_match(build_kmg_histogram("d", list(variable = "x", bins = 20)),
               "geom_histogram")
  expect_match(build_kmg_qq("d", list(variable = "x")), "stat_qq")
  expect_match(build_kmg_box("d", list(variable = "y", group = "g",
                                      type = "violin")), "geom_violin")
  expect_match(build_kmg_scatter("d", list(x = "x", y = "y")), "geom_point")
  expect_match(build_kmg_line("d", list(x = "x", y = "y")), "geom_line")
  expect_match(build_kmg_pie("d", list(variable = "g")), "coord_polar")
  expect_match(build_kmg_bar("d", list(variable = "g")), "geom_bar")
  expect_match(build_kmg_contour("d", list(x = "x", y = "y")),
               "geom_density_2d")
  expect_match(build_kmg_scattermatrix("d", list(variables = c("x", "y"))),
               "pairs\\(")
  expect_match(build_kmg_km("d", list(time = "t", status = "s", group = "g")),
               "survfit")
  expect_match(build_kmg_factorize("d", list(variable = "x", breaks = 4)),
               "cut\\(")
})

test_that("distribution commands are generated", {
  expect_match(build_kmg_distribution("norm", list(mean = 0, sd = 1)),
               "stat_function")
  expect_match(build_kmg_distribution("binom", list(size = 10, prob = .5)),
               "geom_col")
  expect_match(build_kmg_distribution("hyper", list(m = 10, n = 10, k = 5)),
               "dhyper")
})

test_that("a plot dialog returns a ggplot command", {
  RcmdrShiny::unload_plugins()
  on.exit(RcmdrShiny::unload_plugins(), add = TRUE)
  rcmdrshiny_plugin()
  state <- RcmdrShiny::AppState(env = new.env())
  assign("mtcars", mtcars, envir = state$env)
  RcmdrShiny::active_dataset(state, "mtcars")
  spec <- RcmdrShiny::get_dialog("windowHist")
  result <- spec$on_ok(list(windowHist_variable = "mpg",
                            windowHist_bins = 20), state)
  expect_match(result$commands, "ggplot2::ggplot")
  expect_true(isTRUE(result$plot))
})
