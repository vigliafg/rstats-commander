# RcmdrShinyPlugin.ROC

ROC curves and Hosmer-Lemeshow goodness-of-fit tests.

Derived from `RcmdrPlugin.ROC`.

## Install

```r
remotes::install_github(
  "vigliafg/rstats-commander",
  subdir = "plugins/RcmdrShinyPlugin.ROC"
)
```

## Use

```r
RcmdrShiny::run(plugins = "RcmdrShinyPlugin.ROC")
```

## Features

single, paired and unpaired ROC curves, logistic-model ROC, HL test.

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
