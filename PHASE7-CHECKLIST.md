# Phase 7 — Hardening, documentation and release checklist

Reference plan: `~/.opencode/plan/rstats-commander-piano-implementazione.md`,
Phase 7.  Milestone: **v1.0.0**.

Date: 13 November 2026

## Deliverables

| ID | Item | Evidence | Status |
|---|---|---|---|
| P7.1 | Complete test suite: unit, golden, integration, E2E, opt-in visual | `tests/testthat/*`, `test-shinytest2.R`, `test-hardening.R` | done |
| P7.2 | Performance: large datasets, rendering, memory | server-side `DT` above threshold; bounded output buffers; plot-history cap with file cleanup | done |
| P7.3 | Accessibility: keyboard, contrast, ARIA, fonts | skip link, banner/navigation/main/status landmarks, `aria-live`, `aria-label`, focus-visible CSS, alt text | done |
| P7.4 | Browser and OS compatibility | CI matrix Linux/Windows/macOS; browser E2E workflow | done |
| P7.5 | Documentation: pkgdown, Getting Started, Migrating, Plugins | `vignettes/`, `_pkgdown.yml`, README | done |
| P7.6 | Packaging: launcher, `.desktop`, optional Tauri/Electron | `inst/desktop/rcmdrshiny.desktop`; `run()` launcher | done |
| P7.7 | CRAN preparation: check, examples, size, policy | `R CMD check` clean; `cran-comments.md`; `CITATION`; attribution | done |
| P7.8 | Release 1.0: GitHub release, CRAN submission | `RELEASE-CHECKLIST.md`; tarball built; remaining external submission steps | prepared |

## Verification

```text
testthat::test_local()                          -> all tests pass
R CMD check --no-manual RcmdrShiny_1.0.0.tar.gz  -> Status: OK
R CMD check --as-cran (informational)            -> only "new submission" and
                                                    unavailable suggested
                                                    packages notes
RCMDRSHINY_E2E=1 test_local(filter="shinytest2")-> 13 assertions pass
```

Vignettes build successfully with `knitr`/`rmarkdown`.

## Hardening details

- `state$options$max_output_lines` bounds output/messages (default 20,000).
- `state$options$max_plots` bounds the plot history (default 50) and deletes
  old files.
- `state$options$dt_server_threshold` switches `DT` to server-side rendering.
- Menu evaluation results are cached per state; plugin registration
  invalidates the implemented-command cache.

## Known limits (accepted for 1.0)

- Four upstream Tk utilities (`setupGUI`, `compileRmd`, `RcmdrEditor`,
  `RcmdrTkmessageBox`) are internal and not exposed in the menu.
- Gumbel distribution, `identify()`/`locator()`, live R Markdown generation
  and legacy Tk plugins remain out of scope.
- The `--as-cran` incoming-feasibility note is the standard new-submission
  note; `aplpack`, `TeachingDemos` and `sem` are optional Suggests.
- CRAN upload and GitHub release publication require repository credentials
  and are prepared but not executed by the agent.

## Decision

**1.0.0 release candidate ready.**
