#!/usr/bin/env Rscript
#
# Scaffold a new RcmdrShiny plugin package.
#
# Usage:
#   Rscript tools/new_plugin.R <Name> [--dir plugins] [--title "..."]
#                              [--upstream RcmdrPlugin.Name] [--force]
#
# <Name> is the short plugin name (for example `Export`); the package is
# created as `RcmdrShinyPlugin.<Name>`.

args <- commandArgs(trailingOnly = TRUE)
if (length(args) == 0L) {
  stop("Usage: Rscript tools/new_plugin.R <Name> [--dir plugins] [--title ...] [--upstream ...] [--force]",
       call. = FALSE)
}

name <- args[[1L]]
if (!grepl("^[A-Za-z][A-Za-z0-9.]*$", name)) {
  stop("Plugin name must start with a letter and contain only letters, digits and dots.",
       call. = FALSE)
}

option <- function(flag, default = NULL) {
  index <- match(flag, args)
  if (is.na(index) || index == length(args)) return(default)
  args[[index + 1L]]
}

directory <- option("--dir", "plugins")
title <- option("--title", sprintf("RcmdrShiny Plugin: %s", name))
upstream <- option("--upstream", sprintf("RcmdrPlugin.%s", name))
force <- "--force" %in% args

package <- paste0("RcmdrShinyPlugin.", name)
root <- file.path(directory, package)
if (dir.exists(root) && !force) {
  stop(sprintf("%s already exists; use --force to overwrite.", root),
       call. = FALSE)
}

dir.create(file.path(root, "R"), recursive = TRUE, showWarnings = FALSE)
dir.create(file.path(root, "inst", "etc"), recursive = TRUE,
           showWarnings = FALSE)
dir.create(file.path(root, "tests", "testthat"), recursive = TRUE,
           showWarnings = FALSE)
dir.create(file.path(root, "man"), recursive = TRUE, showWarnings = FALSE)

writeLines(c(
  sprintf("Package: %s", package),
  "Type: Package",
  sprintf("Title: %s", title),
  "Version: 0.1.0",
  "Authors@R: person(\"RcmdrShiny\", \"Contributors\", role = c(\"aut\", \"cre\"),",
  "    email = \"vigliafg@gmail.com\")",
  sprintf("Description: RcmdrShiny menus and Shiny dialogs for the %s plugin.",
          upstream),
  "License: GPL (>= 2)",
  "Encoding: UTF-8",
  "Depends: R (>= 4.1.0)",
  "Imports:",
  "    RcmdrShiny (>= 1.1.0),",
  "    htmltools",
  "Suggests:",
  "    testthat (>= 3.0.0)",
  "Config/testthat/edition: 3",
  "URL: https://github.com/vigliafg/rstats-commander",
  "BugReports: https://github.com/vigliafg/rstats-commander/issues"
), file.path(root, "DESCRIPTION"))

writeLines(c(
  "export(rcmdrshiny_plugin)",
  "importFrom(htmltools, tagList, tags)"
), file.path(root, "NAMESPACE"))

writeLines(c(
  "# Plugin registration -------------------------------------------------------",
  "",
  "#' Register the plugin with RcmdrShiny",
  "#'",
  "#' @return The plugin object, invisibly.",
  "#' @export",
  "rcmdrshiny_plugin <- function() {",
  "  RcmdrShiny::RcmdrShiny.plugin(",
  sprintf("    name = \"%s\",", package),
  "    menus = system.file(\"etc\", \"rcmdrshiny-menus.txt\",",
  sprintf("                        package = \"%s\"),", package),
  "    commands = plugin_commands(),",
  "    dialogs = plugin_dialogs(),",
  sprintf("    version = \"%s\"", "0.1.0"),
  "  )",
  "}",
  "",
  "#' Direct commands (menu entries without a dialog)",
  "#' @keywords internal",
  "plugin_commands <- function() {",
  "  list()",
  "}",
  "",
  "#' Shiny dialog specifications",
  "#' @keywords internal",
  "plugin_dialogs <- function() {",
  "  list()",
  "}"
), file.path(root, "R", "plugin.R"))

writeLines(c(
  "# RcmdrShiny plugin menu definitions",
  "#",
  "# type    menu    kind      label    command    activation    install",
  "#",
  "# Example:",
  sprintf("# item    %sMenu    command    \"Example\"    exampleCmd    \"\"    \"\"", name),
  sprintf("# item    topMenu    cascade    \"%s\"    %sMenu    \"\"    \"\"", name, name),
  sprintf("# item    %sMenu    command    \"Example\"    exampleCmd    \"\"    \"\"", name)
), file.path(root, "inst", "etc", "rcmdrshiny-menus.txt"))

writeLines(c(
  "library(testthat)",
  sprintf("library(%s)", package),
  "",
  sprintf("test_check(\"%s\")", package)
), file.path(root, "tests", "testthat.R"))

writeLines(c(
  "\\name{rcmdrshiny_plugin}",
  "\\alias{rcmdrshiny_plugin}",
  sprintf("\\title{Register the %s plugin}", package),
  "\\usage{",
  "rcmdrshiny_plugin()",
  "}",
  "\\value{",
  "The plugin object, invisibly.",
  "}",
  "\\description{",
  "Registers the menus, direct commands and Shiny dialogs of the plugin with",
  "RcmdrShiny.",
  "}"
), file.path(root, "man", "rcmdrshiny_plugin.Rd"))

writeLines(c(
  "test_that(\"the plugin registers with RcmdrShiny\", {",
  "  RcmdrShiny::unload_plugins()",
  "  on.exit(RcmdrShiny::unload_plugins(), add = TRUE)",
  "",
  "  rcmdrshiny_plugin()",
  sprintf("  expect_true(\"%s\" %%in%% RcmdrShiny::list_plugins())", package),
  "})",
  "",
  "test_that(\"plugin menus merge with the core menus\", {",
  "  RcmdrShiny::unload_plugins()",
  "  on.exit(RcmdrShiny::unload_plugins(), add = TRUE)",
  "  rcmdrshiny_plugin()",
  "",
  "  leaves <- RcmdrShiny::menu_leaves(RcmdrShiny::menu_tree())",
  "  expect_true(nrow(leaves) > 0L)",
  "})"
), file.path(root, "tests", "testthat", "test-plugin.R"))

writeLines(c(
  sprintf("# %s", package),
  "",
  sprintf("RcmdrShiny plugin based on `%s`.", upstream),
  "",
  "## Install",
  "",
  "```r",
  sprintf("remotes::install_github(\"vigliafg/rstats-commander\", subdir = \"plugins/%s\")",
          package),
  "```",
  "",
  "## Use",
  "",
  "```r",
  sprintf("RcmdrShiny::run(plugins = \"%s\")", package),
  "```",
  "",
  "## Status",
  "",
  "- [ ] menus ported",
  "- [ ] commands ported",
  "- [ ] dialogs ported",
  "- [ ] golden tests",
  "- [ ] no Tk dependency"
), file.path(root, "README.md"))

cat(sprintf("Created %s\n", root))
