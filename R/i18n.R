# Internationalisation ------------------------------------------------------
#
# Rcmdr's translation catalogues are reused as-is.  The gettext domain is
# derived from the package name, so the files installed in po/ are picked up by
# the standard R translation machinery.  As in Rcmdr, the language is chosen
# when the R process starts; switching language at run time requires a restart.

#' Translate a message
#'
#' Thin wrapper around [gettext()] using the package translation domain.
#' @param ... Pieces of the message, pasted together.
#' @export
tr <- function(...) {
  gettext(paste0(...), domain = "R-RcmdrShiny")
}

#' @keywords internal
trn <- function(n, msg1, msg2) {
  ngettext(n, msg1, msg2, domain = "R-RcmdrShiny")
}

#' Languages shipped with the package
#'
#' @return A character vector of language codes, with `"en"` first.
#' @export
available_languages <- function() {
  po_dir <- system.file("po", package = "RcmdrShiny")
  if (!nzchar(po_dir) || !dir.exists(po_dir)) return("en")
  files <- list.files(po_dir, pattern = "^R-[a-zA-Z_]+\\.po$")
  langs <- sub("^R-", "", sub("\\.po$", "", files))
  c("en", sort(unique(langs)))
}

#' Language used for the current session
#' @keywords internal
current_language <- function() {
  lang <- Sys.getenv("LANGUAGE", "")
  if (!nzchar(lang)) return("en")
  code <- sub("[_.].*$", "", strsplit(lang, ":")[[1L]][1L])
  if (identical(code, "C")) "en" else code
}

# Labels stored in the menus file are English msgids; translate them on the
# fly so that a translated catalogue can be plugged in without touching the
# parser.
menu_label <- function(label) {
  if (!nzchar(label)) return(label)
  tr(label)
}
