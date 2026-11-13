---
id: arnova-overview
title: aRnova overview
type: task
category: plugins
order: 10
keywords: [arnova, plugin]
aliases: []
dialogs: [oneWayAnova_, multiWayAnova_, repMeasAnovaSetup, generalizedLinearModel_]
commands: []
packages: [RcmdrShinyPlugin.aRnova]
related: []
language: en
status: draft
---

## What it does

`RcmdrShinyPlugin.aRnova` adds its menus and dialogs to RcmdrShiny.

## Dialogs

| Dialog | Title |
|---|---|
| `oneWayAnova_` | One-way ANOVA |
| `multiWayAnova_` | Multi-way ANOVA |
| `repMeasAnovaSetup` | Repeated-measures ANOVA |
| `generalizedLinearModel_` | Generalized Linear Model |

## Loading

```r
RcmdrShiny::run(plugins = "RcmdrShinyPlugin.aRnova")
```
