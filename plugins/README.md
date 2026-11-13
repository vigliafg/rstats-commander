# RcmdrShiny plugins

This directory is a monorepo of RcmdrShiny plugin packages.  Each plugin is an
independent R package named `RcmdrShinyPlugin.<Name>`; the core package remains
`RcmdrShiny` in the repository root.

Distribution is GitHub-only.  There is no CRAN submission for the plugins.

## Install and use

```r
remotes::install_github(
  "vigliafg/rstats-commander",
  subdir = "plugins/RcmdrShinyPlugin.Export"
)

RcmdrShiny::run(plugins = "RcmdrShinyPlugin.Export")
```

Several plugins can be loaded together:

```r
RcmdrShiny::run(plugins = c(
  "RcmdrShinyPlugin.Export",
  "RcmdrShinyPlugin.sos"
))
```

## Status

| Plugin | Wave | Status |
|---|---|---|
| RcmdrShinyPlugin.Export | 1 | done |
| RcmdrShinyPlugin.sos | 1 | done |
| RcmdrShinyPlugin.PcaRobust | 1 | done |
| RcmdrShinyPlugin.ROC | 1 | done |
| RcmdrShinyPlugin.UCA | 1 | done |
| RcmdrShinyPlugin.TeachingDemos | 2 | done |
| RcmdrShinyPlugin.HH | 2 | done |
| RcmdrShinyPlugin.KMggplot2 | 2 | done |
| RcmdrShinyPlugin.TeachStat | 2 | done |
| RcmdrShinyPlugin.survival | 3 | done |
| RcmdrShinyPlugin.aRnova | 3 | done |
| RcmdrShinyPlugin.NMBU | 3 | done |
| RcmdrShinyPlugin.DoE | 3 | done |
| RcmdrShinyPlugin.FactoMineR | 4 | done |
| RcmdrShinyPlugin.EZR | 4 | done (core workflow) |

## Create a plugin skeleton

```bash
Rscript tools/new_plugin.R Export --title "Export R output" \
  --upstream RcmdrPlugin.Export
```

## Inventory an upstream plugin

```bash
Rscript tools/inventory_plugin.R /path/to/RcmdrPlugin.Export
```

The inventory lists every menu entry, the R function behind it, whether the
function uses Tk, and whether it generates R commands.  Use it to plan the
porting of each dialog.

## Package contract

Every plugin package:

- depends on `RcmdrShiny (>= 1.1.0)`;
- exports `rcmdrshiny_plugin()`;
- stores its menu file at `inst/etc/rcmdrshiny-menus.txt`;
- does not import `tcltk` or `tcltk2`;
- passes `R CMD check` with its optional dependencies absent.

## CI

`.github/workflows/plugins.yaml` discovers every `plugins/RcmdrShinyPlugin.*`
directory and runs a separate check job for each one.  Plugins are checked only
when their own files or the core package change.
