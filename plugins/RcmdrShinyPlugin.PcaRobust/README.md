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

## Help

The package ships in-app help topics in `inst/help-topics/`.  They appear
in the **Help** tab once the plugin is loaded, and each dialog's **Help**
button opens its own topic.

## Status

- [x] menus ported
- [x] commands ported
- [x] Shiny dialogs ported
- [x] `R CMD check` clean
- [x] no Tk dependency
