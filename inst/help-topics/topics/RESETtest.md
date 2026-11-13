---
id: RESETtest
title: RESET Test
type: task
category: models
order: 1090
keywords: [resettest, reset, test]
aliases: []
dialogs: [RESETtest]
commands: [resettest]
packages: [RcmdrShiny]
related: []
language: en
status: draft
---

## What it does

The **RESET Test** dialog is the menu entry `Models > Numerical diagnostics > RESET test for nonlinearity...`.

## How to fill it in

1. Choose the active data set if the dialog offers a selector.
2. Select the variables and options you need.
3. Press **OK**.

## What it produces

The generated command is written to the **Script** tab and evaluated in
the current session. Printed results appear in the **Output** tab; plots
appear in the **Plots** tab.

## R reference

`?resettest` (RcmdrShiny)

## See also

Browse the **Help** tab for related topics.
