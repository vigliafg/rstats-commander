# Plugin registration -------------------------------------------------------

#' Register the TeachingDemos plugin with RcmdrShiny
#'
#' @return The plugin object, invisibly.
#' @export
rcmdrshiny_plugin <- function() {
  RcmdrShiny::RcmdrShiny.plugin(
    name = "RcmdrShinyPlugin.TeachingDemos",
    menus = system.file("etc", "rcmdrshiny-menus.txt",
                        package = "RcmdrShinyPlugin.TeachingDemos"),
    dialogs = teaching_dialogs(),
    version = "0.1.0",
    description = "Teaching demonstrations and distribution visualization."
  )
}
