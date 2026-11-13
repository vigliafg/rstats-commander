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
  tcltk = FALSE, predicates = list(), replace = FALSE, help = NULL)

plugin_dialog(id, title, ui, on_ok, on_open = NULL,
  observers = NULL, size = "l", help = NULL, help_package = NULL,
  help_topic = NULL)

list_plugins()

unload_plugins()

load_plugin(file)

load_plugin_package(package, lib.loc = NULL)
}
\arguments{
\item{name}{Unique plugin name.}

\item{menus}{Path to an Rcmdr-style \code{menus.txt} file or a data frame
returned by \code{read_rcmdr_menus()}.  Plugin menu files may contain
\code{menu}, \code{item} and \code{remove} rows.}

\item{dialogs}{Named list of \code{plugin_dialog()} specifications.}

\item{commands}{Named list of direct command functions, called with the
application state.}

\item{description, version}{Optional plugin metadata.}

\item{tcltk}{Set to \code{TRUE} for a legacy Tk plugin; a warning is
emitted and entries without a Shiny implementation stay disabled.}

\item{predicates}{Named list of activation predicates, called with no
arguments or with the application state, and used in the \code{activation}
column of plugin menu entries.}

\item{replace}{Allow this plugin to replace an earlier plugin with the same
name and to override command, dialog or predicate names.}

\item{id}{Command name used in the plugin menu file.}

\item{title}{Dialog title.}

\item{ui}{Function \code{function(state, memory)} returning the dialog UI.}

\item{on_ok}{Function \code{function(input, state)} returning a result list
with \code{commands}, \code{error}, \code{memory}, \code{activate_dataset}
or \code{activate_model}.}

\item{on_open}{Optional function called before the dialog opens.}

\item{observers}{Optional function \code{function(input, output, session,
state, refresh)} registering Shiny observers.  Observers run for every dialog,
so they should guard on \code{state$current_dialog}.}

\item{size}{Modal size.}

\item{help, help_package}{For \code{plugin_dialog()}, an optional R help topic
and package.  For \code{RcmdrShiny.plugin()}, the path to a directory with
\code{index.yml} and Markdown topics; it is registered with the plugin and
shown in the Help tab.}

\item{help_topic}{Optional help-topic id opened by the dialog's Help button.
When \code{NULL}, the dialog id is tried first, then any topic that declares the
dialog in its \code{dialogs} front matter.}

\item{file}{Path to an R script that calls \code{RcmdrShiny.plugin()}.}

\item{package}{Installed plugin package.}

\item{lib.loc}{Optional library location.}
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
Plugin menu files use the same format as \code{Rcmdr-menus.txt}.  New plugin
packages are named \code{RcmdrShinyPlugin.*}, depend on \code{RcmdrShiny} and
export \code{rcmdrshiny_plugin()}, which either calls
\code{RcmdrShiny.plugin()} or returns a plugin specification (or a list of
specifications).  A plugin script is sourced in a new environment.

\code{load_plugin_package()} also accepts legacy \code{RcmdrPlugin.*}
packages.  Their \code{etc/menus.txt} is registered with a warning, but Tk
dialog functions are not executed and the entries stay disabled.

Plugin menus are read when the application starts; after \code{load_plugin()}
in a running session, restart the application to display them.
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
  )),
  predicates = list(hasDemoData = function() TRUE)
)
}
}
