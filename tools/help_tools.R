# Shared helpers for the help tooling --------------------------------------
#
# The tools run against the installed package and rewrite only the files they
# own: topic skeletons and the generated part of index.yml.

suppressPackageStartupMessages(library(RcmdrShiny))

`%||%` <- function(x, y) if (is.null(x)) y else x

help_tool_parse <- function(path) {
  RcmdrShiny:::help_parse_front_matter(
    readLines(path, warn = FALSE, encoding = "UTF-8")
  )
}

help_tool_scalar <- function(meta, key, default = NULL) {
  value <- meta[[key]]
  if (is.null(value)) return(default)
  value <- as.character(unlist(value, use.names = FALSE))
  value <- value[!is.na(value) & nzchar(value)]
  if (length(value) == 0L) default else value[[1L]]
}

help_tool_list <- function(meta, key) {
  value <- meta[[key]]
  if (is.null(value)) return(character())
  as.character(unlist(value, use.names = FALSE))
}

help_tool_manifest <- function(directory) {
  path <- file.path(directory, "index.yml")
  if (!file.exists(path)) {
    return(list(version = 1L, language = "en", categories = list(),
                topics = list()))
  }
  RcmdrShiny:::help_read_manifest(path)
}

help_tool_topics <- function(directory) {
  roots <- file.path(directory, "topics")
  if (!dir.exists(roots)) return(list())
  files <- list.files(roots, pattern = "\\.md$", recursive = TRUE,
                      full.names = TRUE)
  topics <- lapply(files, function(path) {
    parsed <- help_tool_parse(path)
    meta <- parsed$meta
    language <- help_tool_scalar(meta, "language", "en")
    if (!identical(language, "en")) return(NULL)
    file_id <- sub("\\.md$", "", basename(path))
    list(
      id = help_tool_scalar(meta, "id", file_id),
      title = help_tool_scalar(meta, "title", file_id),
      category = help_tool_scalar(meta, "category", "general"),
      order = as.integer(help_tool_scalar(meta, "order", "100")),
      file = file.path("topics", sub(paste0("^", roots, "/?"), "", path)),
      dialogs = help_tool_list(meta, "dialogs"),
      status = help_tool_scalar(meta, "status", "documented")
    )
  })
  Filter(Negate(is.null), topics)
}

help_tool_categories <- function(directory) {
  manifest <- help_tool_manifest(directory)
  categories <- manifest$categories
  if (length(categories) == 0L) {
    categories <- list(
      list(id = "getting-started", title = "Getting started", order = 10L),
      list(id = "data", title = "Data", order = 20L),
      list(id = "statistics", title = "Statistics", order = 30L),
      list(id = "models", title = "Models", order = 40L),
      list(id = "graphs", title = "Graphs", order = 50L),
      list(id = "distributions", title = "Distributions", order = 60L),
      list(id = "tools", title = "Tools", order = 65L),
      list(id = "plugins", title = "Plugins", order = 70L),
      list(id = "help", title = "Using the help", order = 80L),
      list(id = "troubleshooting", title = "Troubleshooting", order = 90L)
    )
  }
  categories
}

help_tool_write_index <- function(directory, categories = NULL,
                                  topics = NULL) {
  if (is.null(categories)) categories <- help_tool_categories(directory)
  if (is.null(topics)) topics <- help_tool_topics(directory)

  category_order <- vapply(categories, function(category) {
    as.integer(help_tool_scalar(category, "order", "100"))
  }, integer(1))
  categories <- categories[order(category_order)]

  if (length(topics) > 0L) {
    category_of <- vapply(topics, function(topic) topic$category, character(1))
    order_of <- vapply(topics, function(topic) topic$order %||% 100L, integer(1))
    title_of <- vapply(topics, function(topic) topic$title, character(1))
    rank <- match(category_of, vapply(categories, function(category) {
      help_tool_scalar(category, "id", "")
    }, character(1)))
    topics <- topics[order(rank, order_of, title_of)]
  }

  lines <- c("version: 1", "language: en", "", "categories:")
  for (category in categories) {
    lines <- c(
      lines,
      sprintf("  - id: %s", help_tool_scalar(category, "id", "")),
      sprintf("    title: %s", help_tool_scalar(category, "title", "")),
      sprintf("    order: %s", help_tool_scalar(category, "order", "100"))
    )
  }
  lines <- c(lines, "", "topics:")
  for (topic in topics) {
    lines <- c(
      lines,
      sprintf("  - id: %s", topic$id),
      sprintf("    file: %s", topic$file),
      sprintf("    category: %s", topic$category),
      sprintf("    order: %d", as.integer(topic$order %||% 100L))
    )
  }
  writeLines(lines, file.path(directory, "index.yml"), useBytes = TRUE)
  invisible(topics)
}

help_tool_existing <- function(directory) {
  topics <- help_tool_topics(directory)
  list(
    ids = vapply(topics, function(topic) topic$id, character(1)),
    dialogs = unique(unlist(lapply(topics, function(topic) topic$dialogs),
                             use.names = FALSE)),
    files = vapply(topics, function(topic) topic$file, character(1))
  )
}

help_tool_slug <- function(x) {
  x <- tolower(gsub("[^A-Za-z0-9]+", "-", x))
  gsub("^-+|-+$", "", x)
}

help_tool_write_topic <- function(directory, id, text, overwrite = FALSE) {
  path <- file.path(directory, "topics", paste0(id, ".md"))
  if (file.exists(path) && !isTRUE(overwrite)) return(invisible(FALSE))
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  writeLines(text, path, useBytes = TRUE)
  invisible(TRUE)
}
