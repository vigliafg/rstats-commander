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

## Help

The package ships in-app help topics in `inst/help-topics/`.  They appear
in the **Help** tab once the plugin is loaded, and each dialog's **Help**
button opens its own topic.

## Status

- [x] menus ported
- [x] Shiny dialogs ported
- [x] `R CMD check` clean
- [x] no Tk dependency
