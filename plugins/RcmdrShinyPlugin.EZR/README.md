# RcmdrShinyPlugin.EZR

Core EZR statistical workflow for RcmdrShiny.

Derived from `RcmdrPlugin.EZR`.

## Install

```r
remotes::install_github(
  "vigliafg/rstats-commander",
  subdir = "plugins/RcmdrShinyPlugin.EZR"
)
```

## Use

```r
RcmdrShiny::run(plugins = "RcmdrShinyPlugin.EZR")
```

## Features

data preparation, descriptive statistics, t and proportion tests, ANOVA, regression, nonparametric tests, survival, diagnostic accuracy and graphics.

## Status

- [x] menus ported
- [x] Shiny dialogs ported
- [x] `R CMD check` clean
- [x] no Tk dependency

## Limits

The most specialised EZR entries (meta-analysis, matched-pair analysis,
sample-size calculators and advanced survival models) are not implemented and
remain disabled in the menu.
