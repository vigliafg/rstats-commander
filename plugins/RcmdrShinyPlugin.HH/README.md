# RcmdrShinyPlugin.HH

HH graphics and tests for RcmdrShiny.

Derived from `RcmdrPlugin.HH`.

## Install

```r
remotes::install_github(
  "vigliafg/rstats-commander",
  subdir = "plugins/RcmdrShinyPlugin.HH"
)
```

## Use

```r
RcmdrShiny::run(plugins = "RcmdrShinyPlugin.HH")
```

## Features

two-way tables, best subsets, CI plots, lattice plots, Likert, ANOVA, hypothesis plots, MMC.

## Status

- [x] menus ported
- [x] Shiny dialogs ported
- [x] `R CMD check` clean
- [x] no Tk dependency
