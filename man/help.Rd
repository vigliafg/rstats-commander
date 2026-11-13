\name{help}
\alias{help_topic}\alias{help_topics}
\alias{help_index}
\alias{help_catalog}
\alias{help_search}
\alias{help_render}
\alias{help_topic_html}
\alias{help_topic_available}
\alias{help_topic_for_dialog}
\alias{help_topics_for_dialog}
\alias{help_register}
\alias{help_unregister}
\alias{help_registry}
\alias{register_plugin_help}
\title{Offline help topics}
\description{
Task-oriented help is stored as Markdown files with YAML front matter.  The
core ships its topics in \code{inst/help/}; plugin packages can ship their own
\code{inst/help/} directory, which is discovered when the plugin is loaded.

The registry is kept in memory and can be inspected or reset for tests.
}
\usage{
help_topics(language = NULL)

help_topic(id, language = NULL)

help_topic_available(id)

help_topic_for_dialog(spec, language = NULL)

help_topics_for_dialog(dialog_id, language = NULL)

help_index()

help_catalog(category = NULL, language = NULL)

help_search(query, limit = 20L, language = NULL)

help_render(markdown)

help_topic_html(id, language = NULL)

help_register(manifest, base_dir = NULL, package = NULL)

help_unregister(package = NULL)

help_registry()

register_plugin_help(package, name = package, lib.loc = NULL)
}
\arguments{
  \item{language}{Language code such as \code{"en"} or \code{"it"}.  Missing
  translations fall back to English.}
  \item{id}{Topic identifier.  Canonical ids are used for plugin topics
  (\code{plugin:<package>:<topic>}); short names are accepted when they are
  unambiguous.}
  \item{spec}{A dialog specification created with \code{dialog_spec()} or
  \code{\link{plugin_dialog}}.}
  \item{dialog_id}{Dialog identifier.}
  \item{category}{Optional category filter.}
  \item{query}{One or more search terms.}
  \item{limit}{Maximum number of search results.}
  \item{markdown}{Markdown source.}
  \item{manifest}{Manifest list as returned by the internal
  \code{help_read_manifest()} function.}
  \item{base_dir}{Directory the manifest paths are relative to.}
  \item{package}{Package name for plugin help registration, or \code{NULL} for
  the core.  In \code{help_unregister()}, the plugin to remove (all topics when
  \code{NULL}).}
  \item{name}{Plugin name used for the help namespace; defaults to the package
  name.}
  \item{lib.loc}{Library location, or \code{NULL}.}
}
\details{
\code{help_search()} ranks matches by where the terms appear: title, keywords,
aliases and command names, then body.  A lightweight prefix match handles plural
forms such as \sQuote{summaries} versus \sQuote{summary}.

\code{help_topic_for_dialog()} resolves a dialog's help in this order: the
\code{help_topic} field of the specification, the dialog id, then any topic that
declares the dialog in its \code{dialogs} front matter.  The Rd page declared in
the dialog's \code{help} field remains the technical fallback.

Rendering uses \pkg{commonmark} when installed and falls back to a plain
\code{<pre>} block otherwise.  Set
\code{options(RcmdrShiny.help.markdown = "plain")} to force the fallback.
Manifests are parsed with \pkg{yaml} when installed and with an internal parser
for the supported subset otherwise; set
\code{options(RcmdrShiny.help.yaml = "internal")} to force it.
}
\value{
\code{help_topics()} returns a named list of topic records.  \code{help_topic()}
returns one record or \code{NULL}.  \code{help_search()} returns a data frame
with \code{id}, \code{title}, \code{category}, \code{score}, \code{snippet} and
\code{package}.  \code{help_index()} returns the category table and
\code{help_catalog()} the topic table.  The registration functions return
invisible values.
}
\seealso{
\code{\link{help_center_ui}}, \code{\link{help_server}},
\code{dialog_spec()}, \code{\link{plugin_dialog}}
}
\keyword{utilities}
