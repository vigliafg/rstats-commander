---
id: getting-started
title: Your first analysis
type: tutorial
category: getting-started
keywords: [start, first, tutorial, overview, workflow, quickstart]
aliases: [start, quickstart, first-analysis]
dialogs: []
commands: []
packages: [RcmdrShiny]
related: [data-import, numerical-summaries, linear-model]
language: en
status: documented
---

# Your first analysis

This tutorial walks through a complete session: load data, describe it, fit a
model and export the results.  Every action writes reproducible R code to the
**Script** tab, so you can copy the whole analysis into a script file.

## 1. Start the application

```r
RcmdrShiny::run()
```

The browser opens the local interface.  The left sidebar holds the application
menus; the right side holds the tabs **Script**, **Output**, **Messages**,
**Plots**, **Data**, **Environment** and **Help**.

## 2. Load a data set

Open **Data > Import data > from text file, clipboard, or URL...** and choose a
file, or type the name of a data set that is already loaded in R.

If you just want to explore, load a packaged data set with
**Data > Read data set from an attached package...** and pick `mtcars`.

## 3. Describe the data

- **Statistics > Summaries > Active data set** prints `summary()`.
- **Statistics > Summaries > Numerical summaries...** produces a table of
  means, standard deviations and counts.
- **Statistics > Summaries > Frequency distributions...** tabulates factors.

## 4. Fit a model

Open **Models > Linear model...**, select the response and the explanatory
variables, and press **OK**.  The model is stored in the active model slot and
appears in the **Environment** tab.

## 5. Export the results

Open **Data > Active data set > Export active data set...** to write a CSV file,
or copy the code from the **Script** tab into an R Markdown document.

## What you get

Every dialog writes a command such as:

```r
numSummary(mtcars[, c("mpg", "hp")])
```

The command is evaluated in the session and its output is captured in the
**Output** tab.  This is the core promise of RcmdrShiny: a graphical interface
that never hides the R code it generates.

## See also

- `topic:data-import`
- `topic:numerical-summaries`
- `topic:linear-model`
