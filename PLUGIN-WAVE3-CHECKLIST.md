# Plugin Wave 3 — Models and design

Reference plan: `~/.opencode/plan/rstats-commander-piano-plugin-2026-11-13.md`,
Wave 3.  Baseline: RcmdrShiny 1.4.0.

Date: 13 November 2026

## Plugins

| Plugin | Upstream | Menus | Dialogs | Tests | Check |
|---|---|---|---|---|---|
| `RcmdrShinyPlugin.survival` | RcmdrPlugin.survival 1.3-2 | 18 items | 14 | 3 | OK |
| `RcmdrShinyPlugin.aRnova` | RcmdrPlugin.aRnova 0.0.6 | 6 items | 4 | 3 | OK |
| `RcmdrShinyPlugin.NMBU` | RcmdrPlugin.NMBU 1.8.15 | 124 lines | 22 | 3 | OK |
| `RcmdrShinyPlugin.DoE` | RcmdrPlugin.DoE 0.12-6 | 120 lines | 19 | 3 | OK |

## Core additions

- Plugin model-capability tables are merged into the core table, enabling
  `modelCapability('tph')` for Cox models.
- `AOVModelsP()`, `coxphP()`, `survregP()` and `highOrderTermsP()` predicates.
- Plugin predicates now accept the application state plus their own arguments.
- Version 1.4.0.

## Verification

```text
testthat::test_local()                    -> core tests pass
R CMD check RcmdrShiny_1.4.0.tar.gz       -> Status: OK
R CMD check each Wave 3 plugin             -> Status: OK
Rscript tools/smoke_plugins.R              -> 14 plugins, 616 leaves, OK
```

## Deliberate adaptations

- survival data attributes and commands use the same `survival::` calls as the
  original plugin; the wide-to-long dialog uses base `reshape`.
- aRnova repeated-measures analysis reshapes wide data and uses
  `aov(value ~ within + Error(id/within))`.
- NMBU focuses on the t/z, proportion, ANOVA, PLS, stepwise and diagnostic
  entries; the remaining specialised entries stay disabled ("In porting").
- DoE creates designs with `FrF2`, `DoE.base`, `rsm`, `lhs` and `AlgDesign`;
  import/export entries rely on the core workspace commands.

## Known limits

- NMBU mixture models, discriminant scores and some post-hoc/contrast dialogs
  are not implemented.
- DoE import/export and some design-modification entries are not implemented.
- Plot dialogs expose the main options rather than every upstream control.
