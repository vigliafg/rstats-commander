# RcmdrShinyPlugin.aRnova

ANOVA extensions for RcmdrShiny.

Derived from `RcmdrPlugin.aRnova`.

## Install

```r
remotes::install_github(
  "vigliafg/rstats-commander",
  subdir = "plugins/RcmdrShinyPlugin.aRnova"
)
```

## Use

```r
RcmdrShiny::run(plugins = "RcmdrShinyPlugin.aRnova")
```

## Features

one-way, multi-way and repeated-measures ANOVA.

## Status

- [x] menus ported
- [x] Shiny dialogs ported
- [x] `R CMD check` clean
- [x] no Tk dependency
