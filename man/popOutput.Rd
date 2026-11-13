\name{popOutput}
\alias{popOutput}
\title{Retrieve the last printed object}
\usage{
popOutput(keep = FALSE)
}
\arguments{
\item{keep}{Keep the object in the output stack.}
}
\value{
The last object printed by \code{run_command()}, or \code{NA} when the stack
is empty.
}
\description{
RcmdrShiny keeps the objects returned by commands so that plugins can export
the last output.  \code{popOutput()} mirrors the Rcmdr function of the same
name; generated plugin commands call it inside \code{local()} blocks.
}
\examples{
\dontrun{
state <- AppState()
run_command(state, "1:10")
popOutput(keep = TRUE)
}
}
