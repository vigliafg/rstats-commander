# RcmdrShinyPlugin.KMggplot2

ggplot2 graphics for RcmdrShiny.

Derived from `RcmdrPlugin.KMggplot2`.

## Install

```r
remotes::install_github(
  "vigliafg/rstats-commander",
  subdir = "plugins/RcmdrShinyPlugin.KMggplot2"
)
```

## Use

```r
RcmdrShiny::run(plugins = "RcmdrShinyPlugin.KMggplot2")
```

## Features

histograms, Q-Q, box/violin/CI, scatter, line, pie/bar, contour, KM, distribution plots.

## Help

The package ships in-app help topics in `inst/help-topics/`.  They appear
in the **Help** tab once the plugin is loaded, and each dialog's **Help**
button opens its own topic.

## Status

- [x] menus ported
- [x] Shiny dialogs ported
- [x] `R CMD check` clean
- [x] no Tk dependency
