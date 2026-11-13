---
id: data-import
title: Importing data
type: task
category: data
keywords: [import, read, csv, excel, spss, stata, sas, clipboard, url, text]
aliases: [import, read-data, load-data]
dialogs: [readDataSet, importExcel, importSPSS, importSTATA, importSAS, importSASb7dat, importMinitab, readDataFromPackage]
commands: [read.table, readXL, readSPSS, readStata, read.xport, readSAS, read.mtp]
packages: [utils, RcmdrMisc]
related: [data-editing, exporting-results]
language: en
status: documented
---

# Importing data

Use the import dialogs to read a file into the R session and make it the active
data set.  Importing never modifies the file on disk.

## When to use it

- You have a CSV, tab-separated or whitespace-separated text file.
- You have a spreadsheet, SPSS, Stata, SAS or Minitab file.
- You want to work with a data set that ships with an installed R package.

## Choose the right dialog

| Source | Menu entry |
|---|---|
| Text file, clipboard or URL | **Data > Import data > from text file, clipboard, or URL...** |
| Excel | **Data > Import data > from Excel file...** |
| SPSS | **Data > Import data > from SPSS data set...** |
| Stata | **Data > Import data > from Stata data set...** |
| SAS | **Data > Import data > from SAS data set...** |
| Minitab | **Data > Import data > from Minitab data set...** |
| Installed package | **Data > Read data set from an attached package...** |

## How to fill it in

1. Type the file name, or use **Browse** to pick it.
2. Set the field separator, decimal mark and quote character for text files.
3. Decide whether the first row contains variable names.
4. Choose how missing values are coded (`NA`, empty strings, a sentinel such as
   `-99`).
5. Give the data set a name; the dialog suggests one derived from the file name.
6. Press **OK**.

## What it produces

A command such as:

```r
Data <- read.table("data/survey.csv", header = TRUE, sep = ",", na.strings = "NA")
```

The new object appears in the **Environment** tab and becomes the active data
set, so the menus that need data become enabled.

## Tips

- Variables whose values look like text are imported as factors, matching
  Rcmdr's behaviour.
- Use **Data > Active data set > Convert character variables to factors...** if
  a column arrives as text when you expected a factor.
- The working directory is shown in **File > Change working directory...**.

## See also

- `topic:data-editing`
- `topic:exporting-results`
