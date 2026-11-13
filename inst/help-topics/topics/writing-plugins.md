---
id: writing-plugins
title: Writing a plugin
type: reference
category: plugins
keywords: [plugin, develop, package, rcmdrshiny_plugin, dialogs, menus, namespace]
aliases: [plugin-development, developer-guide]
dialogs: []
commands: [RcmdrShiny.plugin, plugin_dialog, load_plugin_package]
packages: [RcmdrShiny]
related: [plugins, writing-help-topics]
language: en
status: documented
---

# Writing a plugin

A plugin is an ordinary R package with a `rcmdrshiny_plugin()` function and,
optionally, a menu file and help topics.

## Package skeleton

```text
RcmdrShinyPlugin.Example/
├─ DESCRIPTION
├─ NAMESPACE
├─ R/
│  ├─ plugin.R
│  ├─ dialogs.R
│  └─ commands.R
├─ inst/etc/rcmdrshiny-menus.txt
├─ inst/help/index.yml
├─ man/
└─ tests/testthat/
```

`DESCRIPTION` imports `RcmdrShiny` and, if the dialogs use HTML helpers,
`htmltools`.

## Register the plugin

```r
rcmdrshiny_plugin <- function() {
  RcmdrShiny::RcmdrShiny.plugin(
    name = "RcmdrShinyPlugin.Example",
    menus = system.file("etc", "rcmdrshiny-menus.txt",
                        package = "RcmdrShinyPlugin.Example"),
    dialogs = example_dialogs(),
    version = "0.1.0",
    description = "Example plugin."
  )
}
```

Export the function in `NAMESPACE`:

```r
export(rcmdrshiny_plugin)
```

## Build a dialog

```r
example_dialogs <- function() {
  list(
    examplePlot = RcmdrShiny::plugin_dialog(
      id = "examplePlot",
      title = "Example plot",
      help_topic = "example-plot",
      ui = function(state, memory) {
        htmltools::tagList(
          RcmdrShiny::var_input(
            "examplePlot_variable", "Variable",
            RcmdrShiny::numeric_variables(state),
            if (is.null(memory)) NULL else memory$variable
          )
        )
      },
      on_ok = function(input, state) {
        variable <- input$examplePlot_variable
        if (is.null(variable) || !nzchar(variable)) {
          return(list(error = "Choose a variable."))
        }
        list(
          commands = sprintf("plot(%s$%s)",
                             RcmdrShiny::active_dataset(state), variable),
          memory = list(variable = variable),
          plot = TRUE
        )
      }
    )
  )
}
```

`on_ok()` returns either `list(error = ...)` or `list(commands = ...,
memory = ..., plot = ...)`.  Commands are shown in the **Script** tab exactly as
returned, so keep them short and readable.

## Menu file

The format is the Rcmdr menu format: one row per menu or item, whitespace
separated, with quoted labels.

```text
menu  exampleMenu  topMenu  ""  ""  ""  ""
item  exampleMenu  command  "Example plot..."  examplePlot  "activeDataSetP()"  ""
item  topMenu      cascade  "Example"         exampleMenu  ""  ""
```

## Help topics

Add `inst/help/index.yml` and Markdown topics; the loader discovers them
automatically.  See `topic:writing-help-topics`.

## Test the plugin

```r
testthat::test_local("plugins/RcmdrShinyPlugin.Example")
R CMD check RcmdrShinyPlugin.Example_0.1.0.tar.gz
```

## See also

- `topic:plugins`
- `topic:writing-help-topics`
