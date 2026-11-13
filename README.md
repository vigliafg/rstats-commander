# RcmdrShiny

[![R-CMD-check](https://github.com/vigliafg/rstats-commander/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/vigliafg/rstats-commander/actions/workflows/R-CMD-check.yaml)
[![Browser E2E](https://github.com/vigliafg/rstats-commander/actions/workflows/e2e.yaml/badge.svg)](https://github.com/vigliafg/rstats-commander/actions/workflows/e2e.yaml)

A local, browser-based version of the [R Commander](https://www.r-commander.com/)
(Rcmdr), rebuilt on [Shiny](https://shiny.posit.co/) and free of Tcl/Tk.

RcmdrShiny is a fork of the Rcmdr 2.15.0 engine: it keeps the R command
generation semantics of Rcmdr, so every action in the graphical interface
produces a reproducible command in the script log and in the output pane.

> **Status: 1.6 help infrastructure.** All user-facing Rcmdr dialogs are ported
> (138 of 142 inventory entries; the remaining four are internal Tk
> utilities). The package includes the Shiny shell, File/Data, Statistics,
> Graphs/Distributions, Models and Tools/Help menus, a searchable in-app help
> centre with Markdown topics and plugin help, the plugin-package
> protocol and helpers, accessibility landmarks, vignettes and release
> engineering. All 15 general-purpose plugins are ported and tested.

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
| Statistics: summaries, correlations, normality, tables | done |
| Statistics: t-tests, ANOVA (incl. repeated measures) | done |
| Statistics: variance, proportion and nonparametric tests | done |
| Statistics: PCA, factor analysis, reliability, clustering | done |
| Statistics: linear, GLM, multinomial, ordinal and mixed models | done |
| Graphs: base, RcmdrMisc, car and lattice dialogs | done |
| Distributions: quantiles, probabilities, plots and samples | done |
| 3D graphs with rgl and plot export/snapshot | done |
| Models: diagnostics, influence, hypotheses, model selection, effect plots | done |
| Tools and Help menus | done |
| Help tab: search, categories, topic pane, recent and contextual help | done |
| Markdown help topics for the core and every plugin | done |
| Help API: `help_search()`, `help_topic()`, `help_index()` and plugin registration | done |
| Help inventory and link checker in CI | done |
| Plugin API: menus, direct commands, Shiny dialogs | done |
| Plugin packages (`RcmdrShinyPlugin.*`), predicates, menu merge and tooling | done |
| Legacy Tk plugin detection and warning | done |
| Accessibility landmarks and keyboard pass | done |
| Vignettes, pkgdown and release checklist | done |
| Help authoring guide and diagnostic report | done |
| Remaining 4 internal utilities (no user-facing dialog) | backlog |
| Wave 1 plugins: Export, sos, PcaRobust, ROC, UCA | done |
| Wave 2 plugins: TeachingDemos, HH, KMggplot2, TeachStat | done |
| Wave 3 plugins: survival, aRnova, NMBU, DoE | done |
| Wave 4 plugins: FactoMineR, EZR | done |
| Plugin hardening and release preparation | done |

The inventory is regenerated from an Rcmdr source tree with:

```sh
Rscript tools/inventory_dialogs.R /path/to/Rcmdr
```

## Help and documentation

The **Help** tab is a small offline documentation browser: search, categories,
recent topics and a topic pane. Every dialog has a **Help** button that opens
its topic inside the dialog, with a link to the R reference and to the full
help centre.

Help topics are Markdown files with a YAML front matter, shipped in
`inst/help-topics/` and in each plugin's `inst/help-topics/`. The same API is available from
R:

```r
RcmdrShiny::help_search("logistic regression")
RcmdrShiny::help_topic("linear-model")
RcmdrShiny::help_index()
RcmdrShiny::help_catalog()
```

Plugins are discovered automatically, and can also register help explicitly:

```r
RcmdrShiny::RcmdrShiny.plugin(
  name = "RcmdrShinyPlugin.Example",
  dialogs = my_dialogs(),
  help = system.file("help", package = "RcmdrShinyPlugin.Example")
)
```

Rendering uses `commonmark` when installed and falls back to a plain `<pre>`
block otherwise, so the help works with no optional dependency. Topics can be
translated by adding `topics/<language>/<id>.md`; missing translations fall back
to English.

Tools:

```sh
Rscript tools/new_help_topic.R my-topic --title "My topic" --category statistics
Rscript tools/generate_help_topics.R --core
Rscript tools/inventory_help.R
Rscript tools/check_help_links.R --strict
```

`inventory_help.R` writes `inst/etc/help-inventory.csv` with one row per dialog
(`documented`, `draft`, `fallback` or `missing`) and the continuous integration
job fails when a dialog has neither a topic nor an Rd fallback.

`RcmdrShiny::format_diagnostics()` produces the report shown by
**Help > Diagnostics**, ready to paste into an issue.

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

## Plugins

A minimal plugin API allows adding Rcmdr-style menus, direct commands and
Shiny dialogs:

```r
RcmdrShiny::RcmdrShiny.plugin(
  name = "demo",
  menus = "etc/menus.txt",
  commands = list(hello = function(state) {
    RcmdrShiny::run_command(state, 'cat("Hello\n")')
  }),
  dialogs = list(demo = RcmdrShiny::plugin_dialog(
    "demo", "Demo",
    ui = function(state, memory) htmltools::tags$p("Hello"),
    on_ok = function(input, state) list(commands = "1 + 1")
  ))
)
```

Load a plugin before starting the app:

```r
RcmdrShiny::run(plugins = "path/to/plugin.R")
```

Package plugins follow the `RcmdrShinyPlugin.*` protocol and export
`rcmdrshiny_plugin()`:

```r
RcmdrShiny::run(plugins = c(
  "RcmdrShinyPlugin.Export",
  "RcmdrShinyPlugin.sos"
))
```

They live under `plugins/` in this repository and are distributed on GitHub;
see `plugins/README.md`.  `tools/new_plugin.R` creates a new package skeleton
and `tools/inventory_plugin.R` inventories an upstream plugin.

See `inst/examples/demo-plugin.R` and `inst/examples/demo-menus.txt` for a
script plugin.  Legacy Tk plugins are detected and disabled with a warning.

## License and attribution

RcmdrShiny is distributed under the GNU General Public License, version 2 or
later (GPL-2+).  It is derived from Rcmdr 2.15.0, Copyright (C) 2001-2026
John Fox, Milan Bouchet-Valat and contributors.  See `NOTICE` and `UPSTREAM.md`
for details.
