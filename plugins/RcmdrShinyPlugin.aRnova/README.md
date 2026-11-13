# RcmdrShinyPlugin.aRnova

ANOVA extensions for RcmdrShiny.

Derived from `RcmdrPlugin.aRnova`.

## Install

```r
remotes::install_github(
  "vigliafg/rstats-commander",
  subdir = "plugins/RcmdrShinyPlugin.aRnova"
)
```

## Use

```r
RcmdrShiny::run(plugins = "RcmdrShinyPlugin.aRnova")
```

## Features

one-way, multi-way and repeated-measures ANOVA.

## Help

The package ships in-app help topics in `inst/help-topics/`.  They appear
in the **Help** tab once the plugin is loaded, and each dialog's **Help**
button opens its own topic.

## Status

- [x] menus ported
- [x] Shiny dialogs ported
- [x] `R CMD check` clean
- [x] no Tk dependency
