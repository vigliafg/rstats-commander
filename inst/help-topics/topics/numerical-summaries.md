---
id: numerical-summaries
title: Numerical summaries
type: task
category: statistics
keywords: [summary, mean, median, sd, quantile, describe, numSummary, statistics]
aliases: [summary, descriptive-statistics, describe]
dialogs: [numericalSummaries]
commands: [numSummary]
packages: [RcmdrMisc]
related: [frequency-distributions, correlation]
language: en
status: documented
---

# Numerical summaries

**Statistics > Summaries > Numerical summaries...** describes numeric variables
with means, standard deviations, quantiles and missing-value counts.

## When to use it

- You need a first look at the distribution of a numeric variable.
- You want the same summary table broken down by a grouping factor.
- You want to compare several variables side by side.

## How to fill it in

1. **Data set**: the active data set, when more than one is loaded.
2. **Variables**: select one or more numeric variables.  Factors are offered by
   the separate *Frequency distributions* dialog.
3. **Summarize by groups**: optional factor that splits the table.
4. **Statistics**: choose mean, standard deviation, median, quantiles,
   skewness and the count of missing values.
5. **Quantiles**: the probabilities to report, for example `0, .25, .5, .75, 1`.
6. Press **OK**.

## What it produces

```r
numSummary(Dataset[, c("height", "weight")],
           statistics = c("mean", "sd", "quantiles", "missing"))
```

The result is a table in the **Output** tab.  When a grouping factor is used,
the command adds `groups = Dataset$sex`.

## Tips

- If a variable is stored as a factor with numeric labels, convert it first with
  **Data > Manage variables > Convert factors to numeric variables...**.
- The **Statistics** tab of the dialog remembers your choices for the session.

## See also

- `topic:frequency-distributions`
- `topic:histogram`
- `topic:correlation`
