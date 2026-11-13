---
id: doe-designs
title: Design types and glossary (DoE)
type: concept
category: plugins
order: 6
keywords: [factorial, fractional, orthogonal array, ccd, box-behnken, lhs,
           d-optimal, taguchi, glossary, doe]
aliases: [doe-designs, design-types, glossary-doe]
dialogs: [Menu.cand, Menu.param, Menu.loadcatlg, Menu.augmentlhs]
commands: [fac.design, param.design, randomLHS, augmentLHS, optFederov]
packages: [DoE.base, FrF2, rsm, lhs, AlgDesign]
related: [doe-import-export, doe-analyse]
language: en
status: documented
---

# Design types and glossary (DoE)

## Two-level designs

- **Screening (Plackett-Burman)**: many factors, few runs, main effects only.
- **Fractional factorial**: `2^(k-p)` runs with a chosen resolution.
- **Full factorial**: all combinations; estimates every interaction.

Resolution IV designs confound main effects with three-factor interactions;
resolution V designs confound them with four-factor interactions.

## General and quantitative designs

- **General full factorial**: factors with more than two levels.
- **Orthogonal array**: Taguchi-style arrays.
- **Latin hypercube**: space-filling designs for computer experiments.

## Response surface designs

- **Central composite**: cube plus star points plus centre points.
- **Box-Behnken**: no corner runs, three levels per factor.
- **D-optimal**: best subset of candidate runs for a given model.

## Candidate and parameter designs

The candidate design provides the pool of runs for `AlgDesign::optFederov()`:

```r
candidates <- DoE.base::fac.design(nfactors = 3, nlevels = 2, replications = 1)
```

A parameter design crosses an inner array with an outer (noise) array:

```r
param <- DoE.base::param.design(inner, outer)
```

## Glossary

- **Factor**: a controlled experimental variable.
- **Level**: a value of a factor.
- **Run**: one combination of factor levels.
- **Replicate**: a repeated run.
- **Block**: a group of runs homogeneous in nuisance factors.
- **Confounding**: two effects estimated by the same contrast.
- **Resolution**: the length of the shortest word in the defining relation.
- **Centre point**: a run with all factors at their middle level.

## See also

- `topic:doe-import-export`
- `topic:doe-analyse`
