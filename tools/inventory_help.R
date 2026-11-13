#!/usr/bin/env Rscript
# Report help coverage: which dialogs have a topic, which rely on Rd help and
# which have neither.
#
# Usage:
#   Rscript tools/inventory_help.R                  # core only
#   Rscript tools/inventory_help.R --plugins all    # core + installed plugins
#   Rscript tools/inventory_help.R --strict         # exit 1 when topics are missing

script_path <- function() {
  args <- commandArgs(trailingOnly = FALSE)
  hit <- grep("^--file=", args, value = TRUE)
  if (length(hit) == 0L) return("tools")
  dirname(normalizePath(sub("^--file=", "", hit[[1L]])))
}

source(file.path(script_path(), "help_tools.R"))

args <- commandArgs(trailingOnly = TRUE)
strict <- "--strict" %in% args
output <- file.path(getwd(), "inst", "etc", "help-inventory.csv")
if ("--output" %in% args) {
  output <- args[[which(args == "--output") + 1L]]
}

plugins <- character()
if ("--plugins" %in% args) {
  value <- args[[which(args == "--plugins") + 1L]]
  plugins <- if (identical(value, "all")) {
    rownames(utils::installed.packages())
  } else {
    strsplit(value, ",", fixed = TRUE)[[1L]]
  }
  plugins <- plugins[grepl("^RcmdrShinyPlugin\\.", plugins)]
}

for (plugin in plugins) {
  try(suppressWarnings(RcmdrShiny::load_plugin_package(plugin)), silent = TRUE)
}

dialogs <- RcmdrShiny:::dialog_catalog()
rows <- lapply(names(dialogs), function(id) {
  spec <- dialogs[[id]]
  topic <- RcmdrShiny::help_topic_for_dialog(spec)
  fallback <- spec$help
  status <- if (!is.null(topic)) {
    if (identical(topic$status, "draft")) "draft" else "documented"
  } else if (!is.null(fallback) && nzchar(fallback)) {
    "fallback"
  } else {
    "missing"
  }
  data.frame(
    command = id,
    dialog = id,
    topic = if (is.null(topic)) "" else topic$id,
    status = status,
    fallback = if (is.null(fallback)) "" else fallback,
    package = if (is.null(topic)) "" else (topic$package %||% "RcmdrShiny"),
    stringsAsFactors = FALSE
  )
})
table <- do.call(rbind, rows)

extra <- setdiff(names(RcmdrShiny::help_topics()), table$topic)
if (length(extra) > 0L) {
  extra_rows <- data.frame(
    command = "",
    dialog = "",
    topic = extra,
    status = "extra",
    fallback = "",
    package = vapply(extra, function(id) {
      RcmdrShiny::help_topic(id)$package %||% "RcmdrShiny"
    }, character(1)),
    stringsAsFactors = FALSE
  )
  table <- rbind(table, extra_rows)
}

table <- table[order(table$status, table$command), , drop = FALSE]
dir.create(dirname(output), recursive = TRUE, showWarnings = FALSE)
utils::write.csv(table, output, row.names = FALSE)

counts <- table(table$status)
cat("Help inventory written to", output, "\n")
for (status in names(counts)) {
  cat(sprintf("  %-12s %d\n", status, counts[[status]]))
}

missing <- table$command[table$status == "missing"]
if (length(missing) > 0L) {
  cat("\nDialogs without a topic or Rd fallback:\n")
  cat(paste0("  - ", missing, collapse = "\n"), "\n")
}

if (isTRUE(strict) && length(missing) > 0L) {
  quit(status = 1L)
}
