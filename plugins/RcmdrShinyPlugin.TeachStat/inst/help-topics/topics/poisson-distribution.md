---
id: poisson-distribution
title: Poisson distribution
type: task
category: distributions
order: 150
keywords: [poisson, counts, quantiles, probabilities]
aliases: []
dialogs: [PoissonDistrQuantiles, PoissonProbabilitiesInter, PoissonDistrMass, PoissonDistrPlot, PoissonDistrCharac, PoissonDistrSamples]
commands: [qpois, ppois, dpois, rpois]
packages: [stats]
related: []
language: en
status: draft
---

## What it does

The Poisson distribution dialogs cover the four operations available for this distribution: quantiles, probabilities, density and random samples. Each dialog generates a call to the corresponding R function.

## Available dialogs

| Dialog | Title |
|---|---|
| `PoissonDistrQuantiles` | Quantiles of the Poisson distribution |
| `PoissonProbabilitiesInter` | Probabilities of the Poisson distribution |
| `PoissonDistrMass` | Probabilities of the Poisson distribution |
| `PoissonDistrPlot` | Plot of the Poisson distribution |
| `PoissonDistrCharac` | Characteristics of the Poisson distribution |
| `PoissonDistrSamples` | Sample from the Poisson distribution |

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
