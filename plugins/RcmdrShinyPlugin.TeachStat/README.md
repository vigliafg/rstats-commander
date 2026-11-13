# RcmdrShinyPlugin.TeachStat

Basic statistics teaching toolkit.

Derived from `RcmdrPlugin.TeachStat`.

## Install

```r
remotes::install_github(
  "vigliafg/rstats-commander",
  subdir = "plugins/RcmdrShinyPlugin.TeachStat"
)
```

## Use

```r
RcmdrShiny::run(plugins = "RcmdrShinyPlugin.TeachStat")
```

## Features

descriptive statistics, index numbers, distributions, confidence intervals, hypothesis tests.

## Status

- [x] menus ported
- [x] Shiny dialogs ported
- [x] `R CMD check` clean
- [x] no Tk dependency
