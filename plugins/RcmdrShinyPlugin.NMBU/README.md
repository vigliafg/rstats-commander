# RcmdrShinyPlugin.NMBU

NMBU statistics extensions for RcmdrShiny.

Derived from `RcmdrPlugin.NMBU`.

## Install

```r
remotes::install_github(
  "vigliafg/rstats-commander",
  subdir = "plugins/RcmdrShinyPlugin.NMBU"
)
```

## Use

```r
RcmdrShiny::run(plugins = "RcmdrShinyPlugin.NMBU")
```

## Features

t/z tests, proportions, ANOVA, PLS, principal components, stepwise selection, diagnostics.

## Status

- [x] menus ported
- [x] Shiny dialogs ported
- [x] `R CMD check` clean
- [x] no Tk dependency
