# Survival, matched-pair and meta-analysis tools for EZR -------------------
#
# These entries extend the survival workflow with competing risks, conditional
# models and evidence synthesis.  Optional packages are used through their
# namespace so the plugin loads without them.

ezr_split_numbers <- function(text, what) {
  values <- suppressWarnings(as.numeric(trimws(strsplit(
    as.character(text), ",", fixed = TRUE
  )[[1L]])))
  if (length(values) == 0L || anyNA(values)) {
    stop(sprintf("Enter the %s as comma-separated numbers.", what))
  }
  values
}

ezr_surv_logrank_trend <- function(dataset, time, status, group) {
  if (any(!nzchar(c(time, status, group)))) {
    stop("Choose time, status and an ordered group.")
  }
  sprintf(paste0(
    "survival::survdiff(survival::Surv(%s, %s) ~ as.numeric(%s), data = %s)"
  ), time, status, group, dataset)
}

ezr_surv_current <- function(dataset, time, status, group = "", at = 12) {
  if (any(!nzchar(c(time, status)))) stop("Choose time and status.")
  formula <- if (nzchar(group)) {
    sprintf("survival::Surv(%s, %s) ~ %s", time, status, group)
  } else {
    sprintf("survival::Surv(%s, %s) ~ 1", time, status)
  }
  paste0(
    "local({\n",
    sprintf("  .fit <- survival::survfit(%s, data = %s)\n", formula, dataset),
    sprintf("  summary(.fit, times = %s)\n", format(as.numeric(at))),
    "})"
  )
}

ezr_surv_cox_td <- function(dataset, start, stop, event, predictors) {
  if (any(!nzchar(c(start, stop, event))) || length(predictors) == 0L) {
    stop("Choose start, stop, event and at least one predictor.")
  }
  sprintf(paste0(
    "survival::coxph(survival::Surv(%s, %s, %s) ~ %s, data = %s)"
  ), start, stop, event, paste(predictors, collapse = " + "), dataset)
}

ezr_surv_cuminc <- function(dataset, time, status, group = "") {
  if (any(!nzchar(c(time, status)))) stop("Choose time and status.")
  group_code <- if (nzchar(group)) sprintf("%s$%s", dataset, group) else "1"
  paste0(
    "local({\n",
    sprintf("  .ci <- cmprsk::cuminc(%s$%s, %s$%s, %s)\n",
            dataset, time, dataset, status, group_code),
    "  print(.ci)\n",
    "  plot(.ci, lwd = 2, xlab = \"Time\", ylab = \"Cumulative incidence\")\n",
    "})"
  )
}

ezr_surv_crr <- function(dataset, time, status, predictors) {
  if (any(!nzchar(c(time, status))) || length(predictors) == 0L) {
    stop("Choose time, status and at least one predictor.")
  }
  covariates <- sprintf("model.matrix(~ %s, data = %s)[, -1, drop = FALSE]",
                        paste(predictors, collapse = " + "), dataset)
  paste0(
    "local({\n",
    sprintf("  .fit <- cmprsk::crr(%s$%s, %s$%s, %s)\n",
            dataset, time, dataset, status, covariates),
    "  summary(.fit)\n",
    "})"
  )
}

ezr_surv_crr_td <- function(dataset, time, status, predictors) {
  if (any(!nzchar(c(time, status))) || length(predictors) == 0L) {
    stop("Choose time, status and at least one predictor.")
  }
  paste0(
    "local({\n",
    sprintf("  .fg <- survival::finegray(survival::Surv(%s, %s) ~ ., data = %s)\n",
            time, status, dataset),
    sprintf("  .fit <- survival::coxph(survival::Surv(fgstart, fgstop, fgstatus) ~ %s,\n",
            paste(predictors, collapse = " + ")),
    "                            data = .fg, weights = fgwt)\n",
    "  summary(.fit)\n",
    "})"
  )
}

ezr_surv_matching <- function(dataset, treatment, covariates, ratio = 1) {
  if (!nzchar(treatment) || length(covariates) == 0L) {
    stop("Choose the treatment indicator and at least one covariate.")
  }
  formula <- sprintf("%s ~ %s", treatment, paste(covariates, collapse = " + "))
  paste0(
    "local({\n",
    sprintf("  .match <- MatchIt::matchit(%s, data = %s, method = \"nearest\",\n",
            formula, dataset),
    sprintf("                            ratio = %d, replace = FALSE)\n",
            max(1L, as.integer(ratio))),
    "  .matched <- MatchIt::match.data(.match)\n",
    "  summary(.match)\n",
    "})"
  )
}

ezr_surv_mh <- function(dataset, row, column, strata) {
  if (any(!nzchar(c(row, column, strata)))) {
    stop("Choose row, column and strata variables.")
  }
  sprintf("mantelhaen.test(xtabs(~ %s + %s + %s, data = %s))",
          row, column, strata, dataset)
}

ezr_surv_clogistic <- function(dataset, response, predictors, strata) {
  if (any(!nzchar(c(response, strata))) || length(predictors) == 0L) {
    stop("Choose response, strata and at least one predictor.")
  }
  sprintf(paste0(
    "survival::clogit(%s ~ %s + survival::strata(%s), data = %s)"
  ), response, paste(predictors, collapse = " + "), strata, dataset)
}

ezr_surv_stratified_cox <- function(dataset, time, status, predictors, strata) {
  if (any(!nzchar(c(time, status, strata))) || length(predictors) == 0L) {
    stop("Choose time, status, strata and at least one predictor.")
  }
  sprintf(paste0(
    "survival::coxph(survival::Surv(%s, %s) ~ %s + survival::strata(%s), ",
    "data = %s)"
  ), time, status, paste(predictors, collapse = " + "), strata, dataset)
}

ezr_meta_frame <- function(study, values, names) {
  list_code <- vapply(names, function(name) {
    sprintf("%s = c(%s)", name, paste(values[[name]], collapse = ", "))
  }, character(1))
  labels <- if (nzchar(study)) {
    sprintf('study = c(%s)', paste0('"', strsplit(study, ",", fixed = TRUE)[[1L]],
                                     '"', collapse = ", "))
  } else {
    sprintf('study = paste("Study", seq_len(%d))', length(values[[1]]))
  }
  paste(c(labels, list_code), collapse = ", ")
}

ezr_meta_prop <- function(events, n, study = "") {
  events <- ezr_split_numbers(events, "events")
  n <- ezr_split_numbers(n, "sample sizes")
  if (length(events) != length(n)) stop("Events and sample sizes must match.")
  paste0(
    "local({\n",
    "  .d <- data.frame(", ezr_meta_frame(study, list(events = events, n = n),
                                        c("events", "n")), ")\n",
    "  meta::metaprop(events, n, studlab = study, data = .d, sm = \"PLOGIT\")\n",
    "})"
  )
}

ezr_meta_cont <- function(n1, m1, s1, n2, m2, s2, study = "") {
  values <- list(
    n.e = ezr_split_numbers(n1, "group 1 sizes"),
    mean.e = ezr_split_numbers(m1, "group 1 means"),
    sd.e = ezr_split_numbers(s1, "group 1 standard deviations"),
    n.c = ezr_split_numbers(n2, "group 2 sizes"),
    mean.c = ezr_split_numbers(m2, "group 2 means"),
    sd.c = ezr_split_numbers(s2, "group 2 standard deviations")
  )
  lengths <- vapply(values, length, integer(1))
  if (length(unique(lengths)) != 1L) stop("All columns must have the same length.")
  paste0(
    "local({\n",
    "  .d <- data.frame(", ezr_meta_frame(study, values, names(values)), ")\n",
    "  meta::metacont(n.e, mean.e, sd.e, n.c, mean.c, sd.c, studlab = study,\n",
    "                 data = .d)\n",
    "})"
  )
}

ezr_meta_hazard <- function(hr, lower, upper, study = "") {
  hr <- ezr_split_numbers(hr, "hazard ratios")
  lower <- ezr_split_numbers(lower, "lower limits")
  upper <- ezr_split_numbers(upper, "upper limits")
  lengths <- c(length(hr), length(lower), length(upper))
  if (length(unique(lengths)) != 1L) stop("All columns must have the same length.")
  paste0(
    "local({\n",
    "  .d <- data.frame(",
    ezr_meta_frame(study, list(hr = hr, lower = lower, upper = upper),
                   c("hr", "lower", "upper")), ")\n",
    "  .d$TE <- log(.d$hr)\n",
    "  .d$seTE <- (log(.d$upper) - log(.d$lower)) / (2 * qnorm(0.975))\n",
    "  meta::metagen(TE, seTE, studlab = study, data = .d)\n",
    "})"
  )
}

ezr_netmeta <- function(treat1, treat2, TE, seTE) {
  te <- ezr_split_numbers(TE, "treatment effects")
  se <- ezr_split_numbers(seTE, "standard errors")
  if (length(te) != length(se)) stop("Effects and standard errors must match.")
  read_strings <- function(text, what) {
    values <- trimws(strsplit(as.character(text), ",", fixed = TRUE)[[1L]])
    if (any(!nzchar(values))) stop(sprintf("Enter the %s.", what))
    values
  }
  t1 <- read_strings(treat1, "first treatments")
  t2 <- read_strings(treat2, "second treatments")
  if (length(t1) != length(te) || length(t2) != length(te)) {
    stop("Treatments and effects must have the same length.")
  }
  paste0(
    "local({\n",
    "  .d <- data.frame(",
    sprintf('treat1 = c(%s), treat2 = c(%s), TE = c(%s), seTE = c(%s)',
            paste0('"', t1, '"', collapse = ", "),
            paste0('"', t2, '"', collapse = ", "),
            paste(te, collapse = ", "), paste(se, collapse = ", ")), ")\n",
    "  netmeta::netmeta(TE, seTE, treat1, treat2, data = .d, sm = \"RR\")\n",
    "})"
  )
}

ezr_survival_dialogs <- function() {
  list(
    StatMedLogrankTrend = ezr_dialog(
      "StatMedLogrankTrend", "Logrank trend test",
      list(ev("time", "Follow-up time", "numeric", FALSE),
           ev("status", "Event indicator", "all", FALSE),
           ev("group", "Ordered group", "factor", FALSE)),
      function(values, state) {
        ezr_surv_logrank_trend(RcmdrShiny::active_dataset(state),
                               values$time, values$status, values$group)
      },
      help_topic = "ezr-survival-meta", plot = FALSE
    ),
    StatMedCurrentSurvival = ezr_dialog(
      "StatMedCurrentSurvival", "Current survival and cumulative incidence",
      list(ev("time", "Follow-up time", "numeric", FALSE),
           ev("status", "Event indicator", "all", FALSE),
           ev("group", "Group (optional)", "factor", FALSE),
           ei("at", "Time point", 12)),
      function(values, state) {
        ezr_surv_current(RcmdrShiny::active_dataset(state), values$time,
                         values$status,
                         if (is.null(values$group)) "" else values$group,
                         values$at)
      },
      help_topic = "ezr-survival-meta", plot = FALSE
    ),
    StatMedCoxTD = ezr_dialog(
      "StatMedCoxTD", "Cox model with time-dependent covariate",
      list(ev("start", "Start time", "numeric", FALSE),
           ev("stop", "Stop time", "numeric", FALSE),
           ev("event", "Event indicator", "all", FALSE),
           ev("predictors", "Predictors", "all", TRUE)),
      function(values, state) {
        ezr_surv_cox_td(RcmdrShiny::active_dataset(state), values$start,
                        values$stop, values$event, values$predictors)
      },
      help_topic = "ezr-survival-meta", plot = FALSE
    ),
    StatMedCumInc = ezr_dialog(
      "StatMedCumInc", "Cumulative incidence and Gray test",
      list(ev("time", "Follow-up time", "numeric", FALSE),
           ev("status", "Competing event status", "all", FALSE),
           ev("group", "Group (optional)", "factor", FALSE)),
      function(values, state) {
        ezr_surv_cuminc(RcmdrShiny::active_dataset(state), values$time,
                        values$status,
                        if (is.null(values$group)) "" else values$group)
      },
      help_topic = "ezr-survival-meta"
    ),
    StatMedCrr = ezr_dialog(
      "StatMedCrr", "Fine-Gray model for competing events",
      list(ev("time", "Follow-up time", "numeric", FALSE),
           ev("status", "Competing event status", "all", FALSE),
           ev("predictors", "Predictors", "all", TRUE)),
      function(values, state) {
        ezr_surv_crr(RcmdrShiny::active_dataset(state), values$time,
                     values$status, values$predictors)
      },
      help_topic = "ezr-survival-meta", plot = FALSE
    ),
    StatMedCrrTD = ezr_dialog(
      "StatMedCrrTD", "Fine-Gray model with time-dependent covariate",
      list(ev("time", "Follow-up time", "numeric", FALSE),
           ev("status", "Competing event status", "all", FALSE),
           ev("predictors", "Predictors", "all", TRUE)),
      function(values, state) {
        ezr_surv_crr_td(RcmdrShiny::active_dataset(state), values$time,
                        values$status, values$predictors)
      },
      help_topic = "ezr-survival-meta", plot = FALSE
    ),
    StatMedMatching = ezr_dialog(
      "StatMedMatching", "Extract matched controls",
      list(ev("treatment", "Treatment indicator (0/1)", "all", FALSE),
           ev("covariates", "Matching covariates", "all", TRUE),
           ei("ratio", "Controls per case", 1)),
      function(values, state) {
        ezr_surv_matching(RcmdrShiny::active_dataset(state),
                          values$treatment, values$covariates, values$ratio)
      },
      help_topic = "ezr-survival-meta", plot = FALSE
    ),
    StatMedMH = ezr_dialog(
      "StatMedMH", "Mantel-Haenszel test for matched proportions",
      list(ev("row", "Row variable", "factor", FALSE),
           ev("column", "Column variable", "factor", FALSE),
           ev("strata", "Strata", "factor", FALSE)),
      function(values, state) {
        ezr_surv_mh(RcmdrShiny::active_dataset(state), values$row,
                    values$column, values$strata)
      },
      help_topic = "ezr-survival-meta", plot = FALSE
    ),
    StatMedCLogistic = ezr_dialog(
      "StatMedCLogistic", "Conditional logistic regression",
      list(ev("response", "Response (0/1)", "all", FALSE),
           ev("predictors", "Predictors", "all", TRUE),
           ev("strata", "Matched set identifier", "all", FALSE)),
      function(values, state) {
        ezr_surv_clogistic(RcmdrShiny::active_dataset(state), values$response,
                           values$predictors, values$strata)
      },
      help_topic = "ezr-survival-meta", plot = FALSE
    ),
    StatMedStCox = ezr_dialog(
      "StatMedStCox", "Stratified Cox model",
      list(ev("time", "Follow-up time", "numeric", FALSE),
           ev("status", "Event indicator", "all", FALSE),
           ev("predictors", "Predictors", "all", TRUE),
           ev("strata", "Strata", "factor", FALSE)),
      function(values, state) {
        ezr_surv_stratified_cox(RcmdrShiny::active_dataset(state),
                                values$time, values$status,
                                values$predictors, values$strata)
      },
      help_topic = "ezr-survival-meta", plot = FALSE
    ),
    StatMedMeta = ezr_dialog(
      "StatMedMeta", "Meta-analysis of proportions",
      list(ee("events", "Events (comma separated)", "10, 20"),
           ee("n", "Sample sizes (comma separated)", "50, 60"),
           ee("study", "Study labels (optional)", "")),
      function(values, state) {
        ezr_meta_prop(values$events, values$n,
                      if (is.null(values$study)) "" else values$study)
      },
      help_topic = "ezr-survival-meta", plot = FALSE
    ),
    StatMedMetaCont = ezr_dialog(
      "StatMedMetaCont", "Meta-analysis of means",
      list(ee("n1", "Group 1 sizes", "30, 40"),
           ee("m1", "Group 1 means", "5, 6"),
           ee("s1", "Group 1 SDs", "1, 1.2"),
           ee("n2", "Group 2 sizes", "30, 40"),
           ee("m2", "Group 2 means", "4, 5"),
           ee("s2", "Group 2 SDs", "1, 1.1"),
           ee("study", "Study labels (optional)", "")),
      function(values, state) {
        ezr_meta_cont(values$n1, values$m1, values$s1,
                      values$n2, values$m2, values$s2,
                      if (is.null(values$study)) "" else values$study)
      },
      help_topic = "ezr-survival-meta", plot = FALSE
    ),
    StatMedMetaHazard = ezr_dialog(
      "StatMedMetaHazard", "Meta-analysis of hazard ratios",
      list(ee("hr", "Hazard ratios", "0.8, 0.7"),
           ee("lower", "Lower confidence limits", "0.6, 0.5"),
           ee("upper", "Upper confidence limits", "1.0, 0.9"),
           ee("study", "Study labels (optional)", "")),
      function(values, state) {
        ezr_meta_hazard(values$hr, values$lower, values$upper,
                        if (is.null(values$study)) "" else values$study)
      },
      help_topic = "ezr-survival-meta", plot = FALSE
    ),
    StatMedNetworkMeta = ezr_dialog(
      "StatMedNetworkMeta", "Network meta-analysis",
      list(ee("treat1", "First treatments", "A, A"),
           ee("treat2", "Second treatments", "B, C"),
           ee("TE", "Treatment effects", "0.2, 0.3"),
           ee("seTE", "Standard errors", "0.1, 0.12")),
      function(values, state) {
        ezr_netmeta(values$treat1, values$treat2, values$TE, values$seTE)
      },
      help_topic = "ezr-survival-meta", plot = FALSE
    )
  )
}
