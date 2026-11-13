---
id: export-overview
title: Export overview
type: task
category: plugins
order: 10
keywords: [export, plugin]
aliases: []
dialogs: [xtableExport, latexExport, formatdfExport]
commands: []
packages: [RcmdrShinyPlugin.Export]
related: []
language: en
status: documented
---

## What it does

`RcmdrShinyPlugin.Export` adds its menus and dialogs to RcmdrShiny.

## Dialogs

| Dialog | Title |
|---|---|
| `xtableExport` | Export objects using xtable() |
| `latexExport` | Export objects using latex() |
| `formatdfExport` | Format for LaTeX or HTML export |

## Loading

```r
RcmdrShiny::run(plugins = "RcmdrShinyPlugin.Export")
```
