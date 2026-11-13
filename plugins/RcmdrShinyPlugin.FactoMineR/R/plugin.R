# Plugin registration -------------------------------------------------------

#' Register the FactoMineR plugin with RcmdrShiny
#'
#' @return The plugin object, invisibly.
#' @export
rcmdrshiny_plugin <- function() {
  dialogs <- facto_dialogs()
  reader <- RcmdrShiny::get_dialog("readDataSet")
  if (!is.null(reader)) dialogs$readDataSetFacto <- reader
  RcmdrShiny::RcmdrShiny.plugin(
    name = "RcmdrShinyPlugin.FactoMineR",
    menus = system.file("etc", "rcmdrshiny-menus.txt",
                        package = "RcmdrShinyPlugin.FactoMineR"),
    dialogs = dialogs,
    version = "0.1.0",
    description = "FactoMineR multivariate analysis."
  )
}
