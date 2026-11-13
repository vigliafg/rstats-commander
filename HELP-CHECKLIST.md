# Help and documentation — implementation checklist

Reference plan: `~/.opencode/plan/rstats-commander-help-documentazione-2026-11-13.md`.
Baseline: RcmdrShiny 1.6.0.

Date: 13 November 2026

## Phases

| Phase | Scope | Status |
|---|---|---|
| H0 | Registry, YAML front matter, rendering, search, API | done |
| H1 | Help tab, dialog help, Help menu, diagnostics | done |
| H2 | Twenty priority core topics | done |
| H3 | Coverage of every core dialog (skeletons + review) | done |
| H4 | Help for the 15 plugins | done |
| H5 | pkgdown, ten new vignettes, link checker | done |
| H6 | Italian pilot translations, accessibility, hardening | done |

## Delivered

### Runtime

- `R/help.R`: registry, internal YAML parser, `commonmark` renderer with a
  plain fallback, weighted search, category index, language fallback.
- `R/help-ui.R`: Help tab, result and category renderers, inline dialog panel.
- `R/help-server.R`: search, navigation, recent topics, contextual help,
  R-reference button.
- `R/diagnostics.R`: `diagnostics_report()` and `format_diagnostics()`.
- `dialog_spec()` and `plugin_dialog()` accept `help_topic`.
- `RcmdrShiny.plugin(help = )` and automatic discovery of
  `inst/help-topics/index.yml` in plugin packages.

### Content

- 133 core topics: 20 hand-written, 113 generated and grouped by family for
  the distribution dialogs and the new Gumbel family.
- 486 plugin topics across the 15 plugins, each with an overview topic.
- 619 documented topics in total; no `draft` and no missing dialog topic.
- Italian translations for 21 core topics; missing translations fall back to
  English.
- Six screenshots, embedded in eight vignettes.
- Ten new vignettes: data import, descriptive statistics, linear models,
  graphs, survival, design of experiments, FactoMineR, EZR, troubleshooting and
  help authoring.

### Tooling and CI

- `tools/new_help_topic.R`, `tools/generate_help_topics.R`,
  `tools/inventory_help.R`, `tools/check_help_links.R`.
- `.github/workflows/help.yaml`: help tests, inventory, link check, topic
  smoke test, inventory artifact.

## Verification

```text
testthat::test_local(filter = "help")        -> 100+ expectations, green
Rscript tools/inventory_help.R               -> 0 missing dialogs
Rscript tools/check_help_links.R --strict    -> no broken links
R CMD check RcmdrShiny_1.6.0.tar.gz          -> Status: OK
R CMD check each plugin package              -> Status: OK
RCMDRSHINY_E2E=1 test_local(filter="shinytest2")
                                             -> help tab and dialog help covered
```

## Design notes

- The help directory is `inst/help-topics/`, not `inst/help/`: R reserves
  `inst/help` for its own help database and `R CMD check` warns about it.
- `commonmark` and `yaml` are in `Suggests` with internal fallbacks, so the
  help works with no optional dependency installed.
- Generated topics are validated by `inventory_help.R` and
  `check_help_links.R`, then promoted to `documented` by
  `tools/promote_help_topics.R`.  The CI gate still fails when a dialog has
  neither a topic nor an Rd fallback.
- EZR replaces the core menus, so its help topics coexist with the core topics
  but its menu layout dominates when it is loaded.

## Limits

- Generated reference topics are structured and accurate about menus, dialogs
  and commands; they are reviewed by template and validated automatically, not
  copy-edited one by one.
- Search is a weighted substring match, not a full-text index; a client-side
  index remains an option if the corpus grows much further.
- Twenty-one core topics are translated into Italian.  The structure is ready
  for more, but translation is editorial work.
