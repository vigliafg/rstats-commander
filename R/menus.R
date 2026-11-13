# Menu definitions ----------------------------------------------------------
#
# Rcmdr's Rcmdr-menus.txt remains the source of truth for the menu structure.
# The file is parsed into a tree; the Shiny sidebar renders that tree, and the
# server registers one observer per leaf.  Leaves whose command has not been
# ported yet are disabled with an "in porting" tooltip, which gives an
# incremental release path without editing the menu file.

#' Read an Rcmdr menu definition file
#'
#' @param path Path to `Rcmdr-menus.txt`.
#' @return A data frame with one row per definition and columns `type`, `menu`,
#'   `kind`, `label`, `command`, `activation` and `install`.
#' @export
read_rcmdr_menus <- function(path = system.file("etc", "Rcmdr-menus.txt",
                                                package = "RcmdrShiny")) {
  if (!file.exists(path)) {
    stop(sprintf("Menu file not found: %s", path), call. = FALSE)
  }
  lines <- readLines(path, warn = FALSE, encoding = "UTF-8")
  lines <- trimws(lines)
  lines <- lines[nzchar(lines) & !startsWith(lines, "#")]

  rows <- lapply(lines, parse_menu_line)
  rows <- rows[!vapply(rows, is.null, logical(1))]
  if (length(rows) == 0L) {
    return(empty_menu_definitions())
  }
  do.call(rbind, rows)
}

parse_menu_line <- function(line) {
  tokens <- regmatches(line, gregexpr('"([^"]*)"|\\S+', line, perl = TRUE))[[1L]]
  tokens <- sub('^"(.*)"$', "\\1", tokens)

  type <- if (length(tokens) > 0L) tokens[[1L]] else ""
  if (!type %in% c("menu", "item", "remove")) return(NULL)
  minimum <- if (identical(type, "remove")) 2L else 4L
  if (length(tokens) < minimum) return(NULL)

  fields <- rep("", 7L)
  fields[seq_len(min(length(tokens), 7L))] <- tokens[seq_len(min(length(tokens), 7L))]

  data.frame(
    type = fields[[1L]],
    menu = fields[[2L]],
    kind = fields[[3L]],
    label = fields[[4L]],
    command = fields[[5L]],
    activation = fields[[6L]],
    install = fields[[7L]],
    stringsAsFactors = FALSE
  )
}

empty_menu_definitions <- function() {
  data.frame(
    type = character(), menu = character(), kind = character(),
    label = character(), command = character(), activation = character(),
    install = character(), stringsAsFactors = FALSE
  )
}

insert_menu_row <- function(definitions, row, after = 0L) {
  n <- nrow(definitions)
  after <- max(0L, min(as.integer(after), n))
  before <- if (after > 0L) definitions[seq_len(after), , drop = FALSE] else {
    definitions[0L, , drop = FALSE]
  }
  rest <- if (after < n) definitions[seq.int(after + 1L, n), , drop = FALSE] else {
    definitions[0L, , drop = FALSE]
  }
  rbind(before, row, rest)
}

# Remove a menu (or a command) and its descendants.  Mirrors Rcmdr's
# `removeMenus()`: a definition can be removed either by menu id or by the
# command it points to.
remove_menu_rows <- function(definitions, what) {
  if (is.null(what) || !nzchar(what) || nrow(definitions) == 0L) {
    return(definitions)
  }
  children <- unique(definitions$menu[
    definitions$type == "menu" & definitions$kind == what
  ])
  keep <- !(definitions$menu == what | definitions$command == what)
  definitions <- definitions[keep, , drop = FALSE]
  for (child in children) {
    definitions <- remove_menu_rows(definitions, child)
  }
  definitions
}

#' Merge plugin menu definitions into a base menu
#'
#' Implements the insertion rules of Rcmdr's `processMenus()`: menu and item
#' rows are appended to their parent menu, top-level cascades are placed before
#' Tools and Help, and `remove` rows delete a menu or command with its
#' descendants.
#'
#' @param definitions Base menu data frame.
#' @param additions Plugin menu data frame.
#' @param source Optional plugin name used in error messages.
#' @return A merged menu data frame.
#' @keywords internal
merge_menu_definitions <- function(definitions, additions, source = NULL) {
  if (is.null(additions) || nrow(additions) == 0L) return(definitions)
  where <- if (is.null(source)) "" else sprintf(" in plugin '%s'", source)

  find_menu <- function(menu) {
    rows <- which(definitions$type == "menu" & definitions$menu == menu)
    if (length(rows) == 0L) {
      stop(sprintf("Plugin menu refers to unknown parent menu '%s'%s.",
                   menu, where), call. = FALSE)
    }
    max(rows)
  }

  for (i in seq_len(nrow(additions))) {
    row <- additions[i, , drop = FALSE]

    if (identical(row$type, "remove")) {
      definitions <- remove_menu_rows(definitions, row$menu)
      next
    }

    if (identical(row$type, "menu")) {
      parent <- row$kind
      after <- if (!nzchar(parent) || identical(parent, "topMenu")) {
        0L
      } else {
        find_menu(parent)
      }
      definitions <- insert_menu_row(definitions, row, after)
      next
    }

    if (!identical(row$type, "item")) {
      stop(sprintf("Unrecognised plugin menu type '%s'%s.",
                   row$type, where), call. = FALSE)
    }

    if (row$kind %in% c("command", "separator")) {
      siblings <- which(
        definitions$menu == row$menu &
          definitions$kind %in% c("command", "separator")
      )
      after <- if (length(siblings) > 0L) {
        max(siblings)
      } else {
        find_menu(row$menu)
      }
      # A separator can be anchored after a given command.
      if (identical(row$kind, "separator") && nzchar(row$command)) {
        anchor <- which(definitions$command == row$command)
        if (length(anchor) == 0L) {
          stop(sprintf("Plugin separator refers to unknown command '%s'%s.",
                       row$command, where), call. = FALSE)
        }
        after <- max(anchor)
      }
      definitions <- insert_menu_row(definitions, row, after)
    } else if (identical(row$kind, "cascade")) {
      if (identical(row$menu, "topMenu")) {
        siblings <- which(
          definitions$kind == "cascade" &
            definitions$menu == "topMenu" &
            !definitions$command %in% c("toolsMenu", "helpMenu")
        )
        after <- if (length(siblings) > 0L) max(siblings) else 0L
      } else {
        siblings <- which(
          (definitions$kind == "cascade" & definitions$menu == row$menu) |
            definitions$command == row$menu
        )
        if (length(siblings) == 0L) {
          stop(sprintf("Plugin cascade refers to unknown parent menu '%s'%s.",
                       row$menu, where), call. = FALSE)
        }
        after <- max(siblings)
      }
      definitions <- insert_menu_row(definitions, row, after)
    } else {
      stop(sprintf("Unrecognised plugin menu operation '%s'%s.",
                   row$kind, where), call. = FALSE)
    }
  }

  definitions
}

#' Build the menu tree
#'
#' @param definitions Data frame returned by [read_rcmdr_menus()].  Defaults to
#'   the core menus plus all registered plugin menus.
#' @return A list of top-level menu nodes.
#' @export
menu_tree <- function(definitions = NULL) {
  if (is.null(definitions)) definitions <- plugin_menu_definitions()
  counter <- new.env(parent = emptyenv())
  counter$n <- 0L
  build_menu_children(definitions, "topMenu", path = character(), counter = counter)
}

build_menu_children <- function(definitions, menu, path = character(),
                                counter = NULL) {
  if (is.null(counter)) {
    counter <- new.env(parent = emptyenv())
    counter$n <- 0L
  }
  rows <- which(definitions$type == "item" & definitions$menu == menu)
  nodes <- vector("list", length(rows))

  for (i in seq_along(rows)) {
    row <- definitions[rows[[i]], , drop = FALSE]
    counter$n <- counter$n + 1L
    key <- sprintf("menu_item_%d", counter$n)
    node_path <- c(path, row$label)

    if (identical(row$kind, "separator")) {
      nodes[[i]] <- list(type = "separator", key = key, path = node_path)
    } else if (identical(row$kind, "cascade")) {
      nodes[[i]] <- list(
        type = "menu",
        id = row$command,
        label = row$label,
        key = key,
        path = node_path,
        children = build_menu_children(definitions, row$command, node_path,
                                       counter = counter)
      )
    } else {
      nodes[[i]] <- list(
        type = "item",
        id = row$command,
        label = row$label,
        command = row$command,
        key = key,
        path = node_path,
        activation = row$activation,
        install = row$install
      )
    }
  }
  nodes
}

#' Flatten the menu tree to its leaves
#'
#' @param tree Menu tree returned by [menu_tree()].
#' @return A data frame with one row per command item.
#' @export
menu_leaves <- function(tree) {
  rows <- list()
  walk <- function(nodes) {
    for (node in nodes) {
      if (node$type == "menu") {
        walk(node$children)
      } else if (node$type == "item") {
        rows[[length(rows) + 1L]] <<- data.frame(
          key = node$key,
          command = node$command,
          label = node$label,
          path = paste(node$path, collapse = " > "),
          activation = node$activation,
          install = node$install,
          stringsAsFactors = FALSE
        )
      }
    }
  }
  walk(tree)
  if (length(rows) == 0L) {
    return(data.frame(
      key = character(), command = character(), label = character(),
      path = character(), activation = character(), install = character(),
      stringsAsFactors = FALSE
    ))
  }
  do.call(rbind, rows)
}

# Rendering -----------------------------------------------------------------

#' Render the menu tree as HTML
#'
#' @param tree Menu tree returned by [menu_tree()].
#' @param status Function taking a menu item node and returning one of
#'   `"enabled"`, `"porting"`, `"inactive"` or `"hidden"`.
#' @keywords internal
menu_ui <- function(tree, status = function(node) "enabled") {
  htmltools::tags$div(
    class = "rcmdr-menu",
    lapply(tree, menu_node_ui, status = status)
  )
}

menu_node_ui <- function(node, status = function(node) "enabled") {
  if (identical(node$type, "separator")) {
    return(htmltools::tags$hr(class = "my-1"))
  }

  if (identical(node$type, "menu")) {
    children <- lapply(node$children, menu_node_ui, status = status)
    return(htmltools::tags$details(
      class = "rcmdr-menu-group",
      htmltools::tags$summary(menu_label(node$label)),
      htmltools::tags$div(class = "rcmdr-menu-children", children)
    ))
  }

  state <- status(node)
  if (identical(state, "hidden")) return(NULL)

  if (identical(state, "enabled")) {
    actionLink(node$key, menu_label(node$label), class = "rcmdr-menu-item")
  } else {
    tooltip <- if (identical(state, "porting")) {
      tr("In porting")
    } else {
      tr("Not available for the current data set")
    }
    htmltools::tags$span(
      class = "rcmdr-menu-item disabled",
      title = tooltip,
      menu_label(node$label)
    )
  }
}
