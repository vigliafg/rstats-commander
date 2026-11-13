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

## Status

- [x] menus ported
- [x] commands ported
- [x] Shiny dialogs ported
- [x] `R CMD check` clean
- [x] no Tk dependency
