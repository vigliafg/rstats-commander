---
id: linear-model
title: Linear model
type: task
category: models
keywords: [linear, regression, lm, model, ols, predictors, diagnostics]
aliases: [lm, regression, linear-regression]
dialogs: [linearModel, linearRegressionModel]
commands: [lm, summary, Anova, vif]
packages: [stats, car]
related: [generalized-linear-model, correlation, one-way-anova]
language: en
status: documented
---

# Linear model

**Models > Linear model...** fits an ordinary least-squares regression and makes
the result the active model, so the model menus and diagnostic plots can use it.

## When to use it

- The response is numeric and roughly continuous.
- You want to quantify the effect of one or more predictors while adjusting for
  the others.

## How to fill it in

1. **Response variable**: the numeric outcome.
2. **Explanatory variables**: one or more numeric or factor predictors.
3. **Subset**: optionally restrict the model to a subset expression.
4. **Interactions**: request the interactions you need; the dialog writes them
   explicitly with `*` or `:`.
5. Press **OK**.

## What it produces

```r
.Model <- lm(response ~ predictor1 + predictor2 + factor1, data = Dataset)
summary(.Model)
```

The model object is stored in the **Environment** tab and becomes the active
model, enabling **Models > Hypothesis tests**, **Models > Numerical
diagnostics** and the diagnostic plots.

## Reading the output

- `Estimate` is the change in the response for a one-unit change in the
  predictor, holding the others fixed.
- `Std. Error`, `t value` and `Pr(>|t|)` test each coefficient against zero.
- `Multiple R-squared` is the share of variance explained; the adjusted version
  penalises extra predictors.
- For factors with more than two levels, the reference level is the first one;
  change it with **Data > Manage variables > Reorder factor levels...**.

## Diagnostics

After fitting, open **Models > Graphs** for residuals versus fitted values, a
QQ plot, scale-location and leverage plots.

## See also

- `topic:generalized-linear-model`
- `topic:one-way-anova`
- `topic:correlation`
