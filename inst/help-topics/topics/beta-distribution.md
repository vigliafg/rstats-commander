---
id: beta-distribution
title: Beta distribution
type: task
category: distributions
order: 160
keywords: [beta, proportion, quantiles, probabilities]
aliases: []
dialogs: [betaQuantiles, betaProbabilities, betaDistributionPlot, betaDistributionSamples]
commands: [qbeta, pbeta, dbeta, rbeta]
packages: [stats]
related: []
language: en
status: draft
---

## What it does

The Beta distribution dialogs cover the four operations available for this distribution: quantiles, probabilities, density and random samples. Each dialog generates a call to the corresponding R function.

## Available dialogs

| Dialog | Title |
|---|---|
| `betaQuantiles` | Beta Quantiles |
| `betaProbabilities` | Beta Probabilities |
| `betaDistributionPlot` | Beta Distribution |
| `betaDistributionSamples` | Beta Samples |

## How to fill it in

1. Choose the operation you need from the **Distributions** menu.
2. Enter the parameters: `mean` and `sd` for the normal distribution,
   `df` for t and chi-squared, and so on.
3. For probabilities, choose whether you need the lower tail, the upper
   tail or both.
4. Press **OK**.

## What it produces

```r
qnorm(0.95, mean = 0, sd = 1)
```

The command is written to the **Script** tab and evaluated in the session.
Printed values appear in the **Output** tab; distribution plots appear in
the **Plots** tab.

## See also

- `topic:histogram`
- `topic:numerical-summaries`
