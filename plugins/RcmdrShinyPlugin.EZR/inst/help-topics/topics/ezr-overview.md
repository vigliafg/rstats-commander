---
id: ezr-overview
title: EZR overview
type: task
category: plugins
order: 10
keywords: [ezr, plugin]
aliases: []
dialogs: [StatMedVariableCheck, StatMedTrainTestSplit, StatMedDummy, StatMedDatediff, StatMedNAgroup, StatMedProbCI, StatMedProbSingle, StatMedTwoWayTable, StatMedMcNemar, StatMedLogisticRegression, StatMedMeanCI, StatMedSingleSampleTTest, StatMedTtest, StatMedPairedTtest, StatMedBartlett, StatMedANOVA, StatMedMultiANOVA, StatMedCorrelation, StatMedLinearMixedModel, StatMedMannW, StatMedWilSign, StatMedKruWalli, StatMedFriedman, StatMedSpearman, StatMedKaplanMeier, StatMedCoxRegression, StatMedTest, StatMedKappa, StatMedROC, StatMedHistogram, StatMedBoxPlot, StatMedBarGraph, StatMedScatterPlot, StatMedTableOne, StatMedReadDataSet, StatMedCompute, StatMedNumericToFactor, StatMedReorderFactor, StatMedRecodeDialog, StatMedDeleteVariable, StatMedSubsetDataSet, StatMedSort, StatMedFrequency, StatMedNumericalSummaries, StatMedLinearRegression, StatMedOrdinalRegressionModel, StatMedMultinomialLogitModel]
commands: []
packages: [RcmdrShinyPlugin.EZR]
related: []
language: en
status: documented
---

## What it does

`RcmdrShinyPlugin.EZR` adds its menus and dialogs to RcmdrShiny.

## Dialogs

| Dialog | Title |
|---|---|
| `StatMedVariableCheck` | Variables in active data set |
| `StatMedTrainTestSplit` | Training-test data split |
| `StatMedDummy` | Create dummy variables |
| `StatMedDatediff` | Difference between two dates |
| `StatMedNAgroup` | Missing observations to a group |
| `StatMedProbCI` | Confidence interval for a proportion |
| `StatMedProbSingle` | One-sample proportion test |
| `StatMedTwoWayTable` | Two-way table and proportions |
| `StatMedMcNemar` | McNemar test |
| `StatMedLogisticRegression` | Logistic regression |
| `StatMedMeanCI` | Confidence interval for a mean |
| `StatMedSingleSampleTTest` | Single-sample t-test |
| `StatMedTtest` | Two-sample t-test |
| `StatMedPairedTtest` | Paired t-test |
| `StatMedBartlett` | Bartlett test |
| `StatMedANOVA` | One-way ANOVA |
| `StatMedMultiANOVA` | Multi-way ANOVA |
| `StatMedCorrelation` | Correlation test |
| `StatMedLinearMixedModel` | Linear mixed model |
| `StatMedMannW` | Mann-Whitney U test |
| `StatMedWilSign` | Wilcoxon signed rank test |
| `StatMedKruWalli` | Kruskal-Wallis test |
| `StatMedFriedman` | Friedman test |
| `StatMedSpearman` | Spearman rank correlation |
| `StatMedKaplanMeier` | Kaplan-Meier survival curve |
| `StatMedCoxRegression` | Cox proportional hazards regression |
| `StatMedTest` | Accuracy of qualitative test |
| `StatMedKappa` | Kappa statistics |
| `StatMedROC` | ROC curve analysis |
| `StatMedHistogram` | Histogram |
| `StatMedBoxPlot` | Boxplot |
| `StatMedBarGraph` | Bar graph (frequencies) |
| `StatMedScatterPlot` | Scatterplot |
| `StatMedTableOne` | Summary table of sample characteristics |
| `StatMedReadDataSet` | Read Text Data From File, Clipboard, or URL |
| `StatMedCompute` | Compute New Variable |
| `StatMedNumericToFactor` | Convert Numeric Variables to Factors |
| `StatMedReorderFactor` | Reorder Factor Levels |
| `StatMedRecodeDialog` | Recode Variables |
| `StatMedDeleteVariable` | Delete Variables |
| `StatMedSubsetDataSet` | Subset Data Set |
| `StatMedSort` | Sort Active Data Set |
| `StatMedFrequency` | Frequency Distributions |
| `StatMedNumericalSummaries` | Numerical Summaries |
| `StatMedLinearRegression` | Linear Model |
| `StatMedOrdinalRegressionModel` | Ordinal Regression Model |
| `StatMedMultinomialLogitModel` | Multinomial Logit Model |

## Loading

```r
RcmdrShiny::run(plugins = "RcmdrShinyPlugin.EZR")
```
