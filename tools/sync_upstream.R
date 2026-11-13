#!/usr/bin/env Rscript
#
# Synchronise the copied Rcmdr assets and regenerate the dialog inventory.
#
# Usage:
#   Rscript tools/sync_upstream.R /path/to/Rcmdr [repo-root]
#
# The script copies inst/etc/Rcmdr-menus.txt and inst/po/*.po verbatim and
# rebuilds inst/etc/dialogs-inventory.csv.  Review the diff before committing:
# upstream changes may require updating command builders and golden tests.

args <- commandArgs(trailingOnly = TRUE)
source_dir <- if (length(args) >= 1L) args[[1L]] else "../Rcmdr"
repo <- if (length(args) >= 2L) args[[2L]] else "."

if (!dir.exists(file.path(source_dir, "R"))) {
  stop("Rcmdr source directory not found: ", source_dir, call. = FALSE)
}

menu_source <- file.path(source_dir, "inst", "etc", "Rcmdr-menus.txt")
if (!file.exists(menu_source)) {
  stop("Menu file not found: ", menu_source, call. = FALSE)
}

dir.create(file.path(repo, "inst", "etc"), recursive = TRUE)
dir.create(file.path(repo, "inst", "po"), recursive = TRUE)

file.copy(menu_source, file.path(repo, "inst", "etc", "Rcmdr-menus.txt"),
          overwrite = TRUE)

po_files <- list.files(file.path(source_dir, "po"), pattern = "[.]po$",
                       full.names = TRUE)
if (length(po_files) > 0L) {
  file.copy(po_files, file.path(repo, "inst", "po"), overwrite = TRUE)
}
message(sprintf("Copied %d translation catalogues", length(po_files)))

old_wd <- setwd(repo)
on.exit(setwd(old_wd), add = TRUE)
status <- system2(
  file.path(R.home("bin"), "Rscript"),
  c("tools/inventory_dialogs.R", shQuote(source_dir))
)
if (!identical(status, 0L)) {
  stop("Inventory generation failed", call. = FALSE)
}

message("Upstream assets synchronised. Review the diff, then run the tests.")
