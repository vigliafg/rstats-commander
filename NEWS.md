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
