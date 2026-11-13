# Phase 0 — go/no-go checklist

Reference plan: `~/.opencode/plan/rstats-commander-piano-implementazione.md`,
Phase 0 (P0.1–P0.7).

Date: 13 November 2026

## Deliverables

| ID | Item | Evidence | Status |
|---|---|---|---|
| P0.1 | Repo, package skeleton, DESCRIPTION, license, CI | `DESCRIPTION`, `NAMESPACE`, `LICENSE`, `NOTICE`, `.github/workflows/R-CMD-check.yaml` | done |
| P0.2 | Engine extraction: state, commands, menus, i18n; no Tcl/Tk | `R/state.R`, `R/commands.R`, `R/menus.R`, `R/i18n.R`; no `tcltk` in `DESCRIPTION` | done |
| P0.3 | `run_command()` with output/messages/warnings/errors | `R/commands.R`; `tests/testthat/test-commands.R` | done |
| P0.4 | Dialog runtime + variable/checkbox widgets | `R/dialogs.R`, `R/widgets.R`, `tests/testthat/test-dialogs.R` | done |
| P0.5 | Three dialogs: Read Text Data, Numerical Summaries, Linear Model | `R/dialogs-import-text.R`, `R/dialogs-summaries.R`, `R/dialogs-models.R` | done |
| P0.6 | DT view, plot capture, Output/Messages panes | `R/app.R`; plot test in `test-commands.R` | done |
| P0.7 | shinytest2 end-to-end flow + go/no-go | `tests/testthat/test-shinytest2.R`; `tests/testthat/test-app-integration.R` | done |

## Acceptance evidence

```text
testthat::test_local()                         -> all tests pass
R CMD check --no-manual RcmdrShiny_0.1.0.tar.gz -> Status: OK
RCMDRSHINY_E2E=1 test_local(filter="shinytest2") -> 8 assertions pass
```

The browser test drives, in headless Chrome:

1. click *Data > Import data > from text file, clipboard, or URL...*;
2. import a CSV through the dialog;
3. click *Statistics > Summaries > Numerical summaries...*;
4. select two variables, run, and read the result from the Output tab;
5. click *Statistics > Fit models > Linear model...*;
6. fit `y ~ x`, check the model badge and summary;
7. inspect the generated script, which contains both `numSummary(...)` and
   `LinearModel.1 <- lm(...)`.

## Command parity

The generated commands are byte-for-byte compatible with the corresponding
Rcmdr 2.15.0 dialogs for the tested configurations:

- `read.table(...)` with header/stringsAsFactors/sep/na.strings/dec/strip.white;
- `numSummary(...)` with statistics order, quantiles, type, groups and
  `binnedCounts`/`discreteCounts`;
- `lm(...)` + `summary(...)` with subset/weights/row removal.

## Porting cost check

Phase 0 ported three representative dialogs (import, summaries, linear model)
including command builders, validation, memory, layout, tests and the browser
flow.  The work stayed well below the plan's 2-day-per-dialog threshold, so no
DSL/shim revision is needed.

## Decision

**GO.**

Proceed to Phase 1 (shell and infrastructure) with the current architecture:

- keep the pure command builders as the parity contract;
- keep `Rcmdr-menus.txt` as the menu source of truth;
- keep `run_command()` as the single evaluation path;
- add dialogs incrementally, updating the inventory each time.

## Known limits (accepted for Phase 0)

- Only the last plot is shown; history thumbnails and export are Phase 4.
- Data editing uses `DT` view only; `rhandsontable` editing is Phase 1.
- Language catalogues are shipped but need `msgfmt` at install time to be
  compiled into `.mo` files (standard on CRAN and CI).
- Help buttons are not wired to R documentation yet (Phase 5).
- Browser test is opt-in so that `R CMD check` does not require Chrome.
