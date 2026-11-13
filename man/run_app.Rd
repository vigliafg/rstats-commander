\name{run_app}
\alias{run_app}
\alias{run}
\title{Run RcmdrShiny}
\usage{
run_app(env = globalenv(), ...)

run(env = globalenv(), ...)
}
\arguments{
\item{env}{Evaluation environment for user commands.}

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
