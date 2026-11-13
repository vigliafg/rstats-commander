---
id: randomnessNTest
title: Randomness test for numeric variable
type: task
category: plugins
order: 120
keywords: [randomnessntest, randomness, test, for, numeric, variable, runs.test]
aliases: []
dialogs: [randomnessNTest]
commands: [runs.test]
packages: [tseries]
related: []
language: en
status: draft
---

## What it does

The **Randomness test for numeric variable** dialog is the menu entry `Statistics > Nonparametric tests > Randomness test for numeric variable...`.

## How to fill it in

1. Choose the active data set if the dialog offers a selector.
2. Select the variables and options you need.
3. Press **OK**.

## What it produces

The generated command is written to the **Script** tab and evaluated in
the current session. Printed results appear in the **Output** tab; plots
appear in the **Plots** tab.

## R reference

`?runs.test` (tseries)

## See also

Browse the **Help** tab for related topics.
