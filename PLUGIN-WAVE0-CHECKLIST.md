# Plugin Wave 0 — Core plugin infrastructure

Reference plan: `~/.opencode/plan/rstats-commander-piano-plugin-2026-11-13.md`,
Wave 0.  Baseline: RcmdrShiny 1.1.0.

Date: 13 November 2026

## Deliverables

| ID | Item | Evidence | Status |
|---|---|---|---|
| W0.1 | `RcmdrShinyPlugin.*` package protocol | `load_plugin_package()`, `load_plugin_namespace()` | done |
| W0.2 | Plugin packages may register directly or return specifications | `load_plugin_namespace()`, `test-plugins-wave0.R` | done |
| W0.3 | Legacy `RcmdrPlugin.*` fallback | `load_plugin_package()` menus-only path, warning | done |
| W0.4 | Activation predicates | `predicates` argument, `plugin_predicates()`, `activation_environment()` | done |
| W0.5 | Menu merge with Rcmdr insertion rules | `merge_menu_definitions()`, `remove_menu_rows()` | done |
| W0.6 | Duplicate menu detection | `plugin_menu_definitions()` | done |
| W0.7 | Name-conflict detection | `RcmdrShiny.plugin(replace = FALSE)` | done |
| W0.8 | Stable plugin API | exported state accessors, `plugin_formula()`, widgets, `tr()` | done |
| W0.9 | Plugin scaffold | `tools/new_plugin.R` | done |
| W0.10 | Plugin inventory tool | `tools/inventory_plugin.R` | done |
| W0.11 | Test harness | `tests/testthat/test-plugins-wave0.R` | done |
| W0.12 | Plugin CI | `.github/workflows/plugins.yaml` | done |
| W0.13 | Monorepo layout and docs | `plugins/README.md`, `vignettes/plugins.Rmd` | done |

## Verification

```text
testthat::test_local(filter = "plugins")        -> all tests pass
testthat::test_local(filter = "plugins-wave0")  -> all tests pass
R CMD INSTALL .                                 -> OK
tools/new_plugin.R Demo                         -> skeleton installs and loads
tools/inventory_plugin.R RcmdrPlugin.Export     -> 3 dialogs, 1 menu
```

## Contract for Wave 1

- Core version is 1.1.0; plugins declare `RcmdrShiny (>= 1.1.0)`.
- Plugin package name: `RcmdrShinyPlugin.<Name>`.
- Exported loader: `rcmdrshiny_plugin()`.
- Menu file: `inst/etc/rcmdrshiny-menus.txt`.
- No `tcltk`/`tcltk2` dependency.
- Each plugin has golden command tests and a registration test.
- Distribution is GitHub-only.

## Known limits

- Plugin menus are read at application start; loading a plugin in a running
  session still requires a restart.
- Legacy plugins keep their entries disabled because Tk dialogs are not
  executed.
- `tools/inventory_plugin.R` is heuristic: it classifies functions by textual
  patterns (`initializeDialog`, `tk*`, `doItAndPrint`).
