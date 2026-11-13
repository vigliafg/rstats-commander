test_that("the internal YAML parser reads the manifest subset", {
  text <- paste(
    "version: 1",
    "language: en",
    "categories:",
    "  - id: data",
    "    title: Data",
    "    order: 10",
    "  - id: stats",
    "    title: Statistics",
    "    order: 20",
    "topics:",
    "  - id: foo",
    "    file: topics/foo.md",
    "    category: data",
    "    keywords: [one, two]",
    sep = "\n"
  )
  parsed <- help_yaml_parse(text, engine = "internal")

  expect_equal(parsed$version, 1L)
  expect_equal(parsed$language, "en")
  expect_length(parsed$categories, 2L)
  expect_equal(parsed$categories[[2L]]$title, "Statistics")
  expect_equal(parsed$topics[[1L]]$keywords, c("one", "two"))
})

test_that("the internal parser strips comments and unquotes scalars", {
  parsed <- help_yaml_parse(
    paste(
      "# a comment",
      "title: \"Quoted title\"  # trailing comment",
      "flag: true",
      "empty: []",
      sep = "\n"
    ),
    engine = "internal"
  )
  expect_equal(parsed$title, "Quoted title")
  expect_true(parsed$flag)
  expect_length(parsed$empty, 0L)
})

test_that("the yaml package and the internal parser agree", {
  skip_if_not_installed("yaml")
  text <- paste(
    "id: sample",
    "title: Sample topic",
    "keywords: [a, b, c]",
    "dialogs: [foo]",
    sep = "\n"
  )
  external <- help_yaml_parse(text, engine = "yaml")
  internal <- help_yaml_parse(text, engine = "internal")
  expect_equal(internal$id, external$id)
  expect_equal(internal$title, external$title)
  expect_equal(internal$keywords, external$keywords)
  expect_equal(internal$dialogs, external$dialogs)
})

test_that("front matter is separated from the body", {
  parsed <- help_parse_front_matter(paste(
    "---",
    "id: sample",
    "title: Sample",
    "---",
    "",
    "# Heading",
    "",
    "Body text.",
    sep = "\n"
  ))
  expect_equal(parsed$meta$id, "sample")
  expect_match(parsed$body, "Body text")
  expect_false(grepl("^---", parsed$body))
})

test_that("files without front matter are treated as body only", {
  parsed <- help_parse_front_matter("# Just markdown\n\nText.")
  expect_length(parsed$meta, 0L)
  expect_match(parsed$body, "Just markdown")
})

test_that("the core manifest registers the shipped topics", {
  help_unregister()
  on.exit(help_unregister(), add = TRUE)

  topics <- help_topics()
  expect_gt(length(topics), 10L)
  expect_true("getting-started" %in% names(topics))
  expect_true("numerical-summaries" %in% names(topics))

  topic <- topics[["numerical-summaries"]]
  expect_equal(topic$category, "statistics")
  expect_true("numericalSummaries" %in% topic$dialogs)
  expect_match(topic$body, "numSummary")
})

test_that("the category index reports counts and order", {
  help_unregister()
  on.exit(help_unregister(), add = TRUE)

  index <- help_index()
  expect_true(all(c("id", "title", "order", "count") %in% names(index)))
  expect_equal(index$id[[1L]], "getting-started")
  expect_gt(sum(index$count), 0L)
})

test_that("help_topic resolves ids, aliases and short plugin names", {
  help_unregister()
  on.exit(help_unregister(), add = TRUE)

  expect_equal(help_topic("numerical-summaries")$id, "numerical-summaries")
  expect_equal(help_topic("summary")$id, "numerical-summaries")

  help_register(list(
    version = 1,
    language = "en",
    categories = list(list(id = "plugins", title = "Plugins", order = 70)),
    topics = list(list(id = "demo-topic", file = "topics/demo-topic.md",
                       category = "plugins"))
  ), base_dir = help_test_plugin_dir(), package = "RcmdrShinyPlugin.Demo")

  expect_equal(help_topic("plugin:RcmdrShinyPlugin.Demo:demo-topic")$id,
               "plugin:RcmdrShinyPlugin.Demo:demo-topic")
  expect_equal(help_topic("demo-topic")$package, "RcmdrShinyPlugin.Demo")

  help_unregister("RcmdrShinyPlugin.Demo")
  expect_null(help_topic("plugin:RcmdrShinyPlugin.Demo:demo-topic"))
})

test_that("a dialog finds its topic by id or by the dialogs field", {
  help_unregister()
  on.exit(help_unregister(), add = TRUE)

  expect_equal(help_topic_for_dialog(list(id = "linearModel"))$id,
               "linear-model")
  expect_equal(help_topic_for_dialog(
    list(id = "numericalSummaries", help_topic = "t-tests")
  )$id, "t-tests")
  expect_null(help_topic_for_dialog(list(id = "not-a-dialog")))
})

test_that("translations fall back to English", {
  help_unregister()
  on.exit(help_unregister(), add = TRUE)

  english <- help_topic("getting-started", language = "en")
  german <- help_topic("getting-started", language = "de")
  expect_equal(german$title, english$title)
  expect_equal(german$language, "en")
})

test_that("Italian translations are registered and resolved", {
  help_unregister()
  on.exit(help_unregister(), add = TRUE)

  italian <- help_topic("numerical-summaries", language = "it")
  expect_equal(italian$language, "it")
  expect_match(italian$title, "Riassunti numerici")
  expect_match(italian$body, "numSummary")

  english <- help_topic("numerical-summaries", language = "en")
  expect_equal(english$title, "Numerical summaries")

  titles <- vapply(help_topics(language = "it"), function(topic) topic$title,
                   character(1))
  expect_true("Riassunti numerici" %in% titles)
})
