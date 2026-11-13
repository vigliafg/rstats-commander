\name{report_rmd}
\alias{report_rmd}
\alias{write_report_rmd}
\alias{write_report_html}
\title{Session report}
\description{
Build an R Markdown report from the command log, the captured output and the
plots of the current session.  The commands are included with \code{eval =
FALSE}, so rendering the report does not re-execute the analysis.
}
\usage{
report_rmd(state, title = "RcmdrShiny report", include_plots = TRUE)

write_report_rmd(state, file, title = "RcmdrShiny report")

write_report_html(state, file, title = "RcmdrShiny report")
}
\arguments{
  \item{state}{Application state created by \code{\link{AppState}}.}
  \item{title}{Report title.}
  \item{include_plots}{Embed the session plots.}
  \item{file}{Destination path.}
}
\details{
The R Markdown file is always available.  \code{write_report_html()} needs
\pkg{rmarkdown}, \pkg{knitr} and a working Pandoc installation; when they are
missing the dialog offers only the R Markdown format.

The report is also available from \strong{File > Export report...}.  Nothing is
sent anywhere: the file is written locally from data already visible in the
session.
}
\value{
\code{report_rmd()} returns a character vector with the document.
\code{write_report_rmd()} and \code{write_report_html()} return the path,
invisibly.
}
\seealso{\code{\link{AppState}}, \code{\link{run_command}}}
\keyword{utilities}
