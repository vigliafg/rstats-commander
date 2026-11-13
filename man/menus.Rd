\name{menus}
\alias{read_rcmdr_menus}
\alias{menu_tree}
\alias{menu_leaves}
\title{Read and inspect Rcmdr menu definitions}
\usage{
read_rcmdr_menus(path = system.file("etc", "Rcmdr-menus.txt",
  package = "RcmdrShiny"))

menu_tree(definitions = NULL)

menu_leaves(tree)
}
\arguments{
\item{path}{Path to a menu definition file in Rcmdr format.}

\item{definitions}{Menu data frame returned by \code{read_rcmdr_menus()}.
The default includes the menus of all registered plugins.}

\item{tree}{Menu tree returned by \code{menu_tree()}.}
}
\value{
\code{read_rcmdr_menus()} returns a data frame with one row per definition and
columns \code{type}, \code{menu}, \code{kind}, \code{label}, \code{command},
\code{activation} and \code{install}.  \code{menu_tree()} returns a list of
menu nodes.  \code{menu_leaves()} returns a data frame with one row per command
item.
}
\description{
These functions expose the menu parser used by RcmdrShiny.  Plugin packages can
use them in tests to check that their menus merge correctly with the core
menus.
}
\examples{
\dontrun{
definitions <- read_rcmdr_menus()
leaves <- menu_leaves(menu_tree(definitions))
}
}
