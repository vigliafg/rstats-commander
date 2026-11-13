#!/usr/bin/env Rscript
#
# Inventory the menus and dialogs of an Rcmdr plugin source tree.
#
# Usage:
#   Rscript tools/inventory_plugin.R <plugin-source> [output.csv]
#
# The script accepts both legacy RcmdrPlugin.* layouts (inst/etc/menus.txt) and
# RcmdrShiny plugin layouts (inst/etc/rcmdrshiny-menus.txt).  It reports every
# menu entry, the R function behind it, whether that function uses Tk, and
# whether it generates commands with doItAndPrint()/justDoIt().

args <- commandArgs(trailingOnly = TRUE)
if (length(args) == 0L) {
  stop("Usage: Rscript tools/inventory_plugin.R <plugin-source> [output.csv]",
       call. = FALSE)
}

source_dir <- args[[1L]]
output <- if (length(args) >= 2L) args[[2L]] else {
  file.path(source_dir, "plugin-inventory.csv")
}

if (!dir.exists(source_dir)) {
  stop("Plugin source directory not found: ", source_dir, call. = FALSE)
}

# Reuse the menu parser without loading the installed package.
menu_parser <- file.path("R", "menus.R")
if (file.exists(menu_parser)) {
  source(menu_parser)
} else {
  stop("Run this script from the RcmdrShiny repository root.", call. = FALSE)
}

candidates <- c(
  file.path(source_dir, "inst", "etc", "rcmdrshiny-menus.txt"),
  file.path(source_dir, "inst", "etc", "menus.txt")
)
menus_path <- candidates[file.exists(candidates)][1L]
if (is.na(menus_path)) {
  stop("No menu file found in inst/etc/.", call. = FALSE)
}

definitions <- read_rcmdr_menus(menus_path)

# Collect top-level function definitions from R/*.R.
files <- list.files(file.path(source_dir, "R"), pattern = "[.]R$",
                    full.names = TRUE)
files <- sort(files)
functions <- list()

for (file in files) {
  expressions <- tryCatch(parse(file), error = function(e) NULL)
  if (is.null(expressions)) next

  for (expr in expressions) {
    if (!is.call(expr) || length(expr) != 3L) next
    if (!identical(expr[[1L]], as.name("<-"))) next
    if (!is.name(expr[[2L]])) next
    if (!is.call(expr[[3L]]) ||
        !identical(expr[[3L]][[1L]], as.name("function"))) next

    functions[[as.character(expr[[2L]])]] <- list(
      file = basename(file),
      body = paste(deparse(expr[[3L]]), collapse = "\n")
    )
  }
}

tk_pattern <- paste(
  "initializeDialog", "tk[A-Za-z.]", "tcl[A-Za-z.]", "tkrplot",
  "tkmessageBox", "tkgetOpenFile", "tkgetSaveFile", "tkselectFile",
  "tkentry", "tkbutton", "tkframe", "tklabel", "tkpack", "tkgrid",
  "tkconfigure", "tkdestroy", "tkfocus", "tkinsert", "tkdelete",
  "tklistbox", "tkradiobutton", "tkcheckbutton", "tktext", "tkscrollbar",
  sep = "|"
)

classify <- function(kind, command) {
  if (identical(kind, "separator")) {
    return(list(source_function = "", file = "", tk_dialog = FALSE,
                generates_command = FALSE, status = "separator"))
  }
  if (identical(kind, "cascade")) {
    return(list(source_function = "", file = "", tk_dialog = FALSE,
                generates_command = FALSE, status = "menu"))
  }
  if (!nzchar(command)) {
    return(list(source_function = "", file = "", tk_dialog = FALSE,
                generates_command = FALSE, status = "separator"))
  }
  info <- functions[[command]]
  if (is.null(info)) {
    return(list(source_function = "", file = "", tk_dialog = FALSE,
                generates_command = FALSE, status = "missing"))
  }
  tk <- grepl(tk_pattern, info$body)
  generates <- grepl("doItAndPrint|justDoIt|putRcmdr|runCommand|eval\\(",
                     info$body)
  status <- if (tk) "port: dialog" else if (generates) "port: command" else {
    "port: utility"
  }
  list(source_function = command, file = info$file, tk_dialog = tk,
       generates_command = generates, status = status)
}

rows <- lapply(seq_len(nrow(definitions)), function(i) {
  row <- definitions[i, , drop = FALSE]
  info <- classify(row$kind, row$command)
  data.frame(
    type = row$type,
    menu = row$menu,
    kind = row$kind,
    label = row$label,
    command = row$command,
    activation = row$activation,
    install = row$install,
    source_function = info$source_function,
    file = info$file,
    tk_dialog = info$tk_dialog,
    generates_command = info$generates_command,
    status = info$status,
    stringsAsFactors = FALSE
  )
})

inventory <- if (length(rows) > 0L) do.call(rbind, rows) else {
  data.frame(
    type = character(), menu = character(), kind = character(),
    label = character(), command = character(), activation = character(),
    install = character(), source_function = character(), file = character(),
    tk_dialog = logical(), generates_command = logical(),
    status = character(), stringsAsFactors = FALSE
  )
}

utils::write.csv(inventory, output, row.names = FALSE)

items <- inventory[inventory$type == "item" & nzchar(inventory$command), ]
summary <- table(items$status)
cat(sprintf("Plugin: %s\n", basename(source_dir)))
cat(sprintf("Menu file: %s\n", menus_path))
cat(sprintf("Menu entries: %d\n", nrow(items)))
for (status in names(summary)) {
  cat(sprintf("  %-16s %d\n", status, summary[[status]]))
}
cat(sprintf("Inventory written to %s\n", output))
