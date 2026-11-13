# RcmdrShinyPlugin.TeachingDemos

Teaching demonstrations and distribution visualization.

Derived from `RcmdrPlugin.TeachingDemos`.

## Install

```r
remotes::install_github(
  "vigliafg/rstats-commander",
  subdir = "plugins/RcmdrShinyPlugin.TeachingDemos"
)
```

## Use

```r
RcmdrShiny::run(plugins = "RcmdrShinyPlugin.TeachingDemos")
```

## Features

central limit theorem, confidence intervals, power, coin/die, regression, correlation, distribution plots.

## Status

- [x] menus ported
- [x] Shiny dialogs ported
- [x] `R CMD check` clean
- [x] no Tk dependency
