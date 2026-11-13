---
id: doe-overview
title: DoE overview
type: task
category: plugins
order: 10
keywords: [doe, plugin]
aliases: []
dialogs: [Menu.pb2level, Menu.FrF2level, Menu.fac, Menu.oa, Menu.ccd, Menu.bbd, Menu.lhs, Menu.Dopt, Menu.display, summarize.design, Menu.plot, design.info.design, Menu.addresponse, Menu.colremove, Menu.model, Menu.rsmmodel, Menu.EffectPlots, Menu.IAPlot, Menu.contour]
commands: []
packages: [RcmdrShinyPlugin.DoE]
related: []
language: en
status: documented
---

## What it does

`RcmdrShinyPlugin.DoE` adds its menus and dialogs to RcmdrShiny.

## Dialogs

| Dialog | Title |
|---|---|
| `Menu.pb2level` | Screening design |
| `Menu.FrF2level` | Regular fractional factorial |
| `Menu.fac` | General full factorial |
| `Menu.oa` | General orthogonal array |
| `Menu.ccd` | Central composite design |
| `Menu.bbd` | Box-Behnken design |
| `Menu.lhs` | Latin hypercube design |
| `Menu.Dopt` | D-optimal design |
| `Menu.display` | Display active design |
| `summarize.design` | Summarize active design |
| `Menu.plot` | Plot active design |
| `design.info.design` | Design information |
| `Menu.addresponse` | Add response variable |
| `Menu.colremove` | Remove column |
| `Menu.model` | Default linear model |
| `Menu.rsmmodel` | Response surface model |
| `Menu.EffectPlots` | Effects normal plot |
| `Menu.IAPlot` | Main effects and interaction plots |
| `Menu.contour` | Response surface plots |

## Loading

```r
RcmdrShiny::run(plugins = "RcmdrShinyPlugin.DoE")
```
