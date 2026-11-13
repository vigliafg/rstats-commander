#!/usr/bin/env Rscript
# Check internal links and images in the help topics.
#
# Usage:
#   Rscript tools/check_help_links.R [--strict]
#
# Checks:
#   * topic:<id> links resolve to a shipped topic;
#   * relative Markdown links and images exist on disk;
#   * every manifest entry points to an existing file;
#   * every topic file is listed in its manifest.

script_path <- function() {
  args <- commandArgs(trailingOnly = FALSE)
  hit <- grep("^--file=", args, value = TRUE)
  if (length(hit) == 0L) return("tools")
  dirname(normalizePath(sub("^--file=", "", hit[[1L]])))
}

source(file.path(script_path(), "help_tools.R"))

args <- commandArgs(trailingOnly = TRUE)
strict <- "--strict" %in% args
root <- getwd()

directories <- c(file.path(root, "inst", "help-topics"))
plugin_dirs <- list.dirs(file.path(root, "plugins"), recursive = FALSE)
for (plugin_dir in plugin_dirs) {
  candidate <- file.path(plugin_dir, "inst", "help-topics")
  if (dir.exists(candidate)) directories <- c(directories, candidate)
}
directories <- directories[dir.exists(directories)]

problems <- character()

all_topics <- list()
for (directory in directories) {
  topics <- help_tool_topics(directory)
  package <- if (grepl("plugins", directory, fixed = TRUE)) {
    basename(dirname(dirname(directory)))
  } else {
    NULL
  }
  for (topic in topics) {
    canonical <- if (is.null(package)) {
      topic$id
    } else {
      sprintf("plugin:%s:%s", package, topic$id)
    }
    all_topics[[canonical]] <- list(
      id = topic$id, file = file.path(directory, topic$file),
      directory = directory, package = package
    )
  }

  # Manifest integrity.
  manifest <- help_tool_manifest(directory)
  listed <- vapply(manifest$topics %||% list(), function(entry) {
    help_tool_scalar(entry, "file", "")
  }, character(1))
  present <- vapply(topics, function(topic) topic$file, character(1))
  for (file in setdiff(present, listed)) {
    problems <- c(problems, sprintf("%s: topic file not listed in index.yml: %s",
                                    directory, file))
  }
  for (file in setdiff(listed, present)) {
    problems <- c(problems, sprintf("%s: index.yml lists a missing file: %s",
                                    directory, file))
  }
}

known <- names(all_topics)
short <- vapply(all_topics, function(topic) topic$id, character(1))

# Translated topics are scanned for links too, but they do not add ids to the
# manifest: the English file already provides the entry.
translation_files <- unlist(lapply(directories, function(directory) {
  roots <- list.dirs(file.path(directory, "topics"), recursive = FALSE,
                     full.names = TRUE)
  roots <- roots[grepl("^[a-z]{2}(_[A-Z]{2})?$", basename(roots))]
  unlist(lapply(roots, function(root) {
    list.files(root, pattern = "\\.md$", full.names = TRUE)
  }), use.names = FALSE)
}), use.names = FALSE)

resolve_topic <- function(target) {
  if (target %in% known) return(TRUE)
  if (target %in% short) return(TRUE)
  suffix <- paste0(":", target)
  any(endsWith(known, suffix))
}

link_pattern <- "\\]\\((topic:[^)]+|[^)h][^)]*)\\)"
image_pattern <- "!\\[[^]]*\\]\\(([^)]+)\\)"

for (topic in c(all_topics, lapply(translation_files, function(file) {
  list(file = file)
}))) {
  lines <- readLines(topic$file, warn = FALSE, encoding = "UTF-8")
  body <- paste(lines, collapse = "\n")
  # Code spans and fenced blocks contain examples, not links.
  body <- gsub("(?s)```.*?```", "", body, perl = TRUE)
  body <- gsub("`[^`]*`", "", body)

  topic_links <- regmatches(body, gregexpr("topic:[A-Za-z0-9_.:-]+", body))[[1L]]
  for (link in unique(topic_links)) {
    target <- sub("^topic:", "", link)
    if (!resolve_topic(target)) {
      problems <- c(problems,
                    sprintf("%s: unknown topic link %s",
                            topic$file, link))
    }
  }

  relative <- regmatches(body, gregexpr(link_pattern, body, perl = TRUE))[[1L]]
  relative <- sub("^\\]\\(topic:", "", relative)
  relative <- sub("^\\]\\(", "", relative)
  relative <- sub("\\)$", "", relative)
  relative <- relative[!grepl("^(https?|mailto):", relative)]
  relative <- relative[nzchar(relative)]
  for (link in relative) {
    target <- sub("#.*$", "", link)
    if (!nzchar(target)) next
    if (!file.exists(file.path(dirname(topic$file), target))) {
      problems <- c(problems,
                    sprintf("%s: missing link target %s", topic$file, link))
    }
  }

  images <- regmatches(body, gregexpr(image_pattern, body, perl = TRUE))[[1L]]
  images <- sub("^!\\[[^]]*\\]\\(", "", images)
  images <- sub("\\)$", "", images)
  images <- images[!grepl("^(https?|data):", images)]
  for (image in images) {
    if (!file.exists(file.path(dirname(topic$file), image))) {
      problems <- c(problems,
                    sprintf("%s: missing image %s", topic$file, image))
    }
  }
}

problems <- unique(problems)
cat(sprintf("Checked %d topic(s) in %d director(ies).\n",
            length(all_topics), length(directories)))
if (length(problems) == 0L) {
  cat("No broken links.\n")
} else {
  cat(sprintf("%d problem(s):\n", length(problems)))
  cat(paste0("  - ", problems, collapse = "\n"), "\n")
  if (isTRUE(strict)) quit(status = 1L)
}
