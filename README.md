# RcmdrShiny

A local, browser-based version of the [R Commander](https://www.r-commander.com/)
(Rcmdr), rebuilt on [Shiny](https://shiny.posit.co/) and free of Tcl/Tk.

RcmdrShiny is a fork of the Rcmdr 2.15.0 engine: it keeps the R command
generation semantics of Rcmdr, so every action in the graphical interface
produces a reproducible command in the script log and in the output pane.

> **Status: Phase 0 (vertical slice).** The application runs, the menu is
> generated from Rcmdr's own `Rcmdr-menus.txt`, and three dialogs are ported
> end to end: *Read Text Data*, *Numerical Summaries* and *Linear Model*.
> The remaining dialogs are listed in
> [`inst/etc/dialogs-inventory.csv`](inst/etc/dialogs-inventory.csv) and are
> disabled in the sidebar with an "In porting" tooltip.

## Requirements

- R >= 4.1
- A modern browser
- Packages: `shiny`, `bslib`, `DT`, `shinyAce`, `shinyFiles`, `RcmdrMisc`
  (plus their dependencies)

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

## What works in Phase 0

| Area | Status |
|---|---|
| Menu sidebar generated from `Rcmdr-menus.txt` | done |
| Command runner (`run_command`) with output, messages, warnings and errors | done |
| Script pane (Ace), run selection / run all | done |
| Output and Messages panes | done |
| Data view (`DT`) and environment view | done |
| Plot capture, history and preview | done (single last plot) |
| Dialog runtime (modal, reset, memory, validation) | done |
| Read Text Data (file, clipboard, URL) | done |
| Numerical Summaries (statistics, groups, counts) | done |
| Linear Model (formula, subset, weights, row removal) | done |
| Remaining 139 dialog functions | backlog |
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
