# Help infrastructure --------------------------------------------------------
#
# User-facing help is stored as Markdown files with a small YAML front matter.
# The package ships a manifest in inst/help-topics/index.yml; plugin packages can ship
# their own inst/help-topics directory and are discovered automatically.
#
# The registry is a plain environment so tests and the Shiny session can reset
# it without reinstalling the package.  No new mandatory dependency is needed:
# `yaml` is used when installed, otherwise an internal parser for the subset of
# YAML used by the help files takes over.

.help_registry <- new.env(parent = emptyenv())

help_registry_reset <- function() {
  .help_registry$topics <- list()
  .help_registry$aliases <- list()
  .help_registry$categories <- list()
  .help_registry$manifests <- list()
  .help_registry$loaded <- FALSE
  .help_registry$revision <- 0L
  invisible(NULL)
}

help_registry_reset()

#' Help registry
#'
#' Returns the environment holding the registered help topics.  Exposed for
#' tests and for plugin packages that need to inspect the registry.
#'
#' @return An environment with `topics`, `aliases`, `categories`,
#'   `manifests` and `revision` elements.
#' @export
help_registry <- function() {
  .help_registry
}

# -- YAML subset -------------------------------------------------------------

help_yaml_engine <- function(engine = NULL) {
  engine <- engine %||% getOption("RcmdrShiny.help.yaml", "auto")
  engine
}

#' Parse a small YAML document
#'
#' Uses the `yaml` package when available and falls back to an internal parser
#' that supports the subset used by help front matter and manifests: nested
#' mappings, sequences, inline lists and quoted scalars.
#'
#' @param text Character vector with the YAML source.
#' @param engine `"auto"`, `"yaml"` or `"internal"`.
#' @return A list.
#' @keywords internal
help_yaml_parse <- function(text, engine = NULL) {
  engine <- help_yaml_engine(engine)
  text <- paste(text, collapse = "\n")
  if (!nzchar(trimws(text))) return(list())

  if (identical(engine, "auto")) {
    engine <- if (requireNamespace("yaml", quietly = TRUE)) "yaml" else "internal"
  }

  if (identical(engine, "yaml")) {
    if (!requireNamespace("yaml", quietly = TRUE)) {
      stop("The 'yaml' package is required to parse YAML with engine = 'yaml'.",
           call. = FALSE)
    }
    out <- tryCatch(yaml::yaml.load(text, eval.expr = FALSE),
                    error = function(e) e)
    if (inherits(out, "error")) {
      stop(sprintf("Invalid YAML: %s", conditionMessage(out)), call. = FALSE)
    }
    return(out %||% list())
  }

  help_yaml_parse_internal(text)
}

help_yaml_strip_comment <- function(line) {
  chars <- strsplit(line, "", fixed = TRUE)[[1L]]
  quote <- ""
  for (i in seq_along(chars)) {
    ch <- chars[[i]]
    if (nzchar(quote)) {
      if (identical(ch, quote)) quote <- ""
    } else if (ch %in% c("\"", "'")) {
      quote <- ch
    } else if (identical(ch, "#") &&
               (i == 1L || chars[[i - 1L]] %in% c(" ", "\t"))) {
      return(if (i > 1L) substr(line, 1L, i - 1L) else "")
    }
  }
  line
}

help_yaml_lines <- function(text) {
  text <- gsub("\r\n", "\n", text, fixed = TRUE)
  raw <- strsplit(text, "\n", fixed = TRUE)[[1L]]
  out <- list()
  for (line in raw) {
    stripped <- help_yaml_strip_comment(line)
    if (!nzchar(trimws(stripped))) next
    indent <- nchar(stripped) - nchar(sub("^[ \t]+", "", stripped))
    content <- sub("^[ \t]+", "", stripped)
    out[[length(out) + 1L]] <- list(
      indent = indent,
      text = content,
      seq = grepl("^-([ \t]|$)", content)
    )
  }
  out
}

help_yaml_parse_internal <- function(text) {
  ctx <- new.env(parent = emptyenv())
  ctx$lines <- help_yaml_lines(text)
  ctx$pos <- 1L
  if (length(ctx$lines) == 0L) return(list())
  help_yaml_block(ctx, ctx$lines[[1L]]$indent)
}

help_yaml_block <- function(ctx, level) {
  if (ctx$pos > length(ctx$lines)) return(NULL)
  if (isTRUE(ctx$lines[[ctx$pos]]$seq)) {
    help_yaml_seq(ctx, level)
  } else {
    help_yaml_map(ctx, level)
  }
}

help_yaml_map <- function(ctx, level) {
  out <- list()
  while (ctx$pos <= length(ctx$lines)) {
    line <- ctx$lines[[ctx$pos]]
    if (line$indent < level || isTRUE(line$seq)) break
    if (line$indent > level) {
      ctx$pos <- ctx$pos + 1L
      next
    }
    match <- regmatches(line$text, regexec("^([^:]+):(.*)$", line$text))[[1L]]
    if (length(match) < 3L) {
      ctx$pos <- ctx$pos + 1L
      next
    }
    key <- trimws(match[[2L]])
    rest <- trimws(match[[3L]])
    ctx$pos <- ctx$pos + 1L
    if (nzchar(rest)) {
      out[key] <- list(help_yaml_scalar(rest))
    } else if (ctx$pos <= length(ctx$lines) &&
               ctx$lines[[ctx$pos]]$indent > level) {
      out[key] <- list(help_yaml_block(ctx, ctx$lines[[ctx$pos]]$indent))
    } else {
      out[key] <- list(NULL)
    }
  }
  out
}

help_yaml_seq <- function(ctx, level) {
  out <- list()
  while (ctx$pos <= length(ctx$lines)) {
    line <- ctx$lines[[ctx$pos]]
    if (line$indent != level || !isTRUE(line$seq)) break
    item <- sub("^-[ \t]*", "", line$text)
    ctx$pos <- ctx$pos + 1L
    child_level <- level + 2L
    has_child <- ctx$pos <= length(ctx$lines) &&
      !isTRUE(ctx$lines[[ctx$pos]]$seq) &&
      ctx$lines[[ctx$pos]]$indent > level
    if (has_child) child_level <- ctx$lines[[ctx$pos]]$indent

    if (!nzchar(item)) {
      if (has_child) {
        out[[length(out) + 1L]] <- help_yaml_block(ctx, child_level)
      } else {
        out[length(out) + 1L] <- list(NULL)
      }
    } else if (grepl("^([^:]+):([ \t]|$)", item)) {
      ctx$lines <- append(
        ctx$lines,
        list(list(indent = child_level, text = item, seq = FALSE)),
        after = ctx$pos - 1L
      )
      out[[length(out) + 1L]] <- help_yaml_map(ctx, child_level)
    } else {
      out[[length(out) + 1L]] <- help_yaml_scalar(item)
    }
  }
  out
}

help_yaml_split_list <- function(x) {
  chars <- strsplit(x, "", fixed = TRUE)[[1L]]
  parts <- character()
  current <- ""
  quote <- ""
  for (ch in chars) {
    if (nzchar(quote)) {
      current <- paste0(current, ch)
      if (identical(ch, quote)) quote <- ""
    } else if (ch %in% c("\"", "'")) {
      quote <- ch
      current <- paste0(current, ch)
    } else if (identical(ch, ",")) {
      parts <- c(parts, trimws(current))
      current <- ""
    } else {
      current <- paste0(current, ch)
    }
  }
  parts <- c(parts, trimws(current))
  parts[nzchar(parts)]
}

help_yaml_unquote <- function(x) {
  quote <- substr(x, 1L, 1L)
  value <- substr(x, 2L, nchar(x) - 1L)
  value <- gsub(paste0("\\\\", quote), quote, value, fixed = TRUE)
  gsub("\\\\\\\\", "\\\\", value)
}

help_yaml_scalar <- function(x) {
  x <- trimws(x)
  if (!nzchar(x) || x %in% c("null", "~", "NULL")) return(NULL)
  if (grepl("^\\[.*\\]$", x)) {
    inner <- trimws(substr(x, 2L, nchar(x) - 1L))
    if (!nzchar(inner)) return(character())
    parts <- help_yaml_split_list(inner)
    return(vapply(parts, function(part) {
      value <- help_yaml_scalar(part)
      if (is.null(value)) "" else as.character(value)
    }, character(1), USE.NAMES = FALSE))
  }
  if (grepl("^\"[^\"]*\"$", x) || grepl("^'[^']*'$", x)) {
    return(help_yaml_unquote(x))
  }
  if (x %in% c("true", "TRUE", "yes", "Yes")) return(TRUE)
  if (x %in% c("false", "FALSE", "no", "No")) return(FALSE)
  if (grepl("^-?[0-9]+$", x)) return(as.integer(x))
  if (grepl("^-?([0-9]+\\.[0-9]*|\\.[0-9]+)([eE][-+]?[0-9]+)?$", x)) {
    return(as.numeric(x))
  }
  x
}

# -- front matter ------------------------------------------------------------

#' Parse Markdown with YAML front matter
#'
#' @param text Character vector with the file content.
#' @param engine Passed to [help_yaml_parse()].
#' @return A list with `meta` (a list) and `body` (a string).
#' @keywords internal
help_parse_front_matter <- function(text, engine = NULL) {
  text <- gsub("\r\n", "\n", paste(text, collapse = "\n"), fixed = TRUE)
  lines <- strsplit(text, "\n", fixed = TRUE)[[1L]]
  if (length(lines) == 0L || !grepl("^---[ \t]*$", lines[[1L]])) {
    return(list(meta = list(), body = text))
  }
  closing <- which(grepl("^---[ \t]*$", lines[-1L]))
  if (length(closing) == 0L) return(list(meta = list(), body = text))
  closing <- closing[[1L]] + 1L
  meta_text <- if (closing > 2L) {
    paste(lines[seq.int(2L, closing - 1L)], collapse = "\n")
  } else {
    ""
  }
  body_lines <- if (closing < length(lines)) {
    lines[seq.int(closing + 1L, length(lines))]
  } else {
    character()
  }
  list(
    meta = help_yaml_parse(meta_text, engine = engine),
    body = paste(body_lines, collapse = "\n")
  )
}

help_meta_chr <- function(meta, key, default = NULL) {
  value <- meta[[key]]
  if (is.null(value)) return(default)
  value <- unlist(value, use.names = FALSE)
  value <- as.character(value[!is.na(value)])
  if (length(value) == 0L) return(default)
  value
}

help_meta_int <- function(meta, key, default) {
  value <- suppressWarnings(as.integer(help_meta_chr(meta, key, NA_character_)))
  if (length(value) == 0L || is.na(value[[1L]])) default else value[[1L]]
}

help_meta_list <- function(meta, key) {
  value <- help_meta_chr(meta, key, character())
  value[nzchar(value)]
}

# -- registry ----------------------------------------------------------------

help_ensure_loaded <- function(force = FALSE) {
  if (isTRUE(.help_registry$loaded) && !force) return(invisible(NULL))
  if (isTRUE(force)) help_registry_reset()

  directory <- help_core_dir()
  if (nzchar(directory)) {
    help_load_directory(directory, package = NULL)
  }
  .help_registry$loaded <- TRUE
  invisible(NULL)
}

help_core_dir <- function() {
  path <- system.file("help-topics", package = "RcmdrShiny")
  if (nzchar(path) && file.exists(file.path(path, "index.yml"))) return(path)
  candidates <- c(
    file.path(getwd(), "inst", "help-topics"),
    file.path("inst", "help-topics")
  )
  for (candidate in candidates) {
    if (file.exists(file.path(candidate, "index.yml"))) return(candidate)
  }
  ""
}

help_load_directory <- function(directory, package = NULL) {
  manifest_path <- file.path(directory, "index.yml")
  if (!file.exists(manifest_path)) return(invisible(NULL))
  manifest <- help_read_manifest(manifest_path)
  help_register(manifest, base_dir = directory, package = package)
  help_load_translations(directory, package = package)
  invisible(manifest)
}

help_load_translations <- function(directory, package = NULL) {
  topics_dir <- file.path(directory, "topics")
  if (!dir.exists(topics_dir)) return(invisible(NULL))
  subdirectories <- list.dirs(topics_dir, recursive = FALSE, full.names = TRUE)
  subdirectories <- subdirectories[
    grepl("^[a-z]{2}(_[A-Z]{2})?$", basename(subdirectories))
  ]
  for (subdirectory in subdirectories) {
    files <- list.files(subdirectory, pattern = "\\.md$", full.names = TRUE)
    for (file in files) {
      topic <- help_read_topic(file, package = package)
      if (is.null(topic)) next
      existing <- .help_registry$topics[[topic$id]]
      if (is.null(existing)) {
        warning(sprintf(
          "Translation %s has no matching English topic '%s'; skipped.",
          file, topic$local_id
        ), call. = FALSE)
        next
      }
      .help_registry$topics[[topic$id]] <- help_add_topic(topic)
    }
  }
  invisible(NULL)
}

#' Register the help shipped by a plugin package
#'
#' Looks for `inst/help-topics/index.yml` inside the installed package.  Missing help
#' is not an error: the plugin remains usable and its dialogs fall back to the
#' Rd pages declared in `help`.
#'
#' @param package Package name.
#' @param name Plugin name to use for the help namespace; defaults to the
#'   package name.
#' @param lib.loc Library location, or `NULL`.
#' @return `TRUE` when help was registered, invisibly.
#' @export
#' @details The help directory is named `help-topics` rather than `help`
#'   because R reserves `inst/help` for its own help database.
register_plugin_help <- function(package, name = package, lib.loc = NULL) {
  directory <- system.file("help-topics", package = package, lib.loc = lib.loc)
  if (!nzchar(directory) || !file.exists(file.path(directory, "index.yml"))) {
    return(invisible(FALSE))
  }
  help_load_directory(directory, package = name)
  invisible(TRUE)
}

#' Read a help manifest
#'
#' @param path Path to an `index.yml` file.
#' @return A list with `version`, `language`, `categories` and `topics`.
#' @keywords internal
help_read_manifest <- function(path) {
  manifest <- help_yaml_parse(readLines(path, warn = FALSE, encoding = "UTF-8"))
  if (is.null(manifest$categories)) manifest$categories <- list()
  if (is.null(manifest$topics)) manifest$topics <- list()
  manifest
}

#' Register help topics
#'
#' Registers the topics declared by a manifest.  Plugin topics get the
#' canonical id `plugin:<package>:<topic>`; a short alias is registered only
#' when it is not already taken.
#'
#' @param manifest Manifest list as returned by [help_read_manifest()].
#' @param base_dir Directory the manifest paths are relative to.
#' @param package Package name for plugin help, or `NULL` for the core.
#' @return The registry revision, invisibly.
#' @export
help_register <- function(manifest, base_dir = NULL, package = NULL) {
  if (is.null(base_dir)) base_dir <- dirname(manifest$path %||% ".")
  if (is.null(package) && !is.null(manifest$package)) package <- manifest$package

  .help_registry$manifests[[package %||% "RcmdrShiny"]] <- list(
    package = package,
    version = manifest$version %||% 1L,
    language = manifest$language %||% "en"
  )

  for (category in manifest$categories %||% list()) {
    id <- help_meta_chr(category, "id")
    if (is.null(id)) next
    if (is.null(.help_registry$categories[[id]])) {
      .help_registry$categories[[id]] <- list(
        id = id,
        title = help_meta_chr(category, "title", id),
        order = help_meta_int(category, "order", 100L),
        package = package
      )
    }
  }

  for (entry in manifest$topics %||% list()) {
    id <- help_meta_chr(entry, "id")
    file <- help_meta_chr(entry, "file")
    if (is.null(id) || is.null(file)) next
    path <- file.path(base_dir, file)
    if (!file.exists(path)) {
      warning(sprintf("Help topic '%s' points to a missing file: %s", id, path),
              call. = FALSE)
      next
    }
    topic <- help_read_topic(path, entry = entry, package = package)
    if (!is.null(topic)) help_add_topic(topic)
  }

  .help_registry$revision <- .help_registry$revision + 1L
  invisible(.help_registry$revision)
}

#' Read a single help topic
#'
#' @param path Markdown file with YAML front matter.
#' @param entry Manifest entry providing defaults.
#' @param package Plugin package name, or `NULL`.
#' @return A topic record, or `NULL` when the file cannot be read.
#' @keywords internal
help_read_topic <- function(path, entry = list(), package = NULL) {
  text <- tryCatch(
    readLines(path, warn = FALSE, encoding = "UTF-8"),
    error = function(e) NULL
  )
  if (is.null(text)) return(NULL)

  parsed <- help_parse_front_matter(text)
  meta <- parsed$meta
  local_id <- help_meta_chr(meta, "id") %||% help_meta_chr(entry, "id")
  if (is.null(local_id)) {
    local_id <- sub("\\.md$", "", basename(path))
  }

  language <- help_meta_chr(meta, "language") %||%
    help_meta_chr(entry, "language") %||% "en"
  title <- help_meta_chr(meta, "title") %||%
    help_meta_chr(entry, "title") %||% local_id

  canonical <- if (!is.null(package) && nzchar(package)) {
    sprintf("plugin:%s:%s", package, local_id)
  } else {
    local_id
  }

  body <- parsed$body
  # The title lives in the front matter; drop a duplicated leading H1.
  body <- sub("^[ \t]*\n*#[ \t]+[^\n]*\n?", "", body)

  topic <- list(
    id = canonical,
    local_id = local_id,
    package = package,
    title = title,
    type = help_meta_chr(meta, "type", "task"),
    category = help_meta_chr(meta, "category") %||%
      help_meta_chr(entry, "category") %||% "general",
    order = help_meta_int(meta, "order",
                          help_meta_int(entry, "order", 100L)),
    keywords = help_meta_list(meta, "keywords"),
    aliases = help_meta_list(meta, "aliases"),
    dialogs = help_meta_list(meta, "dialogs"),
    commands = help_meta_list(meta, "commands"),
    packages = help_meta_list(meta, "packages"),
    related = help_meta_list(meta, "related"),
    status = help_meta_chr(meta, "status", "documented"),
    language = language,
    path = path,
    body = body
  )
  topic$languages <- list()
  topic$languages[[language]] <- list(
    title = title, body = body, path = path,
    status = topic$status
  )
  topic
}

help_add_topic <- function(topic) {
  id <- topic$id
  existing <- .help_registry$topics[[id]]

  if (!is.null(existing) && !identical(existing$language, topic$language)) {
    existing$languages[[topic$language]] <- topic$languages[[topic$language]]
    .help_registry$topics[[id]] <- existing
    return(invisible(existing))
  }

  if (!is.null(existing)) {
    warning(sprintf("Help topic '%s' is overridden by %s.",
                    id, topic$path), call. = FALSE)
  }

  .help_registry$topics[[id]] <- topic

  if (is.null(topic$package)) {
    aliases <- unique(c(topic$local_id, topic$aliases))
  } else {
    aliases <- unique(c(topic$local_id, topic$aliases))
  }
  for (alias in aliases) {
    alias <- as.character(alias)
    if (!nzchar(alias) || identical(alias, id)) next
    current <- .help_registry$aliases[[alias]]
    if (!is.null(current) && !identical(current, id)) {
      warning(sprintf("Help alias '%s' is already registered; keeping it.",
                      alias), call. = FALSE)
      next
    }
    .help_registry$aliases[[alias]] <- id
  }
  invisible(topic)
}

#' Remove help topics
#'
#' @param package Plugin package to unregister, or `NULL` to clear everything.
#' @return `NULL`, invisibly.
#' @export
help_unregister <- function(package = NULL) {
  if (is.null(package)) {
    help_registry_reset()
    return(invisible(NULL))
  }
  keep <- vapply(.help_registry$topics, function(topic) {
    !identical(topic$package, package)
  }, logical(1))
  .help_registry$topics <- .help_registry$topics[keep]
  keep_alias <- vapply(.help_registry$aliases, function(id) {
    id %in% names(.help_registry$topics)
  }, logical(1))
  .help_registry$aliases <- .help_registry$aliases[keep_alias]
  .help_registry$manifests[[package]] <- NULL
  .help_registry$revision <- .help_registry$revision + 1L
  invisible(NULL)
}

help_resolve_language <- function(topic, language = NULL) {
  if (is.null(language) || !length(topic$languages)) return(topic)
  entry <- topic$languages[[language]]
  if (is.null(entry) && !identical(language, "en")) {
    entry <- topic$languages[["en"]]
  }
  if (is.null(entry)) return(topic)
  topic$title <- entry$title %||% topic$title
  topic$body <- entry$body %||% topic$body
  topic$path <- entry$path %||% topic$path
  topic$status <- entry$status %||% topic$status
  topic$language <- if (language %in% names(topic$languages)) language else "en"
  topic
}

#' All registered help topics
#'
#' @param language Language code; missing translations fall back to English.
#' @return A named list of topic records, named by canonical id.
#' @export
help_topics <- function(language = NULL) {
  help_ensure_loaded()
  topics <- .help_registry$topics
  if (is.null(language) || length(topics) == 0L) return(topics)
  lapply(topics, help_resolve_language, language = language)
}

#' Retrieve a help topic
#'
#' Looks up a canonical id, an alias, a dialog id or the short name of a plugin
#' topic.
#'
#' @param id Topic id.
#' @param language Language code.
#' @return A topic record, or `NULL`.
#' @export
help_topic <- function(id, language = NULL) {
  if (is.null(id) || length(id) == 0L) return(NULL)
  id <- as.character(id)[[1L]]
  topics <- help_topics()
  if (id %in% names(topics)) return(help_resolve_language(topics[[id]], language))

  canonical <- .help_registry$aliases[[id]]
  if (!is.null(canonical) && canonical %in% names(topics)) {
    return(help_resolve_language(topics[[canonical]], language))
  }

  suffix <- paste0(":", id)
  matches <- names(topics)[endsWith(names(topics), suffix)]
  if (length(matches) == 1L) {
    return(help_resolve_language(topics[[matches]], language))
  }
  NULL
}

#' Check whether a help topic exists
#' @param id Topic id.
#' @return `TRUE` or `FALSE`.
#' @export
help_topic_available <- function(id) {
  !is.null(help_topic(id))
}

#' Help topics declared for a dialog
#'
#' @param dialog_id Dialog identifier.
#' @param language Language code.
#' @return A list of topic records.
#' @export
help_topics_for_dialog <- function(dialog_id, language = NULL) {
  if (is.null(dialog_id) || !nzchar(dialog_id)) return(list())
  topics <- help_topics(language)
  keep <- vapply(topics, function(topic) {
    dialog_id %in% topic$dialogs || identical(topic$local_id, dialog_id)
  }, logical(1))
  topics[keep]
}

#' Topic that should open from a dialog
#'
#' Honours an explicit `help_topic`, then the dialog id, then a topic that
#' declares the dialog in its front matter.
#'
#' @param spec Dialog specification.
#' @param language Language code.
#' @return A topic record, or `NULL`.
#' @export
help_topic_for_dialog <- function(spec, language = NULL) {
  if (is.null(spec)) return(NULL)
  explicit <- spec$help_topic
  if (!is.null(explicit) && nzchar(explicit)) {
    topic <- help_topic(explicit, language)
    if (!is.null(topic)) return(topic)
  }
  if (!is.null(spec$id) && nzchar(spec$id)) {
    topic <- help_topic(spec$id, language)
    if (!is.null(topic)) return(topic)
  }
  matches <- help_topics_for_dialog(spec$id, language)
  if (length(matches) == 0L) return(NULL)
  matches[[1L]]
}

# -- categories and catalogue ------------------------------------------------

help_category_table <- function() {
  topics <- help_topics()
  categories <- .help_registry$categories

  ids <- unique(c(
    names(categories),
    vapply(topics, function(topic) topic$category %||% "general", character(1))
  ))
  ids <- ids[nzchar(ids)]
  if (length(ids) == 0L) return(data.frame())

  rows <- lapply(ids, function(id) {
    category <- categories[[id]]
    count <- sum(vapply(topics, function(topic) {
      identical(topic$category %||% "general", id)
    }, logical(1)))
    data.frame(
      id = id,
      title = if (is.null(category)) help_title_case(id) else category$title,
      order = if (is.null(category)) 100L else category$order,
      count = count,
      stringsAsFactors = FALSE
    )
  })
  table <- do.call(rbind, rows)
  table[order(table$order, table$title), , drop = FALSE]
}

help_title_case <- function(x) {
  x <- gsub("[-_]+", " ", x)
  paste0(toupper(substr(x, 1L, 1L)), substr(x, 2L, nchar(x)))
}

#' Help categories
#'
#' @return A data frame with `id`, `title`, `order` and `count`.
#' @export
help_index <- function() {
  help_ensure_loaded()
  table <- help_category_table()
  rownames(table) <- NULL
  table
}

#' Help catalogue
#'
#' @param category Optional category filter.
#' @param language Language code.
#' @return A data frame with one row per topic.
#' @export
help_catalog <- function(category = NULL, language = NULL) {
  topics <- help_topics(language)
  if (length(topics) == 0L) {
    return(data.frame(
      id = character(), title = character(), category = character(),
      type = character(), status = character(), package = character(),
      stringsAsFactors = FALSE
    ))
  }
  rows <- lapply(topics, function(topic) {
    data.frame(
      id = topic$id,
      local_id = topic$local_id,
      title = topic$title,
      category = topic$category %||% "general",
      type = topic$type %||% "task",
      status = topic$status %||% "documented",
      order = topic$order %||% 100L,
      package = topic$package %||% NA_character_,
      stringsAsFactors = FALSE
    )
  })
  table <- do.call(rbind, rows)
  if (!is.null(category)) {
    table <- table[table$category == category, , drop = FALSE]
  }
  table <- table[order(table$category, table$order, table$title), , drop = FALSE]
  rownames(table) <- NULL
  table
}

# -- search ------------------------------------------------------------------

help_tokens <- function(x) {
  x <- tolower(paste(x, collapse = " "))
  x <- gsub("[^[:alnum:]_]+", " ", x)
  tokens <- strsplit(trimws(x), "[[:space:]]+")[[1L]]
  unique(tokens[nzchar(tokens)])
}

help_token_match <- function(token, values) {
  if (length(values) == 0L || !nzchar(token)) return(FALSE)
  if (token %in% values) return(TRUE)
  if (nchar(token) >= 4L) {
    stem <- substr(token, 1L, min(5L, nchar(token)))
    return(any(substr(values, 1L, nchar(stem)) == stem))
  }
  FALSE
}

help_score_topic <- function(topic, tokens) {
  if (length(tokens) == 0L) return(0)
  title <- help_tokens(topic$title)
  keywords <- help_tokens(topic$keywords)
  aliases <- help_tokens(c(topic$aliases, topic$commands, topic$dialogs,
                           topic$local_id))
  body <- help_tokens(topic$body)

  score <- 0
  for (token in tokens) {
    if (help_token_match(token, title)) score <- score + 5
    if (help_token_match(token, keywords)) score <- score + 3
    if (help_token_match(token, aliases)) score <- score + 2
    if (help_token_match(token, body)) score <- score + 1
  }
  score
}

help_plain_text <- function(markdown) {
  text <- paste(markdown, collapse = "\n")
  text <- gsub("```[^`]*```", " ", text)
  text <- gsub("`([^`]*)`", "\\1", text)
  text <- gsub("!\\[[^]]*\\]\\([^)]*\\)", " ", text)
  text <- gsub("\\[([^]]*)\\]\\([^)]*\\)", "\\1", text)
  text <- gsub("^[ \t]*#+[ \t]*", "", text)
  text <- gsub("[*_>#|]", " ", text)
  text <- gsub("[ \t]+", " ", text)
  trimws(text)
}

help_snippet <- function(body, tokens, width = 160L) {
  plain <- help_plain_text(body)
  if (!nzchar(plain)) return("")
  position <- NA_integer_
  lowered <- tolower(plain)
  for (token in tokens) {
    hit <- tryCatch(
      regexpr(tolower(token), lowered, fixed = TRUE),
      error = function(e) -1L
    )
    if (hit > 0L) {
      position <- hit
      break
    }
  }
  if (is.na(position)) {
    if (nchar(plain) <= width) return(plain)
    return(paste0(substr(plain, 1L, width - 3L), "..."))
  }
  start <- max(1L, position - 60L)
  end <- min(nchar(plain), start + width - 1L)
  snippet <- substr(plain, start, end)
  if (start > 1L) snippet <- paste0("...", snippet)
  if (end < nchar(plain)) snippet <- paste0(snippet, "...")
  snippet
}

#' Search the offline help
#'
#' Simple weighted search over titles, keywords, aliases, dialogs and body.
#'
#' @param query Search terms.
#' @param limit Maximum number of results.
#' @param language Language code.
#' @return A data frame with `id`, `title`, `category`, `score`, `snippet`
#'   and `package`.
#' @export
help_search <- function(query, limit = 20L, language = NULL) {
  help_ensure_loaded()
  tokens <- help_tokens(query %||% "")
  empty <- data.frame(
    id = character(), title = character(), category = character(),
    score = numeric(), snippet = character(), package = character(),
    stringsAsFactors = FALSE
  )
  if (length(tokens) == 0L) return(empty)

  topics <- help_topics(language)
  if (length(topics) == 0L) return(empty)

  categories <- help_category_table()
  category_order <- stats::setNames(categories$order, categories$id)

  rows <- lapply(topics, function(topic) {
    score <- help_score_topic(topic, tokens)
    if (score <= 0) return(NULL)
    category <- topic$category %||% "general"
    data.frame(
      id = topic$id,
      title = topic$title,
      category = category,
      score = score,
      snippet = help_snippet(topic$body, tokens),
      package = topic$package %||% NA_character_,
      category_order = unname(category_order[[category]] %||% 100L),
      topic_order = topic$order %||% 100L,
      stringsAsFactors = FALSE
    )
  })
  rows <- Filter(Negate(is.null), rows)
  if (length(rows) == 0L) return(empty)

  table <- do.call(rbind, rows)
  table <- table[order(-table$score, table$category_order, table$topic_order,
                       table$title), , drop = FALSE]
  table <- utils::head(table, max(1L, as.integer(limit)))
  table$category_order <- NULL
  table$topic_order <- NULL
  rownames(table) <- NULL
  table
}

# -- rendering ---------------------------------------------------------------

#' Render help Markdown as HTML
#'
#' @param markdown Markdown source.
#' @return An HTML string.  Falls back to a `<pre>` block when `commonmark` is
#'   not installed.
#' @export
help_render <- function(markdown) {
  markdown <- paste(markdown, collapse = "\n")
  renderer <- getOption("RcmdrShiny.help.markdown", "auto")
  if (identical(renderer, "auto")) {
    renderer <- if (requireNamespace("commonmark", quietly = TRUE)) {
      "commonmark"
    } else {
      "plain"
    }
  }
  if (identical(renderer, "commonmark")) {
    if (!requireNamespace("commonmark", quietly = TRUE)) {
      stop("The 'commonmark' package is required when ",
           "options(RcmdrShiny.help.markdown = \"commonmark\") is set.",
           call. = FALSE)
    }
    html <- commonmark::markdown_html(markdown, extensions = TRUE)
  } else {
    html <- paste0(
      "<pre class=\"rcmdr-help-plain\">",
      htmltools::htmlEscape(markdown),
      "</pre>"
    )
  }
  help_rewrite_links(html)
}

# Internal links use the scheme topic:<id>, so that the help centre can open
# them without a page reload.
help_rewrite_links <- function(html) {
  html <- gsub(
    "href=\"topic:([^\"]+)\"",
    "href=\"#\" class=\"rcmdr-help-link\" data-help-topic=\"\\1\"",
    html
  )
  html
}

#' Render a help topic as HTML
#'
#' @param id Topic id.
#' @param language Language code.
#' @return An HTML string, or `NULL` when the topic does not exist.
#' @export
help_topic_html <- function(id, language = NULL) {
  topic <- help_topic(id, language)
  if (is.null(topic)) return(NULL)
  help_topic_html_from_record(topic)
}

#' Open a help topic in the running application
#'
#' Falls back to a modal when the Help tab server is not available, for example
#' in scripted use.
#'
#' @param state Application state.
#' @param id Topic id.
#' @return `TRUE` when the topic was opened, invisibly.
#' @keywords internal
open_help_topic <- function(state, id) {
  if (!is.null(state$help_show)) {
    return(invisible(state$help_show(id)))
  }
  topic <- help_topic(id)
  if (is.null(topic)) {
    try(shiny::showNotification(
      sprintf(tr("No help topic found for '%s'."), id),
      type = "warning", duration = 5
    ), silent = TRUE)
    return(invisible(FALSE))
  }
  try(shiny::showModal(shiny::modalDialog(
    title = topic$title,
    htmltools::HTML(help_topic_html_from_record(topic)),
    size = "l", easyClose = TRUE,
    footer = shiny::modalButton(tr("Close"))
  )), silent = TRUE)
  invisible(TRUE)
}

help_topic_html_from_record <- function(topic) {  body <- help_render(topic$body)
  header <- help_render_topic_header(topic)
  paste0(header, body)
}

help_render_topic_header <- function(topic) {
  subtitle <- if (identical(topic$language, "en")) {
    ""
  } else {
    sprintf("<p class=\"rcmdr-help-language\">%s</p>",
            htmltools::htmlEscape(topic$language))
  }
  paste0(
    sprintf("<header class=\"rcmdr-help-header\"><h2>%s</h2>",
            htmltools::htmlEscape(topic$title)),
    subtitle,
    "</header>"
  )
}

help_related_topics <- function(topic) {
  if (length(topic$related) == 0L) return(list())
  topics <- lapply(topic$related, function(id) help_topic(id))
  Filter(Negate(is.null), topics)
}
