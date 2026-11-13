# Plugin Wave 1 — Quick wins

Reference plan: `~/.opencode/plan/rstats-commander-piano-plugin-2026-11-13.md`,
Wave 1.  Baseline: RcmdrShiny 1.2.0.

Date: 13 November 2026

## Plugins

| Plugin | Upstream | Menus | Commands | Dialogs | Tests | Check |
|---|---|---|---|---|---|---|
| `RcmdrShinyPlugin.Export` | RcmdrPlugin.Export 0.3-1 | 3 items | xtable, latex, format.df | 3 | 8 | OK |
| `RcmdrShinyPlugin.sos` | RcmdrPlugin.sos 0.3-0 | 1 item | findFn, grepFn, xls | 1 | 7 | OK |
| `RcmdrShinyPlugin.PcaRobust` | RcmdrPlugin.PcaRobust 1.1.4 | 1 item | PcaHubert + plots | 1 | 5 | OK |
| `RcmdrShinyPlugin.ROC` | RcmdrPlugin.ROC 1.0-19 | 5 items | pROC, roc.test, hoslem.test | 5 | 8 | OK |
| `RcmdrShinyPlugin.UCA` | RcmdrPlugin.UCA 5.1-4 | 30 items | sigma/runs/predict/qcc | 27 | 8 | OK |

## Core additions

- `popOutput()` and a bounded output-object stack compatible with Rcmdr's
  Export plugin.
- `get_dialog()` for plugin dialog tests.
- `glmP()` and `lmP()` activation predicates.
- Lazy attachment of `xtable`, `Hmisc`, `sos`, `rrcov`, `ResourceSelection`,
  `qcc`, `qicharts2`, `TeachingDemos`, `randtests` and `tseries`.
- Plot capture for `screeplot`, `biplot`, `qcc` and `paretochart`.
- Core version 1.2.0.

## Verification

```text
testthat::test_local()                          -> all core tests pass
R CMD check RcmdrShiny_1.2.0.tar.gz             -> Status: OK
R CMD check plugins/RcmdrShinyPlugin.*          -> Status: OK (5 packages)
app(plugins = c(...))                           -> loads all five plugins
Rscript tools/smoke_plugins.R                   -> 6 plugins, 307 menu leaves, OK
```

A combined menu tree has 307 leaves; the five plugins add 40 items and place
Export, ROC and Quality Control before Tools and Help.

## Deliberate adaptations

- Generated Export commands call `RcmdrShiny::popOutput()` instead of
  `popOutput()` so they also work when RcmdrShiny is loaded with `::`.
- PcaRobust uses `alpha=` (the upstream code contains the typo `aplha=`).
- Tk plot windows are replaced by base-graphics commands captured in the
  Plots pane; no `tkrplot` dependency.
- The sos filter sub-dialog is a section of the main dialog.
- UCA's `edit()` data-entry path is replaced by a Shiny predictor form.
- Quality-control charts use `qcc::qcc`, `qicharts2::paretochart`,
  `randtests::runs.test` and `tseries::runs.test` explicitly.

## Known limits

- Optional upstream packages are Suggests; dialogs are hidden by their install
  predicates when the package is absent.
- ROC dialogs expose the main pROC options but not every upstream bootstrap and
  density-control combination.
- UCA QC dialogs share one generic implementation; labels and defaults follow
  the upstream menu.
