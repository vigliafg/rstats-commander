# FactoMineR command builders -------------------------------------------

facto_subset <- function(dataset, variables) {
  sprintf("%s[, c(%s)]", dataset,
          paste(sprintf('"%s"', variables), collapse = ", "))
}

build_facto_pca <- function(dataset, variables, quanti_sup = character(),
                            quali_sup = character()) {
  args <- ""
  if (length(quanti_sup) > 0L) {
    args <- paste0(args, sprintf(", quanti.sup = c(%s)",
                                 paste(quanti_sup, collapse = ", ")))
  }
  if (length(quali_sup) > 0L) {
    args <- paste0(args, sprintf(", quali.sup = c(%s)",
                                 paste(quali_sup, collapse = ", ")))
  }
  c(
    sprintf(".pca <- FactoMineR::PCA(%s, graph = TRUE%s)",
            facto_subset(dataset, variables), args),
    "summary(.pca)"
  )
}

build_facto_ca <- function(dataset, row, col) {
  c(
    sprintf('.ca <- FactoMineR::CA(table(%s$%s, %s$%s), graph = TRUE)',
            dataset, row, dataset, col),
    "summary(.ca)"
  )
}

build_facto_mca <- function(dataset, variables) {
  c(
    sprintf(".mca <- FactoMineR::MCA(%s, graph = TRUE)",
            facto_subset(dataset, variables)),
    "summary(.mca)"
  )
}

build_facto_mfa <- function(dataset, variables, groups, type = "MFA") {
  fun <- if (identical(type, "DMFA")) "DMFA" else "MFA"
  c(
    sprintf(".mfa <- FactoMineR::%s(%s, group = c(%s), graph = TRUE)",
            fun, facto_subset(dataset, variables),
            paste(groups, collapse = ", ")),
    "summary(.mfa)"
  )
}

build_facto_famd <- function(dataset, variables) {
  c(
    sprintf(".famd <- FactoMineR::FAMD(%s, graph = TRUE)",
            facto_subset(dataset, variables)),
    "summary(.famd)"
  )
}

build_facto_hcpc <- function(object) {
  c(sprintf(".hcpc <- FactoMineR::HCPC(%s)", object), "summary(.hcpc)")
}

build_facto_gpa <- function(dataset, variables, groups) {
  c(
    sprintf(".gpa <- FactoMineR::GPA(%s, group = c(%s))",
            facto_subset(dataset, variables), paste(groups, collapse = ", ")),
    "summary(.gpa)"
  )
}

build_facto_catdes <- function(dataset, variable) {
  sprintf("FactoMineR::catdes(%s, num.var = %s$%s)",
          dataset, dataset, variable)
}

build_facto_prefpls <- function(dataset, variables) {
  sprintf("FactoMineR::prefpls(%s)", facto_subset(dataset, variables))
}
