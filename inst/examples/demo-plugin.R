# Example RcmdrShiny plugin.
#
# Load before starting the application:
#   RcmdrShiny::load_plugin(system.file("examples", "demo-plugin.R",
#                                       package = "RcmdrShiny"))
#   RcmdrShiny::run()
#
# Or pass it directly:
#   RcmdrShiny::run(plugins = system.file("examples", "demo-plugin.R",
#                                         package = "RcmdrShiny"))

RcmdrShiny.plugin(
  name = "RcmdrShinyDemo",
  description = "Small example plugin for RcmdrShiny",
  version = "0.1.0",
  menus = system.file("examples", "demo-menus.txt", package = "RcmdrShiny"),
  commands = list(
    demoHello = function(state) {
      run_command(state, 'cat("Hello from the demo plugin.\\n")')
    },
    demoAdd = function(state) {
      run_command(state, "1 + 1")
    }
  ),
  dialogs = list(
    demoDialog = plugin_dialog(
      id = "demoDialog",
      title = "Demo plugin dialog",
      ui = function(state, memory) {
        htmltools::tagList(
          htmltools::tags$p("This dialog is provided by the demo plugin."),
          textInput("demoDialog_text", "Text:", memory$text %||% "plugin")
        )
      },
      on_ok = function(input, state) {
        text <- input$demoDialog_text %||% "plugin"
        list(
          commands = sprintf('cat("Dialog says: %s\\n")', text),
          memory = list(text = text)
        )
      }
    )
  )
)
