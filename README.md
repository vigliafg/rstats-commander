# RcmdrShiny

A local, browser-based version of the [R Commander](https://www.r-commander.com/)
(Rcmdr), rebuilt on [Shiny](https://shiny.posit.co/) and free of Tcl/Tk.

RcmdrShiny is a fork of the Rcmdr 2.15.0 engine: it keeps the R command
generation semantics of Rcmdr, so every action in the graphical interface
produces a reproducible command in the script log and in the output pane.

> **Status: Phase 2 (File and Data).** The application has a complete File/Data
> workflow: imports (text, Excel, SPSS, Stata, SAS, Minitab), compute, recode,
> factor conversions, binning, standardization, missing-data filtering,
> subsetting, case names, rename, contrasts, stack, remove/select rows, merge,
> aggregate, drop levels, sort, reshape and export. The complete shell from
> Phase 1 (menu activation, dialog runtime, data editor, plot history, rgl,
> options and help) remains in place. Thirty-seven Rcmdr dialogs are ported;
> the remaining ones are listed in
> [`inst/etc/dialogs-inventory.csv`](inst/etc/dialogs-inventory.csv) and are
> disabled with an "In porting" tooltip.

## Requirements

- R >= 4.1
- A modern browser
- Packages: `shiny`, `bslib`, `DT`, `shinyAce`, `shinyFiles`,
  `rhandsontable`, `RcmdrMisc` (plus their dependencies)
- Optional: `rgl` for the 3D plot pane

## Install

```r
# from a local clone
install.packages(".", repos = NULL, type = "source")

# development dependencies
install.packages(c("testthat", "shinytest2", "pkgdown"))
```

## Run

```r
RcmdrShiny::run()
```

This starts a local Shiny application and opens it in the browser.  Commands
are evaluated in `.GlobalEnv`, mirroring Rcmdr's single-user desktop model.
Pass a different environment for tests or embedding:

```r
env <- new.env()
RcmdrShiny::run(env = env)
```

## What works

| Area | Status |
|---|---|
| Menu sidebar generated from `Rcmdr-menus.txt` | done |
| Reactive activation from Rcmdr predicates (`numericP()`, `modelCapability()`, ...) | done |
| Command runner (`run_command`) with output, messages, warnings and errors | done |
| Script pane (Ace), run selection / run all, open and download `.R` | done |
| Output and Messages panes (clear, download) | done |
| Data view (`DT`) and interactive editor (`rhandsontable`, 10,000-cell threshold) | done |
| Plot capture, history gallery, PNG/PDF export | done |
| rgl 3D scene rendered with `rglwidget()` | done |
| Dialog runtime (tabs, OK/Apply/Reset/Cancel/Help, memory, validation, retry) | done |
| Read Text Data (file, clipboard, URL) | done |
| Numerical Summaries (statistics, groups, counts) | done |
| Linear Model (formula builder, subset, weights, row removal) | done |
| Options, Setwd, Load Data Set, Open Script File | done |
| Environment view, workspace download, dark mode, language selector | done |
| File/Data: imports (text/Excel/SPSS/Stata/SAS/Minitab) | done |
| Data: compute, recode, factors, binning, standardize | done |
| Data: missing values, subset, case names, rename, contrasts, stack | done |
| Data: remove/select rows, merge, aggregate, drop levels, sort, reshape | done |
| Data: export, save `.RData`, workspace, editor | done |
| Remaining 105 dialog functions | backlog |
| Plugin API, full i18n coverage, CRAN hardening | later phases |

The inventory is regenerated from an Rcmdr source tree with:

```sh
Rscript tools/inventory_dialogs.R /path/to/Rcmdr
```

## Test

```r
testthat::test_local()
```

The browser end-to-end test is opt-in:

```sh
RCMDRSHINY_E2E=1 Rscript -e 'testthat::test_local(filter = "shinytest2")'
```

It drives the full flow in headless Chrome: import a CSV, compute numerical
summaries, fit a linear model, and verify the generated script and output.

## Architecture

| File | Responsibility |
|---|---|
| `R/app.R` | Shiny UI, server, menu wiring, panes and status bar |
| `R/state.R` | `AppState`: environment, active data set/model, logs, memory |
| `R/commands.R` | `run_command()`: evaluation, capture, plot capture |
| `R/menus.R` | Parser for `Rcmdr-menus.txt` and sidebar renderer |
| `R/dialogs.R` | Dialog runtime and implementation registry |
| `R/widgets.R` | Shiny equivalents of Rcmdr widgets |
| `R/command-builders.R` | Pure functions that generate Rcmdr-compatible commands |
| `R/dialogs-*.R` | Dialog specifications and validation |
| `R/i18n.R` | gettext helpers and language discovery |
| `inst/etc/Rcmdr-menus.txt` | Menu source of truth, copied from Rcmdr |
| `inst/po/` | Rcmdr translation catalogues |

Adding a dialog means:

1. write a `dialog_spec()` with `ui`, `on_ok` and optional `observers`;
2. keep command generation in a pure function and test it;
3. register the dialog in `dialog_catalog()`;
4. add the dialog to the inventory status list in
   `tools/inventory_dialogs.R`;
5. add unit and integration tests.

## License and attribution

RcmdrShiny is distributed under the GNU General Public License, version 2 or
later (GPL-2+).  It is derived from Rcmdr 2.15.0, Copyright (C) 2001-2026
John Fox, Milan Bouchet-Valat and contributors.  See `NOTICE` and `UPSTREAM.md`
for details.
