---
id: exporting-results
title: Exporting data and results
type: task
category: data
keywords: [export, save, csv, write, output, table, script, report]
aliases: [export, save-data, write-csv]
dialogs: [exportDataSet, saveOptions, loadLog]
commands: [write.table, capture.output, xtable]
packages: [utils]
related: [data-import, getting-started]
language: en
status: documented
---

# Exporting data and results

RcmdrShiny can write the active data set to disk and lets you copy or save the
commands and output produced by the session.

## Export the active data set

Open **Data > Active data set > Export active data set...**.

1. Pick the destination file.
2. Choose the field separator (comma, semicolon, tab or space).
3. Choose whether to write variable names, row names and quotes.
4. Enter the missing-value string, usually `NA`.
5. Press **OK**.

The dialog generates:

```r
write.table(Dataset, "data/clean.csv", sep = ",", col.names = TRUE,
            row.names = FALSE, quote = TRUE, na = "NA")
```

## Export output and code

- The **Script** tab holds every command generated in the session.  Use the
  editor buttons to save it as an `.R` file.
- The **Output** tab holds printed results; copy it into a report or use
  **File > Save output to file...** where available.
- **File > Open script file...** loads a saved script back into the editor, and
  **File > Save script...** writes the current one.

## Reproducible reports

Because every action is recorded as R code, a reliable workflow is:

1. Work through the dialogs.
2. Copy the **Script** tab into an R Markdown document.
3. Knit the document to HTML, PDF or Word.

The package vignette `getting-started` shows the complete flow.

## See also

- `topic:data-import`
- `topic:getting-started`
