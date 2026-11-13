---
id: correlation
title: Correlation
type: task
category: statistics
keywords: [correlation, pearson, spearman, kendall, matrix, association]
aliases: [cor, correlation-matrix]
dialogs: [correlationMatrix, correlationTest]
commands: [cor, cor.test, rcorr.adjust]
packages: [stats, RcmdrMisc]
related: [scatterplot, linear-model]
language: en
status: documented
---

# Correlation

Two dialogs measure association between numeric variables: a matrix for several
variables and a test for a single pair.

| Dialog | Use |
|---|---|
| **Statistics > Summaries > Correlation matrix...** | Several variables at once, with optional p-values |
| **Statistics > Summaries > Correlation test...** | One pair, with a confidence interval |

## How to fill it in

1. **Variables**: at least two numeric variables.
2. **Type of correlation**: Pearson (linear), Spearman (rank) or Kendall
   (rank, small samples).
3. **Alternative hypothesis** and **confidence level** for the test dialog.
4. **Pairwise observations**: how to handle missing values — complete
   observations or pairwise deletion.
5. Press **OK**.

## What it produces

```r
rcorr.adjust(Dataset[, c("height", "weight")], type = "pearson",
             use = "complete.obs")
```

and, for the single pair:

```r
cor.test(Dataset$height, Dataset$weight, alternative = "two.sided",
         method = "pearson")
```

## Reading the output

- `r` ranges from -1 to 1; the sign gives the direction and the absolute value
  the strength.
- Correlation measures linear association.  A strong non-linear relationship
  can produce a small `r`, so always plot the pair with `topic:scatterplot`.
- Correlation is not causation, and it is sensitive to outliers.

## See also

- `topic:scatterplot`
- `topic:linear-model`
