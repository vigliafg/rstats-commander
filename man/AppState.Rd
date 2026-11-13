\name{AppState}
\alias{AppState}
\title{Create an application state}
\usage{
AppState(env = globalenv())
}
\arguments{
\item{env}{Evaluation environment used by \code{\link{run_command}}.
Defaults to the global environment, mirroring Rcmdr.}
}
\value{
An environment of class \code{RcmdrShinyState}.
}
\description{
Creates the per-session state used by the application: evaluation
environment, active data set and model, command log, output, messages,
dialog memory and plot history.
}
\examples{
state <- AppState(env = new.env())
state$active_dataset
}
