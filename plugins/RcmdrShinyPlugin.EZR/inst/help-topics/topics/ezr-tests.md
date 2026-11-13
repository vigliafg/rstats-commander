---
id: ezr-tests
title: Tests and diagnostic accuracy (EZR)
type: task
category: plugins
order: 8
keywords: [proportion, confidence interval, cochran, trend, poisson, grubbs,
           kolmogorov, variance, ancova, jonckheere, ppv, npv, roc, alpha,
           ezr]
aliases: [ezr-tests, diagnostic-accuracy, predictive-values]
dialogs: [StatMedProbDiffCI, StatMedProbRatioCI, StatMedCochranQ,
          StatMedPropTrend, StatMedModifiedPoissonRegression, StatMedSG,
          StatMedKS, StatMedFTest, StatMedANCOVA, StatMedJT,
          StatMedPredictiveValue, StatMedROCtest, StatMedSurvivalROC,
          StatMedReliability]
commands: [prop.test, prop.trend.test, glm, ks.test, var.test, Anova,
           jonckheere.test, roc, roc.test, timeROC, alpha]
packages: [sandwich, lmtest, pROC, clinfun, timeROC, psych, car]
related: [ezr-overview, ezr-tests]
language: en
status: documented
---

# Tests and diagnostic accuracy (EZR)

**Statistical analysis > Discrete variables / Continuous variables /
Nonparametric tests / Accuracy of diagnostic test** gathers the tests that the
core menu does not cover.  The common t, Wilcoxon, chi-square and McNemar tests
are still available from the core **Statistics** menus.

## Discrete variables

| Entry | Command |
|---|---|
| CI for a difference between two proportions | `prop.test()` |
| CI for a ratio of two proportions | Katz log method |
| Cochran Q test | paired proportions, chi-square approximation |
| Cochran-Armitage trend | `prop.trend.test()` |
| Modified Poisson regression | `glm(..., family = poisson)` with robust SE |

```r
prop.test(c(10, 15), c(20, 20), conf.level = 0.95)$conf.int
```

```r
local({
  .p1 <- 10 / 20; .p2 <- 15 / 20
  .se <- sqrt(1/10 - 1/20 + 1/15 - 1/20)
  exp(log(.p1 / .p2) + c(-1, 1) * qnorm(1 - 0.95/2) * .se)
})
```

```r
local({
  .fit <- glm(outcome ~ age + sex, data = Dataset, family = poisson)
  lmtest::coeftest(.fit, vcov = sandwich::vcovHC(.fit, type = "HC0"))
})
```

## Continuous variables

| Entry | Command |
|---|---|
| Smirnov-Grubbs test | Grubbs statistic and t approximation |
| Kolmogorov-Smirnov normality | `ks.test(x, "pnorm", mean(x), sd(x))` |
| Two-variances F-test | `var.test()` |
| ANCOVA | `lm()` plus `car::Anova(type = "II")` |
| Jonckheere-Terpstra | `clinfun::jonckheere.test()` |

The Grubbs test reports `G`, the studentised extreme value `u` and its
approximate p-value.  A p-value below `0.05` suggests one outlier.

`ks.test()` with estimated parameters is conservative; read the p-value as a
screening device, not as a definitive normality test.

## Diagnostic accuracy

| Entry | Command |
|---|---|
| Predictive values | PPV, NPV, sensitivity, specificity from the 2×2 table |
| Compare two ROC curves | `pROC::roc.test()` |
| Time-dependent ROC | `timeROC::timeROC()` |
| Cronbach's alpha | `psych::alpha()` |

```r
local({
  .tp <- 30; .fp <- 10; .fn <- 5; .tn <- 55
  c(PPV = .tp / (.tp + .fp), NPV = .tn / (.tn + .fn),
    sensitivity = .tp / (.tp + .fn),
    specificity = .tn / (.tn + .fp))
})
```

## Requirements

`sandwich` and `lmtest` power the modified Poisson model, `pROC` the ROC
comparison, `clinfun` the Jonckheere-Terpstra test, `timeROC` the
time-dependent ROC and `psych` Cronbach's alpha.  Entries whose package is
missing stay hidden.

## See also

- `topic:ezr-overview`
- `topic:two-sample-proportions-test`
- `topic:correlation`
