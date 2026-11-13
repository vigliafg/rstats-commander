---
id: normal-distribution
title: Normal distribution
type: task
category: distributions
order: 100
keywords: [normal, gaussian, quantiles, probabilities, density, random]
aliases: []
dialogs: [normalQuantiles, normalProbabilities, normalDistributionPlot, normalDistributionSamples]
commands: [qnorm, pnorm, dnorm, rnorm]
packages: [stats]
related: []
language: en
status: documented
---

## What it does

The Normal distribution dialogs cover the four operations available for this distribution: quantiles, probabilities, density and random samples. Each dialog generates a call to the corresponding R function.

## Available dialogs

| Dialog | Title |
|---|---|
| `normalQuantiles` | Normal Quantiles |
| `normalProbabilities` | Normal Probabilities |
| `normalDistributionPlot` | Normal Distribution |
| `normalDistributionSamples` | Normal Samples |

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
