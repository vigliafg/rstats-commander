# Plugin registration -------------------------------------------------------

#' Register the EZR plugin with RcmdrShiny
#'
#' @return The plugin object, invisibly.
#' @export
rcmdrshiny_plugin <- function() {
  RcmdrShiny::RcmdrShiny.plugin(
    name = "RcmdrShinyPlugin.EZR",
    menus = system.file("etc", "rcmdrshiny-menus.txt",
                        package = "RcmdrShinyPlugin.EZR"),
    dialogs = ezr_dialogs(),
    commands = list(
      EZRhelp = function(state) {
        if (!is.null(state$session)) {
          shiny::showNotification("EZR help is available from the project website.",
                                  type = "message", duration = 8)
        }
      },
      EZRVersion = function(state) {
        if (!is.null(state$session)) {
          shiny::showNotification("RcmdrShinyPlugin.EZR 0.1.0",
                                  type = "message", duration = 8)
        }
      }
    ),
    aliases = c(
      StatMedLoadDataSet = "loadDataSet",
      StatMedSaveDataSet = "saveDataSet",
      StatMedLoadLogCP932 = "loadLog",
      StatMedImportSPSS = "importSPSS",
      StatMedImportMinitab = "importMinitab",
      StatMedImportSTATA = "importSTATA",
      StatMedBinVariable = "binVariable",
      StatMedChrToFactor = "characterToFactor",
      StatMedDropUnusedFactorLevels = "dropUnusedFactorLevels",
      StatMedSetContrasts = "setContrasts",
      StatMedRenameVariables = "renameVariables",
      StatMedStack = "Stack",
      StatMedCountMissing = "countMissing",
      StatMedFilterNA = "filterNA",
      StatMedExportDataSet = "exportDataSet",
      StatMedEnterTable = "enterTable",
      StatMedRepANOVA = "oneWayRepeatedMeasures",
      StatMedPieChart = "pieChart",
      StatMedStemAndLeaf = "stemAndLeaf",
      StatMedQQPlot = "QQPlot",
      StatMedPlotMeans = "PlotMeans",
      StatMedLinePlot = "linePlot",
      StatMedStripChart = "stripChart",
      StatMedScatterPlotMatrix = "scatterPlotMatrix",
      StatMedChangePalette = "setPalette",
      StatMedSetPalette = "setPalette",
      StatMedScatterPlotMatrix = "scatterPlotMatrix",
      StatMedQQPlot = "QQPlot",
      StatMedBarMeans = "PlotMeans",
      StatMedPlotMeans = "PlotMeans"
    ),
    version = "0.1.0",
    description = "Core EZR statistical workflow."
  )
}
