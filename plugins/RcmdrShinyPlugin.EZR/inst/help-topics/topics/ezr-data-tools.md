---
id: ezr-data-tools
title: Data and variable tools (EZR)
type: task
category: plugins
order: 6
keywords: [data set, copy, rename, merge, workspace, cp932, csv, stata, bin,
           log, numeric, factor, ezr]
aliases: [ezr-data, cp932, data-management]
dialogs: [StatMedCopyDataset, StatMedRenameDataset, StatMedMergeDatasets,
          StatMedLoadWorkspace, StatMedLoadCP932DataSet, StatMedRenewDataSet,
          StatMedExportStata, StatMedNewVar, StatMedNewVar2, StatMedLog,
          StatMedFactorToNumeric]
commands: [read.csv, merge, load, write.dta, cut, log, as.numeric]
packages: [foreign]
related: [ezr-overview, ezr-sample-size]
language: en
status: documented
---

# Data and variable tools (EZR)

EZR adds file and variable shortcuts that match the clinical workflow: loading
Japanese-encoded CSVs, copying and merging data sets, binning by threshold and
turning numeric factors back into numbers.

## Files and data sets

| Entry | What it does |
|---|---|
| **File > Load CP932 data set** | Reads a CSV encoded with Windows Japanese CP932 |
| **File > Copy data set** | Duplicates the active data set under a new name |
| **File > Rename data set** | Renames the active data set and removes the old object |
| **File > Merge data sets** | Merges two data frames, optionally by a key variable |
| **File > Load work space file** | Runs `load()` on an `.RData` file |
| **Active data set > Renew active data set** | Re-reads the source CSV into the active data set |
| **Active data set > Export (Stata)** | Writes a `.dta` file with `foreign::write.dta()` |

CP932 import is the EZR default for files produced on Japanese Windows:

```r
Dataset <- read.csv("data.csv", fileEncoding = "CP932")
```

Merging:

```r
first.merged <- merge(first, second, by = "id")
```

## Variables

| Entry | Result |
|---|---|
| **Bin numeric variable with specified threshold** | `cut()` with one break |
| **Bin numeric variable with more than 2 groups** | `cut()` with several breaks |
| **Logarithmic transformation** | `log()` of a positive variable |
| **Convert factors or character variables to numeric** | `as.numeric(as.character(x))` |

```r
Dataset$binned <- cut(Dataset$age, breaks = c(-Inf, 40, 65, Inf), right = FALSE)
Dataset$log_age <- log(Dataset$age)
Dataset$score <- as.numeric(as.character(Dataset$score))
```

## Notes and pitfalls

- `cut(..., right = FALSE)` produces intervals closed on the left, which is
  what EZR reports; the labels are `[a,b)` ranges.
- `log()` is natural logarithms.  Zero or negative values produce `-Inf` or
  `NaN`; add a constant first if the variable contains zeros.
- Merging without a key requires the same column names; check with
  **Statistics > Summaries > Active data set** first.
- `as.numeric(as.character(x))` is safe for factors whose labels are numbers;
  converting the factor directly would return the level codes instead.
- Exporting to Stata truncates variable names to 32 characters and converts
  factors to labelled integers.

## See also

- `topic:ezr-overview`
- `topic:data-import`
- `topic:data-editing`
