# Phase 2 — File and Data checklist

Reference plan: `~/.opencode/plan/rstats-commander-piano-implementazione.md`,
Phase 2.  Milestone: **v0.3 “Data”**.

Date: 13 November 2026

## Deliverables

| Area | Dialogs / actions | Status |
|---|---|---|
| Import | text/clipboard/URL, Excel, SPSS, Stata, SAS xport, SAS b7dat, Minitab | done |
| Data set management | new, select active, load RData/RDS, read package data, refresh, view | done |
| Variables | compute, delete, recode, numeric→factor, character→factor, bin, reorder factor, standardize, rename, contrasts | done |
| Active data set | export, filter missing, subset, set case names, sort, aggregate, drop levels, stack, remove rows, select rows, reshape long↔wide | done |
| Merge | merge rows/columns with `mergeRows()`/`merge()` | done |
| Save | export text, save `.RData`, workspace download, script/output/CSV downloads | done |
| Editor | `DT` view + `rhandsontable` editing with threshold | done |
| Tests | command builders, dialog validation, execution, UI rendering, server integration, browser E2E | done |

The Data menu inventory has 34 dialogs; all are in the registry. The porting
inventory now reports 37 ported dialogs overall.

## Verification

```text
testthat::test_local()                          -> all tests pass
R CMD check --no-manual RcmdrShiny_0.3.0.tar.gz  -> Status: OK
RCMDRSHINY_E2E=1 test_local(filter="shinytest2")-> 12 assertions pass
```

The browser test now also opens the Compute dialog and verifies that
`Dataset$z <- with(Dataset, y + x)` appears in the script.

The server integration test drives Compute, Subset Data Set and Aggregate
through the menu, and checks the resulting objects and active data set.

## Command parity

Builders are covered by golden tests for:

- `within()` blocks (compute, delete, recode, factor conversion, drop levels);
- `binVariable()`, `factor(... levels=...)`, `scale()`/`local()`;
- `write.table()`, `na.omit()`, `subset()`, `row.names()`, `names()`;
- `stack()`, `mergeRows()`/`merge()`, `aggregate()`, `order()`;
- `reshapeL2W()`/`reshapeW2L()`;
- `readXL()`, `readSPSS()`, `readStata()`, `readSAS()`, `read.mtp()`,
  `read.xport()`.

## Known limits (accepted for Phase 2)

- Complex Rcmdr sub-dialogs are simplified to single-screen forms:
  numeric-to-factor level names are supplied as a comma-separated list,
  recursive factor reordering uses a comma-separated order, and
  `setContrasts()` supports the four standard contrast types but not the
  custom contrast matrix editor.
- SAS xport files import the first data set only.
- Wide-to-long reshaping supports the one-within-factor design; the two-way
  design is deferred.
- Import paths can be typed or chosen with `shinyFiles`; browser upload is not
  used because generated commands must reference a real server-side path.
- `viewData` switches to the in-app Data tab instead of opening a separate
  Tk data window.

## Decision

**GO to Phase 3 (Statistics).**
