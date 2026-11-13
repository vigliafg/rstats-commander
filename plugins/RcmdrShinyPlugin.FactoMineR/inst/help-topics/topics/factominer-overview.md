---
id: factominer-overview
title: FactoMineR overview
type: task
category: plugins
order: 10
keywords: [factominer, plugin]
aliases: []
dialogs: [FactoPCA, FactoCA, FactoMCA, FactoMFA, FactoDMFA, FactoFAMD, FactoHCPC, FactoGPA, Factocatdes, Factoprefpls, readDataSetFacto]
commands: []
packages: [RcmdrShinyPlugin.FactoMineR]
related: []
language: en
status: draft
---

## What it does

`RcmdrShinyPlugin.FactoMineR` adds its menus and dialogs to RcmdrShiny.

## Dialogs

| Dialog | Title |
|---|---|
| `FactoPCA` | Principal Component Analysis (PCA) |
| `FactoCA` | Correspondence Analysis (CA) |
| `FactoMCA` | Multiple Correspondence Analysis (MCA) |
| `FactoMFA` | Multiple Factor Analysis (MFA) |
| `FactoDMFA` | Dual Multiple Factor Analysis (DMFA) |
| `FactoFAMD` | Factor Analysis of Mixed Data (FAMD) |
| `FactoHCPC` | Hierarchical Clustering on Principal Components |
| `FactoGPA` | General Procrustes Analysis (GPA) |
| `Factocatdes` | Description of categories |
| `Factoprefpls` | Scatter plot with additional variables |
| `readDataSetFacto` | Read Text Data From File, Clipboard, or URL |

## Loading

```r
RcmdrShiny::run(plugins = "RcmdrShinyPlugin.FactoMineR")
```
