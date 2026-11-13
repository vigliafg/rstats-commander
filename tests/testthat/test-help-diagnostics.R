test_that("the diagnostic report lists versions and plugins", {
  report <- diagnostics_report()
  expect_true(nzchar(report$r_version))
  expect_true(nzchar(report$rcmdrshiny))
  expect_true(is.character(report$plugins))
  expect_true("RcmdrShiny" %in% names(report$packages))

  text <- format_diagnostics(report)
  expect_true(any(grepl("RcmdrShiny", text)))
  expect_true(any(grepl("Plugins:", text)))
})
