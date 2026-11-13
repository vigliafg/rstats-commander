# RcmdrShinyPlugin.DoE

Design of experiments for RcmdrShiny.

Derived from `RcmdrPlugin.DoE`.

## Install

```r
remotes::install_github(
  "vigliafg/rstats-commander",
  subdir = "plugins/RcmdrShinyPlugin.DoE"
)
```

## Use

```r
RcmdrShiny::run(plugins = "RcmdrShinyPlugin.DoE")
```

## Features

screening, factorial, orthogonal array, CCD, Box-Behnken, LHS and D-optimal designs.

## Status

- [x] menus ported
- [x] Shiny dialogs ported
- [x] `R CMD check` clean
- [x] no Tk dependency
