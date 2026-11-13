# Plugin registration -------------------------------------------------------

#' Register the KMggplot2 plugin with RcmdrShiny
#'
#' @return The plugin object, invisibly.
#' @export
rcmdrshiny_plugin <- function() {
  RcmdrShiny::RcmdrShiny.plugin(
    name = "RcmdrShinyPlugin.KMggplot2",
    menus = system.file("etc", "rcmdrshiny-menus.txt",
                        package = "RcmdrShinyPlugin.KMggplot2"),
    dialogs = kmg_dialogs(),
    version = "0.1.0",
    description = "ggplot2 graphics for RcmdrShiny."
  )
}
