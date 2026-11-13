# RcmdrShinyPlugin.HH

HH graphics and tests for RcmdrShiny.

Derived from `RcmdrPlugin.HH`.

## Install

```r
remotes::install_github(
  "vigliafg/rstats-commander",
  subdir = "plugins/RcmdrShinyPlugin.HH"
)
```

## Use

```r
RcmdrShiny::run(plugins = "RcmdrShinyPlugin.HH")
```

## Features

two-way tables, best subsets, CI plots, lattice plots, Likert, ANOVA, hypothesis plots, MMC.

## Help

The package ships in-app help topics in `inst/help-topics/`.  They appear
in the **Help** tab once the plugin is loaded, and each dialog's **Help**
button opens its own topic.

## Status

- [x] menus ported
- [x] Shiny dialogs ported
- [x] `R CMD check` clean
- [x] no Tk dependency
