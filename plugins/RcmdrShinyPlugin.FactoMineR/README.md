# RcmdrShinyPlugin.FactoMineR

FactoMineR multivariate analysis for RcmdrShiny.

Derived from `RcmdrPlugin.FactoMineR`.

## Install

```r
remotes::install_github(
  "vigliafg/rstats-commander",
  subdir = "plugins/RcmdrShinyPlugin.FactoMineR"
)
```

## Use

```r
RcmdrShiny::run(plugins = "RcmdrShinyPlugin.FactoMineR")
```

## Features

PCA, CA, MCA, MFA, DMFA, FAMD, HCPC, GPA and category description.

## Status

- [x] menus ported
- [x] Shiny dialogs ported
- [x] `R CMD check` clean
- [x] no Tk dependency
