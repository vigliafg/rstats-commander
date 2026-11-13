# Plugin command aliases

Some plugin menu entries do the same thing as a core dialog.  Instead of
duplicating the dialog, a plugin declares an **alias**: the menu keeps its own
label and command id, but the command opens the core dialog or runs the core
direct command.

Aliases are registered with `RcmdrShiny.plugin(aliases = c(new = "core"))` and
resolved by `get_dialog()` and `direct_commands()`.  The dialog specification
keeps the alias id, so dialog memory and the Help button work per menu entry.

## EZR

| EZR command | Core command |
|---|---|
| `StatMedReadDataSet` | `readDataSet` |
| `StatMedLoadDataSet` | `loadDataSet` |
| `StatMedSaveDataSet` | `saveDataSet` |
| `StatMedLoadLogCP932` | `loadLog` |
| `StatMedImportSPSS` | `importSPSS` |
| `StatMedImportMinitab` | `importMinitab` |
| `StatMedImportSTATA` | `importSTATA` |
| `StatMedExportDataSet` | `exportDataSet` |
| `StatMedExportStata` | *new dialog* (`foreign::write.dta`) |
| `StatMedCompute` | `Compute` |
| `StatMedRecodeDialog` | `RecodeDialog` |
| `StatMedDeleteVariable` | `deleteVariable` |
| `StatMedRenameVariables` | `renameVariables` |
| `StatMedBinVariable` | `binVariable` |
| `StatMedNumericToFactor` | `numericToFactor` |
| `StatMedChrToFactor` | `characterToFactor` |
| `StatMedDropUnusedFactorLevels` | `dropUnusedFactorLevels` |
| `StatMedSetContrasts` | `setContrasts` |
| `StatMedReorderFactor` | `reorderFactor` |
| `StatMedStack` | `Stack` |
| `StatMedSubsetDataSet` | `subsetDataSet` |
| `StatMedSort` | `sortDataSet` |
| `StatMedCountMissing` | `countMissing` |
| `StatMedFilterNA` | `filterNA` |
| `StatMedFrequency` | `frequencyDistribution` |
| `StatMedNumericalSummaries` | `numericalSummaries` |
| `StatMedEnterTable` | `enterTable` |
| `StatMedRepANOVA` | `oneWayRepeatedMeasures` |
| `StatMedLinearRegression` | `linearModel` |
| `StatMedOrdinalRegressionModel` | `ordinalRegressionModel` |
| `StatMedMultinomialLogitModel` | `multinomialLogitModel` |
| `StatMedPieChart` | `pieChart` |
| `StatMedStemAndLeaf` | `stemAndLeaf` |
| `StatMedQQPlot` | `QQPlot` |
| `StatMedPlotMeans` | `PlotMeans` |
| `StatMedBarMeans` | `PlotMeans` |
| `StatMedLinePlot` | `linePlot` |
| `StatMedStripChart` | `stripChart` |
| `StatMedScatterPlotMatrix` | `scatterPlotMatrix` |
| `StatMedChangePalette` | `setPalette` |
| `StatMedSetPalette` | `setPalette` |

## NMBU

| NMBU command | Core command |
|---|---|
| `numericalSummariesNMBU` | `numericalSummaries` |
| `tally.GUI` | `frequencyDistribution` |
| `twoWayTableNMBU` | `twoWayTableFromCounts` |
| `enterTableNMBU` | `enterTable` |
| `histogram_discrete` | `DiscretePlot` |
| `linePlotNMBU` | `linePlot` |
| `dotplotGUI` | `DotPlot` |
| `sortData` | `sortDataSet` |
| `twoSamplesZTest` | `independentSamplesZTestNMBU` |
| `anova_reg_GUI` | `anovaTable` |
| `bestSubsets` | `subsetRegression` |
| `binomialDistributionPlotNMBU` | `binomialDistributionPlot` |
| `PoissonDistributionPlotNMBU` | `PoissonDistributionPlot` |
| `geomDistributionPlotNMBU` | `geomDistributionPlot` |
| `hyperDistributionPlotNMBU` | `hyperDistributionPlot` |
| `negbinomialDistributionPlotNMBU` | `negbinomialDistributionPlot` |
| `linearModelNMBU` | `linearModel` |
| `generalizedLinearModelNMBU` | `generalizedLinearModel` |
| `multinomialLogitModelNMBU` | `multinomialLogitModel` |
| `ordinalRegressionModelNMBU` | `ordinalRegressionModel` |
| `principalComponentsStat` | `principalComponents` |

## Counting rule

An alias is preferred when the menu entry and the core dialog have the same
statistical content.  When the plugin adds defaults, extra fields or a
different output, it gets its own dialog.  The EZR sample-size calculators,
for example, share a builder but keep seventeen distinct dialogs because the
questions and the inputs differ.
