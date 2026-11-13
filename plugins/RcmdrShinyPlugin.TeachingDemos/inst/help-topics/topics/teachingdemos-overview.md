---
id: teachingdemos-overview
title: TeachingDemos overview
type: task
category: plugins
order: 10
keywords: [teachingdemos, plugin]
aliases: []
dialogs: [centralLimitTheorem, simulateConfidenceIntervals, powerExample, flipCoin, rollDie, linearRegressionExample, correlationExample, visBinom, visNormal, vist, visGamma]
commands: []
packages: [RcmdrShinyPlugin.TeachingDemos]
related: []
language: en
status: draft
---

## What it does

`RcmdrShinyPlugin.TeachingDemos` adds its menus and dialogs to RcmdrShiny.

## Dialogs

| Dialog | Title |
|---|---|
| `centralLimitTheorem` | Central limit theorem |
| `simulateConfidenceIntervals` | Confidence interval for the mean |
| `powerExample` | Power of the test |
| `flipCoin` | Flip a coin |
| `rollDie` | Roll a die |
| `linearRegressionExample` | Simple linear regression |
| `correlationExample` | Simple correlation |
| `visBinom` | Binomial distributions |
| `visNormal` | Normal distributions |
| `vist` | t distributions |
| `visGamma` | Gamma distributions |

## Loading

```r
RcmdrShiny::run(plugins = "RcmdrShinyPlugin.TeachingDemos")
```
