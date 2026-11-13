# Plugin registration -------------------------------------------------------

#' Register the TeachStat plugin with RcmdrShiny
#'
#' @return The plugin object, invisibly.
#' @export
rcmdrshiny_plugin <- function() {
  RcmdrShiny::RcmdrShiny.plugin(
    name = "RcmdrShinyPlugin.TeachStat",
    menus = system.file("etc", "rcmdrshiny-menus.txt",
                        package = "RcmdrShinyPlugin.TeachStat"),
    dialogs = ts_dialogs(),
    commands = ts_commands(),
    version = "0.1.0",
    description = "Basic statistics teaching toolkit."
  )
}

ts_dataset <- function(state) RcmdrShiny::active_dataset(state)

ts_commands <- function() {
  list(
    variablesandtypesDataSet = function(state) {
      dataset <- RcmdrShiny::active_dataset(state)
      if (!is.null(dataset)) RcmdrShiny::run_command(state, paste0("str(", dataset, ")"))
    }
  )
}
