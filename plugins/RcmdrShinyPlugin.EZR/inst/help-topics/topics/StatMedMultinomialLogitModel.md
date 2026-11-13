---
id: StatMedMultinomialLogitModel
title: Multinomial Logit Model
type: task
category: plugins
order: 560
keywords: [statmedmultinomiallogitmodel, multinomial, logit, model, multinom]
aliases: []
dialogs: [StatMedMultinomialLogitModel]
commands: [multinom]
packages: [RcmdrShinyPlugin.EZR]
related: []
language: en
status: draft
---

## What it does

The **Multinomial Logit Model** dialog is the menu entry `Statistical analysis > Discrete variables > Multinomial logistic regression`.

## How to fill it in

1. Choose the active data set if the dialog offers a selector.
2. Select the variables and options you need.
3. Press **OK**.

## What it produces

The generated command is written to the **Script** tab and evaluated in
the current session. Printed results appear in the **Output** tab; plots
appear in the **Plots** tab.

## R reference

`?multinom` (RcmdrShinyPlugin.EZR)

## See also

Browse the **Help** tab for related topics.
