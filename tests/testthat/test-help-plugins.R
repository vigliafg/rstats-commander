test_that("a plugin can register help topics by directory", {
  RcmdrShiny::unload_plugins()
  help_unregister()
  on.exit({
    RcmdrShiny::unload_plugins()
    help_unregister()
  }, add = TRUE)

  directory <- help_test_plugin_dir()
  on.exit(unlink(directory, recursive = TRUE), add = TRUE)

  RcmdrShiny::RcmdrShiny.plugin(
    name = "test-help-plugin",
    dialogs = list(),
    help = directory
  )

  topic <- help_topic("plugin:test-help-plugin:demo-topic")
  expect_false(is.null(topic))
  expect_equal(topic$title, "Demo topic")

  # unload_plugins removes the plugin topics.
  RcmdrShiny::unload_plugins()
  expect_null(help_topic("plugin:test-help-plugin:demo-topic"))
})

test_that("a missing plugin help directory produces a warning, not an error", {
  RcmdrShiny::unload_plugins()
  on.exit(RcmdrShiny::unload_plugins(), add = TRUE)

  expect_warning(
    RcmdrShiny::RcmdrShiny.plugin(
      name = "test-missing-help",
      dialogs = list(),
      help = file.path(tempdir(), "does-not-exist")
    ),
    "help directory not found"
  )
})

test_that("plugin topics declare their dialogs so dialogs can find them", {
  RcmdrShiny::unload_plugins()
  help_unregister()
  on.exit({
    RcmdrShiny::unload_plugins()
    help_unregister()
  }, add = TRUE)

  directory <- help_test_plugin_dir()
  on.exit(unlink(directory, recursive = TRUE), add = TRUE)
  RcmdrShiny::RcmdrShiny.plugin(
    name = "test-help-plugin",
    dialogs = list(),
    help = directory
  )

  spec <- dialog_spec(
    id = "demoDialog", title = "Demo",
    ui = function(state, memory) NULL,
    on_ok = function(input, state) list()
  )
  topic <- help_topic_for_dialog(spec)
  expect_equal(topic$id, "plugin:test-help-plugin:demo-topic")
})

test_that("every installed plugin has a help manifest", {
  skip_on_cran()
  plugins <- rownames(utils::installed.packages())
  plugins <- plugins[grepl("^RcmdrShinyPlugin\\.", plugins)]
  plugins <- setdiff(plugins, "RcmdrShinyPlugin.Demo")
  if (length(plugins) == 0L) skip("no plugin packages installed")

  manifests <- vapply(plugins, function(package) {
    nzchar(system.file("help-topics", "index.yml", package = package))
  }, logical(1))

  expect_equal(plugins[!manifests], character())
})

