---
id: troubleshooting
title: Troubleshooting
type: concept
category: troubleshooting
keywords: [error, problem, not working, debug, messages, diagnostics]
aliases: [problems, errors, faq]
dialogs: []
commands: [diagnostics_report]
packages: [RcmdrShiny]
related: [keyboard-shortcuts, plugins]
language: en
status: documented
---

# Troubleshooting

## The menus are greyed out

Most commands need an active data set.  Import or select one first
(`topic:data-import`).  Model commands additionally need an active model, which
is created when a model dialog succeeds.

## A command produced an error

The error appears in the **Messages** tab and, for dialogs, in a modal with a
**Retry** button.  Read the message: it usually names the variable or the
argument that failed.  Common causes:

| Message | Cause |
|---|---|
| `object 'x' not found` | The variable or data set was renamed or removed |
| `contrasts can be applied only to factors with 2 or more levels` | A factor has one level; drop unused levels |
| `NA/NaN/Inf in 'y'` | Missing values in a model variable |
| `there are aliased coefficients in the model` | Collinear predictors |

## A plot does not appear

Plots are captured into the **Plots** tab.  If the tab is empty, check the
**Messages** tab: a graphics package may be missing, for example `rgl` for 3D
plots or `ggplot2` for KMggplot2.

## A plugin does not load

- Confirm the package is installed: `requireNamespace("RcmdrShinyPlugin.Export")`.
- Check the version: plugins require `RcmdrShiny (>= 1.1.0)`.
- Read the warnings printed at load time; they name skipped menu entries.
- EZR replaces the core menus by design, so load it alone if the layout looks
  unfamiliar.

## Capture a diagnostic report

**Help > Diagnostics** collects the R version, the RcmdrShiny version, the
loaded plugins and the recent messages.  Include it when reporting a problem.

```r
RcmdrShiny::diagnostics_report()
```

## Reset the session

```r
RcmdrShiny::unload_plugins()
```

and reload the app with a fresh R session if the state looks inconsistent.

## See also

- `topic:keyboard-shortcuts`
- `topic:plugins`
