# Plugin registration -------------------------------------------------------

#' Register the aRnova plugin with RcmdrShiny
#'
#' @return The plugin object, invisibly.
#' @export
rcmdrshiny_plugin <- function() {
  RcmdrShiny::RcmdrShiny.plugin(
    name = "RcmdrShinyPlugin.aRnova",
    menus = system.file("etc", "rcmdrshiny-menus.txt",
                        package = "RcmdrShinyPlugin.aRnova"),
    dialogs = arnova_dialogs(),
    version = "0.1.0",
    description = "ANOVA extensions for RcmdrShiny."
  )
}
