---
id: filterNA
title: Remove Missing Data
type: task
category: data
order: 290
keywords: [filterna, remove, missing, data, na.omit]
aliases: []
dialogs: [filterNA]
commands: [na.omit]
packages: [RcmdrShiny]
related: []
language: en
status: draft
---

## What it does

The **Remove Missing Data** dialog is the menu entry `Data > Active data set > Remove cases with missing data...`.

## How to fill it in

1. Choose the active data set if the dialog offers a selector.
2. Select the variables and options you need.
3. Press **OK**.

## What it produces

The generated command is written to the **Script** tab and evaluated in
the current session. Printed results appear in the **Output** tab; plots
appear in the **Plots** tab.

## R reference

`?na.omit` (RcmdrShiny)

## See also

Browse the **Help** tab for related topics.
