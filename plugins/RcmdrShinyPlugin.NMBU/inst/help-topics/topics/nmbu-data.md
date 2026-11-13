---
id: nmbu-data
title: Data utilities (NMBU)
type: task
category: plugins
order: 5
keywords: [sequence, center, clipboard, import, export, delete, nmbu]
aliases: [nmbu-data, mean-centering, clipboard-import]
dialogs: [createSequence, meanCenter]
commands: [seq, readClipboard, writeClipboard, rm, popOutput]
packages: [RcmdrShinyPlugin.NMBU]
related: [nmbu-tests, nmbu-models]
language: en
status: documented
---

# Data utilities (NMBU)

The NMBU **Data** menu adds a few shortcuts that the course uses constantly.

## Entries

| Entry | What it does |
|---|---|
| Automatic import from clipboard | Reads tab-separated data from the clipboard into `Dataset` |
| Export last result to clipboard | Copies the last printed object |
| Create data sequence | Builds `seq()` and stores it in a new data frame |
| Delete active data set | Removes the active data frame |
| Mean center variables | Subtracts each variable's mean, keeping the original |

## Examples

A sequence:

```r
s <- data.frame(x = seq(1, 10, by = 2))
```

Mean centering:

```r
D$x_c <- D$x - mean(D$x, na.rm = TRUE)
```

Clipboard import:

```r
Dataset <- read.table(text = utils::readClipboard(), header = TRUE, sep = "\t")
```

## Notes

- `readClipboard()` works on Windows and macOS; on Linux it returns an empty
  string.  Open the data through **Data > Import data** instead.
- Mean centering is useful before fitting models with polynomial terms or
  interactions: it reduces collinearity and makes the intercept interpretable.
- The centered variables keep the `_c` suffix by default; change it in the
  dialog.
- **Delete active data set** runs `rm()` and clears the active slot.  The
  command is written to the **Script** tab, so the deletion is reproducible.

## See also

- `topic:nmbu-tests`
- `topic:nmbu-models`
- `topic:data-editing`
