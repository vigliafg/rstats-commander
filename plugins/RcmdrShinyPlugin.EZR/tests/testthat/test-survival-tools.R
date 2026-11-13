test_that("survival builders produce valid calls", {
  expect_match(ezr_surv_logrank_trend("D", "time", "status", "g"),
               "survdiff")
  expect_match(ezr_surv_current("D", "time", "status", "g", 12),
               "summary\\(\\.fit, times = 12\\)")
  expect_match(ezr_surv_cox_td("D", "start", "stop", "event", c("x")),
               "Surv\\(start, stop, event\\)")
  expect_match(ezr_surv_cuminc("D", "time", "status", "g"),
               "cmprsk::cuminc")
  expect_match(ezr_surv_crr("D", "time", "status", c("x")),
               "cmprsk::crr")
  expect_match(ezr_surv_crr_td("D", "time", "status", c("x")),
               "survival::finegray")
  expect_match(ezr_surv_matching("D", "t", c("age"), 1),
               "MatchIt::matchit")
  expect_match(ezr_surv_mh("D", "r", "c", "s"), "mantelhaen.test")
  expect_match(ezr_surv_clogistic("D", "case", c("x"), "set"),
               "survival::clogit")
  expect_match(ezr_surv_stratified_cox("D", "time", "status", "x", "g"),
               "survival::strata\\(g\\)")
})

test_that("meta-analysis builders assemble the data frame", {
  expect_match(ezr_meta_prop("10, 20", "50, 60", "A, B"),
               "meta::metaprop")
  expect_match(ezr_meta_prop("10, 20", "50, 60", ""), 'paste\\("Study"')
  expect_match(
    ezr_meta_cont("30, 40", "5, 6", "1, 1.2", "30, 40", "4, 5", "1, 1.1"),
    "meta::metacont"
  )
  expect_match(ezr_meta_hazard("0.8, 0.7", "0.6, 0.5", "1, 0.9"),
               "\\.d\\$TE <- log")
  expect_match(ezr_netmeta("A, A", "B, C", "0.2, 0.3", "0.1, 0.12"),
               "netmeta::netmeta")
  expect_error(ezr_netmeta("A", "B, C", "0.2, 0.3", "0.1, 0.12"),
               "same length")
})

test_that("the fourteen survival entries are registered", {
  RcmdrShiny::unload_plugins()
  on.exit(RcmdrShiny::unload_plugins(), add = TRUE)
  rcmdrshiny_plugin()

  ids <- c("StatMedLogrankTrend", "StatMedCurrentSurvival", "StatMedCoxTD",
           "StatMedCumInc", "StatMedCrr", "StatMedCrrTD", "StatMedMatching",
           "StatMedMH", "StatMedCLogistic", "StatMedStCox", "StatMedMeta",
           "StatMedMetaCont", "StatMedMetaHazard", "StatMedNetworkMeta")
  for (id in ids) {
    expect_false(is.null(RcmdrShiny::get_dialog(id)), info = id)
  }
  expect_true(all(ids %in% RcmdrShiny:::implemented_commands()))
})
