# Plugin registration -------------------------------------------------------

doe_active_design_p <- function(state) {
  dataset <- RcmdrShiny::dataset(state)
  !is.null(dataset) && inherits(dataset, "design")
}

#' Register the DoE plugin with RcmdrShiny
#'
#' @return The plugin object, invisibly.
#' @export
rcmdrshiny_plugin <- function() {
  RcmdrShiny::RcmdrShiny.plugin(
    name = "RcmdrShinyPlugin.DoE",
    menus = system.file("etc", "rcmdrshiny-menus.txt",
                        package = "RcmdrShinyPlugin.DoE"),
    dialogs = doe_dialogs(),
    commands = local({
      info <- function(topic) function(state) {
        RcmdrShiny::open_help_topic(state, topic)
      }
      list(
        dc = function(state) invisible(NULL),
        helpImport = info("doe-import-export"),
        helpExport = info("doe-import-export"),
        helpExpImp = info("doe-import-export"),
        help2level = info("doe-designs"),
        helpgeneral = info("doe-designs"),
        helpquant = info("doe-designs"),
        helpDopt = info("doe-designs"),
        displayGlossary = info("doe-designs"),
        displayblock = info("doe-designs"),
        displaysplitplot = info("doe-designs"),
        displayCentralCompositeDesigns = info("doe-designs"),
        helpInspect = info("doe-analyse"),
        helpModify = info("doe-analyse"),
        helpAnalyze = info("doe-analyse"),
        helpMenus = info("doe-analyse"),
        helpabout = info("doe-about")
      )
    }),
    predicates = list(
      existDesigns = function(state) {
        objects <- ls(envir = state$env)
        any(vapply(objects, function(name) {
          inherits(get(name, envir = state$env), "design")
        }, logical(1)))
      },
      exist2Designs = function(state) {
        objects <- ls(envir = state$env)
        sum(vapply(objects, function(name) {
          inherits(get(name, envir = state$env), "design")
        }, logical(1))) >= 2
      },
      activeDataSetDesignP = doe_active_design_p,
      activeDataSetDesignRemovableP = doe_active_design_p,
      activeDataSetDesignQualP = doe_active_design_p,
      activeDataSetDesignLongToWide = doe_active_design_p,
      activeDataSetDesignWide = doe_active_design_p,
      activeDataSetDesign2Pwoc = doe_active_design_p,
      activeDataSetDesign2Pnoccd = doe_active_design_p,
      activeDataSetDesignccd = doe_active_design_p,
      activeDataSetDesignlhs = doe_active_design_p,
      activeDataSetDesignPResp = doe_active_design_p,
      activeDataSetDesign2PResp = doe_active_design_p,
      activeDataSetDesignparamlong = function(state) FALSE,
      activeModelRSM = function(state) !is.null(RcmdrShiny::active_model(state)),
      activeModelLM = function(state) !is.null(RcmdrShiny::active_model(state))
    ),
    version = "0.1.0",
    description = "Design of experiments with DoE.base, FrF2 and rsm."
  )
}
