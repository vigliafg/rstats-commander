# RcmdrShinyPlugin.sos

Search R help pages with the sos package.

Derived from `RcmdrPlugin.sos`.

## Install

```r
remotes::install_github(
  "vigliafg/rstats-commander",
  subdir = "plugins/RcmdrShinyPlugin.sos"
)
```

## Use

```r
RcmdrShiny::run(plugins = "RcmdrShinyPlugin.sos")
```

## Features

multi-term search, union/intersection, column filter, spreadsheet output.

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
