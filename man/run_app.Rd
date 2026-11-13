\name{run_app}
\alias{run_app}
\alias{run}
\title{Run RcmdrShiny}
\usage{
run_app(env = globalenv(), language = NULL, plugins = NULL, ...)

run(env = globalenv(), language = NULL, plugins = NULL, ...)
}
\arguments{
\item{env}{Evaluation environment for user commands.}

\item{language}{Language code for the session (for example \code{"en"} or
\code{"it"}).  Defaults to the current language.}

\item{plugins}{Optional plugin files, package names or argument lists.}

\item{...}{Further arguments passed to \code{\link[shiny:runApp]{shiny::runApp}}.}
}
\value{
The value returned by \code{\link[shiny:runApp]{shiny::runApp}}, invisibly.
}
\description{
Starts the local Shiny application in the browser.
}
\examples{
\dontrun{
RcmdrShiny::run()
}
}
