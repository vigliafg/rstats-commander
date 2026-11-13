test_that("the plugin registers the FactoMineR menu", {
  RcmdrShiny::unload_plugins()
  on.exit(RcmdrShiny::unload_plugins(), add = TRUE)
  rcmdrshiny_plugin()
  leaves <- RcmdrShiny::menu_leaves(RcmdrShiny::menu_tree())
  expect_true(all(c("FactoPCA", "FactoCA", "FactoMCA", "FactoMFA",
                    "FactoDMFA", "FactoFAMD", "FactoHCPC", "FactoGPA",
                    "Factocatdes", "Factoprefpls", "readDataSetFacto") %in%
                    leaves$command))
})

test_that("FactoMineR builders produce calls", {
  expect_match(build_facto_pca("d", c("x", "y"))[[1]], "FactoMineR::PCA")
  expect_match(build_facto_ca("d", "r", "c")[[1]], "FactoMineR::CA")
  expect_match(build_facto_mca("d", c("a", "b"))[[1]], "FactoMineR::MCA")
  expect_match(build_facto_mfa("d", c("x", "y"), c(1, 1))[[1]], "FactoMineR::MFA")
  expect_match(build_facto_famd("d", c("x", "a"))[[1]], "FactoMineR::FAMD")
  expect_match(build_facto_hcpc(".pca")[[1]], "FactoMineR::HCPC")
  expect_match(build_facto_gpa("d", c("x", "y"), c(1, 1))[[1]], "FactoMineR::GPA")
  expect_match(build_facto_catdes("d", "g"), "catdes")
  expect_match(build_facto_prefpls("d", c("x", "y")), "prefpls")
})

test_that("the PCA dialog returns a command", {
  RcmdrShiny::unload_plugins()
  on.exit(RcmdrShiny::unload_plugins(), add = TRUE)
  rcmdrshiny_plugin()
  state <- RcmdrShiny::AppState(env = new.env())
  assign("mtcars", mtcars, envir = state$env)
  RcmdrShiny::active_dataset(state, "mtcars")
  spec <- RcmdrShiny::get_dialog("FactoPCA")
  result <- spec$on_ok(list(FactoPCA_variables = c("mpg", "disp", "hp")), state)
  expect_match(result$commands[[1]], "FactoMineR::PCA")
})
