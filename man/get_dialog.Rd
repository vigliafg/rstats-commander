\name{get_dialog}
\alias{get_dialog}
\title{Retrieve a dialog specification}
\usage{
get_dialog(id)
}
\arguments{
\item{id}{Command name used in the menu file.}
}
\value{
A dialog specification, or \code{NULL} when no dialog has that id.
}
\description{
Exposes the dialog registry to plugin packages.  Plugin tests can retrieve
their dialog and call its \code{on_ok()} callback with a synthetic input.
}
\examples{
\dontrun{
spec <- get_dialog("numericalSummaries")
spec$on_ok(list(), AppState())
}
}
