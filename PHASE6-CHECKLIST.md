# Phase 6 — Plugin API checklist

Reference plan: `~/.opencode/plan/rstats-commander-piano-implementazione.md`,
Phase 6 (optional before 1.0).  Milestone: **v0.7 “Plugin API”**.

Date: 13 November 2026

## Deliverables

| Item | Status |
|---|---|
| `RcmdrShiny.plugin(name, menus, dialogs, commands, ...)` | done |
| Merge plugin Rcmdr-style `menus.txt` definitions into the sidebar | done |
| Direct-command adapter (with or without a `state` argument) | done |
| Shiny dialog API through `plugin_dialog()` | done |
| Public `load_plugin()`, `load_plugin_package()`, `list_plugins()`, `unload_plugins()` | done |
| `run()`/`app()` `plugins` argument | done |
| Tools → Load Rcmdr plug-in(s) dialog | done |
| Legacy Tk plugin detection and warning | done |
| Example plugin (`inst/examples/demo-plugin.R`, `demo-menus.txt`) | done |
| Plugin tests | done |

## Verification

```text
testthat::test_local()                          -> all tests pass
R CMD check --no-manual RcmdrShiny_0.7.0.tar.gz  -> Status: OK
RCMDRSHINY_E2E=1 test_local(filter="shinytest2")-> 13 assertions pass
```

Plugin tests cover:

- menu leaves and command status after registration;
- direct commands receiving the application state;
- no-argument command adapter;
- plugin dialog specs and `on_ok` execution;
- menu HTML rendering;
- loading a plugin script from a file;
- legacy Tk warning.

## Example

```r
unload_plugins()
load_plugin(system.file("examples", "demo-plugin.R",
                        package = "RcmdrShiny"))
run()
```

The demo adds a *Demo plugin* top-level menu with two direct commands and one
Shiny dialog.

## Known limits (accepted for Phase 6)

- Menu definitions are merged at application start.  Plugins loaded through
  the Tools dialog require a restart to appear, as in Rcmdr.
- Legacy Tk dialogs are never executed.  Legacy plugins are registered with a
  warning and their menu entries remain disabled.
- Plugin activation predicates are evaluated with the same Rcmdr expression
  engine; plugins that reference custom predicate functions need to keep the
  expression empty or provide direct commands.
- The upstream `RcmdrModels:` DESCRIPTION capability extension is not
  implemented; model capabilities come from the standard Rcmdr table.

## Decision

**Feature-complete for the planned scope. Proceed to Phase 7 (hardening,
documentation, CRAN preparation).**
