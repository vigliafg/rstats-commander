---
id: ezr-survival-meta
title: Survival, matched pairs and meta-analysis (EZR)
type: task
category: plugins
order: 9
keywords: [survival, cox, competing risks, fine-gray, cumulative incidence,
           matching, conditional logistic, meta-analysis, network, ezr]
aliases: [ezr-survival, competing-risks, meta-analysis]
dialogs: [StatMedLogrankTrend, StatMedCurrentSurvival, StatMedCoxTD,
          StatMedCumInc, StatMedCrr, StatMedCrrTD, StatMedMatching, StatMedMH,
          StatMedCLogistic, StatMedStCox, StatMedMeta, StatMedMetaCont,
          StatMedMetaHazard, StatMedNetworkMeta]
commands: [survdiff, survfit, coxph, cuminc, crr, finegray, matchit, clogit,
           mantelhaen.test, metaprop, metacont, metagen, netmeta]
packages: [survival, cmprsk, MatchIt, meta, netmeta]
related: [ezr-overview, ezr-tests]
language: en
status: documented
---

# Survival, matched pairs and meta-analysis (EZR)

The core survival menu covers Kaplan-Meier and the standard Cox model.  EZR adds
competing risks, time-dependent covariates, matched-pair analysis and evidence
synthesis.

## Survival analysis

| Entry | Command |
|---|---|
| Logrank trend test | `survdiff()` with a numeric group |
| Current survival | `summary(survfit(), times = )` |
| Cox with time-dependent covariate | `coxph(Surv(start, stop, event) ~ ...)` |
| Cumulative incidence and Gray test | `cmprsk::cuminc()` |
| Fine-Gray model | `cmprsk::crr()` |
| Fine-Gray with time-dependent covariate | `survival::finegray()` + `coxph()` |

The trend test uses the ordered group as a numeric score, so the factor levels
must be in the expected order:

```r
survival::survdiff(survival::Surv(time, status) ~ as.numeric(group),
                   data = Dataset)
```

Fine-Gray with a time-dependent covariate uses the `finegray()` expansion:

```r
local({
  .fg <- survival::finegray(survival::Surv(time, status) ~ ., data = Dataset)
  .fit <- survival::coxph(survival::Surv(fgstart, fgstop, fgstatus) ~ x,
                          data = .fg, weights = fgwt)
  summary(.fit)
})
```

## Matched pairs

| Entry | Command |
|---|---|
| Extract matched controls | `MatchIt::matchit()` + `match.data()` |
| Mantel-Haenszel test | `mantelhaen.test()` |
| Conditional logistic regression | `survival::clogit()` |
| Stratified Cox model | `coxph()` + `strata()` |

```r
local({
  .match <- MatchIt::matchit(treated ~ age + sex, data = Dataset,
                             method = "nearest", ratio = 1, replace = FALSE)
  .matched <- MatchIt::match.data(.match)
  summary(.match)
})
```

Conditional logistic regression needs one row per subject and a matched-set
identifier:

```r
survival::clogit(case ~ exposure + survival::strata(set), data = Dataset)
```

## Meta-analysis

| Entry | Command |
|---|---|
| Proportions | `meta::metaprop()` |
| Means | `meta::metacont()` |
| Hazard ratios | `meta::metagen()` on log scale |
| Network | `netmeta::netmeta()` |

```r
local({
  .d <- data.frame(study = c("A", "B"), events = c(10, 20), n = c(50, 60))
  meta::metaprop(events, n, studlab = study, data = .d, sm = "PLOGIT")
})
```

Hazard ratios are converted to the log scale with the standard error derived
from the confidence limits:

```r
.d$TE <- log(.d$hr)
.d$seTE <- (log(.d$upper) - log(.d$lower)) / (2 * qnorm(0.975))
```

## Requirements

`survival`, `cmprsk`, `MatchIt`, `meta` and `netmeta` are optional.  Entries
whose package is missing stay hidden; the rest of the menu keeps working.

## See also

- `topic:ezr-overview`
- `topic:ezr-tests`
- `topic:survival`
