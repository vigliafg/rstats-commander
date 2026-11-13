---
id: roc-overview
title: ROC overview
type: task
category: plugins
order: 10
keywords: [roc, plugin]
aliases: []
dialogs: [fncvpROC, fncPairedpROC, fncUnpairedpROC, fndHosmerLemeshow, fncLRpROC]
commands: []
packages: [RcmdrShinyPlugin.ROC]
related: []
language: en
status: draft
---

## What it does

`RcmdrShinyPlugin.ROC` adds its menus and dialogs to RcmdrShiny.

## Dialogs

| Dialog | Title |
|---|---|
| `fncvpROC` | Plot ROC curve |
| `fncPairedpROC` | Paired ROC curves comparison |
| `fncUnpairedpROC` | Unpaired ROC curves comparison |
| `fndHosmerLemeshow` | Hosmer-Lemeshow GOF Test |
| `fncLRpROC` | Plot ROC curve for logistic regression model |

## Loading

```r
RcmdrShiny::run(plugins = "RcmdrShinyPlugin.ROC")
```
