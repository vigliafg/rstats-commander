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

## Help

The package ships in-app help topics in `inst/help-topics/`.  They appear
in the **Help** tab once the plugin is loaded, and each dialog's **Help**
button opens its own topic.

## Status

- [x] menus ported
- [x] Shiny dialogs ported
- [x] `R CMD check` clean
- [x] no Tk dependency
