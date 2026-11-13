\name{plugin-helpers}
\alias{plugin-helpers}
\alias{variables}
\alias{numeric_variables}
\alias{factor_variables}
\alias{two_level_factors}
\alias{dataset}
\alias{plugin_formula}
\alias{tr}
\alias{available_languages}
\title{Helpers for RcmdrShiny plugins}
\usage{
variables(state)

numeric_variables(state)

factor_variables(state)

two_level_factors(state)

dataset(state)

plugin_formula(response = NULL, predictors = character(),
  interactions = list())

tr(...)

available_languages()
}
\arguments{
\item{state}{Application state created by \code{AppState()}.}

\item{response}{Optional response variable name.}

\item{predictors}{Character vector of predictor names.}

\item{interactions}{Optional list of character vectors.  A vector with more
than one element becomes an interaction term such as \code{(a * b)}.}

\item{...}{Pieces of a message, pasted together before translation.}
}
\value{
\code{variables()}, \code{numeric_variables()}, \code{factor_variables()} and
\code{two_level_factors()} return character vectors.  \code{dataset()} returns the active data frame or
\code{NULL}.  \code{plugin_formula()} returns a formula string.
\code{tr()} returns a translated string and \code{available_languages()}
returns the language codes shipped with RcmdrShiny.
}
\description{
Stable helpers for plugin packages.  They expose the active data set and its
variables, build formula strings, and provide the same translation helpers used
by the core application.
}
\examples{
\dontrun{
state <- AppState()
variables(state)
plugin_formula("y", c("x1", "x2"))
plugin_formula("y", "x", list(c("a", "b")))
}
}
