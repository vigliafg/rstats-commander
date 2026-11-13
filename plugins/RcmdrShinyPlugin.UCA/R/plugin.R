# Plugin registration -------------------------------------------------------

#' Register the UCA plugin with RcmdrShiny
#'
#' @return The plugin object, invisibly.
#' @export
rcmdrshiny_plugin <- function() {
  RcmdrShiny::RcmdrShiny.plugin(
    name = "RcmdrShinyPlugin.UCA",
    menus = system.file("etc", "rcmdrshiny-menus.txt",
                        package = "RcmdrShinyPlugin.UCA"),
    dialogs = uca_dialogs(),
    commands = uca_commands(),
    version = "0.1.0",
    description = "Teaching statistics extensions from the University of Cadiz."
  )
}
