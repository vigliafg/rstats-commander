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

## Help

The package ships in-app help topics in `inst/help-topics/`.  They appear
in the **Help** tab once the plugin is loaded, and each dialog's **Help**
button opens its own topic.

## Status

- [x] menus ported
- [x] Shiny dialogs ported
- [x] `R CMD check` clean
- [x] no Tk dependency
