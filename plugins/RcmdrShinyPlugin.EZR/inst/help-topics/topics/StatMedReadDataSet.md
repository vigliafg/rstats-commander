---
id: StatMedReadDataSet
title: Read Text Data From File, Clipboard, or URL
type: task
category: plugins
order: 440
keywords: [statmedreaddataset, read, text, data, from, file, clipboard, or]
aliases: []
dialogs: [StatMedReadDataSet]
commands: [read.table]
packages: [RcmdrShinyPlugin.EZR]
related: []
language: en
status: documented
---

## What it does

The **Read Text Data From File, Clipboard, or URL** dialog is the menu entry `File > Import data > Read Text Data From File, Clipboard, or URL`.

## How to fill it in

1. Choose the active data set if the dialog offers a selector.
2. Select the variables and options you need.
3. Press **OK**.

## What it produces

The generated command is written to the **Script** tab and evaluated in
the current session. Printed results appear in the **Output** tab; plots
appear in the **Plots** tab.

## R reference

`?read.table` (RcmdrShinyPlugin.EZR)

## See also

Browse the **Help** tab for related topics.
