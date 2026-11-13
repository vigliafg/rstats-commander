\name{help_center_ui}
\alias{help_center_ui}
\alias{help_server}
\title{Help centre UI and server}
\description{
Build the \sQuote{Help} tab and wire its server logic.  The tab combines a
search box, a category list, a result list, a recent-topics list and a topic
pane.  \code{help_server()} also provides the inline help shown inside dialogs.
}
\usage{
help_center_ui()

help_server(input, output, session, state)
}
\arguments{
  \item{input, output, session}{Shiny objects.}
  \item{state}{Application state created by \code{\link{AppState}}.}
}
\details{
\code{help_server()} registers observers for the search results, the category
filter, the \sQuote{R reference} button and the dialog help panel.  It also adds
\code{help_show()}, \code{help_show_dialog()}, \code{help_reset_dialog()} and
\code{help_topic_open()} to the state, so direct commands such as
\sQuote{Help centre} can open a topic.

Search results and internal links are rendered on the server and navigated
through a Shiny input, so the same markup works for plugin topics and needs no
client-side index.
}
\value{
\code{help_center_ui()} returns a \code{shiny.tag.list}.  \code{help_server()}
returns \code{NULL}, invisibly.
}
\seealso{\code{\link{help}}, \code{\link{run_app}}}
\keyword{utilities}
