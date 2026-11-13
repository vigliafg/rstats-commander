#!/usr/bin/env Rscript
# Promote generated help topics from `draft` to `documented`.
#
# The generator writes structured reference topics whose menu paths, dialog ids
# and R functions are taken from the application itself.  This tool upgrades
# those topics once they have been checked by `inventory_help.R` and
# `check_help_links.R`: only files whose body matches the generated template
# are touched, so hand-written topics are never modified.
#
# Usage:
#   Rscript tools/promote_help_topics.R [--dry-run]

script_path <- function() {
  args <- commandArgs(trailingOnly = FALSE)
  hit <- grep("^--file=", args, value = TRUE)
  if (length(hit) == 0L) return("tools")
  dirname(normalizePath(sub("^--file=", "", hit[[1L]])))
}

source(file.path(script_path(), "help_tools.R"))

args <- commandArgs(trailingOnly = TRUE)
dry_run <- "--dry-run" %in% args

directories <- c(file.path(getwd(), "inst", "help-topics"))
plugins <- list.dirs(file.path(getwd(), "plugins"), recursive = FALSE)
for (plugin in plugins) {
  candidate <- file.path(plugin, "inst", "help-topics")
  if (dir.exists(candidate)) directories <- c(directories, candidate)
}
directories <- directories[dir.exists(directories)]

is_generated <- function(body) {
  markers <- c(
    "is the menu entry",
    "dialogs cover the four operations",
    "adds its menus and dialogs to RcmdrShiny",
    "## What it does"
  )
  any(vapply(markers, function(marker) grepl(marker, body, fixed = TRUE),
             logical(1))) &&
    grepl("## What it does", body, fixed = TRUE)
}

promoted <- 0L
skipped <- 0L

for (directory in directories) {
  topics <- help_tool_topics(directory)
  files <- vapply(topics, function(topic) {
    file.path(directory, topic$file)
  }, character(1))

  for (file in files) {
    lines <- readLines(file, warn = FALSE, encoding = "UTF-8")
    status_line <- grep("^status:", lines)
    if (length(status_line) != 1L) {
      skipped <- skipped + 1L
      next
    }
    if (!identical(trimws(lines[[status_line]]), "status: draft")) {
      next
    }
    body <- paste(lines, collapse = "\n")
    if (!is_generated(body)) {
      skipped <- skipped + 1L
      next
    }
    lines[[status_line]] <- "status: documented"
    if (!isTRUE(dry_run)) writeLines(lines, file, useBytes = TRUE)
    promoted <- promoted + 1L
  }

  if (!isTRUE(dry_run)) help_tool_write_index(directory)
}

cat(sprintf("%s %d topic(s); %d left as draft.\n",
            if (isTRUE(dry_run)) "Would promote" else "Promoted",
            promoted, skipped))
