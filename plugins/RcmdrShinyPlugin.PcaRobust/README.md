# RcmdrShinyPlugin.PcaRobust

Robust principal component analysis with ROBPCA.

Derived from `RcmdrPlugin.PcaRobust`.

## Install

```r
remotes::install_github(
  "vigliafg/rstats-commander",
  subdir = "plugins/RcmdrShinyPlugin.PcaRobust"
)
```

## Use

```r
RcmdrShiny::run(plugins = "RcmdrShinyPlugin.PcaRobust")
```

## Features

loadings, scores, scree/biplot/OD/SD/diagnostic plots.

## Status

- [x] menus ported
- [x] commands ported
- [x] Shiny dialogs ported
- [x] `R CMD check` clean
- [x] no Tk dependency
