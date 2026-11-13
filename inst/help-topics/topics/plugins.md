---
id: plugins
title: Using plugins
type: concept
category: plugins
keywords: [plugin, extend, package, load, menu, rcmdrshinyplugin]
aliases: [plugin, plug-in, extensions]
dialogs: [loadPlugins]
commands: [load_plugin, load_plugin_package, list_plugins, unload_plugins]
packages: [RcmdrShiny]
related: [writing-plugins, writing-help-topics]
language: en
status: documented
---

# Using plugins

A plugin is an R package that adds menus, dialogs and commands to RcmdrShiny.
The 15 official plugins live under `plugins/` in the project repository and are
distributed through GitHub.

## Load a plugin

From the interface: **Tools > Load Rcmdr plug-in(s)...**, then pick one or more
installed plugin packages.

From R:

```r
RcmdrShiny::run(plugins = c("RcmdrShinyPlugin.Export", "RcmdrShinyPlugin.ROC"))
```

or, in a running session:

```r
RcmdrShiny::load_plugin_package("RcmdrShinyPlugin.Export")
```

## What a plugin can add

- a top-level menu or entries inside existing menus;
- dialogs with their own validation and command generation;
- commands that run directly without a dialog;
- help topics, displayed in the **Help** tab and from the dialog's **Help**
  button.

## Official plugins

| Plugin | Purpose |
|---|---|
| `Export` | LaTeX and HTML tables |
| `sos` | Search R help and packages |
| `PcaRobust` | Robust PCA |
| `ROC` | ROC curves and diagnostic accuracy |
| `UCA` | Statistical process control |
| `TeachingDemos` | Teaching demonstrations |
| `KMggplot2` | ggplot2-based graphics |
| `HH` | HH graphics and tables |
| `TeachStat` | Teaching statistics |
| `survival` | Survival analysis |
| `aRnova` | Analysis of variance helpers |
| `NMBU` | NMBU statistics course tools |
| `DoE` | Design of experiments |
| `FactoMineR` | Multivariate analysis |
| `EZR` | EZR clinical workflow |

## Notes

- EZR replaces the core menus with its own layout, so load it alone or last.
- A plugin that reuses a menu id is merged with the existing menu; conflicting
  commands produce a warning and the last plugin wins.
- Unload everything with `RcmdrShiny::unload_plugins()`.

## See also

- `topic:writing-plugins`
- `topic:writing-help-topics`
