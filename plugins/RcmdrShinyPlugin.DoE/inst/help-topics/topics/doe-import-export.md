---
id: doe-import-export
title: Import and export designs (DoE)
type: task
category: plugins
order: 5
keywords: [import, export, csv, workspace, catalogue, design, doe]
aliases: [doe-import, doe-export, export-design]
dialogs: [loadworkspace, Menu.import, Menu.importrdacsv, Menu.export]
commands: [load, read.csv, write.csv, data]
packages: [FrF2, DoE.base]
related: [doe-designs, doe-analyse]
language: en
status: documented
---

# Import and export designs (DoE)

The **Design > Import** and **Design > Export** menus move an experiment
between R and disk.

## Import

| Entry | Use |
|---|---|
| Load R workspace | `load()` an `.RData` file |
| Load experiment from R workspace | Rename an existing design object |
| Re-import experiment from CSV | Read a design previously exported as CSV |

```r
load("workspace.RData")
design <- myDesign
design <- read.csv("design.csv")
```

A design created by `FrF2`, `DoE.base` or `rsm` is a data frame with extra
attributes.  `read.csv()` returns a plain data frame, so the design metadata
is lost; re-create the design from the dialog if you need it.

## Export

```r
write.csv(design, "design.csv", row.names = FALSE)
```

Export the design together with its response columns, so the analysis can be
reproduced from the CSV alone.

## Catalogue designs

**Experts: load additional catalogue** reads a catalogue entry shipped with
`FrF2`:

```r
utils::data(list = "catlg", package = "FrF2")
```

## See also

- `topic:doe-designs`
- `topic:doe-analyse`
