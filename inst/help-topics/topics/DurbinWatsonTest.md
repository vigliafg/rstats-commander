---
id: DurbinWatsonTest
title: Durbin-Watson Test
type: task
category: models
order: 1080
keywords: [durbinwatsontest, durbin, watson, test, dwtest]
aliases: []
dialogs: [DurbinWatsonTest]
commands: [dwtest]
packages: [RcmdrShiny]
related: []
language: en
status: documented
---

## What it does

The **Durbin-Watson Test** dialog is the menu entry `Models > Numerical diagnostics > Durbin-Watson test for autocorrelation...`.

## How to fill it in

1. Choose the active data set if the dialog offers a selector.
2. Select the variables and options you need.
3. Press **OK**.

## What it produces

The generated command is written to the **Script** tab and evaluated in
the current session. Printed results appear in the **Output** tab; plots
appear in the **Plots** tab.

## R reference

`?dwtest` (RcmdrShiny)

## See also

Browse the **Help** tab for related topics.
