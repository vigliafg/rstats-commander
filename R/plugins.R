# Plugin API ----------------------------------------------------------------
#
# A plugin is a named collection of menu definitions, direct commands and
# Shiny dialog specifications.  Legacy Tk dialogs are deliberately not
# executed: plugins that depend on them are registered with a warning and
# their menu entries remain disabled.
#
# Two plugin shapes are supported:
#
#   * a script that calls RcmdrShiny.plugin();
#   * an installed package that exports rcmdrshiny_plugin().  Packages named
#     RcmdrShinyPlugin.* use this protocol; legacy RcmdrPlugin.* packages fall
#     back to the menus-only compatibility loader.

.plugin_registry <- new.env(parent = emptyenv())
.plugin_registry$plugins <- list()
.plugin_registry$version <- 0L

# Predicates provided by the core activation environment.  Plugin predicates
# may not shadow these unless the plugin is registered with `replace = TRUE`.
.base_predicate_names <- c(
  "activeDataSetP", "activeModelP", "dataSetsP", "numericP",
  "numericPositiveP", "factorsP", "characterP", "twoLevelFactorsP",
  "discreteNumericP", "modelsP", "glmP", "lmP", "aovModelsP", "nonFactorsP",
  "twoOrMoreLevelFactorsP", "AbscontDistrsP", "DiscreteDistrsP",
  "hclustSolutionsP", "modelCapability",
  "CoefficientsP", "PredictorsP", "packageAvailable", "getRcmdr",
  "listPlugins", "rglLoaded", "rgl.cur", "dev.cur", "MarkdownP", "knitrP",
  "manualTranslationP"
)


#' Create a plugin dialog specification
#'
#' Wraps the internal dialog specification so that plugin authors do not need
#' to use unexported functions.
#'
#' @param id Command name used in the plugin menu file.
#' @param title Dialog title.
#' @param ui Function `function(state, memory)` returning the dialog UI.
#' @param on_ok Function `function(input, state)` returning a list with
#'   `commands`, `error`, `memory`, `activate_dataset` or `activate_model`.
#' @param on_open Optional function called before the dialog opens.
#' @param observers Optional function registering Shiny observers.
#' @param size Modal size (`"s"`, `"m"` or `"l"`).
#' @param help Optional R help topic.
#' @param help_package Optional package for the help topic.
#' @return A dialog specification accepted by [RcmdrShiny.plugin()].
#' @export
plugin_dialog <- function(id, title, ui, on_ok, on_open = NULL,
                          observers = NULL, size = "l",
                          help = NULL, help_package = NULL) {
  dialog_spec(id, title, ui, on_ok, on_open, observers, size,
              help, help_package)
}

#' Register an RcmdrShiny plugin
#'
#' @param name Unique plugin name.
#' @param menus Either a path to an Rcmdr-style `menus.txt` file or a data
#'   frame returned by [read_rcmdr_menus()].
#' @param dialogs Named list of [plugin_dialog()] specifications.
#' @param commands Named list of direct command functions.  Each function is
#'   called with the application state.
#' @param description Optional description.
#' @param version Optional version string.
#' @param predicates Named list of activation predicates.  Each predicate is a
#'   function of zero arguments, or of the application state, that returns a
#'   logical value and can be used in the `activation` column of plugin menu
#'   entries.
#' @param replace Replace an existing plugin with the same name and allow
#'   command, dialog or predicate names to override earlier definitions.
#' @return The registered plugin, invisibly.
#' @export
RcmdrShiny.plugin <- function(name, menus = NULL, dialogs = list(),
                              commands = list(), description = NULL,
                              version = NULL, tcltk = FALSE,
                              predicates = list(), replace = FALSE) {
  if (!is.character(name) || length(name) != 1L || !nzchar(name)) {
    stop("Plugin `name` must be a single non-empty string.", call. = FALSE)
  }

  if (is.character(menus) && length(menus) == 1L) {
    if (!file.exists(menus)) {
      stop(sprintf("Plugin menu file not found: %s", menus), call. = FALSE)
    }
    menus <- read_rcmdr_menus(menus)
  }
  if (!is.null(menus) && !is.data.frame(menus)) {
    stop("Plugin `menus` must be a path or a menu data frame.", call. = FALSE)
  }

  if (!is.list(dialogs)) stop("Plugin `dialogs` must be a list.", call. = FALSE)
  dialog_names <- names(dialogs)
  if (length(dialogs) == 0L) {
    dialog_names <- character()
  } else if (is.null(dialog_names) || any(!nzchar(dialog_names))) {
    dialog_names <- paste0("dialog", seq_along(dialogs))
  }
  dialogs <- lapply(seq_along(dialogs), function(i) {
    dialog <- dialogs[[i]]
    if (is.function(dialog)) {
      stop("Plugin dialogs must be created with plugin_dialog().",
           call. = FALSE)
    }
    if (!is.list(dialog) || is.null(dialog$ui) || is.null(dialog$on_ok)) {
      stop(sprintf("Invalid plugin dialog '%s'.", dialog_names[[i]]),
           call. = FALSE)
    }
    dialog$id <- dialog$id %||% dialog_names[[i]]
    dialog
  })
  names(dialogs) <- dialog_names

  if (!is.list(commands)) stop("Plugin `commands` must be a list.", call. = FALSE)
  bad <- !vapply(commands, is.function, logical(1))
  if (any(bad)) {
    stop(sprintf("Plugin commands must be functions: %s",
                 paste(names(commands)[bad], collapse = ", ")), call. = FALSE)
  }

  if (!is.list(predicates)) {
    stop("Plugin `predicates` must be a named list.", call. = FALSE)
  }
  if (length(predicates) > 0L &&
      (is.null(names(predicates)) || any(!nzchar(names(predicates))))) {
    stop("Plugin predicates must be named.", call. = FALSE)
  }
  bad <- !vapply(predicates, is.function, logical(1))
  if (any(bad)) {
    stop(sprintf("Plugin predicates must be functions: %s",
                 paste(names(predicates)[bad], collapse = ", ")), call. = FALSE)
  }

  check_conflicts <- function(names, kind, base_names) {
    if (length(names) == 0L) return(invisible(NULL))
    others <- unlist(lapply(.plugin_registry$plugins, function(plugin) {
      if (identical(plugin$name, name)) character() else names(plugin[[kind]])
    }), use.names = FALSE)
    base_clashes <- intersect(names, base_names)
    plugin_clashes <- intersect(names, others)
    if (length(base_clashes) > 0L && !isTRUE(replace)) {
      stop(sprintf(
        "Plugin '%s' %s already defined by the core: %s. Use replace = TRUE to override.",
        name, kind, paste(base_clashes, collapse = ", ")
      ), call. = FALSE)
    }
    if (length(plugin_clashes) > 0L && !isTRUE(replace)) {
      warning(sprintf(
        "Plugin '%s' overrides %s from an earlier plugin: %s.",
        name, kind, paste(plugin_clashes, collapse = ", ")
      ), call. = FALSE)
    }
    invisible(NULL)
  }

  check_conflicts(names(commands), "commands", names(base_direct_commands()))
  check_conflicts(names(dialogs), "dialogs", names(base_dialog_catalog()))
  check_conflicts(
    names(predicates), "predicates",
    c(.base_predicate_names,
      unlist(lapply(.plugin_registry$plugins, function(plugin) {
        if (identical(plugin$name, name)) character() else names(plugin$predicates)
      }), use.names = FALSE))
  )

  plugin <- list(
    name = name,
    menus = menus,
    dialogs = dialogs,
    commands = commands,
    description = description,
    version = version,
    tcltk = isTRUE(tcltk),
    predicates = predicates
  )

  if (isTRUE(tcltk)) {
    warning(
      sprintf("Plugin '%s' uses legacy Tk dialogs; only its direct commands are supported.",
              name),
      call. = FALSE
    )
  }

  .plugin_registry$plugins[[name]] <- plugin
  .plugin_registry$version <- .plugin_registry$version + 1L
  .implemented_commands_cache$names <- NULL
  invisible(plugin)
}

#' List registered plugins
#' @return A character vector of plugin names.
#' @export
list_plugins <- function() {
  names(.plugin_registry$plugins)
}

#' Remove all registered plugins
#'
#' Intended for tests and for restarting a session with a clean plugin set.
#' @return Invisibly, `NULL`.
#' @export
unload_plugins <- function() {
  .plugin_registry$plugins <- list()
  .plugin_registry$version <- .plugin_registry$version + 1L
  .implemented_commands_cache$names <- NULL
  invisible(NULL)
}

#' Load a plugin script
#'
#' The script is sourced in a new environment and should call
#' [RcmdrShiny.plugin()].  Plugin menus are available after restarting the
#' application (or when the plugin is loaded before [run()]).
#'
#' @param file Path to an R script.
#' @return Invisibly, the names of registered plugins.
#' @export
load_plugin <- function(file) {
  if (!is.character(file) || length(file) != 1L || !file.exists(file)) {
    stop(sprintf("Plugin file not found: %s", file), call. = FALSE)
  }
  environment <- new.env(parent = globalenv())
  sys.source(file, envir = environment, keep.source = FALSE)
  invisible(list_plugins())
}

#' Load an Rcmdr plugin package
#'
#' Supports two package protocols:
#'
#' * `RcmdrShinyPlugin.*` (and any package that exports `rcmdrshiny_plugin()`):
#'   the namespace is loaded and `rcmdrshiny_plugin()` registers the plugin.
#'   The function may either register the plugin itself and return it, or
#'   return a plugin specification (or a list of specifications) to register.
#' * legacy `RcmdrPlugin.*`: `etc/menus.txt` is read and registered with a
#'   warning.  Because legacy menus call Tk dialog functions, their entries
#'   are not executed.
#'
#' @param package Installed package name.
#' @param lib.loc Optional library location.
#' @return Invisibly, the plugin object (or the value returned by
#'   `rcmdrshiny_plugin()`).
#' @export
load_plugin_package <- function(package, lib.loc = NULL) {
  if (!requireNamespace(package, quietly = TRUE, lib.loc = lib.loc)) {
    stop(sprintf("Package '%s' is not installed.", package), call. = FALSE)
  }

  namespace <- asNamespace(package)
  if (exists("rcmdrshiny_plugin", envir = namespace, inherits = FALSE)) {
    return(invisible(load_plugin_namespace(namespace, package)))
  }

  menus_path <- system.file("etc", "rcmdrshiny-menus.txt",
                            package = package, lib.loc = lib.loc)
  if (nzchar(menus_path) && file.exists(menus_path)) {
    plugin <- RcmdrShiny.plugin(
      name = package,
      menus = read_rcmdr_menus(menus_path),
      description = utils::packageDescription(package, lib.loc = lib.loc)$Title,
      version = as.character(utils::packageVersion(package, lib.loc = lib.loc))
    )
    return(invisible(plugin))
  }

  legacy_path <- system.file("etc", "menus.txt", package = package,
                             lib.loc = lib.loc)
  if (!nzchar(legacy_path) || !file.exists(legacy_path)) {
    stop(sprintf(
      "Package '%s' is neither an RcmdrShiny plugin nor a legacy Rcmdr plugin.",
      package
    ), call. = FALSE)
  }
  RcmdrShiny.plugin(
    name = package,
    menus = read_rcmdr_menus(legacy_path),
    description = utils::packageDescription(package, lib.loc = lib.loc)$Title,
    version = as.character(utils::packageVersion(package, lib.loc = lib.loc)),
    tcltk = TRUE
  )
}

# Register the plugin exposed by a package namespace.  Kept separate so that
# the protocol can be tested without installing a package.
#' @keywords internal
load_plugin_namespace <- function(namespace, package) {
  loader <- get("rcmdrshiny_plugin", envir = namespace, inherits = FALSE)
  before <- names(.plugin_registry$plugins)
  result <- loader()
  after <- names(.plugin_registry$plugins)

  if (length(setdiff(after, before)) > 0L) {
    return(invisible(result))
  }

  register_spec <- function(spec) {
    if (is.list(spec) && !is.null(spec$name)) {
      do.call(RcmdrShiny.plugin, spec)
      return(invisible(TRUE))
    }
    FALSE
  }

  if (register_spec(result)) return(invisible(result))

  if (is.list(result) && length(result) > 0L &&
      all(vapply(result, function(spec) {
        is.list(spec) && !is.null(spec$name)
      }, logical(1)))) {
    for (spec in result) do.call(RcmdrShiny.plugin, spec)
    return(invisible(result))
  }

  stop(sprintf(
    "Package '%s' exports rcmdrshiny_plugin() but it did not register a plugin.",
    package
  ), call. = FALSE)
}

#' Load plugins from files or packages
#' @keywords internal
load_plugins <- function(plugins) {
  if (is.null(plugins)) return(invisible(list_plugins()))
  for (plugin in plugins) {
    if (is.character(plugin) && length(plugin) == 1L && file.exists(plugin)) {
      load_plugin(plugin)
    } else if (is.character(plugin) && length(plugin) == 1L) {
      load_plugin_package(plugin)
    } else if (is.list(plugin)) {
      do.call(RcmdrShiny.plugin, plugin)
    } else {
      stop("Plugins must be file paths, package names or argument lists.",
           call. = FALSE)
    }
  }
  invisible(list_plugins())
}

#' Menu definitions including plugin menus
#' @keywords internal
plugin_menu_definitions <- function() {
  definitions <- read_rcmdr_menus()
  for (plugin in .plugin_registry$plugins) {
    if (!is.null(plugin$menus)) {
      definitions <- merge_menu_definitions(
        definitions, plugin$menus, source = plugin$name
      )
    }
  }

  menu_ids <- definitions$menu[definitions$type == "menu"]
  duplicates <- unique(menu_ids[duplicated(menu_ids)])
  if (length(duplicates) > 0L) {
    stop(sprintf("Duplicate menu names after loading plugins: %s",
                 paste(duplicates, collapse = ", ")), call. = FALSE)
  }
  definitions
}

#' Predicates supplied by registered plugins
#' @keywords internal
plugin_predicates <- function() {
  predicates <- list()
  for (plugin in .plugin_registry$plugins) {
    for (name in names(plugin$predicates)) {
      predicates[[name]] <- plugin$predicates[[name]]
    }
  }
  predicates
}

#' @keywords internal
plugin_commands <- function() {
  commands <- list()
  for (plugin in .plugin_registry$plugins) {
    for (name in names(plugin$commands)) {
      command <- plugin$commands[[name]]
      commands[[name]] <- if (length(formals(command)) == 0L) {
        (function(fn) function(state) fn())(command)
      } else {
        command
      }
    }
  }
  commands
}

#' @keywords internal
plugin_dialogs <- function() {
  dialogs <- list()
  for (plugin in .plugin_registry$plugins) {
    for (name in names(plugin$dialogs)) {
      dialogs[[name]] <- plugin$dialogs[[name]]
    }
  }
  dialogs
}


#' Dialog for loading a plugin script
#' @keywords internal
load_plugins_dialog <- function() {
  id <- "loadPlugins"
  ns <- function(x) paste0(id, "_", x)

  dialog_spec(
    id = id, title = tr("Load Rcmdr Plug-in(s)"), help = "library",
    ui = function(state, memory) {
      htmltools::tagList(
        file_input(
          ns("file"), tr("Plugin script:"), memory$file %||% "",
          filetypes = c("R", "r")
        ),
        help_text(tr(
          "The script should call RcmdrShiny.plugin(). Plugin menus appear after restarting RcmdrShiny."
        )),
        if (length(list_plugins()) > 0L) {
          htmltools::tags$p(
            htmltools::tags$strong(tr("Registered plugins:")),
            paste(list_plugins(), collapse = ", ")
          )
        }
      )
    },
    observers = function(input, output, session, state, refresh) {
      roots <- c(home = "~", wd = getwd(), root = "/")
      file_input_observers(
        input, session, ns("file"), roots,
        guard = function() identical(state$current_dialog, id),
        filetypes = c("R", "r")
      )
    },
    on_ok = function(input, state) {
      file <- trim_blanks(input[[ns("file")]] %||% "")
      if (!nzchar(file)) return(list(error = tr("You must select a file.")))
      if (!file.exists(file)) {
        return(list(error = sprintf(tr("File not found: %s"), file)))
      }
      result <- tryCatch(load_plugin(file), error = function(e) e)
      if (inherits(result, "error")) {
        return(list(error = conditionMessage(result)))
      }
      list(
        memory = list(file = file),
        message = tr("Plugin loaded. Restart RcmdrShiny to display its menus.")
      )
    }
  )
}
