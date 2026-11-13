# Plugin registration -------------------------------------------------------

#' Register the ROC plugin with RcmdrShiny
#'
#' @return The plugin object, invisibly.
#' @export
rcmdrshiny_plugin <- function() {
  RcmdrShiny::RcmdrShiny.plugin(
    name = "RcmdrShinyPlugin.ROC",
    menus = system.file("etc", "rcmdrshiny-menus.txt",
                        package = "RcmdrShinyPlugin.ROC"),
    dialogs = roc_dialogs(),
    version = "0.1.0",
    description = "ROC curves and Hosmer-Lemeshow goodness-of-fit tests."
  )
}
