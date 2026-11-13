---
id: ezr-graphs-tables
title: Graphs and tables (EZR)
type: task
category: plugins
order: 7
keywords: [violin, consort, sankey, swimmer, survival curve, cumulative
           incidence, graph options, summary table, ezr]
aliases: [ezr-graphs, consort-diagram, swimmer-plot]
dialogs: [StatMedViolinPlot, StatMedOrderedChart, StatMedSwimPlot,
          StatMedSankey, StatMedConsort, StatMedAdjustedSurvival,
          StatMedAdjustedCumInc, StatMedStackCumInc, StatMedGraphOptions,
          StatMedSummaryResults]
commands: [vioplot, barplot, segments, geom_alluvium, survfit, cuminc, par,
           summary]
packages: [vioplot, ggalluvial, ggplot2, cmprsk, survival]
related: [ezr-overview, ezr-graphs-tables]
language: en
status: documented
---

# Graphs and tables (EZR)

**Graphs and tables** collects the clinical visualisations that have no core
Rcmdr equivalent.  The core plots (histogram, boxplot, scatterplot, means) are
still available from the **Graphs** menu.

## Available entries

| Entry | Use | Requires |
|---|---|---|
| Violin plot | Distribution shape by group | `vioplot` |
| Ordered chart | Bar chart sorted by frequency | — |
| Swimmer plot | One row per patient, from start to event | — |
| Sankey diagram | Flow between two categorical variables | `ggalluvial`, `ggplot2` |
| CONSORT diagram | Participant flow of a trial | — |
| Adjusted survival curve | Survival at the mean covariate values | `survival` |
| Adjusted cumulative incidence | Competing risks by group | `cmprsk` |
| Stacked cumulative incidences | Two competing events stacked | `cmprsk` |
| Graph settings | Default `par()` values for later plots | — |
| Summary table of results | Coefficients of the active model | — |

## Examples

Violin plot:

```r
vioplot::vioplot(score ~ group, data = Dataset, col = "grey80",
                 xlab = "group")
```

CONSORT diagram:

```r
local({
  .n <- c(screened = 100, excluded = 20, randomised = 80, analysed = 76)
  plot.new(); plot.window(xlim = c(0, 1), ylim = c(0, 1))
  .box <- function(x, y, label) {
    rect(x - 0.19, y - 0.055, x + 0.19, y + 0.055, col = "white")
    text(x, y, label, cex = 0.85)
  }
  .arrow <- function(x0, y0, x1, y1) arrows(x0, y0, x1, y1, length = 0.08)
  .box(0.42, 0.90, paste("Screened:", .n[["screened"]]))
  .box(0.82, 0.66, paste("Excluded:", .n[["excluded"]]))
  .box(0.42, 0.66, paste("Randomised:", .n[["randomised"]]))
  .box(0.42, 0.34, paste("Analysed:", .n[["analysed"]]))
  .arrow(0.42, 0.845, 0.42, 0.715)
  .arrow(0.61, 0.66, 0.63, 0.66)
  .arrow(0.42, 0.605, 0.42, 0.395)
})
```

Adjusted survival:

```r
local({
  .fit <- survival::survfit(
    survival::coxph(survival::Surv(time, event) ~ group, data = Dataset))
  plot(.fit, col = seq_along(.fit$strata), lwd = 2,
       xlab = "Time", ylab = "Adjusted survival")
})
```

Graph settings:

```r
par(cex = 1, lwd = 1, las = 0, bty = "o")
```

## Notes

- The adjusted survival curve is evaluated at the mean of the covariates; use
  it to compare groups after adjustment, not to predict individual survival.
- `cmprsk::cuminc()` expects a status variable coded `0` for censoring, `1` for
  the event of interest and `2` for the competing event.
- The Sankey diagram needs two factors; continuous variables are rejected.
- Plots are captured in the **Plots** tab and can be saved as PNG or PDF.

## See also

- `topic:ezr-overview`
- `topic:histogram`
- `topic:scatterplot`
