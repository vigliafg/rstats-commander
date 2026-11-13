---
id: doe-analyse
title: Inspect and analyse a design (DoE)
type: task
category: plugins
order: 7
keywords: [inspect, tabulate, contrasts, reshape, aggregate, centre points,
           effects, steepest, doe]
aliases: [doe-analyse, analyse-design, doe-inspect]
dialogs: [Menu.tab, Menu.responses, Menu.changecontr, Menu.wide,
          Menu.aggregate, Menu.addcenter, Menu.pickcube, Menu.PlotMeansDoE,
          Menu.steepest]
commands: [summary, table, contrasts, reshape, aggregate, cube, MEPlot,
           IAPlot, steepest]
packages: [DoE.base, rsm]
related: [doe-designs, doe-import-export]
language: en
status: documented
---

# Inspect and analyse a design (DoE)

## Inspecting

- **Tabulate active design** prints `summary()` and `table()`.
- **Select response variables** keeps the response columns.
- **Change factor contrasts** sets `contr.sum`, `contr.helmert` or
  `contr.treatment`.

```r
summary(design)
contrasts(design$A) <- "contr.sum"
```

Sum contrasts are the usual choice for ANOVA: they test each level against the
grand mean instead of against a reference level.

## Reshaping and aggregating

```r
reshape(design, idvar = "id", timevar = "time", direction = "wide")
aggregate(response ~ ., data = design, FUN = mean)
```

Aggregation is needed before fitting when replicate runs share the same factor
combination.

## Centre points and design portions

- **Add center points** appends runs with all numeric factors set to zero
  (coded units).
- **Remove star portion** keeps the cube of a central composite design:

```r
cube <- rsm::cube(design)
```

## Plots and steepest ascent

```r
DoE.base::MEPlot(design)
DoE.base::IAPlot(design)
rsm::steepest(model, dist = 1)
```

`MEPlot()` shows main effects, `IAPlot()` the two-factor interactions, and
`steepest()` the path of steepest ascent from the fitted model.

## See also

- `topic:doe-designs`
- `topic:doe-import-export`
