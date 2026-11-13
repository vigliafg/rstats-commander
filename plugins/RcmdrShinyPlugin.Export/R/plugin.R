# Plugin registration -------------------------------------------------------

#' Register the Export plugin with RcmdrShiny
#'
#' @return The plugin object, invisibly.
#' @export
rcmdrshiny_plugin <- function() {
  RcmdrShiny::RcmdrShiny.plugin(
    name = "RcmdrShinyPlugin.Export",
    menus = system.file("etc", "rcmdrshiny-menus.txt",
                        package = "RcmdrShinyPlugin.Export"),
    dialogs = export_dialogs(),
    version = "0.1.0",
    description = "Export the last printed object to LaTeX or HTML."
  )
}
