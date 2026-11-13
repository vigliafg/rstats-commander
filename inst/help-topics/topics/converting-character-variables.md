---
id: converting-character-variables
title: Converting text columns to factors
type: task
category: data
order: 45
keywords: [character, string, factor, convert, categorical, encoding]
aliases: [strings-to-factors, character-to-factor, convertStrings2Factors]
dialogs: [characterToFactor]
commands: [factor, as.factor, convertStrings2Factors]
packages: [RcmdrShiny]
related: [data-editing, numericToFactor]
language: en
status: documented
---

# Converting text columns to factors

R imports text columns as character vectors.  Models, tables and graphs treat
character columns as factors in most cases, but explicit factors give you
control over the order of the levels, which is what the reference category of a
model depends on.

## Two ways to do it

| Situation | Command |
|---|---|
| Convert every character column at once | **Data > Active data set > Convert all character variables to factors** |
| Choose the columns and the new names | **Data > Manage variables > Convert character variables to factors...** |

The first is a direct command: it writes one `within()` block per column and
runs it immediately.  The second opens a dialog where you can rename the result
or create a copy with a prefix.

## What it produces

```r
Dataset <- within(Dataset, {
  group <- as.factor(group)
})
```

and, for the dialog with a prefix:

```r
Dataset <- within(Dataset, {
  group_f <- as.factor(group)
})
```

## Why the level order matters

`factor()` sorts the levels alphabetically by default.  In a model the first
level is the reference, so `control` and `treatment` give a coefficient for
`treatment` versus `control`, while `a` and `b` are less informative.  Set the
order explicitly with **Data > Manage variables > Reorder factor levels...**.

## When not to convert

- Free-text identifiers (names, record numbers) should stay character; a factor
  with hundreds of levels slows models down.
- Dates should be parsed with `as.Date()` rather than turned into factors.
- A numeric column imported as text usually means a decimal mark or thousands
  separator problem; fix the import instead of converting.

## See also

- `topic:data-editing`
- `topic:data-import`
- `topic:linear-model`
