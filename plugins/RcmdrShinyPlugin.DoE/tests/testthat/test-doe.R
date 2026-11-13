test_that("the plugin registers its Design menu", {
  RcmdrShiny::unload_plugins()
  on.exit(RcmdrShiny::unload_plugins(), add = TRUE)
  rcmdrshiny_plugin()
  leaves <- RcmdrShiny::menu_leaves(RcmdrShiny::menu_tree())
  expect_true(all(c("Menu.pb2level", "Menu.FrF2level", "Menu.fac",
                    "Menu.oa", "Menu.ccd", "Menu.bbd", "Menu.lhs",
                    "Menu.Dopt", "Menu.display", "Menu.model",
                    "Menu.rsmmodel", "Menu.EffectPlots", "Menu.IAPlot",
                    "Menu.contour") %in% leaves$command))
})

test_that("design builders produce assignments", {
  expect_match(build_screening("d", 7, 8), "^d <- FrF2::pb")
  expect_match(build_fractional("d", 5, 16), "FrF2::FrF2")
  expect_match(build_full_factorial("d", 3, 2), "fac.design")
  expect_match(build_orthogonal_array("d", 3, 2, 8), "oa.design")
  expect_match(build_ccd("d", 3), "rsm::ccd")
  expect_match(build_bbd("d", 3), "rsm::bbd")
  expect_match(build_lhs("d", 3, 20), "randomLHS")
  expect_match(build_doptimal("d", "cand", "~ .", 12), "optFederov")
  expect_match(build_design_model("d", "y"), "lm\\(y ~")
  expect_match(build_effects_plot("m"), "DanielPlot")
})

test_that("the design dialog returns an assignment", {
  RcmdrShiny::unload_plugins()
  on.exit(RcmdrShiny::unload_plugins(), add = TRUE)
  rcmdrshiny_plugin()
  state <- RcmdrShiny::AppState(env = new.env())
  spec <- RcmdrShiny::get_dialog("Menu.pb2level")
  result <- spec$on_ok(list(Menu.pb2level_name = "design",
                            Menu.pb2level_factors = 7,
                            Menu.pb2level_runs = 8), state)
  expect_match(result$commands, "^design <- FrF2::pb")
  expect_equal(result$activate_dataset, "design")
})
