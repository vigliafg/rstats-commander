test_that("searching for a title word finds the topic first", {
  help_unregister()
  on.exit(help_unregister(), add = TRUE)

  results <- help_search("numerical summaries")
  expect_gt(nrow(results), 0L)
  expect_equal(results$id[[1L]], "numerical-summaries")
})

test_that("search matches command names and aliases", {
  help_unregister()
  on.exit(help_unregister(), add = TRUE)

  results <- help_search("numSummary")
  expect_true("numerical-summaries" %in% results$id)

  results <- help_search("lm")
  expect_true("linear-model" %in% results$id)
})

test_that("search handles partial words", {
  help_unregister()
  on.exit(help_unregister(), add = TRUE)

  results <- help_search("summar")
  expect_true("numerical-summaries" %in% results$id)
})

test_that("search returns an empty frame for empty or unknown queries", {
  help_unregister()
  on.exit(help_unregister(), add = TRUE)

  empty <- help_search("")
  expect_equal(nrow(empty), 0L)
  expect_true(all(c("id", "title", "category", "score", "snippet", "package") %in%
                    names(empty)))

  expect_equal(nrow(help_search("zzzzqqqq")), 0L)
})

test_that("search respects the limit and orders by score", {
  help_unregister()
  on.exit(help_unregister(), add = TRUE)

  results <- help_search("model", limit = 3L)
  expect_lte(nrow(results), 3L)
  expect_true(all(diff(results$score) <= 0))
})

test_that("search results include a snippet", {
  help_unregister()
  on.exit(help_unregister(), add = TRUE)

  results <- help_search("logistic")
  expect_gt(nrow(results), 0L)
  expect_true(nzchar(results$snippet[[1L]]))
})
