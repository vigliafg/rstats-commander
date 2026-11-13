# RcmdrShiny 0.2.0

## Phase 1 — shell and infrastructure

- Reactive menu activation and installation expressions evaluated from
  `Rcmdr-menus.txt` (Rcmdr predicates and model-capability table).
- Dialog runtime: OK, Apply, Reset, Cancel, Help, per-dialog memory,
  command-error notification with Retry, busy state.
- Full widget library: variable selector, checkbox groups, radio buttons,
  text/numeric/slider/combo inputs, file and directory choosers, subset entry,
  model-formula builder.
- Data pane: `DT` view plus `rhandsontable` editing with a configurable cell
  threshold and Apply-changes workflow.
- Plot pipeline: history gallery, thumbnail selection, PNG and PDF export.
- rgl integration: 3D scenes captured with `rgl.useNULL()` and rendered with
  `rglwidget()`.
- File utilities: `Setwd`, `Load Data Set` (RData/RDS), `Open Script File`,
  script/output/dataset/workspace downloads.
- Options dialog (digits, width, editing threshold, stringsAsFactors).
- Help menu: about, quick help, R help system and dataset help.
- Top bar: dataset/model badges, language selector, dark-mode toggle.
- Tests for activation predicates, widgets, options, data editing, plot
  history/export, rgl and workspace loading; browser test extended with plot,
  data editor, options and about flows.
- Version bumped to 0.2.0 (milestone "Shell").

# RcmdrShiny 0.1.0

## Phase 0 — vertical slice

- Package skeleton, GPL-2+ licensing and attribution notice.
- Shiny shell: top bar, menu sidebar, Script/Output/Messages/Plots/Data/
  Environment tabs, status bar.
- Menu sidebar generated from Rcmdr 2.15.0's `Rcmdr-menus.txt`; commands not
  yet ported are disabled with an "In porting" tooltip.
- `AppState` with active data set, active model, command log, output,
  messages, dialog memory and plot history.
- `run_command()` with capture of output, messages, warnings and errors,
  automatic active-object detection, and PNG plot capture.
- Dialog runtime with modal UI, validation, reset and per-dialog memory.
- Ported dialogs: *Read Text Data*, *Numerical Summaries*, *Linear Model*.
- Direct command *Summarize active data set*.
- `DT` data view, environment view and plot preview.
- Unit, golden-command and server integration tests; opt-in shinytest2
  browser end-to-end test.
- `tools/inventory_dialogs.R` generates the official backlog
  (`inst/etc/dialogs-inventory.csv`) from an Rcmdr source tree.
