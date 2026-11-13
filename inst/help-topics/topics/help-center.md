---
id: help-center
title: Using the help centre
type: concept
category: help
keywords: [help, search, topics, documentation, find, guide]
aliases: [help, documentation, search-help]
dialogs: []
commands: [help_search, help_topic, help_index]
packages: [RcmdrShiny]
related: [keyboard-shortcuts, writing-help-topics]
language: en
status: documented
---

# Using the help centre

The **Help** tab combines the task-oriented topics shipped with the core and
with the loaded plugins.  It works offline and needs no internet connection.

## Open the help centre

- Click the **Help** tab.
- Use **Help > Help centre** in the sidebar.
- Press the **Help** button in any dialog to jump straight to that dialog's
  topic.

## Search

Type one or more words in the search box.  Results are ranked by where the
words appear: title first, then keywords, then aliases and command names, then
the body.  Partial words work: `summar` finds "Numerical summaries".

Each result shows a short snippet.  Click it to open the topic.

## Browse by category

The left column lists categories: Getting started, Data, Statistics, Models,
Graphs, Distributions, Plugins, Using the help and Troubleshooting.  Plugin
topics appear under **Plugins**, prefixed with the plugin name.

## Inside a topic

- Links to other topics (`topic:...`) open in place.
- Code blocks contain the R commands the dialog generates; copy them from the
  **Script** tab of a real session.
- The **R reference** link at the bottom opens the underlying Rd page when one
  exists.

## Contextual help

Every dialog knows its topic.  When a dialog is open, the help centre can jump
to "Help on this window", and the dialog's **Help** button opens the same
content in a modal.

## From R

```r
RcmdrShiny::help_search("logistic regression")
RcmdrShiny::help_topic("linear-model")
RcmdrShiny::help_index()
```

## See also

- `topic:keyboard-shortcuts`
- `topic:getting-started`
