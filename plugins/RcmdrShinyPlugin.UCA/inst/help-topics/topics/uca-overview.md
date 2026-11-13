---
id: uca-overview
title: UCA overview
type: task
category: plugins
order: 10
keywords: [uca, plugin]
aliases: []
dialogs: [sigmaTest, randomnessFTest, randomnessNTest, paretochartMenu, predict4dataset, input2predict, pchart1Menu, pchart2Menu, pchartpMenu, npchart1Menu, npchart2Menu, npchartpMenu, uchart1Menu, uchart2Menu, uchartpMenu, cchart1Menu, cchart2Menu, cchartpMenu, xbar1mcMenu, xbar2mcMenu, xbarpmcMenu, R1mcMenu, R2mcMenu, RpmcMenu, S1mcMenu, S2mcMenu, SpmcMenu]
commands: []
packages: [RcmdrShinyPlugin.UCA]
related: []
language: en
status: documented
---

## What it does

`RcmdrShinyPlugin.UCA` adds its menus and dialogs to RcmdrShiny.

## Dialogs

| Dialog | Title |
|---|---|
| `sigmaTest` | Single-Sample Variance Test |
| `randomnessFTest` | Randomness test for two level factor |
| `randomnessNTest` | Randomness test for numeric variable |
| `paretochartMenu` | Pareto chart |
| `predict4dataset` | Predict values for existing dataset |
| `input2predict` | Input data and predict |
| `pchart1Menu` | p-chart |
| `pchart2Menu` | p-chart phase II from data |
| `pchartpMenu` | p-chart phase II from parameter |
| `npchart1Menu` | np-chart |
| `npchart2Menu` | np-chart phase II from data |
| `npchartpMenu` | np-chart phase II from parameter |
| `uchart1Menu` | u-chart (average rate) |
| `uchart2Menu` | u-chart phase II from data |
| `uchartpMenu` | u-chart phase II from parameter |
| `cchart1Menu` | c-chart (rate) |
| `cchart2Menu` | c-chart (rate) from data |
| `cchartpMenu` | c-chart (rate) from parameter |
| `xbar1mcMenu` | xbar-chart (multiple columns) |
| `xbar2mcMenu` | xbar-chart phase II from data (multiple columns) |
| `xbarpmcMenu` | xbar-chart phase II from parameters (multiple columns) |
| `R1mcMenu` | R-chart phase I (multiple columns) |
| `R2mcMenu` | R-chart phase II from data (multiple columns) |
| `RpmcMenu` | R-chart phase II from parameters (multiple columns) |
| `S1mcMenu` | S-chart (multiple columns) |
| `S2mcMenu` | S-chart phase II from data (multiple columns) |
| `SpmcMenu` | S-chart phase II from parameters (multiple columns) |

## Loading

```r
RcmdrShiny::run(plugins = "RcmdrShinyPlugin.UCA")
```
