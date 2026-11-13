---
id: frequency-distributions
title: Frequency distributions
type: task
category: statistics
keywords: [frequency, counts, table, factor, categorical, proportions, percentages]
aliases: [frequencies, counts, tabulate]
dialogs: [frequencyDistribution]
commands: [table, prop.table, chisq.test]
packages: [stats]
related: [numerical-summaries, cross-tables]
language: en
status: documented
---

# Frequency distributions

**Statistics > Summaries > Frequency distributions...** counts the values of a
factor or a discrete numeric variable and optionally tests the counts against
expected proportions.

## When to use it

- You want counts and percentages for a categorical variable.
- You want a one-sample chi-square goodness-of-fit test against given
  proportions.
- You want to check for empty or rare factor levels before modelling.

## How to fill it in

1. **Variables**: select one or more factors.  Numeric variables are accepted
   when they have few distinct values.
2. **Test of proportions**: enable the goodness-of-fit test and enter the
   expected proportions, separated by commas.
3. **Charts**: optionally ask for a bar chart of the counts.
4. Press **OK**.

## What it produces

```r
local({
  .Table <- with(Dataset, table(group))
  cat("\ncounts:\n")
  print(.Table)
  cat("\npercentages:\n")
  print(round(100 * .Table / sum(.Table), 2))
})
```

With the test enabled, a `chisq.test(.Table, p = .Probs)` block is appended.

## Tips

- An empty level is shown with a count of zero; drop it with
  **Data > Manage variables > Drop unused factor levels...**.
- For two-way tables use `topic:cross-tables`.

## See also

- `topic:cross-tables`
- `topic:numerical-summaries`
