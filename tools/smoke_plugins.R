#!/usr/bin/env Rscript
#
# Smoke test for installed RcmdrShiny plugin packages.
#
# Usage:
#   Rscript tools/smoke_plugins.R [package ...]
#
# With no arguments, every installed package whose name starts with
# RcmdrShinyPlugin. is loaded and the combined menu tree is checked.

args <- commandArgs(trailingOnly = TRUE)
if (length(args) == 0L) {
  installed <- rownames(utils::installed.packages())
  args <- grep("^RcmdrShinyPlugin[.]", installed, value = TRUE)
}
if (length(args) == 0L) {
  stop("No RcmdrShinyPlugin.* packages are installed.", call. = FALSE)
}

RcmdrShiny::unload_plugins()
plugin_warnings <- character()
for (package in args) {
  withCallingHandlers(
    RcmdrShiny::load_plugin_package(package),
    warning = function(w) {
      plugin_warnings <<- c(plugin_warnings, conditionMessage(w))
      invokeRestart("muffleWarning")
    }
  )
}

loaded <- RcmdrShiny::list_plugins()
missing <- setdiff(args, loaded)
if (length(missing) > 0L) {
  stop("Plugins did not register: ", paste(missing, collapse = ", "),
       call. = FALSE)
}

leaves <- NULL
top <- NULL
withCallingHandlers({
  tree <- RcmdrShiny::menu_tree()
  leaves <- RcmdrShiny::menu_leaves(tree)
  top <- vapply(tree, function(node) node$label, character(1))
}, warning = function(w) {
  plugin_warnings <<- c(plugin_warnings, conditionMessage(w))
  invokeRestart("muffleWarning")
})
cat(sprintf("Loaded %d plugin(s): %s\n", length(loaded),
            paste(loaded, collapse = ", ")))
cat(sprintf("Menu leaves: %d\n", nrow(leaves)))
cat(sprintf("Top-level menus: %s\n", paste(top, collapse = " | ")))
if (length(plugin_warnings) > 0L) {
  cat(sprintf("Plugin warnings: %d (menu entries skipped or overridden)\n",
              length(plugin_warnings)))
}

if (nrow(leaves) == 0L) stop("The combined menu tree is empty.", call. = FALSE)
if (!all(c("Tools", "Help") %in% top)) {
  stop("Core menus are missing after loading plugins.", call. = FALSE)
}
cat("OK\n")
