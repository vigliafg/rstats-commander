test_that("Markdown is rendered to HTML", {
  html <- help_render("# Title\n\nSome **bold** text.")
  expect_match(html, "<h1>Title</h1>")
  expect_match(html, "<strong>bold</strong>")
})

test_that("topic: links are rewritten for the help centre", {
  html <- help_render("See [the other topic](topic:other-topic).")
  expect_match(html, "data-help-topic=\"other-topic\"")
  expect_false(grepl("href=\"topic:", html))
})

test_that("the plain renderer escapes HTML", {
  old <- options(RcmdrShiny.help.markdown = "plain")
  on.exit(options(old), add = TRUE)
  html <- help_render("# Title\n\n<script>alert(1)</script>")
  expect_match(html, "<pre")
  expect_false(grepl("<script>", html, fixed = TRUE))
})

test_that("help_topic_html includes the topic title", {
  help_unregister()
  on.exit(help_unregister(), add = TRUE)

  html <- help_topic_html("linear-model")
  expect_match(html, "<h2>Linear model</h2>")
  expect_match(html, "lm\\(")
  expect_null(help_topic_html("no-such-topic"))
})
