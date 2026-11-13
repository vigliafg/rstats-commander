# Phase 4 — Graphs, Distributions and 3D checklist

Reference plan: `~/.opencode/plan/rstats-commander-piano-implementazione.md`,
Phase 4.  Milestone: **v0.5 “Graphics”**.

Date: 13 November 2026

## Deliverables

| Area | Content | Status |
|---|---|---|
| Graphs | index plot, histogram, stem-and-leaf, boxplot, dot plot, scatterplot, scatterplot matrix, bar graph, pie chart, line graph, QQ plot, plot of means, 3D scatterplot, XY conditioning plot, strip chart, density estimate, discrete plot, symmetry boxplot, palette | done |
| Save graph | bitmap/PDF actions from the plot history, 3D PNG snapshot | done |
| Distributions | quantiles, probabilities, mass (discrete), density/CDF plots, random samples, random seed | done |
| Plot pipeline | dialog capture with `plot = "auto"`, history gallery, selection, PNG/PDF export | done |
| rgl | `scatter3d` captured with `rgl.useNULL()`, `rglwidget()` pane, snapshot export | done |
| Tests | golden commands, execution + plot capture, rendering/validation, browser E2E | done |

Supported distribution families: normal, t, chi-square, F, exponential,
uniform, beta, Cauchy, logistic, lognormal, gamma, Weibull, binomial, Poisson,
geometric, hypergeometric, negative binomial.

## Verification

```text
testthat::test_local()                          -> all tests pass
R CMD check --no-manual RcmdrShiny_0.5.0.tar.gz  -> Status: OK
RCMDRSHINY_E2E=1 test_local(filter="shinytest2")-> 13 assertions pass
```

The browser test now opens the Histogram dialog and checks that the plot
history contains both the histogram and the plot produced from the script.

## Known limits (accepted for Phase 4)

- The Gumbel distribution is not available because R has no base `qgumbel` /
  `pgumbel`; its dialogs remain disabled.
- `saveBitmap`/`savePDF` delegate to the in-app plot export rather than
  calling `dev.print()`, because the application closes plot devices after
  capture.
- `scatter3d` and the 3D pane require `rgl`; without it the 3D dialogs are
  hidden by the installation predicate.
- Interactive `identify()`/`locator()` remain out of scope.
- Plot dialogs expose the main options; less common Rcmdr options (custom
  axis labels, arbitrary `par()` settings) are not yet surfaced.

## Decision

**GO to Phase 5 (Models, Tools and Help).**
