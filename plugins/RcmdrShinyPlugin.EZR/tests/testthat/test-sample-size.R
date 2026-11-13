test_that("all seventeen sample-size entries are registered", {
  RcmdrShiny::unload_plugins()
  on.exit(RcmdrShiny::unload_plugins(), add = TRUE)
  rcmdrshiny_plugin()

  ids <- c(
    "StatMedSamplePhaseII", "StatMedSampleProportionsCI",
    "StatMedSampleProportionsSingle", "StatMedPowerProportionsSingle",
    "StatMedSampleProportions", "StatMedPowerProportions",
    "StatMedSampleProportionsNonInf", "StatMedSampleSelectionDesign",
    "StatMedSampleMeansCI", "StatMedSampleMeans", "StatMedPowerMeans",
    "StatMedSampleMeansNonInf", "StatMedSampleMeansPaired",
    "StatMedPowerMeansPaired", "StatMedSampleHazard", "StatMedPowerHazard",
    "StatMedSampleHazardNonInf"
  )
  for (id in ids) {
    spec <- RcmdrShiny::get_dialog(id)
    expect_false(is.null(spec), info = id)
    expect_equal(spec$help_topic, "ezr-sample-size")
  }

  implemented <- RcmdrShiny:::implemented_commands()
  expect_true(all(ids %in% implemented))
})

test_that("sample-size builders cover proportions, means and hazard", {
  expect_equal(
    ezr_sample_size_command("proportion_ci",
                            values = list(p = 0.5, margin = 0.1, alpha = 0.05)),
    "ceiling(0.5 * (1 - 0.5) * (qnorm(1 - 0.05/2) / 0.1)^2)"
  )
  expect_match(
    ezr_sample_size_command("mean_ci",
                            values = list(sd = 1, margin = 0.5, alpha = 0.05)),
    "^ceiling\\(\\("
  )
  expect_match(
    ezr_sample_size_command("proportion_one", "size",
                            values = list(p0 = 0.5, p1 = 0.6)),
    "pwr::pwr.p.test\\(h = pwr::ES.h\\(0.6, 0.5\\)"
  )
  expect_match(
    ezr_sample_size_command("proportion_one", "power",
                            values = list(p0 = 0.5, p1 = 0.6, n = 120)),
    "n = 120"
  )
  expect_match(
    ezr_sample_size_command("proportion_two", "size",
                            values = list(p1 = 0.4, p2 = 0.6)),
    "pwr::pwr.2p.test"
  )
  expect_match(
    ezr_sample_size_command("mean_one", "size",
                            values = list(mean0 = 0, mean1 = 1, sd = 1)),
    "pwr::pwr.t.test\\(d = \\(1 - 0\\) / 1"
  )
  expect_match(
    ezr_sample_size_command("paired_mean", "size",
                            values = list(mean1 = 0, mean2 = 1, sd = 1)),
    'type = "paired"'
  )
  expect_match(
    ezr_sample_size_command("hazard", "size",
                            values = list(hr = 0.7, event_rate = 0.6)),
    "^ceiling\\(\\(qnorm"
  )
  expect_match(
    ezr_sample_size_command("phase2", values = list()),
    "clinfun::ph2simon"
  )
  expect_match(
    ezr_sample_size_command("selection", values = list()),
    "clinfun::ph2single"
  )
})

test_that("non-inferiority variants shift the effect", {
  plain <- ezr_sample_size_command(
    "proportion_two", "size", values = list(p1 = 0.4, p2 = 0.6)
  )
  noninf <- ezr_sample_size_command(
    "proportion_two", "size", noninf = TRUE,
    values = list(p1 = 0.4, p2 = 0.6, margin = 0.1)
  )
  expect_false(identical(plain, noninf))
  expect_match(noninf, "0\\.5")
})

test_that("sample-size dialogs return commands and do not capture plots", {
  RcmdrShiny::unload_plugins()
  on.exit(RcmdrShiny::unload_plugins(), add = TRUE)
  rcmdrshiny_plugin()

  state <- RcmdrShiny::AppState(env = new.env())
  spec <- RcmdrShiny::get_dialog("StatMedSampleMeans")
  result <- spec$on_ok(list(
    StatMedSampleMeans_mean0 = "0",
    StatMedSampleMeans_mean1 = "1",
    StatMedSampleMeans_sd = "1",
    StatMedSampleMeans_alpha = "0.05",
    StatMedSampleMeans_power = "0.8",
    StatMedSampleMeans_alternative = "two.sided"
  ), state)

  expect_null(result$error)
  expect_false(isTRUE(result$plot))
  expect_match(result$commands, "pwr::pwr.t.test")
})

test_that("invalid parameters are reported as dialog errors", {
  expect_error(
    ezr_sample_size_command("proportion_ci", values = list(p = 1.5)),
    "between 0 and 1"
  )
  expect_error(
    ezr_sample_size_command("hazard", values = list(hr = 1)),
    "not 1"
  )
})
