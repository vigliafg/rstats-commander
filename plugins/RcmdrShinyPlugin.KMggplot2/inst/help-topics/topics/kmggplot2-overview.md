---
id: kmggplot2-overview
title: KMggplot2 overview
type: task
category: plugins
order: 10
keywords: [kmggplot2, plugin]
aliases: []
dialogs: [windowKM, windowHist, windowQQ, windowBox, windowScatter, windowScattermat, windowLine, windowPie, windowDiscretebar, windowContour, windowFactorize, windowDistNorm, windowDistT, windowDistChisq, windowDistF, windowDistExp, windowDistUnif, windowDistBeta, windowDistCauchy, windowDistLogis, windowDistLnorm, windowDistGamma, windowDistWeibull, windowDistBinom, windowDistPois, windowDistGeom, windowDistHyper, windowDistNbinom]
commands: []
packages: [RcmdrShinyPlugin.KMggplot2]
related: []
language: en
status: draft
---

## What it does

`RcmdrShinyPlugin.KMggplot2` adds its menus and dialogs to RcmdrShiny.

## Dialogs

| Dialog | Title |
|---|---|
| `windowKM` | Kaplan-Meier plot |
| `windowHist` | Histogram |
| `windowQQ` | Q-Q plot |
| `windowBox` | Box plot / Violin plot / Confidence interval |
| `windowScatter` | Scatter plot |
| `windowScattermat` | Scatter matrix |
| `windowLine` | Line chart |
| `windowPie` | Pie chart |
| `windowDiscretebar` | Bar chart for discrete variables |
| `windowContour` | Contour plot |
| `windowFactorize` | Factorizing numeric variables |
| `windowDistNorm` | Normal distribution |
| `windowDistT` | t distribution |
| `windowDistChisq` | Chi-square distribution |
| `windowDistF` | F distribution |
| `windowDistExp` | Exponential distribution |
| `windowDistUnif` | Uniform distribution |
| `windowDistBeta` | Beta distribution |
| `windowDistCauchy` | Cauchy distribution |
| `windowDistLogis` | Logistic distribution |
| `windowDistLnorm` | Log-normal distribution |
| `windowDistGamma` | Gamma distribution |
| `windowDistWeibull` | Weibull distribution |
| `windowDistBinom` | Binomial distribution |
| `windowDistPois` | Poisson distribution |
| `windowDistGeom` | Geometric distribution |
| `windowDistHyper` | Hypergeometric distribution |
| `windowDistNbinom` | Negative binomial distribution |

## Loading

```r
RcmdrShiny::run(plugins = "RcmdrShinyPlugin.KMggplot2")
```
