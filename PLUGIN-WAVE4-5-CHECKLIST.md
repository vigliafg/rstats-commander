# Plugin Wave 4 and Wave 5 — Large suites and completion

Reference plan: `~/.opencode/plan/rstats-commander-piano-plugin-2026-11-13.md`.
Baseline: RcmdrShiny 1.5.0.

Date: 13 November 2026

## Wave 4 plugins

| Plugin | Upstream | Menus | Dialogs | Tests | Check |
|---|---|---|---|---|---|
| `RcmdrShinyPlugin.FactoMineR` | RcmdrPlugin.FactoMineR 1.0-1 | 12 items | 10 + reader alias | 3 | OK |
| `RcmdrShinyPlugin.EZR` | RcmdrPlugin.EZR 1.70 | 639 menu lines | 30 + core aliases | 3 | OK |

## Wave 5 hardening

- All 15 plugin packages are present under `plugins/`.
- `R CMD check` is clean for the core and every plugin package.
- `tools/smoke_plugins.R` loads all installed plugins together and checks the
  combined menu tree.
- Core version 1.5.0.
- Documentation updated: README, NEWS, plugins README, per-plugin READMEs.
- GitHub-only distribution: no plugin is submitted to CRAN.

## Verification

```text
testthat::test_local()                     -> core tests pass
R CMD check RcmdrShiny_1.5.0.tar.gz        -> Status: OK
R CMD check each plugin package             -> Status: OK
Rscript tools/smoke_plugins.R               -> 15 plugins + demo, OK
RCMDRSHINY_E2E=1 test_local("shinytest2")   -> browser E2E passes
```

## Coverage and limits

- EZR is implemented as a core workflow: data preparation, descriptive
  statistics, common tests, regression, survival, diagnostic accuracy and
  graphics.  The specialised meta-analysis, matched-pair, sample-size and
  advanced survival entries remain disabled ("In porting").
- FactoMineR covers the menu entries in the upstream plugin; HCPC operates on
  an existing FactoMineR result object.
- NMBU and DoE also keep their most specialised entries disabled, as recorded
  in `PLUGIN-WAVE3-CHECKLIST.md`.
- Plugin packages remain independent R packages with their own DESCRIPTION,
  NAMESPACE, tests and GitHub installation instructions.

## Plan status

All approved waves are complete at the repository level:

| Wave | Status |
|---|---|
| 0 — infrastructure | done |
| 1 — quick wins | done |
| 2 — teaching and graphics | done |
| 3 — models and design | done |
| 4 — FactoMineR and EZR | done |
| 5 — hardening and release preparation | done |

External release actions (GitHub release publication, CRAN upload of the core)
still require repository credentials and a maintainer decision.
