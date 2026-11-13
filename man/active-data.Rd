\name{active-data}
\alias{active_dataset}
\alias{active_model}
\title{Get or set the active data set and model}
\usage{
active_dataset(state, value)

active_model(state, value)
}
\arguments{
\item{state}{Application state created by \code{AppState()}.}

\item{value}{For \code{active_dataset()}, the name of a data frame in the
state environment, or \code{NULL} to clear it.  For \code{active_model()}, the
name of a model object, or \code{NULL}.  Omit to read the current value.}
}
\value{
When \code{value} is omitted, the current name (or \code{NULL}).  When a value
is supplied, the value invisibly after validating the object.
}
\description{
Read or change the active data set and the active model.  These are the same
accessors used by the application menus and are the supported entry points for
plugin commands and dialogs.
}
\examples{
\dontrun{
state <- AppState()
active_dataset(state, "mtcars")
active_dataset(state)
active_model(state)
}
}
