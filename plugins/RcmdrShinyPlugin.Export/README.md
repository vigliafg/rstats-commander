# RcmdrShinyPlugin.Export

Export the last printed R object to LaTeX or HTML with xtable or Hmisc.

Derived from `RcmdrPlugin.Export`.

## Install

```r
remotes::install_github(
  "vigliafg/rstats-commander",
  subdir = "plugins/RcmdrShinyPlugin.Export"
)
```

## Use

```r
RcmdrShiny::run(plugins = "RcmdrShinyPlugin.Export")
```

## Features

LaTeX/HTML export, Hmisc LaTeX export, format.df.

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
