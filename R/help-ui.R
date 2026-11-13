# Help user interface --------------------------------------------------------
#
# The Help tab is a small browser: a search box, a category list, a result list
# and a topic pane.  All content is rendered on the server, so the same code
# works offline and for plugin topics.

#' Help centre UI
#'
#' @return A `shiny.tag.list` with the Help tab.
#' @export
help_center_ui <- function() {
  htmltools::tagList(
    htmltools::div(
      class = "rcmdr-help-search",
      htmltools::tags$label(
        class = "visually-hidden", `for` = "help_query",
        tr("Search help")
      ),
      shiny::textInput(
        "help_query", NULL,
        placeholder = tr("Search help topics..."),
        width = "100%"
      ),
      htmltools::div(
        class = "rcmdr-help-context",
        uiOutput("help_context")
      )
    ),
    htmltools::div(
      class = "row g-3",
      htmltools::div(
        class = "col-lg-3",
        htmltools::div(
          class = "rcmdr-help-sidebar", role = "navigation",
          `aria-label` = tr("Help categories"),
          htmltools::tags$h6(tr("Categories")),
          uiOutput("help_categories"),
          uiOutput("help_recent")
        )
      ),
      htmltools::div(
        class = "col-lg-9",
        htmltools::div(
          `aria-live` = "polite", class = "rcmdr-help-results",
          uiOutput("help_results")
        ),
        htmltools::div(
          class = "rcmdr-help-topic", id = "help_topic_pane",
          tabindex = "-1",
          uiOutput("help_topic")
        )
      )
    )
  )
}

help_language <- function() {
  language <- tryCatch(current_language(), error = function(e) "en")
  if (!nzchar(language)) "en" else language
}

help_escape_id <- function(x) {
  gsub("[^A-Za-z0-9_.:-]", "", as.character(x))
}

help_topic_link <- function(id, label) {
  htmltools::tags$a(
    href = "#",
    class = "rcmdr-help-link",
    `data-help-topic` = help_escape_id(id),
    label
  )
}

help_topic_link_ui <- function(id, label = NULL) {
  topic <- help_topic(id)
  if (is.null(topic)) return(NULL)
  label <- label %||% topic$title
  htmltools::tags$li(help_topic_link(topic$id, label))
}

help_welcome_ui <- function(state = NULL) {
  htmltools::tagList(
    htmltools::tags$h3(tr("Help centre")),
    htmltools::tags$p(tr(
      "Search the topics or pick a category. Every dialog also has a Help button."
    )),
    htmltools::tags$ul(
      htmltools::tags$li(help_topic_link("getting-started",
                                         tr("Your first analysis"))),
      htmltools::tags$li(help_topic_link("data-import", tr("Importing data"))),
      htmltools::tags$li(help_topic_link("help-center",
                                         tr("Using the help centre")))
    )
  )
}

help_result_ui <- function(result) {
  id <- help_escape_id(result$id)
  htmltools::tags$a(
    href = "#",
    class = "rcmdr-help-result",
    onclick = sprintf(
      "Shiny.setInputValue('help_open', '%s', {priority: 'event'}); return false;",
      id
    ),
    htmltools::tags$span(class = "rcmdr-help-result-title", result$title),
    htmltools::tags$span(class = "rcmdr-help-result-category",
                         result$category),
    if (nzchar(result$snippet)) {
      htmltools::tags$p(class = "rcmdr-help-result-snippet", result$snippet)
    }
  )
}

help_category_ui <- function(category) {
  htmltools::tags$a(
    href = "#",
    class = "rcmdr-help-category",
    onclick = sprintf(
      "Shiny.setInputValue('help_category', '%s', {priority: 'event'}); return false;",
      help_escape_id(category$id)
    ),
    htmltools::tags$span(category$title),
    htmltools::tags$span(class = "badge text-bg-light", category$count)
  )
}

help_topic_footer_ui <- function(topic) {
  reference <- length(topic$commands) > 0L
  htmltools::div(
    class = "rcmdr-help-footer",
    if (reference) {
      shiny::actionButton(
        "help_r_reference", tr("R reference"),
        class = "btn-sm btn-outline-secondary"
      )
    },
    shiny::actionButton(
      "help_open_center", tr("Open in help centre"),
      class = "btn-sm btn-outline-primary"
    )
  )
}

help_topic_panel_ui <- function(topic) {
  htmltools::tagList(
    htmltools::div(
      class = "rcmdr-help-body",
      htmltools::HTML(help_topic_html_from_record(topic))
    ),
    if (length(topic$related) > 0L) {
      related <- Filter(Negate(is.null),
                        lapply(topic$related, help_topic_link_ui))
      if (length(related) > 0L) {
        htmltools::div(
          class = "rcmdr-help-related",
          htmltools::tags$h5(tr("Related topics")),
          htmltools::tags$ul(related)
        )
      }
    },
    help_topic_footer_ui(topic)
  )
}

# Panel shown inside a dialog when the Help button is pressed.  Keeping the
# help inside the dialog avoids stacking modals and preserves the fields the
# user has already filled in.
help_dialog_panel_ui <- function(topic) {
  htmltools::div(
    class = "rcmdr-help-inline",
    htmltools::div(
      class = "d-flex justify-content-between align-items-center mb-2",
      htmltools::tags$h5(topic$title),
      shiny::actionButton(
        "dialog_help_close", tr("Close help"),
        class = "btn-sm btn-outline-secondary"
      )
    ),
    htmltools::div(
      class = "rcmdr-help-body",
      htmltools::HTML(help_topic_html_from_record(topic))
    ),
    htmltools::div(
      class = "rcmdr-help-footer",
      if (length(topic$commands) > 0L) {
        shiny::actionButton(
          "dialog_help_reference", tr("R reference"),
          class = "btn-sm btn-outline-secondary"
        )
      },
      shiny::actionButton(
        "dialog_help_center", tr("Open in help centre"),
        class = "btn-sm btn-outline-primary"
      )
    )
  )
}
