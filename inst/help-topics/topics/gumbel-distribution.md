---
id: gumbel-distribution
title: Gumbel distribution
type: task
category: distributions
order: 190
keywords: [gumbel, extreme value, maximum, quantiles, probabilities, density,
           samples, vgam]
aliases: [gumbel, extreme-value-distribution]
dialogs: [GumbelQuantiles, GumbelProbabilities, GumbelDistributionPlot,
          GumbelDistributionSamples]
commands: [qgumbel, pgumbel, dgumbel, rgumbel]
packages: [VGAM]
related: [normal-distribution, weibull-distribution]
language: en
status: documented
---

# Gumbel distribution

The Gumbel distribution models the maximum (or minimum) of a large number of
independent observations: annual flood peaks, maximum wind speeds, extreme
rainfall, component lifetimes.  RcmdrShiny exposes it through the same four
dialogs as the other continuous families.

## Requirements

The distribution is provided by the **VGAM** package.  When VGAM is not
installed the four menu entries stay hidden instead of failing at run time:

```r
install.packages("VGAM")
```

## Available dialogs

| Dialog | Function | Use |
|---|---|---|
| Gumbel quantiles | `VGAM::qgumbel()` | Value with a given cumulative probability |
| Gumbel probabilities | `VGAM::pgumbel()` | Cumulative probability of a value |
| Plot Gumbel distribution | `VGAM::dgumbel()` | Density or distribution function |
| Sample from Gumbel distribution | `VGAM::rgumbel()` | Simulate a data set |

## Parameters

| Parameter | Meaning |
|---|---|
| `location` | Mode of the distribution; shifts the curve |
| `scale` | Spread; must be positive |

The standard Gumbel has `location = 0` and `scale = 1`.

## How to fill it in

1. Open **Distributions > Continuous distributions > Gumbel distribution**.
2. Pick the operation you need.
3. Enter `location` and `scale`.
4. For quantiles and probabilities choose the tail; for plots choose density
   or cumulative probability and, optionally, the plotting range.
5. Press **OK**.

## What it produces

```r
VGAM::qgumbel(c(0.5, 0.9, 0.99), location = 20, scale = 4,
              lower.tail = TRUE)
```

or, for a plot:

```r
curve(VGAM::dgumbel(x, location = 20, scale = 4),
      xlab = "x", ylab = "Density")
```

Sampling creates a data frame that becomes the active data set:

```r
GumbelSamples <- as.data.frame(matrix(
  VGAM::rgumbel(100, location = 20, scale = 4), ncol = 100))
```

## Reading the output

- The distribution is right-skewed; the mean is `location + 0.5772 * scale`
  and the variance is `pi^2 * scale^2 / 6`.
- Quantiles above about 0.9 grow quickly: that is the tail that matters for
  design values.
- The return period of a value `x` is `1 / (1 - pgumbel(x))`.

## See also

- `topic:weibull-distribution`
- `topic:normal-distribution`
- `topic:histogram`
