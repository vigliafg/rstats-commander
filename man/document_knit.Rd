\name{document_knit}
\alias{document_knit}
\alias{document_modes}
\title{Knit the current document}
\description{
Render the R Markdown or knitr document held in the Script tab.  The document
is evaluated in the session environment, so it sees the active data set and
models.  The result is written to the session knit directory and shown in the
\strong{Report} tab.
}
\usage{
document_knit(state, format = "html")

document_modes()
}
\arguments{
  \item{state}{Application state created by \code{\link{AppState}}.}
  \item{format}{\code{"html"}, \code{"pdf"} or \code{"word"}.  A knitr
  document supports only \code{"pdf"}.}
}
\details{
The formats depend on external tools: HTML and Word need Pandoc, PDF needs a
LaTeX installation (\code{pdflatex}), and a knitr document needs both
\pkg{knitr} and LaTeX.  The \strong{Knit document} dialog only offers the
formats that are available.

Knitting executes the code in the document.  Use \strong{File > Knit
document...} or the \strong{Knit} button in the Script tab.
}
\value{
\code{document_knit()} returns a list with \code{file}, \code{url},
\code{format}, \code{input}, \code{mode} and \code{time}, invisibly.
\code{document_modes()} returns \code{c("r", "rmd", "rnw")}.
}
\seealso{\code{\link{report_rmd}}, \code{\link{AppState}}}
\keyword{utilities}
