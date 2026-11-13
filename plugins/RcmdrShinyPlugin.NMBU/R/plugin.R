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
