---
id: survival-overview
title: survival overview
type: task
category: plugins
order: 10
keywords: [survival, plugin]
aliases: []
dialogs: [Survfit, Survdiff, SurvivalData, Unfold, toDate, CoxModel, survregModel, CoxZPH, PlotCoxph, TermPlots, CoxDfbetas, CoxDfbeta, MartingalePlotsDialog, PartialResPlots]
commands: []
packages: [RcmdrShinyPlugin.survival]
related: []
language: en
status: documented
---

## What it does

`RcmdrShinyPlugin.survival` adds its menus and dialogs to RcmdrShiny.

## Dialogs

| Dialog | Title |
|---|---|
| `Survfit` | Survival function |
| `Survdiff` | Compare survival functions |
| `SurvivalData` | Survival data definition |
| `Unfold` | Convert wide to long data |
| `toDate` | Convert variable to date |
| `CoxModel` | Cox regression model |
| `survregModel` | Parametric survival model |
| `CoxZPH` | Test proportional hazards |
| `PlotCoxph` | Cox-model survival function |
| `TermPlots` | Plot terms in Cox model |
| `CoxDfbetas` | Plot survival-regression dfbetas |
| `CoxDfbeta` | Plot survival-regression dfbeta |
| `MartingalePlotsDialog` | Plot null Martingale residuals |
| `PartialResPlots` | Cox-model partial-residual plots |

## Loading

```r
RcmdrShiny::run(plugins = "RcmdrShinyPlugin.survival")
```
