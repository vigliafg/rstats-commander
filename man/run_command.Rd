\name{run_command}
\alias{run_command}
\title{Run an R command}
\usage{
run_command(state, code, log = TRUE, echo = TRUE, plot = "auto")
}
\arguments{
\item{state}{Application state created by \code{\link{AppState}}.}

\item{code}{Character string (or vector of lines) of R code.}

\item{log}{Append the command to the command log.}

\item{echo}{Reserved: include the command in the output.}

\item{plot}{If \code{TRUE}, capture the resulting plot as a PNG.  The
default \code{"auto"} captures only commands that look like plotting
calls.}
}
\value{
Invisibly, a list with components \code{status}, \code{code},
\code{output}, \code{warnings}, \code{messages}, \code{error} and
\code{value}.
}
\description{
Evaluates \code{code} in \code{state$env}, appends it to the command log
and captures its output, messages, warnings and errors.  This is the
engine counterpart of Rcmdr's \code{doItAndPrint()}.
}
\examples{
state <- AppState(env = new.env())
run_command(state, "1 + 1")
state$output
}
