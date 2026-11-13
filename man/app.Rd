\name{app}
\alias{app}
\title{Create the RcmdrShiny application}
\usage{
app(env = globalenv())
}
\arguments{
\item{env}{Evaluation environment for user commands.  Defaults to the
global environment.}
}
\value{
A \code{shiny.appobj}.
}
\description{
Creates the Shiny application object without starting a server.  This is
useful for automated tests and for embedding the application in another
Shiny process.
}
\examples{
app <- app(env = new.env())
inherits(app, "shiny.appobj")
}
