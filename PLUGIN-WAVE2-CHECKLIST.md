# Plugin Wave 2 — Teaching and graphics

Reference plan: `~/.opencode/plan/rstats-commander-piano-plugin-2026-11-13.md`,
Wave 2.  Baseline: RcmdrShiny 1.3.0.

Date: 13 November 2026

## Plugins

| Plugin | Upstream | Menus | Main dialogs | Tests | Check |
|---|---|---|---|---|---|
| `RcmdrShinyPlugin.TeachingDemos` | RcmdrPlugin.TeachingDemos 1.0-41 | 11 items | 11 | 3 | OK |
| `RcmdrShinyPlugin.KMggplot2` | RcmdrPlugin.KMggplot2 0.5-6 | 29 items | 29 | 4 | OK |
| `RcmdrShinyPlugin.HH` | RcmdrPlugin.HH 1.1-49 | 28 items | 26 + 2 direct | 3 | OK |
| `RcmdrShinyPlugin.TeachStat` | RcmdrPlugin.TeachStat 1.1-4 | 158 items | 90 | 5 | OK |

## Core additions

- `nonFactorsP()`, `twoOrMoreLevelFactorsP()`, `aovModelsP()`,
  `AbscontDistrsP()` and `DiscreteDistrsP()` predicates.
- `two_level_factors()` exported for two-level group selectors.
- Plugin-vs-plugin name clashes warn and override; core clashes still fail.
- Version 1.3.0.

## Verification

```text
testthat::test_local()                     -> core tests pass
R CMD check RcmdrShiny_1.3.0.tar.gz        -> Status: OK
R CMD check each Wave 2 plugin              -> Status: OK
Rscript tools/smoke_plugins.R               -> 10 plugins, 474 leaves, OK
```

## Deliberate adaptations

- TeachingDemos demos use base graphics captured in the Plots pane instead of
  Tk/rgl windows; Tk-only install predicates were removed.
- KMggplot2 uses direct ggplot2 commands rather than the upstream Tcl widget
  toolkit.  Kaplan-Meier and scatter-matrix dialogs use base/survival graphics.
- HH dialogs cover the menu commands with simplified option sets; `HH::ci.plot`
  is restricted to one explanatory variable because the upstream function
  supports simple regression only.
- TeachStat data-management entries reuse the core dialogs; distribution and
  inference dialogs share generic builders.  The generic `distr` package
  definition dialogs are left out.
- All plugins are GitHub-only and declare their optional packages in Suggests.

## Known limits

- Some HH commands depend on the exact HH version and may need dataset-specific
  arguments.
- TeachStat generic distribution objects (`distr` package) are not implemented.
- Plot dialogs expose the main options rather than every upstream theme and
  font control.
