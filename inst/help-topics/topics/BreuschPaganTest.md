---
id: BreuschPaganTest
title: Breusch-Pagan Test
type: task
category: models
order: 1070
keywords: [breuschpagantest, breusch, pagan, test, bptest]
aliases: []
dialogs: [BreuschPaganTest]
commands: [bptest]
packages: [RcmdrShiny]
related: []
language: en
status: draft
---

## What it does

The **Breusch-Pagan Test** dialog is the menu entry `Models > Numerical diagnostics > Breusch-Pagan test for heteroscedasticity...`.

## How to fill it in

1. Choose the active data set if the dialog offers a selector.
2. Select the variables and options you need.
3. Press **OK**.

## What it produces

The generated command is written to the **Script** tab and evaluated in
the current session. Printed results appear in the **Output** tab; plots
appear in the **Plots** tab.

## R reference

`?bptest` (RcmdrShiny)

## See also

Browse the **Help** tab for related topics.
