---
id: setRandomSeed
title: Set Random Seed
type: task
category: distributions
order: 950
keywords: [setrandomseed, set, random, seed, set.seed]
aliases: []
dialogs: [setRandomSeed]
commands: [set.seed]
packages: [RcmdrShiny]
related: []
language: en
status: draft
---

## What it does

The **Set Random Seed** dialog is the menu entry `Distributions > Set random number generator seed...`.

## How to fill it in

1. Choose the active data set if the dialog offers a selector.
2. Select the variables and options you need.
3. Press **OK**.

## What it produces

The generated command is written to the **Script** tab and evaluated in
the current session. Printed results appear in the **Output** tab; plots
appear in the **Plots** tab.

## R reference

`?set.seed` (RcmdrShiny)

## See also

Browse the **Help** tab for related topics.
