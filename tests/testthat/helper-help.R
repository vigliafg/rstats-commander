# Helpers for the help-infrastructure tests.

# Build a throw-away directory that looks like a plugin's inst/help-topics.
help_test_plugin_dir <- function() {
  directory <- tempfile("rcmdrshiny-help-")
  dir.create(file.path(directory, "topics"), recursive = TRUE)

  writeLines(
    c(
      "---",
      "id: demo-topic",
      "title: Demo topic",
      "type: task",
      "category: plugins",
      "keywords: [demo, sample]",
      "dialogs: [demoDialog]",
      "---",
      "",
      "A demo topic used by the test suite."
    ),
    file.path(directory, "topics", "demo-topic.md")
  )

  writeLines(
    c(
      "version: 1",
      "language: en",
      "categories:",
      "  - id: plugins",
      "    title: Plugins",
      "    order: 70",
      "topics:",
      "  - id: demo-topic",
      "    file: topics/demo-topic.md",
      "    category: plugins",
      "    order: 10"
    ),
    file.path(directory, "index.yml")
  )
  directory
}
