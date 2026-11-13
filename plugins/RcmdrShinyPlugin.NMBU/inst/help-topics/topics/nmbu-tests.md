---
id: nmbu-tests
title: Covariance and summarized z-tests (NMBU)
type: task
category: plugins
order: 6
keywords: [covariance, correlation, z-test, summary, means, nmbu]
aliases: [nmbu-tests, summary-z-test, covariance-matrix]
dialogs: [covarianceMatrix, oneSamplesZTestSum, twoSamplesZTestSum]
commands: [cov, cor, pnorm]
packages: [RcmdrShinyPlugin.NMBU]
related: [nmbu-data, nmbu-models]
language: en
status: documented
---

# Covariance and summarized z-tests (NMBU)

## Covariance/correlation matrix

**Statistics > Summaries > Covariance/correlation matrix** prints the
covariance or correlation matrix of the selected numeric variables.

```r
with(D, cov(D[, c("x", "y", "z")], use = "pairwise.complete.obs"))
```

`use = "pairwise.complete.obs"` uses all complete pairs, so the matrix stays
positive definite even when variables have different missingness patterns.

## Summarized z-tests

The course reports z-tests from published summary statistics rather than raw
data.  Two dialogs cover the one-sample and two-sample cases.

One sample, known sigma:

```r
local({
  .z <- (5 - 0) / (1 / sqrt(30))
  .p <- switch('two.sided', two.sided = 2 * pnorm(-abs(.z)),
               less = pnorm(.z), greater = pnorm(.z, lower.tail = FALSE))
  c(statistic = .z, p.value = .p)
})
```

Two samples:

```r
local({
  .z <- (5 - 4) / sqrt(1^2 / 30 + 1^2 / 30)
  .p <- 2 * pnorm(-abs(.z))
  c(statistic = .z, p.value = .p)
})
```

## Reading the output

- `z` is the standardized difference; `|z| > 1.96` corresponds to a two-sided
  p-value below 0.05.
- A known sigma is an assumption, not an estimate: if you only have the sample
  standard deviation, use a t-test instead.
- Correlation is scale-free, covariance is not.  Report the correlation when
  comparing variables measured on different scales.

## See also

- `topic:nmbu-data`
- `topic:nmbu-models`
- `topic:correlation`
