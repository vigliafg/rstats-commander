---
id: t-tests
title: t-tests
type: task
category: statistics
keywords: [t-test, mean, comparison, paired, independent, welch, hypothesis]
aliases: [ttest, t-test, mean-comparison]
dialogs: [independentSamplesTTest, pairedTTest, singleSampleTTest]
commands: [t.test]
packages: [stats]
related: [one-way-anova, cross-tables]
language: en
status: documented
---

# t-tests

Three dialogs cover the classical tests on means.

| Question | Dialog |
|---|---|
| Is the mean of one variable different from a value? | **Statistics > Means > Single-sample t-test...** |
| Do two independent groups differ? | **Statistics > Means > Independent samples t-test...** |
| Did paired measurements change? | **Statistics > Means > Paired t-test...** |

## How to fill it in

1. **Variables**: pick the numeric response.  For the paired test, pick both
   measurements.
2. **Group** (independent test only): pick the two-level factor that defines
   the groups.
3. **Alternative hypothesis**: two-sided, less or greater.
4. **Null hypothesis**: the mean, or the difference between means.
5. **Confidence level**: usually `0.95`.
6. **Assume equal variances**: leave off for Welch's default.
7. Press **OK**.

## What it produces

```r
t.test(response ~ group, data = Dataset, alternative = "two.sided",
       conf.level = 0.95, var.equal = FALSE)
```

## Reading the output

- `t` is the test statistic, `df` the degrees of freedom and `p-value` the
  probability of a result at least this extreme under the null hypothesis.
- The confidence interval is for the difference (or the mean, in the
  single-sample case).
- With `var.equal = FALSE` R uses the Welch approximation, which does not
  assume equal variances.

## Assumptions

- Independent observations, approximately normal within groups, or large
  enough samples for the central limit theorem.
- For paired data the differences should be approximately normal.
- Use **Statistics > Variances > Levene's test...** to check homogeneity, and
  **Statistics > Summaries > Test of normality...** for normality.

## See also

- `topic:one-way-anova`
- `topic:frequency-distributions`
