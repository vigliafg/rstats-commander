# Phase 3 — Statistics checklist

Reference plan: `~/.opencode/plan/rstats-commander-piano-implementazione.md`,
Phase 3.  Milestone: **v0.4 “Statistics”**.

Date: 13 November 2026

## Deliverables

| Area | Dialogs / actions | Count |
|---|---|---|
| Summaries | frequency distributions, table of statistics, correlation matrix, correlation test, normality, power transforms | 6 |
| Tables | two-way, two-way from counts, multi-way, entered table | 4 |
| Means | single/independent/paired t-test, one-way/multi-way ANOVA, one/two-factor repeated measures | 7 |
| Variances | F-test, Bartlett, Levene, single-sample variance | 4 |
| Proportions | single-sample and two-sample tests | 2 |
| Nonparametric | two-sample/paired/single Wilcoxon, Kruskal-Wallis, Friedman | 5 |
| Dimensional | reliability, PCA, factor analysis, CFA | 4 |
| Cluster | k-means, hierarchical, summary, append group | 4 |
| Models | linear regression, GLM, multinomial, ordinal, mixed, GLMM | 6 |

The direct commands *Summarize active data set* and *Count missing
observations* are also wired.

## Verification

```text
testthat::test_local()                          -> all tests pass
R CMD check --no-manual RcmdrShiny_0.4.0.tar.gz  -> Status: OK
RCMDRSHINY_E2E=1 test_local(filter="shinytest2")-> 13 assertions pass
```

Coverage:

- golden tests for the generated commands of the main analyses;
- execution tests for frequency tables, descriptive tables, correlations,
  t-tests, one-way ANOVA, contingency tables, Kruskal-Wallis, PCA and GLM;
- rendering and validation tests for every Statistics dialog;
- menu activation tests (`numericP`, `modelCapability`, …);
- browser test extended with an independent-samples t-test.

## Command parity

The builders reproduce Rcmdr's `statistics-*-menu.R` / `cluster.R` code for
the tested cases, including:

- `xtabs`, `rowPercents`, `chisq.test`, `fisher.test`, `addmargins`;
- `t.test`, `aov`, `lm` + `Anova`, `oneway.test`, `glht` + `cld`;
- `var.test`, `bartlett.test`, `leveneTest`, `sigma.test`;
- `wilcox.test`, `kruskal.test`, `friedman.test`;
- `princomp`, `factanal`, `reliability`, `KMeans`, `hclust`, `cutree`;
- `glm`, `polr`, `multinom`, `lmer`, `glmer`;
- `numSummary`, `Tapply`, `normalityTest`, `powerTransform`.

## Known limits (accepted for Phase 3)

- Repeated-measures dialogs use simplified single-screen designs; the
  two-way version expects responses in row-major order rather than a matrix
  editor.
- Confirmatory factor analysis accepts `sem::specifyModel` text instead of
  Rcmdr's interactive factor-definition editor.
- `sigma.test` requires the optional `TeachingDemos` package.
- Mixed models take the random-effects part directly in the formula
  (e.g. `x + (1 | g)`), which matches Rcmdr's free-form formula entry.
- Pairwise ANOVA comparisons require `multcomp`; the command is generated and
  lazily attaches the package.

## Decision

**GO to Phase 4 (Graphs, Distributions, Cluster polish).**
