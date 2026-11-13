# RcmdrShiny 1.3.0

## Plugin Wave 2

- Added `RcmdrShinyPlugin.TeachingDemos`: central limit theorem, confidence
  interval simulation, power, coin and die simulations, regression and
  correlation demos, and distribution visualization.  The plugin removes the
  duplicated core distribution entries.
- Added `RcmdrShinyPlugin.KMggplot2`: ggplot2 histograms, Q-Q plots, box,
  violin and confidence-interval plots, scatter, line, pie, bar and contour
  plots, scatter matrices, Kaplan-Meier curves, factor conversion and 17
  distribution plots.
- Added `RcmdrShinyPlugin.HH`: two-way tables, best subsets, confidence
  interval plots, predictions, scatter and lattice plots, Likert plots,
  interaction plots, ANOVA tables, hypothesis plots, MMC and projector
  settings.
- Added `RcmdrShinyPlugin.TeachStat`: descriptive statistics, index numbers,
  random-variable dialogs, confidence intervals and hypothesis tests, plus the
  data-management menu using the core dialogs.
- Core: `nonFactorsP()`, `twoOrMoreLevelFactorsP()`, `aovModelsP()`,
  `AbscontDistrsP()` and `DiscreteDistrsP()` activation predicates.
- Core: `two_level_factors()` is now part of the plugin API.
- Core: plugin names that clash with another plugin now warn and override
  instead of blocking the session; clashes with core still fail.
- Ten plugins now load together (474 menu leaves).

# RcmdrShiny 1.2.0

## Plugin Wave 1

- Added `RcmdrShinyPlugin.Export`: xtable/HTML export, Hmisc LaTeX export and
  `format.df`, with a compatible last-output stack.
- Added `RcmdrShinyPlugin.sos`: R help search with multiple terms, union or
  intersection, column filtering and spreadsheet output.
- Added `RcmdrShinyPlugin.PcaRobust`: robust PCA with ROBPCA, loadings, scores
  and the five diagnostic plots.
- Added `RcmdrShinyPlugin.ROC`: single, paired and unpaired ROC curves,
  logistic-model ROC curves and Hosmer-Lemeshow tests.
- Added `RcmdrShinyPlugin.UCA`: variance and randomness tests, predictions,
  Pareto charts and 21 quality-control charts.
- Core additions for plugins: `popOutput()`, `get_dialog()`, `glmP()`/`lmP()`
  activation predicates, lazy attachment of optional plugin packages and plot
  capture for `screeplot`, `biplot`, `qcc` and `paretochart`.
- Plugin packages are versioned 0.1.0 and tested with `R CMD check`.

# RcmdrShiny 1.1.0

## Plugin infrastructure (Wave 0)

- New `RcmdrShinyPlugin.*` package protocol: `load_plugin_package()` loads the
  namespace and calls the exported `rcmdrshiny_plugin()`.
- Plugin packages can also return a plugin specification, or a list of
  specifications, instead of registering a plugin directly.
- Legacy `RcmdrPlugin.*` packages keep the menus-only compatibility path.
- `RcmdrShiny.plugin()` accepts `predicates` for plugin-specific activation
  expressions and `replace` for explicit overrides.
- Command, dialog and predicate name conflicts are detected when a plugin is
  registered.
- Plugin menus are merged with Rcmdr's insertion rules, including top-level
  placement before Tools/Help, insertion into existing menus and `remove` rows.
- Duplicate menu names after merging are rejected with a clear error.
- Exported plugin helpers: `variables()`, `numeric_variables()`,
  `factor_variables()`, `dataset()`, `plugin_formula()`, widget functions and
  translation helpers.
- Tooling: `tools/new_plugin.R` scaffolds a plugin package;
  `tools/inventory_plugin.R` reports menus, commands and Tk dialogs in an
  upstream plugin source tree.
- CI: the plugins workflow discovers every plugin package and checks each one.

# RcmdrShiny 1.0.0

## Phase 7 — Hardening, documentation and release

- Hardened long-running sessions: bounded output/message buffers and capped
  plot history with file cleanup.
- Large data sets use server-side `DT` rendering above a configurable
  threshold.
- Accessibility pass: skip link, main/navigation/banner landmarks, ARIA live
  status, focus-visible styles, icon labels, plot image alt text and document
  language.
- Documentation: Getting Started, Migrating from Rcmdr and Writing Plugins
  vignettes; pkgdown configuration and reference sections.
- Release engineering: CRAN comments, release checklist, citation file,
  desktop entry, coverage workflow and browser E2E workflow.
- Full suite of unit, golden, integration, plugin and opt-in browser tests.
- Version 1.0.0; 138 user-facing dialogs ported, four internal Tk utilities
  remain.

# RcmdrShiny 0.7.0

## Phase 6 — Plugin API

- Public plugin API: `RcmdrShiny.plugin()`, `plugin_dialog()`,
  `load_plugin()`, `load_plugin_package()`, `list_plugins()` and
  `unload_plugins()`.
- Plugins can add Rcmdr-style menus, direct commands (with or without a state
  argument) and Shiny dialogs.
- Menu definitions from plugin `menus.txt` files are merged with the standard
  Rcmdr menus at application start.
- Legacy Tk plugins are detected and registered with a warning; their Tk
  dialogs are not executed.
- `run()`/`app()` accept a `plugins` argument; the Tools menu can load a
  plugin script (menus appear after restart).
- Example plugin in `inst/examples/demo-plugin.R` and `demo-menus.txt`.
- Plugin tests for menus, commands, dialogs, script loading and legacy
  warnings.
- Inventory unchanged: 138 ported dialogs / 4 internal utilities; version
  0.7.0.

# RcmdrShiny 0.6.0

## Phase 5 — Models, Tools and Help

- Complete Models menu: model selection and summaries, coefficient
  comparison, observation statistics, AIC/BIC, stepwise and subset selection,
  confidence intervals, bootstrap, delta method, ANOVA tables, model
  comparison, linear hypotheses, VIF, Breusch-Pagan, Durbin-Watson, RESET,
  outlier tests, response transformation, basic model plots, residual QQ,
  component+residual and added-variable plots (including 3D), influence plots,
  effect plots and predictor-effect plots.
- Tools: load packages, options/save options, plugin notice, macOS App Nap
  notice and auxiliary-software notice.
- Help: quick help, about, manuals and website links, R Markdown link, R help
  system and dataset help.
- Lazy attachment of car, effects, leaps, lmtest, boot and RcmdrMisc for model
  commands.
- Golden-command and execution tests for the main model diagnostics.
- Rendering and validation tests for every Phase 5 dialog.
- Inventory: 138 ported / 4 internal utilities; version 0.6.0.

# RcmdrShiny 0.5.0

## Phase 4 — Graphs, Distributions and 3D

- Complete Graphs menu: index plot, histogram, stem-and-leaf, boxplot, dot
  plot, scatterplot and matrix, bar graph, pie chart, line graph,
  quantile-comparison plot, plot of means, 3D scatterplot, XY conditioning
  plot, strip chart, density estimate, discrete numeric plot, symmetry boxplot
  and color palette.
- Complete Distributions menu for the supported families (normal, t, chi-square,
  F, exponential, uniform, beta, Cauchy, logistic, lognormal, gamma, Weibull,
  binomial, Poisson, geometric, hypergeometric and negative binomial):
  quantiles, probabilities, mass for discrete families, density/CDF plots and
  random samples, plus random seed control.
- Plot capture from dialogs, plot history gallery, PNG/PDF export and 3D
  snapshot export.
- Lazy attachment of RcmdrMisc/car/lattice/rgl for graph commands.
- Command-builder golden tests and execution tests that verify plot capture.
- Rendering and validation tests for all graph and distribution dialogs.
- Browser E2E extended with a histogram dialog and plot-history assertions.
- Inventory: 107 ported / 35 todo; Phase 4 checklist; version 0.5.0.

# RcmdrShiny 0.4.0

## Phase 3 — Statistics

- Complete Statistics menu coverage: 42 dialogs ported.
- Summaries: frequency distributions with goodness-of-fit, table of
  statistics, correlation matrix/test, normality tests, power transforms.
- Contingency tables: two-way, two-way from counts, multi-way, entered table,
  percentages, chi-square components, expected counts and Fisher tests.
- Means: single, independent and paired t-tests; one-way and multi-way ANOVA;
  one- and two-factor repeated-measures ANOVA through `car::Anova`.
- Variances: F-test, Bartlett, Levene and single-sample variance test.
- Proportions: single- and two-sample proportion tests.
- Nonparametric: two-sample, paired and single-sample Wilcoxon,
  Kruskal-Wallis and Friedman tests.
- Dimensional analysis: reliability, principal components, factor analysis
  and a simplified SEM-based confirmatory factor analysis.
- Cluster analysis: k-means, hierarchical clustering and summaries/assignment.
- Models: linear regression, GLM, multinomial logit, ordinal regression,
  linear mixed models and generalized linear mixed models.
- Lazy attachment of car, lme4, MASS, nnet, multcomp, sem and TeachingDemos.
- Golden-command and execution tests for the main analyses; Statistics
  dialogs registered and rendered in tests.
- Inventory: 79 ported / 63 todo; version 0.4.0.

# RcmdrShiny 0.3.0

## Phase 2 — File and Data

- Complete Data menu coverage: 34 dialogs ported (new data set, select data
  set, package data, text/Excel/SPSS/Stata/SAS/Minitab imports, compute,
  delete, recode, factor conversions, binning, standardize, export, missing
  data, subset, case names, rename, contrasts, stack, remove/select rows,
  merge, aggregate, drop levels, sort, reshape long/wide, view data).
- Command builders reproduce the Rcmdr `data-menu.R` code, with unit and
  execution tests.
- Lazy attachment of RcmdrMisc/car/foreign so generated commands work
  without slowing application startup.
- New data set creates an editable data frame; Data tab remains the editor.
- Import dialogs accept a typed path or `shinyFiles` browsing and validate
  the data set name and file.
- Direct File/Data actions: view data, refresh, variables, add observation
  numbers, help, list data sets in packages, save `.RData`, export/workspace
  downloads.
- Phase 2 checklist and 36-dialog porting inventory.

# RcmdrShiny 0.2.0

## Phase 1 — shell and infrastructure

- Reactive menu activation and installation expressions evaluated from
  `Rcmdr-menus.txt` (Rcmdr predicates and model-capability table).
- Dialog runtime: OK, Apply, Reset, Cancel, Help, per-dialog memory,
  command-error notification with Retry, busy state.
- Full widget library: variable selector, checkbox groups, radio buttons,
  text/numeric/slider/combo inputs, file and directory choosers, subset entry,
  model-formula builder.
- Data pane: `DT` view plus `rhandsontable` editing with a configurable cell
  threshold and Apply-changes workflow.
- Plot pipeline: history gallery, thumbnail selection, PNG and PDF export.
- rgl integration: 3D scenes captured with `rgl.useNULL()` and rendered with
  `rglwidget()`.
- File utilities: `Setwd`, `Load Data Set` (RData/RDS), `Open Script File`,
  script/output/dataset/workspace downloads.
- Options dialog (digits, width, editing threshold, stringsAsFactors).
- Help menu: about, quick help, R help system and dataset help.
- Top bar: dataset/model badges, language selector, dark-mode toggle.
- Tests for activation predicates, widgets, options, data editing, plot
  history/export, rgl and workspace loading; browser test extended with plot,
  data editor, options and about flows.
- Version bumped to 0.2.0 (milestone "Shell").

# RcmdrShiny 0.1.0

## Phase 0 — vertical slice

- Package skeleton, GPL-2+ licensing and attribution notice.
- Shiny shell: top bar, menu sidebar, Script/Output/Messages/Plots/Data/
  Environment tabs, status bar.
- Menu sidebar generated from Rcmdr 2.15.0's `Rcmdr-menus.txt`; commands not
  yet ported are disabled with an "In porting" tooltip.
- `AppState` with active data set, active model, command log, output,
  messages, dialog memory and plot history.
- `run_command()` with capture of output, messages, warnings and errors,
  automatic active-object detection, and PNG plot capture.
- Dialog runtime with modal UI, validation, reset and per-dialog memory.
- Ported dialogs: *Read Text Data*, *Numerical Summaries*, *Linear Model*.
- Direct command *Summarize active data set*.
- `DT` data view, environment view and plot preview.
- Unit, golden-command and server integration tests; opt-in shinytest2
  browser end-to-end test.
- `tools/inventory_dialogs.R` generates the official backlog
  (`inst/etc/dialogs-inventory.csv`) from an Rcmdr source tree.
