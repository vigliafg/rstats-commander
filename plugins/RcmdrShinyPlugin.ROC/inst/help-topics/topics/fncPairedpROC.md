---
id: fncPairedpROC
title: Paired ROC curves comparison
type: task
category: plugins
order: 110
keywords: [fncpairedproc, paired, roc, curves, comparison, roc.test]
aliases: []
dialogs: [fncPairedpROC]
commands: [roc.test]
packages: [pROC]
related: []
language: en
status: draft
---

## What it does

The **Paired ROC curves comparison** dialog is the menu entry `ROC > pROC > Paired ROC curves comparison...`.

## How to fill it in

1. Choose the active data set if the dialog offers a selector.
2. Select the variables and options you need.
3. Press **OK**.

## What it produces

The generated command is written to the **Script** tab and evaluated in
the current session. Printed results appear in the **Output** tab; plots
appear in the **Plots** tab.

## R reference

`?roc.test` (pROC)

## See also

Browse the **Help** tab for related topics.
