# Contributing to RcmdrShiny

## Ground rules

- RcmdrShiny is GPL-2+; contributions are accepted under the same license.
- Every user action must produce a visible, reproducible R command.
- No Tcl/Tk dependency, directly or indirectly.
- Keep the generated command identical (or semantically equivalent) to Rcmdr.

## Porting a dialog

1. Pick a row from `inst/etc/dialogs-inventory.csv`.
2. Read the original Rcmdr dialog and identify: widgets, validation, command
   generation, dialog memory and help topic.
3. Put command generation in a pure function in `R/command-builders.R`.
4. Implement a `dialog_spec()` in the appropriate `R/dialogs-*.R` file.
5. Register it in `dialog_catalog()`.
6. Mark it `ported` in `tools/inventory_dialogs.R`.
7. Add:
   - a unit test for the generated command;
   - a validation test;
   - a server integration test in `tests/testthat/test-app-integration.R`;
   - an entry in the browser test when the flow is user-facing.
8. Run `testthat::test_local()`.

## Definition of Done for a dialog

- [ ] UI covers the original fields, tabs and conditional options.
- [ ] Validation and error messages are equivalent.
- [ ] The generated R command matches Rcmdr (golden test).
- [ ] Dialog memory works across invocations.
- [ ] Strings go through `tr()` and are translatable.
- [ ] No Tk calls.
- [ ] Unit, integration and (where relevant) browser tests pass.
- [ ] The inventory is updated.

## Style

- Base R and Shiny, no tidyverse in the package code.
- Prefer explicit `package::function()` calls.
- Keep command builders free of Shiny so they can be tested directly.
- Document exported functions with Rd files (roxygen2 output will replace the
  manual NAMESPACE once the API stabilises).
