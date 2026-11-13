test_that("plugin menus are inserted into existing menus and before Tools/Help", {
  unload_plugins()
  on.exit(unload_plugins(), add = TRUE)

  menus <- tempfile(fileext = ".txt")
  writeLines(c(
    '    item    helpMenu       command    "Wave 0 help entry"     wave0Help    ""    ""',
    '    menu    wave0Menu       topMenu    ""                      ""           ""    ""',
    '    item    wave0Menu       command    "Wave 0 command"        wave0Cmd     ""    ""',
    '    item    topMenu         cascade    "Wave 0"                wave0Menu    ""    ""'
  ), menus)
  on.exit(unlink(menus), add = TRUE)

  RcmdrShiny.plugin(
    name = "wave0-menus",
    menus = menus,
    commands = list(wave0Help = function(state) invisible(NULL),
                    wave0Cmd = function(state) invisible(NULL))
  )

  tree <- menu_tree()
  labels <- vapply(tree, function(node) node$label, character(1))
  expect_true("Wave 0" %in% labels)
  expect_lt(match("Wave 0", labels), match("Tools", labels))
  expect_lt(match("Wave 0", labels), match("Help", labels))

  help_menu <- tree[[match("Help", labels)]]
  help_nodes <- Filter(function(node) identical(node$type, "item"),
                       help_menu$children)
  help_labels <- vapply(help_nodes, function(node) node$label, character(1))
  expect_equal(tail(help_labels, 1L), "Wave 0 help entry")
})

test_that("plugin menu remove rows delete a menu and its children", {
  definitions <- read_rcmdr_menus()
  additions <- data.frame(
    type = c("menu", "item", "item", "remove"),
    menu = c("tempMenu", "tempMenu", "topMenu", "tempMenu"),
    kind = c("topMenu", "command", "cascade", ""),
    label = c("", "Temporary", "Temporary", ""),
    command = c("", "tempCommand", "tempMenu", ""),
    activation = rep("", 4L),
    install = rep("", 4L),
    stringsAsFactors = FALSE
  )

  merged <- merge_menu_definitions(definitions, additions[1:3, ])
  expect_true("tempCommand" %in% merged$command)
  expect_true("Temporary" %in% merged$label)

  removed <- merge_menu_definitions(merged, additions[4, ])
  expect_false("tempCommand" %in% removed$command)
  expect_false("tempMenu" %in% removed$menu)
})

test_that("plugin predicates extend the activation environment", {
  unload_plugins()
  on.exit(unload_plugins(), add = TRUE)

  flag <- new.env(parent = emptyenv())
  flag$value <- FALSE

  menus <- tempfile(fileext = ".txt")
  writeLines(c(
    '    menu    predicateMenu  topMenu   ""                    ""             ""               ""',
    '    item    predicateMenu  command   "Predicate"            predicateCmd   "wave0FlagP()"   ""',
    '    item    topMenu        cascade   "Predicate plugin"     predicateMenu   ""               ""'
  ), menus)
  on.exit(unlink(menus), add = TRUE)

  RcmdrShiny.plugin(
    name = "wave0-predicates",
    menus = menus,
    commands = list(predicateCmd = function(state) invisible(NULL)),
    predicates = list(wave0FlagP = function() isTRUE(flag$value))
  )

  state <- AppState(env = new.env())
  expect_equal(command_status(state, "predicateCmd", "wave0FlagP()"), "inactive")
  flag$value <- TRUE
  expect_equal(command_status(state, "predicateCmd", "wave0FlagP()"), "enabled")
})

test_that("command and dialog conflicts are rejected", {
  unload_plugins()
  on.exit(unload_plugins(), add = TRUE)

  expect_error(
    RcmdrShiny.plugin(
      name = "conflict-command",
      commands = list(viewData = function(state) invisible(NULL))
    ),
    "already defined"
  )

  expect_error(
    RcmdrShiny.plugin(
      name = "conflict-dialog",
      dialogs = list(linearModel = plugin_dialog(
        "linearModel", "Duplicate",
        ui = function(state, memory) htmltools::tags$p("duplicate"),
        on_ok = function(input, state) list()
      ))
    ),
    "already defined"
  )

  expect_silent(RcmdrShiny.plugin(
    name = "conflict-command",
    commands = list(viewData = function(state) invisible(NULL)),
    replace = TRUE
  ))
})

test_that("package namespaces can return plugin specifications", {
  unload_plugins()
  on.exit(unload_plugins(), add = TRUE)

  namespace <- new.env(parent = globalenv())
  namespace$rcmdrshiny_plugin <- function() {
    list(
      name = "spec-plugin",
      commands = list(specCommand = function(state) invisible(NULL))
    )
  }

  result <- load_plugin_namespace(namespace, "RcmdrShinyPlugin.Spec")
  expect_true("spec-plugin" %in% list_plugins())
  expect_true("specCommand" %in% names(direct_commands()))
  expect_equal(result$name, "spec-plugin")
})

test_that("plugin_formula builds formula strings", {
  expect_equal(plugin_formula("y", c("x1", "x2")), "y ~ x1 + x2")
  expect_equal(plugin_formula(NULL, c("x1", "x2")), "x1 + x2")
  expect_equal(plugin_formula("y", "x", list(c("a", "b"))),
               "y ~ x + (a * b)")
  expect_equal(plugin_formula("y", character()), "y ~ 1")
})

test_that("printed objects are available through popOutput", {
  unload_plugins()
  state <- AppState(env = new.env())
  run_command(state, "summary(1:10)")
  object <- popOutput(keep = TRUE)
  expect_true(inherits(object, "summaryDefault"))
  expect_equal(popOutput(keep = TRUE), object)
  expect_equal(popOutput(), object)
  expect_true(is.na(popOutput()))
})

