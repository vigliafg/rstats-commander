# DoE command builders --------------------------------------------------

doe_assign <- function(name, code) {
  if (!nzchar(name)) stop("Enter a design name.")
  sprintf("%s <- %s", name, code)
}

build_screening <- function(name, factors, runs) {
  doe_assign(name, sprintf("FrF2::pb(nruns = %d, nfactors = %d, randomize = TRUE)",
                            as.integer(runs), as.integer(factors)))
}

build_fractional <- function(name, factors, runs, resolution = 3) {
  doe_assign(name, sprintf("FrF2::FrF2(nruns = %d, nfactors = %d, resolution = %d)",
                            as.integer(runs), as.integer(factors),
                            as.integer(resolution)))
}

build_full_factorial <- function(name, factors, levels, replications = 1) {
  doe_assign(name, sprintf("DoE.base::fac.design(nfactors = %d, nlevels = %d, replications = %d)",
                            as.integer(factors), as.integer(levels),
                            as.integer(replications)))
}

build_orthogonal_array <- function(name, factors, levels, runs) {
  doe_assign(name, sprintf("DoE.base::oa.design(nfactors = %d, nlevels = %d, nruns = %d)",
                            as.integer(factors), as.integer(levels),
                            as.integer(runs)))
}

build_ccd <- function(name, factors, ncenter = 4, alpha = "rotatable") {
  doe_assign(name, sprintf("rsm::ccd(basis = %d, n0 = %d, alpha = '%s')",
                            as.integer(factors), as.integer(ncenter), alpha))
}

build_bbd <- function(name, factors, ncenter = 4) {
  doe_assign(name, sprintf("rsm::bbd(k = %d, n0 = %d)",
                            as.integer(factors), as.integer(ncenter)))
}

build_lhs <- function(name, factors, n) {
  doe_assign(name, sprintf(
    "as.data.frame(lhs::randomLHS(%d, %d), col.names = paste0('x', 1:%d))",
    as.integer(n), as.integer(factors), as.integer(factors)
  ))
}

build_doptimal <- function(name, candidates, terms, n) {
  doe_assign(name, sprintf(
    "AlgDesign::optFederov(%s, data = %s, nTrials = %d)",
    terms, candidates, as.integer(n)
  ))
}

build_design_model <- function(design, response) {
  sprintf(".model <- lm(%s ~ ., data = %s)", response, design)
}

build_design_rsm <- function(design, response, factors) {
  sprintf(".model <- lm(%s ~ polym(%s, degree = 2), data = %s)",
          response, paste(factors, collapse = ", "), design)
}

build_effects_plot <- function(model) {
  sprintf("FrF2::DanielPlot(%s)", model)
}

build_main_effects <- function(design) {
  sprintf("DoE.base::MEPlot(%s)", design)
}

build_interaction_plot <- function(design) {
  sprintf("DoE.base::IAPlot(%s)", design)
}

build_design_summary <- function(design) {
  c(sprintf("summary(%s)", design), sprintf("DoE.base::design.info(%s)", design))
}

build_design_plot <- function(design) {
  sprintf("plot(%s)", design)
}

build_add_response <- function(design, name, values = NULL) {
  if (is.null(values)) {
    sprintf("%s$%s <- NA", design, name)
  } else {
    sprintf("%s$%s <- c(%s)", design, name, paste(values, collapse = ", "))
  }
}

build_remove_column <- function(design, column) {
  sprintf("%s$%s <- NULL", design, column)
}
