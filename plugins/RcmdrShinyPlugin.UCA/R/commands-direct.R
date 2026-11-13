# Direct commands -----------------------------------------------------------

uca_commands <- function() {
  list(
    browseRUCAWebsite = function(state) {
      utils::browseURL("https://knuth.uca.es/R/doku.php?id=inicio")
    },
    browseRcmdrPluginUCA = function(state) {
      utils::browseURL("https://knuth.uca.es/R/doku.php?id=rcmdrplugin.uca")
    },
    checkRUCAversion = function(state) {
      utils::browseURL(paste0(
        "https://knuth.uca.es/version_R-UCA.php?lang=en&version=",
        getRversion()
      ))
    }
  )
}
