# Diagnostic report ----------------------------------------------------------
#
# A small, pasteable report attached to bug reports.  It contains versions and
# configuration only: no data, no script and no environment contents.

#' Build a diagnostic report
#'
#' Collects the R and RcmdrShiny versions, the loaded plugins, the core package
#' versions that matter for graphics and modelling, and the session options that
#' change generated commands.
#'
#' @return A named list.
#' @export
diagnostics_report <- function() {
  package_version <- function(package) {
    tryCatch(as.character(utils::packageVersion(package)),
             error = function(e) NA_character_)
  }

  packages <- c("RcmdrShiny", "RcmdrMisc", "car", "effects", "lattice",
                "ggplot2", "rgl", "survival", "FactoMineR", "commonmark",
                "yaml")
  versions <- vapply(packages, package_version, character(1))

  list(
    r_version = R.version.string,
    platform = R.version$platform,
    rcmdrshiny = package_version("RcmdrShiny"),
    language = tryCatch(current_language(), error = function(e) "en"),
    plugins = tryCatch(as.character(list_plugins()), error = function(e) character()),
    packages = versions,
    help_topics = tryCatch(length(help_topics()), error = function(e) 0L),
    options = list(
      digits = getOption("digits"),
      stringsAsFactors = getOption("stringsAsFactors"),
      help_markdown = getOption("RcmdrShiny.help.markdown", "auto"),
      help_yaml = getOption("RcmdrShiny.help.yaml", "auto")
    )
  )
}

#' Format a diagnostic report as text
#'
#' @param report Report returned by [diagnostics_report()].
#' @return A character vector, one line per item.
#' @export
format_diagnostics <- function(report = diagnostics_report()) {
  lines <- c(
    "RcmdrShiny diagnostic report",
    "----------------------------",
    sprintf("R: %s", report$r_version),
    sprintf("Platform: %s", report$platform),
    sprintf("RcmdrShiny: %s", report$rcmdrshiny),
    sprintf("Language: %s", report$language),
    sprintf("Help topics: %d", report$help_topics),
    sprintf("Plugins: %s",
            if (length(report$plugins) == 0L) {
              "(none)"
            } else {
              paste(report$plugins, collapse = ", ")
            }),
    "",
    "Package versions:",
    sprintf("  %s: %s", names(report$packages),
            ifelse(is.na(report$packages), "(not installed)", report$packages)),
    "",
    "Options:",
    sprintf("  %s: %s", names(report$options),
            vapply(report$options, function(value) {
              paste(format(value), collapse = ", ")
            }, character(1)))
  )
  lines
}
