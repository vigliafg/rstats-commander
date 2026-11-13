# "Read Text Data" dialog ------------------------------------------------

import_text_dialog <- function() {
  id <- "readDataSet"
  ns <- function(x) paste0(id, "_", x)

  defaults <- list(
    dsname = "Dataset",
    location = "local",
    path = "",
    url = "",
    header = TRUE,
    stringsAsFactors = TRUE,
    delimiter = "whitespace",
    other = "",
    missing = "NA",
    decimal = "period"
  )

  dialog_spec(
    id = id,
    title = tr("Read Text Data From File, Clipboard, or URL"),
    ui = function(state, memory) {
      m <- utils::modifyList(defaults, memory %||% list())

      htmltools::tagList(
        entry_input(ns("dsname"), tr("Enter name for data set:"), m$dsname),
        radio_input(
          ns("location"), tr("Location of Data File"),
          c(
            "Local file system" = "local",
            "Clipboard" = "clipboard",
            "Internet URL" = "url"
          ),
          m$location
        ),
        conditionalPanel(
          sprintf("input['%s'] == 'local'", ns("location")),
          entry_input(
            ns("path"), tr("File path:"), m$path,
            placeholder = tr("/path/to/data.csv")
          ),
          shinyFiles::shinyFilesButton(
            ns("browse"), tr("Browse..."), tr("Select a file"), multiple = FALSE
          )
        ),
        conditionalPanel(
          sprintf("input['%s'] == 'url'", ns("location")),
          entry_input(ns("url"), tr("Internet URL:"), m$url,
                      placeholder = "https://example.org/data.csv")
        ),
        checkbox_input(ns("header"), tr("Variable names in file"), m$header),
        checkbox_input(
          ns("stringsAsFactors"),
          tr("Convert character variables to factors"),
          m$stringsAsFactors
        ),
        radio_input(
          ns("delimiter"), tr("Field Separator"),
          c(
            "White space" = "whitespace",
            "Commas [,]" = "commas",
            "Semicolons [;]" = "semicolons",
            "Tabs" = "tabs",
            "Other" = "other"
          ),
          m$delimiter
        ),
        conditionalPanel(
          sprintf("input['%s'] == 'other'", ns("delimiter")),
          entry_input(ns("other"), tr("Specify:"), m$other)
        ),
        radio_input(
          ns("decimal"), tr("Decimal-Point Character"),
          c("Period [.]" = "period", "Comma [,]" = "comma"),
          m$decimal
        ),
        entry_input(ns("missing"), tr("Missing data indicator:"), m$missing),
        help_text(tr("The generated read.table() command is shown in the script pane."))
      )
    },
    on_ok = function(input, state) {
      dsname <- trim_blanks(input[[ns("dsname")]])
      location <- input[[ns("location")]]
      path <- trim_blanks(input[[ns("path")]] %||% "")
      url <- trim_blanks(input[[ns("url")]] %||% "")
      missing <- input[[ns("missing")]] %||% "NA"
      other <- input[[ns("other")]] %||% ""
      decimal <- input[[ns("decimal")]] %||% "period"
      delimiter <- input[[ns("delimiter")]] %||% "whitespace"

      if (!nzchar(dsname)) {
        return(list(error = tr("You must enter a name for the data set.")))
      }
      if (!is_valid_name(dsname)) {
        return(list(error = sprintf(tr('"%s" is not a valid name.'), dsname)))
      }
      if (exists(dsname, envir = state$env, inherits = FALSE)) {
        return(list(error = sprintf(
          tr("An object named '%s' already exists. Choose another name."), dsname
        )))
      }
      if (identical(location, "local")) {
        if (!nzchar(path)) return(list(error = tr("You must select a file.")))
        if (!file.exists(path)) {
          return(list(error = sprintf(tr("File not found: %s"), path)))
        }
      }
      if (identical(location, "url") && !nzchar(url)) {
        return(list(error = tr("You must enter a URL.")))
      }

      command <- read_text_command(
        dsname = dsname,
        header = isTRUE(input[[ns("header")]]),
        stringsAsFactors = isTRUE(input[[ns("stringsAsFactors")]]),
        delimiter = delimiter,
        other = other,
        missing = missing,
        decimal = decimal,
        location = location,
        path = path,
        url = url
      )

      # The dialog closes and the data set becomes active only if read.table()
      # succeeds; the runtime reports the error otherwise.
      list(
        commands = command,
        activate_dataset = dsname,
        memory = list(
          dsname = dsname, location = location, path = path, url = url,
          header = isTRUE(input[[ns("header")]]),
          stringsAsFactors = isTRUE(input[[ns("stringsAsFactors")]]),
          delimiter = delimiter, other = other, missing = missing,
          decimal = decimal
        )
      )
    },
    observers = function(input, output, session, state, refresh) {
      roots <- c(home = "~", wd = getwd(), root = "/")
      shinyFiles::shinyFileChoose(
        input, ns("browse"),
        roots = roots,
        filetypes = c("txt", "csv", "dat", "tsv", "TXT", "CSV", "DAT", "TSV")
      )
      observeEvent(input[[ns("browse")]], {
        req(identical(state$current_dialog, id))
        selected <- shinyFiles::parseFilePaths(roots, input[[ns("browse")]])
        if (nrow(selected) > 0L) {
          updateTextInput(session, ns("path"),
                          value = as.character(selected$datapath[[1L]]))
        }
      }, ignoreInit = TRUE)
      invisible(NULL)
    }
  )
}
