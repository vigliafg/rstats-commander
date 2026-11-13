---
id: hh-overview
title: HH overview
type: task
category: plugins
order: 10
keywords: [hh, plugin]
aliases: []
dialogs: [twoWayTable.HH, enterTable.HH, analyzeTwoWayTable.HH, bestSubsetsRegressionModel.HH, confidenceIntervalsPlot, PredictModel, scatterPlot.HH, scatterPlotMatrix.HH, Xyplot.HH, Xyplot.HH2, LikertFormula, ResizeEtcDialog, Interaction2wtRcmdr, DotplottbRcmdr, Regr1Plot, QQPlot.HH, Scatter3DDialog.HH, anovaTableII.HH, anovaTableI.HH, normal.and.t.hypotheses.plot, FHypothesesPlot, ChisqHypothesesPlot, R_options, MMCmenu]
commands: []
packages: [RcmdrShinyPlugin.HH]
related: []
language: en
status: draft
---

## What it does

`RcmdrShinyPlugin.HH` adds its menus and dialogs to RcmdrShiny.

## Dialogs

| Dialog | Title |
|---|---|
| `twoWayTable.HH` | Two-way table |
| `enterTable.HH` | Enter and analyze two-way table |
| `analyzeTwoWayTable.HH` | Analyze two-way table |
| `bestSubsetsRegressionModel.HH` | Best subsets regression |
| `confidenceIntervalsPlot` | Confidence interval plot |
| `PredictModel` | Prediction intervals |
| `scatterPlot.HH` | Scatterplot (HH) |
| `scatterPlotMatrix.HH` | Scatterplot matrix |
| `Xyplot.HH` | XY conditioning plot |
| `Xyplot.HH2` | lattice plot |
| `LikertFormula` | Likert plot |
| `ResizeEtcDialog` | Resize lattice plots |
| `Interaction2wtRcmdr` | Plot of two-way interactions |
| `DotplottbRcmdr` | Dotplot |
| `Regr1Plot` | Squared residuals |
| `QQPlot.HH` | Quantile-comparison plot |
| `Scatter3DDialog.HH` | 3D scatterplot |
| `anovaTableII.HH` | ANOVA table (Type II) |
| `anovaTableI.HH` | ANOVA table (Type I) |
| `normal.and.t.hypotheses.plot` | Plot hypotheses or confidence intervals |
| `FHypothesesPlot` | Plot F hypotheses |
| `ChisqHypothesesPlot` | Plot chi-squared hypotheses |
| `R_options` | R options (HH) |
| `MMCmenu` | MMC plot |

## Loading

```r
RcmdrShiny::run(plugins = "RcmdrShinyPlugin.HH")
```
