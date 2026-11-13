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
    return(data.frame(
      type = character(), menu = character(), kind = character(),
      label = character(), command = character(), activation = character(),
      install = character(), stringsAsFactors = FALSE
    ))
  }
  do.call(rbind, rows)
}

parse_menu_line <- function(line) {
  tokens <- regmatches(line, gregexpr('"([^"]*)"|\\S+', line, perl = TRUE))[[1L]]
  tokens <- sub('^"(.*)"$', "\\1", tokens)
  if (length(tokens) < 4L) return(NULL)

  type <- tokens[[1L]]
  if (!type %in% c("menu", "item")) return(NULL)

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

#' Build the menu tree
#'
#' @param definitions Data frame returned by [read_rcmdr_menus()].
#' @return A list of top-level menu nodes.
#' @export
menu_tree <- function(definitions = read_rcmdr_menus()) {
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
#' @keywords internal
menu_ui <- function(tree, enabled = function(command) TRUE) {
  htmltools::tags$div(
    class = "rcmdr-menu",
    lapply(tree, menu_node_ui, enabled = enabled)
  )
}

menu_node_ui <- function(node, enabled = function(command) TRUE) {
  if (identical(node$type, "separator")) {
    return(htmltools::tags$hr(class = "my-1"))
  }

  if (identical(node$type, "menu")) {
    return(htmltools::tags$details(
      class = "rcmdr-menu-group",
      htmltools::tags$summary(menu_label(node$label)),
      htmltools::tags$div(
        class = "rcmdr-menu-children",
        lapply(node$children, menu_node_ui, enabled = enabled)
      )
    ))
  }

  available <- isTRUE(enabled(node$command))
  if (available) {
    actionLink(node$key, menu_label(node$label), class = "rcmdr-menu-item")
  } else {
    htmltools::tags$span(
      class = "rcmdr-menu-item disabled",
      title = tr("In porting"),
      menu_label(node$label)
    )
  }
}
