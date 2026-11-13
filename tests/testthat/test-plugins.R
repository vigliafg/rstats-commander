test_that("plugins extend menus, commands and dialogs", {
  unload_plugins()
  on.exit(unload_plugins(), add = TRUE)

  menus <- tempfile(fileext = ".txt")
  writeLines(c(
    '    menu    demoMenu        topMenu         ""                 ""          ""          ""',
    '    item    demoMenu        command         "Demo: Hello"       demoHello   ""          ""',
    '    item    demoMenu        command         "Demo: No args"     demoNoArgs  ""          ""',
    '    item    demoMenu        command         "Demo: Dialog"      demoDialog  ""          ""',
    '    item    topMenu         cascade         "Demo"              demoMenu    ""          ""'
  ), menus)
  on.exit(unlink(menus), add = TRUE)

  seen <- new.env()
  RcmdrShiny.plugin(
    name = "test-plugin",
    menus = menus,
    commands = list(
      demoHello = function(state) seen$hello <- TRUE,
      demoNoArgs = function() seen$noargs <- TRUE
    ),
    dialogs = list(
      demoDialog = plugin_dialog(
        "demoDialog", "Demo",
        ui = function(state, memory) htmltools::tags$p("demo"),
        on_ok = function(input, state) {
          list(commands = "1 + 1", memory = list(a = 1))
        }
      )
    )
  )

  leaves <- menu_leaves(menu_tree())
  expect_true(all(c("demoHello", "demoNoArgs", "demoDialog") %in%
                    leaves$command))
  expect_true("test-plugin" %in% list_plugins())

  state <- AppState(env = new.env())
  expect_equal(command_status(state, "demoHello"), "enabled")
  direct_commands()$demoHello(state)
  expect_true(seen$hello)
  direct_commands()$demoNoArgs(state)
  expect_true(seen$noargs)

  spec <- get_dialog_spec("demoDialog")
  expect_false(is.null(spec))
  expect_equal(spec$on_ok(list(), state)$commands, "1 + 1")

  html <- htmltools::renderTags(menu_ui(menu_tree(), function(node) {
    command_status(state, node$command, node$activation, node$install)
  }))$html
  expect_match(html, "Demo: Hello")
})

test_that("plugin scripts can be loaded from a file", {
  unload_plugins()
  on.exit(unload_plugins(), add = TRUE)

  menus <- tempfile(fileext = ".txt")
  writeLines(c(
    '    menu    scriptMenu      topMenu         ""                 ""          ""          ""',
    '    item    scriptMenu      command         "Script command"    scriptCmd   ""          ""',
    '    item    topMenu         cascade         "Script plugin"     scriptMenu  ""          ""'
  ), menus)
  script <- tempfile(fileext = ".R")
  writeLines(sprintf(
    "RcmdrShiny.plugin(name = 'script-plugin', menus = %s, commands = list(scriptCmd = function(state) invisible(NULL)))",
    deparse(menus)
  ), script)
  on.exit(unlink(c(menus, script)), add = TRUE)

  load_plugin(script)
  expect_true("script-plugin" %in% list_plugins())
  expect_true("scriptCmd" %in% names(direct_commands()))
  leaves <- menu_leaves(menu_tree())
  expect_true("scriptCmd" %in% leaves$command)
})

test_that("legacy Tk plugins are registered with a warning", {
  unload_plugins()
  on.exit(unload_plugins(), add = TRUE)

  expect_warning(
    RcmdrShiny.plugin(name = "legacy", tcltk = TRUE),
    "legacy Tk"
  )
  expect_true("legacy" %in% list_plugins())
})
