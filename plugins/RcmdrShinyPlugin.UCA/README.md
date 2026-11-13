# RcmdrShinyPlugin.UCA

Teaching statistics extensions from the University of Cadiz.

Derived from `RcmdrPlugin.UCA`.

## Install

```r
remotes::install_github(
  "vigliafg/rstats-commander",
  subdir = "plugins/RcmdrShinyPlugin.UCA"
)
```

## Use

```r
RcmdrShiny::run(plugins = "RcmdrShinyPlugin.UCA")
```

## Features

variance/randomness tests, predictions, Pareto charts, 21 quality-control charts.

## Status

- [x] menus ported
- [x] commands ported
- [x] Shiny dialogs ported
- [x] `R CMD check` clean
- [x] no Tk dependency
