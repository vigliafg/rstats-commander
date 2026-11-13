\name{plugins}
\alias{RcmdrShiny.plugin}
\alias{plugin_dialog}
\alias{list_plugins}
\alias{unload_plugins}
\alias{load_plugin}
\alias{load_plugin_package}
\title{RcmdrShiny plugin API}
\usage{
RcmdrShiny.plugin(name, menus = NULL, dialogs = list(),
  commands = list(), description = NULL, version = NULL,
  tcltk = FALSE)

plugin_dialog(id, title, ui, on_ok, on_open = NULL,
  observers = NULL, size = "l", help = NULL, help_package = NULL)

list_plugins()

unload_plugins()

load_plugin(file)

load_plugin_package(package)
}
\arguments{
\item{name}{Unique plugin name.}

\item{menus}{Path to an Rcmdr-style \code{menus.txt} file or a data frame
returned by \code{read_rcmdr_menus()}.}

\item{dialogs}{Named list of \code{plugin_dialog()} specifications.}

\item{commands}{Named list of direct command functions, called with the
application state.}

\item{description, version}{Optional plugin metadata.}

\item{tcltk}{Set to \code{TRUE} for a legacy Tk plugin; a warning is
emitted and entries without a Shiny implementation stay disabled.}

\item{id}{Command name used in the plugin menu file.}

\item{title}{Dialog title.}

\item{ui}{Function \code{function(state, memory)} returning the dialog UI.}

\item{on_ok}{Function \code{function(input, state)} returning a result list
with \code{commands}, \code{error}, \code{memory}, \code{activate_dataset}
or \code{activate_model}.}

\item{on_open}{Optional function called before the dialog opens.}

\item{observers}{Optional function registering Shiny observers.}

\item{size}{Modal size.}

\item{help, help_package}{Optional R help topic and package.}

\item{file}{Path to an R script that calls \code{RcmdrShiny.plugin()}.}

\item{package}{Installed legacy Rcmdr plugin package.}
}
\value{
\code{RcmdrShiny.plugin()} returns the plugin invisibly.  \code{list_plugins()}
returns a character vector.  \code{plugin_dialog()} returns a dialog
specification.
}
\description{
Registers plugins that extend the RcmdrShiny menus with direct commands and
Shiny dialogs.  Legacy Tk-based dialogs are not executed.
}
\details{
Plugin menu files use the same format as \code{Rcmdr-menus.txt}.  A plugin
script is sourced in a new environment.  Plugin menus are read when the
application starts; after \code{load_plugin()} in a running session, restart
the application to display them.
}
\examples{
\dontrun{
RcmdrShiny.plugin(
  name = "demo",
  menus = "etc/menus.txt",
  commands = list(hello = function(state) message("Hello")),
  dialogs = list(demo = plugin_dialog(
    "demo", "Demo", function(state, memory) htmltools::tags$p("Demo"),
    function(input, state) list(commands = "1 + 1")
  ))
)
}
}
