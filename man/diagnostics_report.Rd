\name{diagnostics_report}
\alias{diagnostics_report}
\alias{format_diagnostics}
\title{Diagnostic report}
\description{
Collect the information needed to diagnose a problem: R and RcmdrShiny
versions, loaded plugins, relevant package versions and the options that change
generated commands.  The report contains no data, script or environment
contents.
}
\usage{
diagnostics_report()

format_diagnostics(report = diagnostics_report())
}
\arguments{
  \item{report}{A report returned by \code{diagnostics_report()}.}
}
\value{
\code{diagnostics_report()} returns a named list.  \code{format_diagnostics()}
returns a character vector with one line per item.
}
\seealso{\code{\link{help}}}
\keyword{utilities}
