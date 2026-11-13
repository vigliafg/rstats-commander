# Plugin registration -------------------------------------------------------

#' Register the survival plugin with RcmdrShiny
#'
#' @return The plugin object, invisibly.
#' @export
rcmdrshiny_plugin <- function() {
  RcmdrShiny::RcmdrShiny.plugin(
    name = "RcmdrShinyPlugin.survival",
    menus = system.file("etc", "rcmdrshiny-menus.txt",
                        package = "RcmdrShinyPlugin.survival"),
    dialogs = survival_dialogs(),
    version = "0.1.0",
    description = "Survival analysis with the survival package."
  )
}
