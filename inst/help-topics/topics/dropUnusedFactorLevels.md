---
id: dropUnusedFactorLevels
title: Drop Unused Factor Levels
type: task
category: data
order: 370
keywords: [dropunusedfactorlevels, drop, unused, factor, levels, droplevels]
aliases: []
dialogs: [dropUnusedFactorLevels]
commands: [droplevels]
packages: [RcmdrShiny]
related: []
language: en
status: draft
---

## What it does

The **Drop Unused Factor Levels** dialog is the menu entry `Data > Manage variables in active data set > Drop unused factor levels...`.

## How to fill it in

1. Choose the active data set if the dialog offers a selector.
2. Select the variables and options you need.
3. Press **OK**.

## What it produces

The generated command is written to the **Script** tab and evaluated in
the current session. Printed results appear in the **Output** tab; plots
appear in the **Plots** tab.

## R reference

`?droplevels` (RcmdrShiny)

## See also

Browse the **Help** tab for related topics.
