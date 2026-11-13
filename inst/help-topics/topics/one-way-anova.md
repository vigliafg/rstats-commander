---
id: one-way-anova
title: One-way ANOVA
type: task
category: statistics
keywords: [anova, variance, groups, f-test, means, posthoc]
aliases: [anova, analysis-of-variance]
dialogs: [oneWayAnova, multiWayAnova, oneWayRepeatedMeasures]
commands: [aov, Anova, summary]
packages: [stats, car]
related: [t-tests, linear-model]
language: en
status: documented
---

# One-way ANOVA

**Statistics > Means > One-way ANOVA...** compares the means of two or more
groups defined by a single factor.

## When to use it

- You have a numeric response and one categorical explanatory variable with
  three or more levels.
- You want an overall F test before pairwise comparisons.

## How to fill it in

1. **Response variable**: the numeric outcome.
2. **Factor**: the grouping variable.
3. **Pairwise comparisons**: optionally request Tukey contrasts.
4. Press **OK**.

## What it produces

```r
.Anova <- aov(response ~ factor, data = Dataset)
summary(.Anova)
```

With pairwise comparisons the dialog adds a `TukeyHSD()` call; with
**Multi-way ANOVA** it uses `car::Anova()` and can include interactions.

## Reading the output

- The `F value` and `Pr(>F)` columns test the null hypothesis that all group
  means are equal.
- A significant result says that at least one mean differs; it does not say
  which one.  Use the pairwise comparisons for that.

## Assumptions

- Independent observations and roughly equal variances across groups.
- Residuals should be approximately normal.  **Models > Graphs > Basic
  diagnostic plots** shows the residual plots.

## See also

- `topic:t-tests`
- `topic:linear-model`
