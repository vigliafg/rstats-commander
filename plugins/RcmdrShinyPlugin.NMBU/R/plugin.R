# Plugin registration -------------------------------------------------------

#' Register the NMBU plugin with RcmdrShiny
#'
#' @return The plugin object, invisibly.
#' @export
rcmdrshiny_plugin <- function() {
  RcmdrShiny::RcmdrShiny.plugin(
    name = "RcmdrShinyPlugin.NMBU",
    menus = system.file("etc", "rcmdrshiny-menus.txt",
                        package = "RcmdrShinyPlugin.NMBU"),
    dialogs = numbu_dialogs(),
    commands = list(
      auto.import.GUI = function(state) {
        if (!is.null(state$session)) {
          shiny::showNotification(
            "Reading tab-separated data from the clipboard.",
            type = "message", duration = 4
          )
        }
        RcmdrShiny::run_command(state, paste0(
          "Dataset <- read.table(text = utils::readClipboard(), ",
          "header = TRUE, sep = \"\\t\")"
        ), plot = FALSE)
      },
      onExport = function(state) {
        value <- RcmdrShiny::popOutput(keep = TRUE)
        text <- utils::capture.output(print(value))
        utils::writeClipboard(text)
        if (!is.null(state$session)) {
          shiny::showNotification(
            "The last result was copied to the clipboard.",
            type = "message", duration = 4
          )
        }
        invisible(text)
      },
      deleteActiveDataSet = function(state) {
        name <- RcmdrShiny::active_dataset(state)
        if (is.null(name)) return(invisible(NULL))
        RcmdrShiny::run_command(state, sprintf("rm(%s)", name), plot = FALSE)
        RcmdrShiny::active_dataset(state, NULL)
        invisible(NULL)
      }
    ),
    aliases = c(
      numericalSummariesNMBU = "numericalSummaries",
      twoSamplesZTest = "independentSamplesZTestNMBU",
      tally.GUI = "frequencyDistribution",
      twoWayTableNMBU = "twoWayTableFromCounts",
      enterTableNMBU = "enterTable",
      histogram_discrete = "DiscretePlot",
      linePlotNMBU = "linePlot",
      dotplotGUI = "DotPlot",
      sortData = "sortDataSet",
      anova_reg_GUI = "anovaTable",
      bestSubsets = "subsetRegression",
      binomialDistributionPlotNMBU = "binomialDistributionPlot",
      PoissonDistributionPlotNMBU = "PoissonDistributionPlot",
      geomDistributionPlotNMBU = "geomDistributionPlot",
      hyperDistributionPlotNMBU = "hyperDistributionPlot",
      negbinomialDistributionPlotNMBU = "negbinomialDistributionPlot"
    ),
    predicates = list(
      variablesP = function(state, n = 1) length(RcmdrShiny::variables(state)) >= n,
      lmmP = function(state) {
        model <- RcmdrShiny::active_model(state)
        if (is.null(model)) return(FALSE)
        object <- get(model, envir = state$env, inherits = FALSE)
        inherits(object, c("lm", "lmerMod", "glmerMod"))
      },
      plsP = function(state) {
        model <- RcmdrShiny::active_model(state)
        !is.null(model) && inherits(get(model, envir = state$env), "mvr")
      },
      daP = function(state) {
        model <- RcmdrShiny::active_model(state)
        !is.null(model) && inherits(get(model, envir = state$env), c("lda", "qda"))
      },
      clustP = function(state) {
        objects <- ls(envir = state$env)
        any(vapply(objects, function(name) {
          inherits(get(name, envir = state$env), "hclust")
        }, logical(1)))
      },
      contP = function() TRUE,
      pcaP = function(state) {
        model <- RcmdrShiny::active_model(state)
        !is.null(model) && inherits(get(model, envir = state$env), c("prcomp", "princomp"))
      }
    ),
    version = "0.1.0",
    description = "NMBU statistics extensions."
  )
}
