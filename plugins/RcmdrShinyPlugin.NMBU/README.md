# RcmdrShinyPlugin.NMBU

NMBU statistics extensions for RcmdrShiny.

Derived from `RcmdrPlugin.NMBU`.

## Install

```r
remotes::install_github(
  "vigliafg/rstats-commander",
  subdir = "plugins/RcmdrShinyPlugin.NMBU"
)
```

## Use

```r
RcmdrShiny::run(plugins = "RcmdrShinyPlugin.NMBU")
```

## Features

t/z tests, proportions, ANOVA, PLS, principal components, stepwise selection, diagnostics.

## Help

The package ships in-app help topics in `inst/help-topics/`.  They appear
in the **Help** tab once the plugin is loaded, and each dialog's **Help**
button opens its own topic.

## Status

- [x] menus ported
- [x] Shiny dialogs ported
- [x] `R CMD check` clean
- [x] no Tk dependency
