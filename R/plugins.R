# Plugin API ----------------------------------------------------------------
#
# A plugin is a named collection of menu definitions, direct commands and
# Shiny dialog specifications.  Legacy Tk dialogs are deliberately not
# executed: plugins that depend on them are registered with a warning and
# their menu entries remain disabled.

.plugin_registry <- new.env(parent = emptyenv())
.plugin_registry$plugins <- list()

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
#' @param tcltk Set to `TRUE` for a legacy Tk plugin; a warning is emitted and
#'   menu entries without a Shiny implementation stay disabled.
#' @return The registered plugin, invisibly.
#' @export
RcmdrShiny.plugin <- function(name, menus = NULL, dialogs = list(),
                              commands = list(), description = NULL,
                              version = NULL, tcltk = FALSE) {
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

  plugin <- list(
    name = name,
    menus = menus,
    dialogs = dialogs,
    commands = commands,
    description = description,
    version = version,
    tcltk = isTRUE(tcltk)
  )

  if (isTRUE(tcltk)) {
    warning(
      sprintf("Plugin '%s' uses legacy Tk dialogs; only its direct commands are supported.",
              name),
      call. = FALSE
    )
  }

  .plugin_registry$plugins[[name]] <- plugin
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

#' Load a legacy Rcmdr plugin package
#'
#' Reads `etc/menus.txt` from an installed package and registers its menu.
#' Because legacy menus call Tk dialog functions, their commands are not
#' executed; the entries are shown as disabled with a warning.
#'
#' @param package Installed package name.
#' @return Invisibly, the plugin object.
#' @export
load_plugin_package <- function(package) {
  if (!requireNamespace(package, quietly = TRUE)) {
    stop(sprintf("Package '%s' is not installed.", package), call. = FALSE)
  }
  path <- system.file("etc", "menus.txt", package = package)
  if (!nzchar(path) || !file.exists(path)) {
    stop(sprintf("Package '%s' does not provide etc/menus.txt.", package),
         call. = FALSE)
  }
  RcmdrShiny.plugin(
    name = package,
    menus = read_rcmdr_menus(path),
    tcltk = TRUE
  )
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
      definitions <- rbind(definitions, plugin$menus)
    }
  }
  definitions
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
