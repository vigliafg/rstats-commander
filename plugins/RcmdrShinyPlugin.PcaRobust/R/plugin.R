# Plugin registration -------------------------------------------------------

#' Register the PcaRobust plugin with RcmdrShiny
#'
#' @return The plugin object, invisibly.
#' @export
rcmdrshiny_plugin <- function() {
  RcmdrShiny::RcmdrShiny.plugin(
    name = "RcmdrShinyPlugin.PcaRobust",
    menus = system.file("etc", "rcmdrshiny-menus.txt",
                        package = "RcmdrShinyPlugin.PcaRobust"),
    dialogs = pca_robust_dialogs(),
    version = "0.1.0",
    description = "Robust principal component analysis with ROBPCA."
  )
}
