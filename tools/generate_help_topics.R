#!/usr/bin/env Rscript
# Generate help-topic skeletons for the core package or a plugin.
#
# Usage:
#   Rscript tools/generate_help_topics.R --core [--force]
#   Rscript tools/generate_help_topics.R --plugin RcmdrShinyPlugin.Export
#
# Existing topic files are never overwritten unless --force is given.

script_path <- function() {
  args <- commandArgs(trailingOnly = FALSE)
  hit <- grep("^--file=", args, value = TRUE)
  if (length(hit) == 0L) return("tools")
  dirname(normalizePath(sub("^--file=", "", hit[[1L]])))
}

source(file.path(script_path(), "help_tools.R"))

args <- commandArgs(trailingOnly = TRUE)
core <- "--core" %in% args
force <- "--force" %in% args
plugin <- NULL
if ("--plugin" %in% args) {
  plugin <- args[[which(args == "--plugin") + 1L]]
}
path <- NULL
if ("--path" %in% args) {
  path <- args[[which(args == "--path") + 1L]]
}

if (!core && is.null(plugin)) {
  stop("Use --core or --plugin <package>.", call. = FALSE)
}

if (core) {
  directory <- path %||% file.path(getwd(), "inst", "help-topics")
  dialogs <- RcmdrShiny:::dialog_catalog()
} else {
  suppressWarnings(RcmdrShiny::load_plugin_package(plugin))
  directory <- path %||% file.path(getwd(), "plugins", plugin, "inst", "help-topics")
  dialogs <- RcmdrShiny:::plugin_dialogs()
}

dir.create(file.path(directory, "topics"), recursive = TRUE,
           showWarnings = FALSE)

leaves <- RcmdrShiny::menu_leaves(RcmdrShiny::menu_tree())
path_for <- function(id) {
  hit <- leaves$path[leaves$command == id]
  if (length(hit) == 0L) NA_character_ else hit[[1L]]
}

category_for <- function(id) {
  if (!core) return("plugins")
  menu_path <- path_for(id)
  if (is.na(menu_path)) return("statistics")
  root <- sub(" > .*$", "", menu_path)
  switch(
    root,
    "Data" = "data",
    "File" = "data",
    "Edit" = "data",
    "Statistics" = "statistics",
    "Models" = "models",
    "Graphs" = "graphs",
    "Distributions" = "distributions",
    "Tools" = "tools",
    "Help" = "help",
    "statistics"
  )
}

distribution_families <- list(
  list(id = "normal-distribution", title = "Normal distribution",
       pattern = "^normal",
       commands = c("qnorm", "pnorm", "dnorm", "rnorm"),
       keywords = c("normal", "gaussian", "quantiles", "probabilities",
                    "density", "random")),
  list(id = "t-distribution", title = "Student t distribution",
       pattern = "^t(Quantiles|Probabilities|Distribution)",
       commands = c("qt", "pt", "dt", "rt"),
       keywords = c("t", "student", "quantiles", "probabilities", "density")),
  list(id = "chi-squared-distribution", title = "Chi-squared distribution",
       pattern = "^chisq",
       commands = c("qchisq", "pchisq", "dchisq", "rchisq"),
       keywords = c("chi-squared", "chisq", "quantiles", "probabilities")),
  list(id = "f-distribution", title = "F distribution",
       pattern = "^F(Quantiles|Probabilities|Distribution)",
       commands = c("qf", "pf", "df", "rf"),
       keywords = c("f", "variance", "quantiles", "probabilities")),
  list(id = "exponential-distribution", title = "Exponential distribution",
       pattern = "^exponential",
       commands = c("qexp", "pexp", "dexp", "rexp"),
       keywords = c("exponential", "waiting", "quantiles", "probabilities")),
  list(id = "uniform-distribution", title = "Uniform distribution",
       pattern = "^uniform",
       commands = c("qunif", "punif", "dunif", "runif"),
       keywords = c("uniform", "quantiles", "probabilities")),
  list(id = "beta-distribution", title = "Beta distribution",
       pattern = "^beta",
       commands = c("qbeta", "pbeta", "dbeta", "rbeta"),
       keywords = c("beta", "proportion", "quantiles", "probabilities")),
  list(id = "cauchy-distribution", title = "Cauchy distribution",
       pattern = "^Cauchy",
       commands = c("qcauchy", "pcauchy", "dcauchy", "rcauchy"),
       keywords = c("cauchy", "heavy tails", "quantiles", "probabilities")),
  list(id = "logistic-distribution", title = "Logistic distribution",
       pattern = "^logistic",
       commands = c("qlogis", "plogis", "dlogis", "rlogis"),
       keywords = c("logistic", "quantiles", "probabilities")),
  list(id = "lognormal-distribution", title = "Lognormal distribution",
       pattern = "^lognormal",
       commands = c("qlnorm", "plnorm", "dlnorm", "rlnorm"),
       keywords = c("lognormal", "skewed", "quantiles", "probabilities")),
  list(id = "gamma-distribution", title = "Gamma distribution",
       pattern = "^gamma",
       commands = c("qgamma", "pgamma", "dgamma", "rgamma"),
       keywords = c("gamma", "quantiles", "probabilities")),
  list(id = "weibull-distribution", title = "Weibull distribution",
       pattern = "^Weibull",
       commands = c("qweibull", "pweibull", "dweibull", "rweibull"),
       keywords = c("weibull", "survival", "quantiles", "probabilities")),
  list(id = "binomial-distribution", title = "Binomial distribution",
       pattern = "^binomial",
       commands = c("qbinom", "pbinom", "dbinom", "rbinom"),
       keywords = c("binomial", "counts", "quantiles", "probabilities")),
  list(id = "poisson-distribution", title = "Poisson distribution",
       pattern = "^Poisson",
       commands = c("qpois", "ppois", "dpois", "rpois"),
       keywords = c("poisson", "counts", "quantiles", "probabilities"))
)

family_for <- function(id) {
  for (family in distribution_families) {
    if (grepl(family$pattern, id)) return(family)
  }
  NULL
}

existing <- help_tool_existing(directory)
covered <- c(existing$ids, existing$dialogs)
written <- 0L

sanitise <- function(text) {
  text <- gsub("[\r\n]+", " ", text)
  gsub('"', "'", text)
}

keywords_for <- function(id, title, help) {
  words <- unique(c(
    help_tool_slug(id),
    unlist(strsplit(tolower(title), "[^a-z0-9]+")),
    if (!is.null(help) && nzchar(help)) tolower(help) else character()
  ))
  words <- words[nzchar(words)]
  paste(utils::head(words, 8L), collapse = ", ")
}

front_matter <- function(id, title, category, order, keywords, dialogs,
                         commands, packages, status = "draft") {
  slug <- function(x) {
    if (length(x) == 0L) "[]" else paste0("[", paste(x, collapse = ", "), "]")
  }
  c(
    "---",
    sprintf("id: %s", id),
    sprintf("title: %s", sanitise(title)),
    "type: task",
    sprintf("category: %s", category),
    sprintf("order: %d", as.integer(order)),
    sprintf("keywords: [%s]", keywords),
    "aliases: []",
    sprintf("dialogs: %s", slug(dialogs)),
    sprintf("commands: %s", slug(commands)),
    sprintf("packages: %s", slug(packages)),
    "related: []",
    "language: en",
    sprintf("status: %s", status),
    "---",
    ""
  )
}

# -- grouped distribution topics -------------------------------------------

groups <- list()
for (family in distribution_families) {
  members <- names(dialogs)[grepl(family$pattern, names(dialogs))]
  if (length(members) >= 2L && !family$id %in% covered) {
    groups[[family$id]] <- list(family = family, members = members)
  }
}

ordering <- 100L
for (group_id in names(groups)) {
  group <- groups[[group_id]]
  family <- group$family
  members <- group$members
  rows <- vapply(members, function(member) {
    sprintf("| `%s` | %s |", member, sanitise(dialogs[[member]]$title))
  }, character(1))
  text <- c(
    front_matter(
      id = group_id,
      title = family$title,
      category = "distributions",
      order = ordering,
      keywords = paste(family$keywords, collapse = ", "),
      dialogs = members,
      commands = family$commands,
      packages = "stats"
    ),
    sprintf("## What it does"),
    "",
    sprintf(paste("The %s dialogs cover the four operations available for this",
                  "distribution: quantiles, probabilities, density and random",
                  "samples. Each dialog generates a call to the corresponding R",
                  "function."),
            family$title),
    "",
    "## Available dialogs",
    "",
    "| Dialog | Title |",
    "|---|---|",
    rows,
    "",
    "## How to fill it in",
    "",
    "1. Choose the operation you need from the **Distributions** menu.",
    "2. Enter the parameters: `mean` and `sd` for the normal distribution,",
    "   `df` for t and chi-squared, and so on.",
    "3. For probabilities, choose whether you need the lower tail, the upper",
    "   tail or both.",
    "4. Press **OK**.",
    "",
    "## What it produces",
    "",
    "```r",
    "qnorm(0.95, mean = 0, sd = 1)",
    "```",
    "",
    "The command is written to the **Script** tab and evaluated in the session.",
    "Printed values appear in the **Output** tab; distribution plots appear in",
    "the **Plots** tab.",
    "",
    "## See also",
    "",
    "- `topic:histogram`",
    "- `topic:numerical-summaries`"
  )
  if (help_tool_write_topic(directory, group_id, text, overwrite = force)) {
    written <- written + 1L
  }
  covered <- c(covered, group_id, members)
  ordering <- ordering + 10L
}

# -- one topic per dialog ---------------------------------------------------

for (id in names(dialogs)) {
  if (id %in% covered) next
  spec <- dialogs[[id]]
  title <- spec$title %||% id
  help <- spec$help
  packages <- spec$help_package %||% if (!core) plugin else "RcmdrShiny"
  menu_path <- path_for(id)

  text <- c(
    front_matter(
      id = id,
      title = title,
      category = category_for(id),
      order = ordering,
      keywords = keywords_for(id, title, help),
      dialogs = id,
      commands = if (is.null(help) || !nzchar(help)) character() else help,
      packages = packages
    ),
    "## What it does",
    "",
    sprintf("The **%s** dialog is the menu entry `%s`.", sanitise(title),
            if (is.na(menu_path)) id else menu_path),
    "",
    "## How to fill it in",
    "",
    "1. Choose the active data set if the dialog offers a selector.",
    "2. Select the variables and options you need.",
    "3. Press **OK**.",
    "",
    "## What it produces",
    "",
    "The generated command is written to the **Script** tab and evaluated in",
    "the current session. Printed results appear in the **Output** tab; plots",
    "appear in the **Plots** tab.",
    ""
  )
  if (!is.null(help) && nzchar(help)) {
    text <- c(
      text,
      "## R reference",
      "",
      sprintf("`?%s`%s", help,
              if (nzchar(packages)) sprintf(" (%s)", packages) else ""),
      ""
    )
  }
  text <- c(
    text,
    "## See also",
    "",
    "Browse the **Help** tab for related topics."
  )

  if (help_tool_write_topic(directory, id, text, overwrite = force)) {
    written <- written + 1L
  }
  ordering <- ordering + 10L
}

# -- plugin overview --------------------------------------------------------

if (!core) {
  slug <- help_tool_slug(sub("^RcmdrShinyPlugin\\.", "", plugin))
  overview_id <- sprintf("%s-overview", slug)
  if (!overview_id %in% help_tool_existing(directory)$ids) {
    members <- names(dialogs)
    rows <- vapply(members, function(member) {
      sprintf("| `%s` | %s |", member, sanitise(dialogs[[member]]$title))
    }, character(1))
    text <- c(
      front_matter(
        id = overview_id,
        title = sprintf("%s overview", sub("^RcmdrShinyPlugin\\.", "", plugin)),
        category = "plugins",
        order = 10,
        keywords = paste(unique(c(slug, "plugin")), collapse = ", "),
        dialogs = members,
        commands = character(),
        packages = plugin
      ),
      "## What it does",
      "",
      sprintf("`%s` adds its menus and dialogs to RcmdrShiny.", plugin),
      "",
      "## Dialogs",
      "",
      "| Dialog | Title |",
      "|---|---|",
      rows,
      "",
      "## Loading",
      "",
      "```r",
      sprintf('RcmdrShiny::run(plugins = "%s")', plugin),
      "```"
    )
    if (help_tool_write_topic(directory, overview_id, text,
                              overwrite = force)) {
      written <- written + 1L
    }
  }
}

if (core) {
  help_tool_write_index(directory)
} else {
  help_tool_write_index(
    directory,
    categories = list(list(id = "plugins", title = "Plugins", order = 70L))
  )
}
cat(sprintf("%s: wrote %d topic(s), %d total.\n",
            if (core) "core" else plugin, written,
            length(help_tool_topics(directory))))
