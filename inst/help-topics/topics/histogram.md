---
id: histogram
title: Histogram
type: task
category: graphs
keywords: [histogram, distribution, bins, density, plot, graph]
aliases: [hist, distribution-plot]
dialogs: [Histogram, DensityPlot, stemAndLeaf]
commands: [Hist, hist, densityPlot]
packages: [RcmdrMisc, graphics]
related: [numerical-summaries, scatterplot]
language: en
status: documented
---

# Histogram

**Graphs > Histogram...** shows the distribution of a numeric variable with
optional density, normal curve and grouping.

## How to fill it in

1. **Variable**: one numeric variable.
2. **Groups** (optional): draw one panel per factor level.
3. **Number of bins** or **bin width**: controls the resolution.  Too few bins
   hides shape, too many shows noise.
4. **Scale**: frequency, density or percent.
5. **Overlays**: normal curve, density estimate, rug plot.
6. Press **OK**.

## What it produces

```r
with(Dataset, Hist(variable, scale = "frequency", groups = factor,
                   breaks = "Sturges"))
```

The plot appears in the **Plots** tab, where it can be saved as PNG or PDF.

## Reading the plot

- Look for skewness, multiple modes and outliers before choosing a summary or a
  model.
- A long right tail often suggests a log transformation; use
  **Data > Manage variables > Compute new variable...** with `log(x)`.

## Related graphs

- **Graphs > Boxplot...** summarises the same distribution with quartiles.
- **Graphs > Density estimate...** is a smoothed histogram.
- **Graphs > Stem-and-leaf display...** prints a text version to the output.

## See also

- `topic:numerical-summaries`
- `topic:scatterplot`
