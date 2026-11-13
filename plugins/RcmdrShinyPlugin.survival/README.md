# RcmdrShinyPlugin.survival

Survival analysis for RcmdrShiny.

Derived from `RcmdrPlugin.survival`.

## Install

```r
remotes::install_github(
  "vigliafg/rstats-commander",
  subdir = "plugins/RcmdrShinyPlugin.survival"
)
```

## Use

```r
RcmdrShiny::run(plugins = "RcmdrShinyPlugin.survival")
```

## Features

survival functions, Cox and parametric models, PH tests, diagnostics, data preparation.

## Help

The package ships in-app help topics in `inst/help-topics/`.  They appear
in the **Help** tab once the plugin is loaded, and each dialog's **Help**
button opens its own topic.

## Status

- [x] menus ported
- [x] Shiny dialogs ported
- [x] `R CMD check` clean
- [x] no Tk dependency
