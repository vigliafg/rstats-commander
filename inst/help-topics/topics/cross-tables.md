---
id: cross-tables
title: Cross tables and contingency tests
type: task
category: statistics
keywords: [contingency, cross, table, chisquare, fisher, two-way, percentages]
aliases: [contingency-table, two-way-table, crosstab]
dialogs: [twoWayTable, twoWayTableFromCounts, multiWayTable, enterTable]
commands: [xtabs, chisq.test, fisher.test, rowPercents, colPercents]
packages: [stats, RcmdrMisc]
related: [frequency-distributions, t-tests]
language: en
status: documented
---

# Cross tables and contingency tests

Use the contingency-table dialogs to cross two or more factors, print row and
column percentages, and run the chi-square or Fisher test.

## Choose the dialog

| Situation | Dialog |
|---|---|
| Two factors in the active data set | **Statistics > Contingency tables > Two-way table...** |
| Counts already tabulated | **Statistics > Contingency tables > Enter and analyze two-way table...** |
| Three or more factors | **Statistics > Contingency tables > Multi-way table...** |

## How to fill it in

1. **Row variable** and **column variable**: pick two factors.
2. **Percentages**: none, row, column or total.
3. **Hypothesis test**: chi-square, Fisher's exact test or none.
4. **Expected counts** and **chi-square components**: optional extra output.
5. Press **OK**.

## What it produces

```r
local({
  .Table <- xtabs(~ group + outcome, data = Dataset)
  cat("\nFrequency table:\n")
  print(.Table)
  cat("\nRow percentages:\n")
  print(rowPercents(.Table))
  print(chisq.test(.Table, correct = FALSE))
})
```

## Reading the output

- The chi-square test assumes expected counts above about five in every cell.
  When that fails, R prints a warning and Fisher's exact test is the safer
  choice.
- Row percentages answer "what share of each row falls in each column"; column
  percentages answer the reverse question.

## Tips

- Recode rare categories together before testing; the chi-square approximation
  improves.
- `topic:frequency-distributions` covers one-way counts.

## See also

- `topic:frequency-distributions`
- `topic:t-tests`
