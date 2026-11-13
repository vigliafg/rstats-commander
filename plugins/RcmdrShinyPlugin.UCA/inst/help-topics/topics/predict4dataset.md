---
id: predict4dataset
title: Predict values for existing dataset
type: task
category: plugins
order: 140
keywords: [predict4dataset, predict, values, for, existing, dataset]
aliases: []
dialogs: [predict4dataset]
commands: [predict]
packages: [RcmdrShinyPlugin.UCA]
related: []
language: en
status: documented
---

## What it does

The **Predict values for existing dataset** dialog is the menu entry `Models > Predict using active model > Predict values for existing dataset...`.

## How to fill it in

1. Choose the active data set if the dialog offers a selector.
2. Select the variables and options you need.
3. Press **OK**.

## What it produces

The generated command is written to the **Script** tab and evaluated in
the current session. Printed results appear in the **Output** tab; plots
appear in the **Plots** tab.

## R reference

`?predict` (RcmdrShinyPlugin.UCA)

## See also

Browse the **Help** tab for related topics.
