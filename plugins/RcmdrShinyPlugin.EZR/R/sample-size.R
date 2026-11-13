# Sample size and power dialogs for EZR ------------------------------------
#
# EZR exposes seventeen menu entries under "Calculate sample size".  They fall
# into a handful of statistical questions, so one dialog factory and one pure
# command builder cover all of them.  Commands call pwr or clinfun through
# their namespace, so neither package needs to be attached.

ezr_ss_num <- function(values, name, default) {
  value <- suppressWarnings(as.numeric(values[[name]]))
  if (length(value) == 0L || is.na(value)) default else value
}

ezr_ss_txt <- function(values, name, default) {
  value <- values[[name]]
  if (is.null(value) || !nzchar(value)) default else value
}

ezr_alt_code <- function(alternative) {
  switch(alternative,
         "two.sided" = '"two.sided"',
         "greater" = '"greater"',
         "less" = '"less"',
         '"two.sided"')
}

#' Build a sample size or power command
#'
#' Pure function used by the EZR sample-size dialogs and by the unit tests.
#'
#' @param kind One of `proportion_ci`, `proportion_one`, `proportion_two`,
#'   `mean_ci`, `mean_one`, `paired_mean`, `hazard`, `phase2`, `selection`.
#' @param mode `"size"` or `"power"`.
#' @param noninf Non-inferiority variant.
#' @param values Named list of dialog values.
#' @return A character vector of R commands.
#' @keywords internal
ezr_sample_size_command <- function(kind, mode = "size", noninf = FALSE,
                                    values = list()) {
  alpha <- ezr_ss_num(values, "alpha", 0.05)
  power <- ezr_ss_num(values, "power", 0.8)
  alternative <- ezr_alt_code(ezr_ss_txt(values, "alternative", "two.sided"))

  if (identical(kind, "proportion_ci")) {
    p <- ezr_ss_num(values, "p", 0.5)
    margin <- ezr_ss_num(values, "margin", 0.1)
    if (p <= 0 || p >= 1) stop("The proportion must be between 0 and 1.")
    if (margin <= 0) stop("The margin must be positive.")
    return(sprintf(
      "ceiling(%.6g * (1 - %.6g) * (qnorm(1 - %.6g/2) / %.6g)^2)",
      p, p, alpha, margin
    ))
  }

  if (identical(kind, "mean_ci")) {
    sd <- ezr_ss_num(values, "sd", 1)
    margin <- ezr_ss_num(values, "margin", 1)
    if (sd <= 0 || margin <= 0) stop("The standard deviation and margin must be positive.")
    return(sprintf(
      "ceiling((qnorm(1 - %.6g/2) * %.6g / %.6g)^2)", alpha, sd, margin
    ))
  }

  if (identical(kind, "proportion_one")) {
    p0 <- ezr_ss_num(values, "p0", 0.5)
    p1 <- ezr_ss_num(values, "p1", 0.6)
    effect <- if (noninf) {
      sprintf("pwr::ES.h(%.6g, %.6g)", p1, p0 + ezr_ss_num(values, "margin", 0.1))
    } else {
      sprintf("pwr::ES.h(%.6g, %.6g)", p1, p0)
    }
    if (identical(mode, "power")) {
      n <- ezr_ss_num(values, "n", 100)
      return(sprintf(
        "pwr::pwr.p.test(h = %s, n = %d, sig.level = %.6g, alternative = %s)",
        effect, as.integer(n), alpha, alternative
      ))
    }
    return(sprintf(
      "pwr::pwr.p.test(h = %s, sig.level = %.6g, power = %.6g, alternative = %s)",
      effect, alpha, power, alternative
    ))
  }

  if (identical(kind, "proportion_two")) {
    p1 <- ezr_ss_num(values, "p1", 0.4)
    p2 <- ezr_ss_num(values, "p2", 0.6)
    effect <- if (noninf) {
      sprintf("pwr::ES.h(%.6g, %.6g)", p1, p2 - ezr_ss_num(values, "margin", 0.1))
    } else {
      sprintf("pwr::ES.h(%.6g, %.6g)", p1, p2)
    }
    if (identical(mode, "power")) {
      n <- ezr_ss_num(values, "n", 100)
      return(sprintf(
        "pwr::pwr.2p.test(h = %s, n = %d, sig.level = %.6g, alternative = %s)",
        effect, as.integer(n), alpha, alternative
      ))
    }
    return(sprintf(
      "pwr::pwr.2p.test(h = %s, sig.level = %.6g, power = %.6g, alternative = %s)",
      effect, alpha, power, alternative
    ))
  }

  if (identical(kind, "mean_one")) {
    mean0 <- ezr_ss_num(values, "mean0", 0)
    mean1 <- ezr_ss_num(values, "mean1", 1)
    sd <- ezr_ss_num(values, "sd", 1)
    if (sd <= 0) stop("The standard deviation must be positive.")
    delta <- if (noninf) {
      mean1 - mean0 - ezr_ss_num(values, "margin", 0)
    } else {
      mean1 - mean0
    }
    effect <- sprintf("(%.6g - %.6g) / %.6g", mean0 + delta, mean0, sd)
    if (identical(mode, "power")) {
      n <- ezr_ss_num(values, "n", 100)
      return(sprintf(
        "pwr::pwr.t.test(d = %s, n = %d, sig.level = %.6g, alternative = %s)",
        effect, as.integer(n), alpha, alternative
      ))
    }
    return(sprintf(
      "pwr::pwr.t.test(d = %s, sig.level = %.6g, power = %.6g, alternative = %s)",
      effect, alpha, power, alternative
    ))
  }

  if (identical(kind, "paired_mean")) {
    mean1 <- ezr_ss_num(values, "mean1", 0)
    mean2 <- ezr_ss_num(values, "mean2", 1)
    sd <- ezr_ss_num(values, "sd", 1)
    if (sd <= 0) stop("The standard deviation must be positive.")
    effect <- sprintf("(%.6g - %.6g) / %.6g", mean1, mean2, sd)
    if (identical(mode, "power")) {
      n <- ezr_ss_num(values, "n", 100)
      return(sprintf(
        paste0("pwr::pwr.t.test(d = %s, n = %d, sig.level = %.6g, ",
               "alternative = %s, type = \"paired\")"),
        effect, as.integer(n), alpha, alternative
      ))
    }
    return(sprintf(
      paste0("pwr::pwr.t.test(d = %s, sig.level = %.6g, power = %.6g, ",
             "alternative = %s, type = \"paired\")"),
      effect, alpha, power, alternative
    ))
  }

  if (identical(kind, "hazard")) {
    hr <- ezr_ss_num(values, "hr", 0.7)
    event_rate <- ezr_ss_num(values, "event_rate", 0.6)
    if (hr <= 0 || hr == 1) stop("The hazard ratio must be positive and not 1.")
    if (event_rate <= 0 || event_rate > 1) {
      stop("The event rate must be between 0 and 1.")
    }
    if (noninf) {
      hr <- hr + ezr_ss_num(values, "margin", 0.1)
    }
    events <- sprintf(
      "(qnorm(1 - %.6g/2) + qnorm(%.6g))^2 / (log(%.6g)^2 * 0.25)",
      alpha, power, hr
    )
    if (identical(mode, "power")) {
      n <- ezr_ss_num(values, "n", 100)
      return(sprintf(
        paste0("pnorm(sqrt(%.6g * %.6g * 0.25) * abs(log(%.6g)) - ",
               "qnorm(1 - %.6g/2))"),
        as.integer(n), event_rate, hr, alpha
      ))
    }
    return(sprintf("ceiling(%s / %.6g)", events, event_rate))
  }

  if (identical(kind, "phase2")) {
    pu <- ezr_ss_num(values, "pu", 0.4)
    pa <- ezr_ss_num(values, "pa", 0.2)
    ep1 <- ezr_ss_num(values, "ep1", 0.05)
    ep2 <- ezr_ss_num(values, "ep2", 0.1)
    return(sprintf(
      "clinfun::ph2simon(pu = %.6g, pa = %.6g, ep1 = %.6g, ep2 = %.6g)",
      pu, pa, ep1, ep2
    ))
  }

  if (identical(kind, "selection")) {
    pu <- ezr_ss_num(values, "pu", 0.4)
    pa <- ezr_ss_num(values, "pa", 0.2)
    ep1 <- ezr_ss_num(values, "ep1", 0.05)
    ep2 <- ezr_ss_num(values, "ep2", 0.1)
    nmin <- as.integer(ezr_ss_num(values, "nmin", 10))
    nmax <- as.integer(ezr_ss_num(values, "nmax", 50))
    return(sprintf(
      paste0("clinfun::ph2single(pu = %.6g, pa = %.6g, ep1 = %.6g, ",
             "ep2 = %.6g, nmin = %d, nmax = %d)"),
      pu, pa, ep1, ep2, nmin, nmax
    ))
  }

  stop(sprintf("Unknown sample-size kind: %s", kind))
}

ezr_sample_size_fields <- function(kind, noninf = FALSE) {
  alpha <- ee("alpha", "Significance level", "0.05")

  if (identical(kind, "proportion_ci")) {
    return(list(ee("p", "Expected proportion", "0.5"),
                ee("margin", "Half-width of the confidence interval", "0.1"),
                alpha))
  }
  if (identical(kind, "mean_ci")) {
    return(list(ee("sd", "Standard deviation", "1"),
                ee("margin", "Half-width of the confidence interval", "1"),
                alpha))
  }
  if (identical(kind, "proportion_one")) {
    fields <- list(ee("p0", "Null proportion", "0.5"),
                   ee("p1", "Alternative proportion", "0.6"),
                   alpha, ee("power", "Power", "0.8"),
                   ec("alternative", "Alternative hypothesis",
                      c("two.sided", "greater", "less"), "two.sided"))
    if (noninf) fields <- append(fields, list(ee("margin", "Non-inferiority margin", "0.1")), after = 2)
    return(fields)
  }
  if (identical(kind, "proportion_two")) {
    fields <- list(ee("p1", "Proportion in group 1", "0.4"),
                   ee("p2", "Proportion in group 2", "0.6"),
                   alpha, ee("power", "Power", "0.8"),
                   ec("alternative", "Alternative hypothesis",
                      c("two.sided", "greater", "less"), "two.sided"))
    if (noninf) fields <- append(fields, list(ee("margin", "Non-inferiority margin", "0.1")), after = 2)
    return(fields)
  }
  if (identical(kind, "mean_one")) {
    fields <- list(ee("mean0", "Mean under the null hypothesis", "0"),
                   ee("mean1", "Mean under the alternative hypothesis", "1"),
                   ee("sd", "Standard deviation", "1"),
                   alpha, ee("power", "Power", "0.8"),
                   ec("alternative", "Alternative hypothesis",
                      c("two.sided", "greater", "less"), "two.sided"))
    if (noninf) fields <- append(fields, list(ee("margin", "Non-inferiority margin", "0")), after = 3)
    return(fields)
  }
  if (identical(kind, "paired_mean")) {
    return(list(ee("mean1", "Mean of the first measurement", "0"),
                ee("mean2", "Mean of the second measurement", "1"),
                ee("sd", "Standard deviation of the difference", "1"),
                alpha, ee("power", "Power", "0.8"),
                ec("alternative", "Alternative hypothesis",
                   c("two.sided", "greater", "less"), "two.sided")))
  }
  if (identical(kind, "hazard")) {
    fields <- list(ee("hr", "Hazard ratio", "0.7"),
                   ee("event_rate", "Overall probability of the event", "0.6"),
                   alpha, ee("power", "Power", "0.8"))
    if (noninf) fields <- append(fields, list(ee("margin", "Non-inferiority margin", "0.1")), after = 1)
    return(fields)
  }
  if (identical(kind, "phase2")) {
    return(list(ee("pu", "Unacceptable response rate", "0.4"),
                ee("pa", "Acceptable response rate", "0.2"),
                ee("ep1", "Type I error", "0.05"),
                ee("ep2", "Type II error", "0.1")))
  }
  if (identical(kind, "selection")) {
    return(list(ee("pu", "Unacceptable response rate", "0.4"),
                ee("pa", "Acceptable response rate", "0.2"),
                ee("ep1", "Type I error", "0.05"),
                ee("ep2", "Type II error", "0.1"),
                ei("nmin", "Minimum sample size", 10),
                ei("nmax", "Maximum sample size", 50)))
  }
  stop(sprintf("Unknown sample-size kind: %s", kind))
}

ezr_sample_size_dialog <- function(id, title, kind, mode = "size",
                                   noninf = FALSE) {
  fields <- ezr_sample_size_fields(kind, noninf = noninf)
  if (identical(mode, "power")) {
    fields <- append(fields, list(ei("n", "Sample size per group", 100)))
  }
  ezr_dialog(
    id = id, title = title, fields = fields, plot = FALSE,
    help_topic = "ezr-sample-size",
    build = function(values, state) {
      ezr_sample_size_command(kind, mode = mode, noninf = noninf, values)
    }
  )
}

ezr_sample_size_dialogs <- function() {
  list(
    StatMedSamplePhaseII = ezr_sample_size_dialog(
      "StatMedSamplePhaseII",
      "Sample size from control and desired response rates", "phase2"),
    StatMedSampleProportionsCI = ezr_sample_size_dialog(
      "StatMedSampleProportionsCI",
      "Sample size from proportion and confidence interval",
      "proportion_ci"),
    StatMedSampleProportionsSingle = ezr_sample_size_dialog(
      "StatMedSampleProportionsSingle",
      "Sample size for comparison with a specified proportion",
      "proportion_one", "size"),
    StatMedPowerProportionsSingle = ezr_sample_size_dialog(
      "StatMedPowerProportionsSingle",
      "Power for comparison with a specified proportion",
      "proportion_one", "power"),
    StatMedSampleProportions = ezr_sample_size_dialog(
      "StatMedSampleProportions",
      "Sample size for comparison between two proportions",
      "proportion_two", "size"),
    StatMedPowerProportions = ezr_sample_size_dialog(
      "StatMedPowerProportions",
      "Power for comparison between two proportions",
      "proportion_two", "power"),
    StatMedSampleProportionsNonInf = ezr_sample_size_dialog(
      "StatMedSampleProportionsNonInf",
      "Sample size for a non-inferiority trial of two proportions",
      "proportion_two", "size", noninf = TRUE),
    StatMedSampleSelectionDesign = ezr_sample_size_dialog(
      "StatMedSampleSelectionDesign",
      "Sample size for a selection design in phase II trials",
      "selection"),
    StatMedSampleMeansCI = ezr_sample_size_dialog(
      "StatMedSampleMeansCI",
      "Sample size from standard deviation and confidence interval",
      "mean_ci"),
    StatMedSampleMeans = ezr_sample_size_dialog(
      "StatMedSampleMeans",
      "Sample size for comparison between two means", "mean_one", "size"),
    StatMedPowerMeans = ezr_sample_size_dialog(
      "StatMedPowerMeans",
      "Power for comparison between two means", "mean_one", "power"),
    StatMedSampleMeansNonInf = ezr_sample_size_dialog(
      "StatMedSampleMeansNonInf",
      "Sample size for a non-inferiority trial of two means",
      "mean_one", "size", noninf = TRUE),
    StatMedSampleMeansPaired = ezr_sample_size_dialog(
      "StatMedSampleMeansPaired",
      "Sample size for comparison between two paired means",
      "paired_mean", "size"),
    StatMedPowerMeansPaired = ezr_sample_size_dialog(
      "StatMedPowerMeansPaired",
      "Power for comparison between two paired means",
      "paired_mean", "power"),
    StatMedSampleHazard = ezr_sample_size_dialog(
      "StatMedSampleHazard",
      "Sample size for comparison between two survival curves",
      "hazard", "size"),
    StatMedPowerHazard = ezr_sample_size_dialog(
      "StatMedPowerHazard",
      "Power for comparison between two survival curves",
      "hazard", "power"),
    StatMedSampleHazardNonInf = ezr_sample_size_dialog(
      "StatMedSampleHazardNonInf",
      "Sample size for a non-inferiority trial of two survival curves",
      "hazard", "size", noninf = TRUE)
  )
}
