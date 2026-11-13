---
id: ezr-sample-size
title: Sample size and power (EZR)
type: task
category: plugins
order: 5
keywords: [sample size, power, pwr, proportions, means, hazard, phase II,
           non-inferiority, ezr]
aliases: [sample-size, power, numerosita-campionaria]
dialogs: [StatMedSamplePhaseII, StatMedSampleProportionsCI,
          StatMedSampleProportionsSingle, StatMedPowerProportionsSingle,
          StatMedSampleProportions, StatMedPowerProportions,
          StatMedSampleProportionsNonInf, StatMedSampleSelectionDesign,
          StatMedSampleMeansCI, StatMedSampleMeans, StatMedPowerMeans,
          StatMedSampleMeansNonInf, StatMedSampleMeansPaired,
          StatMedPowerMeansPaired, StatMedSampleHazard, StatMedPowerHazard,
          StatMedSampleHazardNonInf]
commands: [pwr.p.test, pwr.2p.test, pwr.t.test, ph2simon, ph2single]
packages: [pwr, clinfun]
related: [ezr-overview]
language: en
status: documented
---

# Sample size and power (EZR)

**Statistical analysis > Calculate sample size** groups the seventeen EZR
sample-size and power calculators.  Each entry is a small dialog around one
statistical question; all of them write a single `pwr` or `clinfun` call.

## Which entry do I need?

| Question | Entry |
|---|---|
| One proportion, confidence interval | Sample size from proportion and confidence interval |
| One proportion against a reference | Sample size / power for comparison with a specified proportion |
| Two independent proportions | Sample size / power for comparison between two proportions |
| Two proportions, non-inferiority | Sample size for a non-inferiority trial of two proportions |
| One mean, confidence interval | Sample size from standard deviation and confidence interval |
| Two independent means | Sample size / power for comparison between two means |
| Two means, non-inferiority | Sample size for a non-inferiority trial of two means |
| Two paired means | Sample size / power for comparison between two paired means |
| Two survival curves | Sample size / power for comparison between two survival curves |
| Two survival curves, non-inferiority | Sample size for a non-inferiority trial of two survival curves |
| Single-arm phase II | Sample size from control and desired response rates |
| Randomised phase II selection | Sample size for a selection design |

## Common inputs

- **Significance level** (`alpha`): usually `0.05`.
- **Power**: usually `0.8` or `0.9`; the power entries instead ask for the
  sample size and report the power.
- **Alternative hypothesis**: two-sided, greater or less.
- **Non-inferiority margin**: only for the non-inferiority entries.

## What it produces

Sample size for two proportions:

```r
pwr::pwr.2p.test(h = pwr::ES.h(0.4, 0.6), sig.level = 0.05, power = 0.8,
                 alternative = "two.sided")
```

Sample size for a confidence interval around one proportion:

```r
ceiling(0.5 * (1 - 0.5) * (qnorm(1 - 0.05/2) / 0.1)^2)
```

Two survival curves (Schoenfeld's formula):

```r
ceiling((qnorm(1 - 0.05/2) + qnorm(0.8))^2 /
          (log(0.7)^2 * 0.25) / 0.6)
```

Phase II:

```r
clinfun::ph2simon(pu = 0.4, pa = 0.2, ep1 = 0.05, ep2 = 0.1)
```

## Requirements

`pwr` powers most entries and `clinfun` provides the two phase II designs.
When a package is missing the corresponding menu entries stay hidden; install
them with:

```r
install.packages(c("pwr", "clinfun"))
```

## Reading the output

`pwr` prints the sample size per group rounded up, the effect size and the
actual power.  `clinfun::ph2simon()` prints a table of optimal and minimax
two-stage designs; the minimax row has the smallest maximum sample size.
`clinfun::ph2single()` prints the single-stage sample size for the selection
design.

## See also

- `topic:ezr-overview`
- `topic:StatMedTtest`
- `topic:StatMedProbSingle`
