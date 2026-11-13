# RcmdrShinyPlugin.UCA

Teaching statistics extensions from the University of Cadiz.

Derived from `RcmdrPlugin.UCA`.

## Install

```r
remotes::install_github(
  "vigliafg/rstats-commander",
  subdir = "plugins/RcmdrShinyPlugin.UCA"
)
```

## Use

```r
RcmdrShiny::run(plugins = "RcmdrShinyPlugin.UCA")
```

## Features

variance/randomness tests, predictions, Pareto charts, 21 quality-control charts.

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
