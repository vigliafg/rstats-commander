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
for (package in args) {
  RcmdrShiny::load_plugin_package(package)
}

loaded <- RcmdrShiny::list_plugins()
missing <- setdiff(args, loaded)
if (length(missing) > 0L) {
  stop("Plugins did not register: ", paste(missing, collapse = ", "),
       call. = FALSE)
}

leaves <- RcmdrShiny::menu_leaves(RcmdrShiny::menu_tree())
top <- vapply(RcmdrShiny::menu_tree(), function(node) node$label, character(1))
cat(sprintf("Loaded %d plugin(s): %s\n", length(loaded),
            paste(loaded, collapse = ", ")))
cat(sprintf("Menu leaves: %d\n", nrow(leaves)))
cat(sprintf("Top-level menus: %s\n", paste(top, collapse = " | ")))

if (nrow(leaves) == 0L) stop("The combined menu tree is empty.", call. = FALSE)
if (!all(c("Tools", "Help") %in% top)) {
  stop("Core menus are missing after loading plugins.", call. = FALSE)
}
cat("OK\n")
