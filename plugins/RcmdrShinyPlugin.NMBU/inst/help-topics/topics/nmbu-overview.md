---
id: nmbu-overview
title: NMBU overview
type: task
category: plugins
order: 10
keywords: [nmbu, plugin]
aliases: []
dialogs: [singleSampleTTestNMBU, independentSamplesTTestNMBU, pairedTTestNMBU, twoSamplesTTest, oneSamplesTTestSum, twoSamplesTTestSum, powerTtest, singleSampleZTestNMBU, independentSamplesZTestNMBU, pairedZTestNMBU, proportionTest, twoProportionTest, oneWayAnovaNMBU, multiWayAnovaNMBU, plsRegressionModel, predictRegressionModel, coefNMBU, forwardAdd, backwardDrop, forwardBackward, plotModelNMBU, addObservationStatisticsNMBU, linearModelNMBU, generalizedLinearModelNMBU, multinomialLogitModelNMBU, ordinalRegressionModelNMBU, principalComponentsStat]
commands: []
packages: [RcmdrShinyPlugin.NMBU]
related: []
language: en
status: documented
---

## What it does

`RcmdrShinyPlugin.NMBU` adds its menus and dialogs to RcmdrShiny.

## Dialogs

| Dialog | Title |
|---|---|
| `singleSampleTTestNMBU` | Single-sample t-test |
| `independentSamplesTTestNMBU` | Two-sample t-test |
| `pairedTTestNMBU` | Paired t-test |
| `twoSamplesTTest` | Two-sample t-test (unstacked) |
| `oneSamplesTTestSum` | One-sample t-test (summarized data) |
| `twoSamplesTTestSum` | Two-sample t-test (summarized data) |
| `powerTtest` | Power calculations for t tests |
| `singleSampleZTestNMBU` | Single-sample z-test |
| `independentSamplesZTestNMBU` | Two-sample z-test (unstacked) |
| `pairedZTestNMBU` | Paired z-test |
| `proportionTest` | Single-sample proportion test |
| `twoProportionTest` | Two-sample proportion test |
| `oneWayAnovaNMBU` | One-way ANOVA |
| `multiWayAnovaNMBU` | Multi-way ANOVA |
| `plsRegressionModel` | Partial least squares regression |
| `predictRegressionModel` | Prediction |
| `coefNMBU` | Regression coefficients |
| `forwardAdd` | Forward selection |
| `backwardDrop` | Backward elimination |
| `forwardBackward` | Forward/backward selection |
| `plotModelNMBU` | Basic diagnostic plots |
| `addObservationStatisticsNMBU` | Add observation statistics |
| `linearModelNMBU` | Linear Model |
| `generalizedLinearModelNMBU` | Generalized Linear Model |
| `multinomialLogitModelNMBU` | Multinomial Logit Model |
| `ordinalRegressionModelNMBU` | Ordinal Regression Model |
| `principalComponentsStat` | Principal Components Analysis |

## Loading

```r
RcmdrShiny::run(plugins = "RcmdrShinyPlugin.NMBU")
```
