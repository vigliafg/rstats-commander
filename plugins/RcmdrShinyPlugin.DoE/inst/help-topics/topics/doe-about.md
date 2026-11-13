---
id: doe-about
title: About the DoE plugin
type: reference
category: plugins
order: 8
keywords: [doe, design of experiments, plugin, about, rcmdrplugindoe]
aliases: [doe-about, about-doe]
dialogs: []
commands: []
packages: [RcmdrShinyPlugin.DoE]
related: [doe-designs]
language: en
status: documented
---

# About the DoE plugin

`RcmdrShinyPlugin.DoE` rebuilds the menu of `RcmdrPlugin.DoE` on top of
RcmdrShiny.  It covers screening, factorial, response-surface, space-filling
and optimal designs, plus the inspection and analysis helpers.

The design construction is delegated to the established R packages:

| Package | Provides |
|---|---|
| `FrF2` | Plackett-Burman and fractional factorial designs |
| `DoE.base` | Full factorials, orthogonal arrays, parameter designs |
| `rsm` | Central composite and Box-Behnken designs, steepest ascent |
| `lhs` | Latin hypercube designs |
| `AlgDesign` | D-optimal designs |

Nothing is reimplemented: the dialogs generate the same calls you would write
by hand, and the generated code can be copied into a script.

Some advanced entries of the original plug-in (response-surface optimisation
with desirability functions, certain catalogue operations) remain out of scope.

## See also

- `topic:doe-designs`
- `topic:doe-import-export`
- `topic:doe-analyse`
