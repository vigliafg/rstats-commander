# Plugin registration -------------------------------------------------------

#' Register the HH plugin with RcmdrShiny
#'
#' @return The plugin object, invisibly.
#' @export
rcmdrshiny_plugin <- function() {
  RcmdrShiny::RcmdrShiny.plugin(
    name = "RcmdrShinyPlugin.HH",
    menus = system.file("etc", "rcmdrshiny-menus.txt",
                        package = "RcmdrShinyPlugin.HH"),
    dialogs = hh_dialogs(),
    commands = hh_commands(),
    version = "0.1.0",
    description = "HH graphics and tests for RcmdrShiny."
  )
}

hh_commands <- function() {
  list(
    Projector = function(state) {
      for (code in hh_projector()) RcmdrShiny::run_command(state, code)
    },
    H600 = function(state) {
      for (code in hh_h600()) RcmdrShiny::run_command(state, code)
    },
    CloseCommanderRestart = function(state) {
      if (!is.null(state$session)) {
        shiny::showNotification(
          "Restart RcmdrShiny from your R session to apply the restart.",
          type = "message", duration = 8
        )
      } else {
        message("Restart RcmdrShiny from your R session.")
      }
    },
    CloseCommanderNoQuestionRestart = function(state) {
      if (!is.null(state$session)) {
        shiny::showNotification(
          "Restart RcmdrShiny from your R session to apply the restart.",
          type = "message", duration = 8
        )
      } else {
        message("Restart RcmdrShiny from your R session.")
      }
    }
  )
}
