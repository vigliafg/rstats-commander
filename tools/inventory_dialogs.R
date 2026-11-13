#!/usr/bin/env Rscript
#
# Build the official dialog backlog from an Rcmdr source tree.
#
# Usage:
#   Rscript tools/inventory_dialogs.R /path/to/Rcmdr
#
# The script parses every top-level function in R/*.R, keeps the ones that call
# initializeDialog(), and maps them to their menu path using
# inst/etc/Rcmdr-menus.txt.  Output: inst/etc/dialogs-inventory.csv.

args <- commandArgs(trailingOnly = TRUE)
source_dir <- if (length(args) >= 1L) args[[1L]] else "../Rcmdr"
output <- if (length(args) >= 2L) args[[2L]] else "inst/etc/dialogs-inventory.csv"

if (!dir.exists(file.path(source_dir, "R"))) {
  stop("Rcmdr source directory not found: ", source_dir, call. = FALSE)
}

# The menu parser is shared with the package; load only that file so the tool
# also works without an installed package.
source("R/menus.R")

menus_path <- file.path(source_dir, "inst", "etc", "Rcmdr-menus.txt")
if (!file.exists(menus_path)) {
  stop("Menu file not found: ", menus_path, call. = FALSE)
}
definitions <- read_rcmdr_menus(menus_path)
leaves <- menu_leaves(menu_tree(definitions))
command_path <- stats::setNames(leaves$path, leaves$command)

files <- list.files(file.path(source_dir, "R"), pattern = "[.]R$",
                    full.names = TRUE)
files <- sort(files)

rows <- list()
for (file in files) {
  expressions <- tryCatch(parse(file), error = function(e) NULL)
  if (is.null(expressions)) next

  for (expr in expressions) {
    if (!is.call(expr) || length(expr) != 3L) next
    if (!identical(expr[[1L]], as.name("<-"))) next
    if (!is.name(expr[[2L]])) next
    if (!is.call(expr[[3L]]) ||
        !identical(expr[[3L]][[1L]], as.name("function"))) next

    fun_name <- as.character(expr[[2L]])
    body <- paste(deparse(expr[[3L]]), collapse = "\n")
    if (!grepl("initializeDialog[[:space:]]*\\(", body)) next

    rows[[length(rows) + 1L]] <- data.frame(
      function_name = fun_name,
      file = basename(file),
      menu_command = if (fun_name %in% names(command_path)) fun_name else "",
      menu = if (fun_name %in% names(command_path)) {
        command_path[[fun_name]]
      } else {
        ""
      },
      stringsAsFactors = FALSE
    )
  }
}

inventory <- do.call(rbind, rows)
ported <- c("readDataSet", "numericalSummaries", "linearModel")
inventory$status <- ifelse(
  inventory$function_name %in% ported, "ported", "todo"
)
inventory <- inventory[order(inventory$file, inventory$function_name),
                       c("function_name", "file", "menu_command", "menu",
                         "status")]
names(inventory) <- c("dialog_id", "file", "command", "menu", "status")

dir.create(dirname(output), recursive = TRUE, showWarnings = FALSE)
utils::write.csv(inventory, output, row.names = FALSE, fileEncoding = "UTF-8")

message(sprintf(
  "Wrote %d dialogs (%d ported, %d todo) to %s",
  nrow(inventory), sum(inventory$status == "ported"),
  sum(inventory$status == "todo"), output
))
