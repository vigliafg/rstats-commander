\name{plugin-widgets}
\alias{plugin-widgets}
\alias{var_input}
\alias{checkbox_input}
\alias{checkboxes_input}
\alias{radio_input}
\alias{entry_input}
\alias{spin_input}
\alias{slider_input}
\alias{combo_input}
\alias{subset_input}
\alias{file_input}
\alias{dir_input}
\title{Shiny widgets for plugin dialogs}
\usage{
var_input(id, label, choices, selected = NULL, multiple = FALSE,
  size = NULL, placeholder = NULL)

checkbox_input(id, label, value = FALSE)

checkboxes_input(prefix, choices, selected = character(), ncol = 1L)

radio_input(id, label, choices, selected = NULL, inline = TRUE)

entry_input(id, label, value = "", placeholder = NULL, width = NULL)

spin_input(id, label, value = 0, min = NA, max = NA, step = 1)

slider_input(id, label, min, max, value, step = 1)

combo_input(id, label, choices, selected = NULL, multiple = FALSE)

subset_input(id, label = tr("Subset expression:"), value = "")

file_input(id, label, value = "", button = TRUE, placeholder = NULL,
  filetypes = NULL)

dir_input(id, label, value = "", button = TRUE, placeholder = NULL)
}
\arguments{
\item{id}{Input id.  Dialog inputs should be prefixed with the dialog id.}

\item{label}{Visible label.}

\item{choices}{Values shown by the widget: a character vector of variable
names, or a named vector of values and labels.}

\item{selected}{Initially selected value(s).}

\item{multiple}{Allow several selections.}

\item{size}{Optional widget size.}

\item{placeholder}{Placeholder text.}

\item{value}{Initial value.}

\item{prefix}{Prefix used to build checkbox ids (\code{prefix_name}).}

\item{ncol}{Number of columns in a checkbox group.}

\item{inline}{Render radio buttons inline.}

\item{width}{Widget width.}

\item{min, max, step}{Numeric range and step.}

\item{button}{Show a \code{shinyFiles} browse button.}

\item{filetypes}{Accepted file extensions for the browse button.}
}
\value{
An HTML tag or Shiny input, suitable for the \code{ui} function of
\code{plugin_dialog()}.
}
\description{
These widgets mirror the Rcmdr widgets used by the original plugins
(\code{variableListBox()}, \code{checkBoxes()}, \code{radioButtons()} and so
on), so a Tk dialog can be ported without rewriting its validation logic.
}
\examples{
\dontrun{
ui <- function(state, memory) {
  htmltools::tagList(
    var_input("demo_var", "Variable", variables(state), multiple = TRUE),
    checkbox_input("demo_opt", "Optional output")
  )
}
}
}
