# Plugin registration -------------------------------------------------------

#' Register the sos plugin with RcmdrShiny
#'
#' @return The plugin object, invisibly.
#' @export
rcmdrshiny_plugin <- function() {
  RcmdrShiny::RcmdrShiny.plugin(
    name = "RcmdrShinyPlugin.sos",
    menus = system.file("etc", "rcmdrshiny-menus.txt",
                        package = "RcmdrShinyPlugin.sos"),
    dialogs = sos_dialogs(),
    version = "0.1.0",
    description = "Search R help pages with the sos package."
  )
}
