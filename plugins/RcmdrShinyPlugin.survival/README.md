# RcmdrShinyPlugin.survival

Survival analysis for RcmdrShiny.

Derived from `RcmdrPlugin.survival`.

## Install

```r
remotes::install_github(
  "vigliafg/rstats-commander",
  subdir = "plugins/RcmdrShinyPlugin.survival"
)
```

## Use

```r
RcmdrShiny::run(plugins = "RcmdrShinyPlugin.survival")
```

## Features

survival functions, Cox and parametric models, PH tests, diagnostics, data preparation.

## Status

- [x] menus ported
- [x] Shiny dialogs ported
- [x] `R CMD check` clean
- [x] no Tk dependency
