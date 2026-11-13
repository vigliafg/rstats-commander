---
id: data-editing
title: Editing and transforming data
type: task
category: data
keywords: [compute, recode, rename, delete, subset, transform, variable, factor]
aliases: [edit-data, transform, recode]
dialogs: [Compute, RecodeDialog, deleteVariable, renameVariables, subsetDataSet, binVariable, numericToFactor, characterToFactor, reorderFactor, standardize]
commands: [within, Recode, subset, cut, factor, scale]
packages: [RcmdrMisc]
related: [data-import, numerical-summaries]
language: en
status: documented
---

# Editing and transforming data

The data menu provides non-destructive transformations: the original data set is
replaced only when you confirm the dialog, and R code is written for every
change.

## Common operations

| Operation | Where |
|---|---|
| Create a variable from an expression | **Data > Manage variables > Compute new variable...** |
| Recode values of a variable | **Data > Manage variables > Recode variables...** |
| Convert numeric to factor | **Data > Manage variables > Convert numeric variables to factors...** |
| Rename variables | **Data > Active data set > Rename variables...** |
| Delete variables | **Data > Manage variables > Delete variables...** |
| Keep a subset of rows | **Data > Active data set > Subset active data set...** |
| Bin a numeric variable | **Data > Manage variables > Bin a numeric variable...** |
| Standardise variables | **Data > Manage variables > Standardize variables...** |

## How to fill it in

1. Choose the active data set if the dialog offers a selector.
2. Select the variables to change.  Multiple selection uses the usual
   click-with-`Ctrl` and shift-click conventions.
3. Enter the new name or the expression.  In **Compute new variable** you can
   use any R expression that refers to the columns by name, for example
   `(height + weight) / 2`.
4. For **Recode**, define the old values and their replacements; the dialog
   builds a `Recode()` call with the separator you choose.
5. Press **OK**.

## What it produces

```r
Dataset <- within(Dataset, {
  bmi <- weight / (height / 100)^2
})
```

or, for a recode:

```r
Dataset <- within(Dataset, {
  ageGroup <- Recode(age, "'0:17'='child'; '18:64'='adult'; else='senior'")
})
```

## Tips

- **Reset** restores the values the dialog had when it was opened; **Cancel**
  leaves the data untouched.
- A failed command is shown in the **Messages** tab and the dialog stays open
  so you can correct the input.
- `topic:data-import` explains how to get data into the session first.

## See also

- `topic:data-import`
- `topic:exporting-results`
