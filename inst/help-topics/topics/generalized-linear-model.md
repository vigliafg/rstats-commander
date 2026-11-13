---
id: generalized-linear-model
title: Generalized linear model
type: task
category: models
keywords: [glm, logistic, poisson, binomial, link, regression, deviance]
aliases: [glm, logistic-regression, poisson-regression]
dialogs: [generalizedLinearModel]
commands: [glm, summary, Anova]
packages: [stats, car]
related: [linear-model, cross-tables]
language: en
status: documented
---

# Generalized linear model

**Models > Generalized linear model...** fits a model with a non-normal error
distribution: logistic regression for binary outcomes, Poisson regression for
counts, and the other `glm` families.

## When to use it

- The response is binary (0/1, success/failure).
- The response is a count.
- The variance grows with the mean, so ordinary least squares is inappropriate.

## How to fill it in

1. **Response variable**: binary factor, 0/1 numeric, or a count.
2. **Explanatory variables**: the predictors, as in a linear model.
3. **Family**: `binomial` for proportions, `poisson` for counts, `gaussian` for
   a linear model fitted through `glm`.
4. **Link**: usually the canonical link; change it only when you have a reason.
5. Press **OK**.

## What it produces

```r
.Model <- glm(outcome ~ age + treatment, data = Dataset, family = binomial)
summary(.Model)
```

## Reading the output

- Coefficients are on the link scale: for `binomial` they are log-odds, so
  `exp(estimate)` gives an odds ratio.
- `Null deviance` and `Residual deviance` play the role of the residual sum of
  squares.  The difference tests the model against the null model.
- `AIC` compares non-nested models fitted to the same data.

## Practical notes

- Separation — a predictor that perfectly predicts the outcome — produces huge
  coefficients and standard errors.  Collapse rare categories or remove the
  predictor.
- For a binary response stored as 0/1, R treats it as a proportion when the
  values are 0 and 1.

## See also

- `topic:linear-model`
- `topic:cross-tables`
