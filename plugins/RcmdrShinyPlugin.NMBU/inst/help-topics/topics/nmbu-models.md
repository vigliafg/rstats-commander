---
id: nmbu-models
title: Multivariate models and diagnostics (NMBU)
type: task
category: plugins
order: 7
keywords: [lda, qda, pca, pls, simplex, clustering, press, stepwise, diagnostics,
           nmbu]
aliases: [nmbu-models, multivariate-nmbu, press-statistic]
dialogs: [RelComp, hierarchicalClusterVariable, simplex.analysis,
          discriminantAnalysis, CIgrandMeanNMBU, DA.coef, hclust.list,
          contrastGUI, postHocGUI, PRESS.GUI, deviance_tests_GUI, invXtXGUI,
          principalComponentPlots, discriminantPlot, mixtureGUI,
          backwardForward, wideForwardAdd, fittedLinePlot, pieChartNMBU,
          simplexGUI]
commands: [principal, hclust, cutree, lm, lda, qda, linearHypothesis,
           TukeyHSD, stepAIC, persp, scatterplot, pie]
packages: [psych, MASS, car, multcomp, pls]
related: [nmbu-data, nmbu-tests]
language: en
status: documented
---

# Multivariate models and diagnostics (NMBU)

This part of the NMBU menu covers multivariate analysis, mixture experiments
and model diagnostics.  Several entries operate on the **active model**: fit a
model first with **Models > Linear model** (or **Fit models > Linear
regression**) and make it active.

## Dimensional analysis

| Entry | Command |
|---|---|
| Relevant component analysis | `psych::principal(..., rotate = "varimax")` |
| Hierarchical cluster analysis (variables) | `hclust(dist(t(scale(X))))` |
| PCA/PCR/PLS plots | `plot()` and `biplot()` of the active solution |

```r
psych::principal(D[, c("x1", "x2", "x3")], nfactors = 2, rotate = "varimax")
```

## Discriminant analysis

```r
MASS::lda(group ~ x1 + x2, data = D)
MASS::qda(group ~ x1 + x2, data = D)
```

`DA.coef` prints the discriminant scores (`predict(model)$x`) and
`discriminantPlot` draws the first two discriminant functions.

## Mixture and simplex models

A simplex mixture model has no intercept because the components sum to one:

```r
lm(y ~ 0 + a + b + c, data = D)
```

The response surface comes from a two-component interaction model:

```r
persp(.x, .y, .z, theta = 30, phi = 20, ticktype = "detailed")
```

## Model diagnostics

| Entry | Command |
|---|---|
| CI for the grand mean | `confint(model, "(Intercept)")` |
| Test contrast in ANOVA | `car::linearHypothesis(model, "...")` |
| Post hoc pair-wise tests | `TukeyHSD(model, which = "factor")` |
| PRESS, R²pred, RMSEP | leave-one-out residuals from `hatvalues()` |
| Deviance tests | `anova(model, test = "Chisq")` |
| (X'X)⁻¹ | `solve(crossprod(model.matrix(model)))` |
| Backward/forward selection | `MASS::stepAIC()` |

The PRESS statistic uses the leave-one-out residuals
`r_i / (1 - h_i)`:

```r
local({
  .fit <- m
  .r <- residuals(.fit); .h <- hatvalues(.fit)
  .press <- sum((.r / (1 - .h))^2)
  .y <- model.response(model.frame(.fit))
  c(PRESS = .press,
    R2pred = 1 - .press / sum((.y - mean(.y))^2),
    RMSEP = sqrt(.press / length(.r)))
})
```

## Graphs

- **Fitted regression plot** draws a scatterplot with the least-squares line.
- **Pie/bar chart from summaries** builds a chart from typed counts.
- **Simplex mixture design plot** draws the triangular design region.

## See also

- `topic:nmbu-data`
- `topic:nmbu-tests`
- `topic:linear-model`
