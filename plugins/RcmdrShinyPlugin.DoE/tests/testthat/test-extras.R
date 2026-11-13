test_that("import and export builders produce commands", {
  expect_equal(doe_import_workspace("old", "new"), "new <- old")
  expect_error(doe_import_workspace("a", "a"), "must differ")
  expect_equal(doe_import_csv("d.csv"), 'design <- read.csv("d.csv")')
  expect_match(doe_export_design("d", "out.csv"),
               'write.csv\\(d, "out.csv", row.names = FALSE\\)')
  expect_match(doe_load_catalogue("catlg"), "utils::data")
})

test_that("design builders cover candidate, parameter and augmentation", {
  expect_match(doe_candidate_design("c", 3, 2), "DoE.base::fac.design")
  expect_match(doe_parameter_design("p", "i", "o"), "param.design")
  expect_match(doe_augment_lhs("d", 5), "lhs::augmentLHS\\(d, 5\\)")
})

test_that("analysis builders produce commands", {
  expect_true(any(grepl("summary\\(d\\)", doe_tabulate("d"))))
  expect_match(doe_select_responses("d", c("y1", "y2")), "y1")
  expect_match(doe_change_contrasts("d", "A", "sum"), "contr.sum")
  expect_match(doe_long_to_wide("d", "id", "time", "y"), "reshape\\(")
  expect_match(doe_aggregate("d", "y"), "aggregate\\(y ~ \\.")
  expect_match(doe_add_center("d", 3), "rbind\\(d, .center\\)")
  expect_match(doe_pick_cube("d"), "rsm::cube")
  expect_match(doe_effect_plots("d"), "MEPlot")
  expect_match(doe_steepest("m", 1), "rsm::steepest")
})

test_that("the DoE extras are registered", {
  RcmdrShiny::unload_plugins()
  on.exit(RcmdrShiny::unload_plugins(), add = TRUE)
  rcmdrshiny_plugin()

  ids <- c("loadworkspace", "Menu.import", "Menu.importrdacsv", "Menu.export",
           "Menu.loadcatlg", "Menu.cand", "Menu.param", "Menu.tab",
           "Menu.responses", "Menu.changecontr", "Menu.wide", "Menu.aggregate",
           "Menu.addcenter", "Menu.pickcube", "Menu.augmentlhs",
           "Menu.PlotMeansDoE", "Menu.steepest", "helpImport", "helpExport",
           "helpExpImp", "help2level", "helpgeneral", "helpquant", "helpDopt",
           "helpInspect", "helpModify", "helpAnalyze", "helpMenus", "helpabout",
           "displayGlossary", "displayblock", "displaysplitplot",
           "displayCentralCompositeDesigns")
  expect_equal(setdiff(ids, RcmdrShiny:::implemented_commands()), character())
})

test_that("info entries open a help topic", {
  RcmdrShiny::unload_plugins()
  on.exit(RcmdrShiny::unload_plugins(), add = TRUE)
  rcmdrshiny_plugin()

  state <- RcmdrShiny::AppState(env = new.env())
  opened <- character()
  state$help_show <- function(id) {
    opened <<- c(opened, id)
    TRUE
  }
  RcmdrShiny:::direct_commands()[["help2level"]](state)
  expect_equal(opened, "doe-designs")
})
