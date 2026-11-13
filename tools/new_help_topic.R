#!/usr/bin/env Rscript
# Create a help-topic skeleton and reindex the manifest.
#
# Usage:
#   Rscript tools/new_help_topic.R numericalSummaries \
#     --title "Numerical summaries" --category statistics \
#     [--dialogs numericalSummaries] [--commands numSummary] \
#     [--keywords summary,mean] [--dir inst/help-topics]

script_path <- function() {
  args <- commandArgs(trailingOnly = FALSE)
  hit <- grep("^--file=", args, value = TRUE)
  if (length(hit) == 0L) return("tools")
  dirname(normalizePath(sub("^--file=", "", hit[[1L]])))
}

source(file.path(script_path(), "help_tools.R"))

args <- commandArgs(trailingOnly = TRUE)
value_of <- function(flag, default = NULL) {
  if (!flag %in% args) return(default)
  args[[which(args == flag) + 1L]]
}

positional <- character()
index <- 1L
while (index <= length(args)) {
  if (grepl("^--", args[[index]])) {
    index <- index + 2L
  } else {
    positional <- c(positional, args[[index]])
    index <- index + 1L
  }
}
if (length(positional) == 0L) {
  stop("Usage: Rscript tools/new_help_topic.R <id> --title <title>", call. = FALSE)
}
id <- positional[[1L]]

title <- value_of("--title", id)
category <- value_of("--category", "statistics")
dialogs <- value_of("--dialogs", "")
commands <- value_of("--commands", "")
keywords <- value_of("--keywords", "")
directory <- value_of("--dir", file.path(getwd(), "inst", "help"))
force <- "--force" %in% args

split_list <- function(x) {
  if (is.null(x) || !nzchar(x)) return(character())
  trimws(strsplit(x, ",", fixed = TRUE)[[1L]])
}

list_field <- function(values) {
  if (length(values) == 0L) "[]" else paste0("[", paste(values, collapse = ", "), "]")
}

reference <- split_list(commands)
reference <- if (length(reference) == 0L) "topic" else reference[[1L]]

text <- c(
  "---",
  sprintf("id: %s", id),
  sprintf("title: %s", title),
  "type: task",
  sprintf("category: %s", category),
  "order: 100",
  sprintf("keywords: %s", list_field(split_list(keywords))),
  "aliases: []",
  sprintf("dialogs: %s", list_field(split_list(dialogs))),
  sprintf("commands: %s", list_field(split_list(commands))),
  sprintf("packages: %s", list_field(split_list(value_of("--packages", "RcmdrShiny")))),
  "related: []",
  "language: en",
  "status: draft",
  "---",
  "",
  sprintf("## What it does"),
  "",
  sprintf("Describe what the %s workflow does and when a user needs it.", title),
  "",
  "## How to fill it in",
  "",
  "1. Choose the active data set if the dialog offers a selector.",
  "2. Select the variables and options you need.",
  "3. Press **OK**.",
  "",
  "## What it produces",
  "",
  "The generated command is written to the **Script** tab and evaluated in the",
  "current session.",
  "",
  "## R reference",
  "",
  paste0("`?", reference, "`"),
  "",
  "## See also",
  "",
  "- `topic:getting-started`"
)

if (help_tool_write_topic(directory, id, text, overwrite = force)) {
  help_tool_write_index(directory)
  cat("Created", file.path(directory, "topics", paste0(id, ".md")), "\n")
} else {
  cat("Topic already exists; use --force to overwrite.\n")
}
