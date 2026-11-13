# Phase 5 — Models, Tools and Help checklist

Reference plan: `~/.opencode/plan/rstats-commander-piano-implementazione.md`,
Phase 5.  Milestone: **v0.6 “Models”**.

Date: 13 November 2026

## Deliverables

| Area | Content | Status |
|---|---|---|
| Models | select/summarize model, compare coefficients, add observation statistics, AIC, BIC, stepwise/subset selection, confidence intervals, bootstrap, delta method, ANOVA table, compare models, linear hypothesis, VIF, Breusch-Pagan, Durbin-Watson, RESET, outlier test, response transformation | done |
| Model graphs | basic diagnostic plots, residual QQ, component+residual, added-variable, influence plots, 3D variants, effect plots, predictor-effect plots | done |
| Tools | load packages, options, save options, plugin notice, App Nap notice, auxiliary-software notice | done |
| Help | quick help, about, manuals/website/hex sticker, R Markdown link, R help, dataset help | done |
| Support | lazy attachment of car, effects, leaps, lmtest, boot and RcmdrMisc | done |
| Tests | golden commands, execution of summaries/AIC/ANOVA/diagnostics/VIF, rendering of all dialogs | done |

## Verification

```text
testthat::test_local()                          -> all tests pass
R CMD check --no-manual RcmdrShiny_0.6.0.tar.gz  -> Status: OK
RCMDRSHINY_E2E=1 test_local(filter="shinytest2")-> 13 assertions pass
```

The porting inventory now reports **138 ported dialogs / 4 internal
utilities**. The four remaining entries (`setupGUI`, `compileRmd`,
`RcmdrEditor`, `RcmdrTkmessageBox`) are internal Tk helpers without a
user-facing menu entry.

## Known limits (accepted for Phase 5)

- Gumbel distribution remains unavailable (no base quantile functions).
- Interactive `identify()`/`locator()` remain out of scope; influence and
  added-variable plots use automatic point labelling.
- Plugin loading is a notice: legacy Tk dialogs are not executable.
- R Markdown/knitr document generation is not enabled; the Help menu links to
  the R Markdown site but the Rmd menu entries remain hidden.
- Edit-menu clipboard actions are delegated to the browser/Ace editor rather
  than implemented as Tk commands.

## Decision

**GO to Phase 6/7 (Plugin API, hardening, documentation and release).**
