# Residual features — implementation checklist (F1–F12)

Reference plan: `~/.opencode/plan/rstats-commander-piano-feature-residue-2026-11-13.md`.
Baseline: RcmdrShiny 1.6.0.  Delivered: RcmdrShiny 1.12.0.

Date: 13 November 2026

## Waves

| Wave | Scope | Status |
|---|---|---|
| F1 | Gumbel, `convertStrings2Factors`, EZR/NMBU aliases | done |
| F2 | EZR sample size and power (17 entries) | done |
| F3 | EZR data, variables, import/export (11 entries) | done |
| F4 | EZR graphs and tables (10 new entries) | done |
| F5 | EZR tests and diagnostic accuracy (14 entries) | done |
| F6 | EZR survival, matched pairs, meta-analysis (14 entries) | done |
| F7 | NMBU completion (29 remaining entries) | done |
| F8 | DoE completion: import/export, inspection, 16 Info entries | done |
| F9 | Interactive plots with plotly (4 dialogs) | done |
| F10 | R Markdown/HTML report export | done |
| F11 | Help debt, Italian translations, screenshots | done |
| F12 | Browser flows for five plugin families | done |

## Delivered by wave

### F1

- Gumbel dialogs: `GumbelQuantiles`, `GumbelProbabilities`,
  `GumbelDistributionPlot`, `GumbelDistributionSamples`, built on `VGAM`.
- `convertStrings2Factors` direct command.
- Alias registry: `RcmdrShiny.plugin(aliases = )`, resolution in `get_dialog()`
  and `direct_commands()`, alias ids preserved for memory and help.
- 41 EZR aliases and 21 NMBU aliases, documented in `PLUGIN-ALIAS-MAP.md`.

### F2

- `R/sample-size.R` in EZR: one pure builder, nine statistical questions, 17
  menu entries.  `pwr` and `clinfun` are optional with install predicates.

### F3

- `R/data-tools.R`: CP932 import, copy, rename, merge, workspace load, renewal,
  Stata export, threshold binning, log transform, numeric conversion.

### F4

- `R/graphs-tools.R`: violin, ordered chart, swimmer, Sankey, CONSORT, adjusted
  survival, adjusted/stacked cumulative incidence, graph settings, summary.

### F5

- `R/tests-tools.R`: 14 tests and accuracy measures.

### F6

- `R/survival-tools.R`: 14 survival, matched-pair and meta-analysis entries.

### F7

- `R/extras.R` in NMBU: 29 data, test, model-diagnostic and graph entries.

### F8

- `R/extras.R` in DoE: 17 dialogs plus 16 Info commands that open the guide.

### F9

- `R/plotly.R`, `interactive` results, `plotly_pane` output.
- Base graphics still run, so the gallery and export are unchanged.

### F10

- `R/report.R`: `report_rmd()`, `write_report_rmd()`, `write_report_html()`.
- **File > Export report...** with format choice.

### F11

- `tools/promote_help_topics.R`: 408 generated topics promoted after
  validation.
- 21 Italian translations for core topics.
- `tools/help_screenshots.R`: six screenshots, used by eight vignettes.

### F12

- `tests/testthat/test-plugins-e2e.R`: HH, survival, FactoMineR, ROC and
  TeachingDemos browser flows.

## Menu coverage

| Metric | 1.6.0 | 1.12.0 |
|---|---|---|
| Core dialogs | 200 | 205 |
| Dialogs with all plugins | 558 | 619 |
| Menu entries with all plugins | 900 | 900 |
| Implemented entries | 715 | 850 |
| Disabled entries | 185 | 50 |
| Dialogs with a documented topic | 63 | 619 |
| Help topics | 134 | 442 |
| Draft dialog topics | 443 | 0 |
| Italian topics | 3 | 21 |

The 50 disabled entries correspond to 38 distinct commands: 24 core entries
out of scope by design (R Markdown/knitr editor, close/restart commander,
cut/copy/paste/undo/find, `Identify3D`), 2 EZR close/exit duplicates and 13
TeachStat generic-distribution helpers that the plan keeps outside the
perimeter.

## Verification

```text
testthat::test_local()                          -> green
R CMD check RcmdrShiny_1.12.0.tar.gz            -> Status: OK
R CMD check each of 15 plugins                  -> Status: OK
Rscript tools/inventory_help.R --plugins all    -> 0 missing, 0 draft
Rscript tools/check_help_links.R --strict       -> no broken links
RCMDRSHINY_E2E=1 test_local(filter="plugins-e2e") -> 5 flows green
RCMDRSHINY_E2E=1 test_local(filter="shinytest2")  -> core flow green
```

## Notes

- EZR, NMBU and DoE now implement every plugin-specific menu entry.  The only
  disabled entries they still show are the core entries that are out of scope.
- Optional packages (`pwr`, `clinfun`, `meta`, `netmeta`, `MatchIt`, `timeROC`,
  `psych`, `plotly`, `vioplot`, `ggalluvial`, `cmprsk`) are in `Suggests` and
  gate their menu entries with `packageAvailable()`.
- The report exports only what the session already produced; commands are
  included with `eval = FALSE`.
