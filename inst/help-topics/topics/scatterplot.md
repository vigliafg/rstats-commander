---
id: scatterplot
title: Scatterplot
type: task
category: graphs
keywords: [scatterplot, scatter, relationship, xy, smooth, plot, groups]
aliases: [scatter, xyplot]
dialogs: [scatterPlot, scatterPlotMatrix, Scatter3D, Xyplot]
commands: [scatterplot, scatterplotMatrix, xyplot, scatter3d]
packages: [car, lattice]
related: [correlation, linear-model]
language: en
status: documented
---

# Scatterplot

**Graphs > Scatterplot...** plots one numeric variable against another and can
add a smoother, a regression line and grouping.

## How to fill it in

1. **X variable** and **Y variable**: the two numeric variables.
2. **Plot by groups** (optional): colour the points by a factor and optionally
   fit separate lines.
3. **Smoother**: loess, linear or none.
4. **Options**: jitter, point labels, span for the smoother.
5. Press **OK**.

## What it produces

```r
scatterplot(y ~ x | group, data = Dataset, smooth = TRUE)
```

The plot is captured in the **Plots** tab.

## Reading the plot

- Check the shape before trusting a correlation: a curve means Pearson's `r`
  understates the association.
- Widening spread suggests heteroscedasticity; a log transformation of `y` often
  helps.
- Points far from the cloud are candidates for the influence diagnostics of a
  linear model.

## Variations

| Dialog | Use |
|---|---|
| **Scatterplot matrix** | Several variables at once |
| **3D scatterplot** | Three numeric variables, requires `rgl` |
| **XY conditioning plot** | Trellis panels for each combination of factors |

## See also

- `topic:correlation`
- `topic:linear-model`
- `topic:histogram`
