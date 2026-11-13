---
id: sos-overview
title: sos overview
type: task
category: plugins
order: 10
keywords: [sos, plugin]
aliases: []
dialogs: [sosInit]
commands: []
packages: [RcmdrShinyPlugin.sos]
related: []
language: en
status: draft
---

## What it does

`RcmdrShinyPlugin.sos` adds its menus and dialogs to RcmdrShiny.

## Dialogs

| Dialog | Title |
|---|---|
| `sosInit` | Search R help pages |

## Loading

```r
RcmdrShiny::run(plugins = "RcmdrShinyPlugin.sos")
```
