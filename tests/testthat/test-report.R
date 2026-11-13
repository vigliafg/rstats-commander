report_state <- function() {
  env <- new.env()
  env$D <- data.frame(x = 1:5, y = 1:5)
  state <- AppState(env = env)
  active_dataset(state, "D")
  state$log <- c("D <- read.csv(\"data.csv\")", "summary(D)")
  state$output <- c("     x             y", " Min.   :1.0   Min.   :1.0")
  state
}

test_that("the R Markdown report contains script and output", {
  state <- report_state()
  rmd <- report_rmd(state, title = "My report")

  expect_true(any(grepl("^---$", rmd)))
  expect_true(any(grepl("My report", rmd)))
  expect_true(any(grepl("read.csv", rmd)))
  expect_true(any(grepl("Min.", rmd)))
  expect_true(any(grepl("eval=FALSE", rmd)))
})

test_that("plots are embedded when present", {
  state <- report_state()
  file <- tempfile(fileext = ".png")
  writeLines("not a real png", file)
  state$plots <- list(list(file = file, code = "plot(1)"))
  rmd <- report_rmd(state)
  expect_true(any(grepl("include_graphics", rmd)))
  expect_true(any(grepl(basename(file), rmd)))
})

test_that("write_report_rmd writes the document", {
  state <- report_state()
  file <- tempfile(fileext = ".Rmd")
  write_report_rmd(state, file, title = "Report")
  expect_true(file.exists(file))
  expect_true(any(grepl("Report", readLines(file, warn = FALSE))))
})

test_that("fenced code inside the log does not break the document", {
  expect_false(grepl("```", report_escape("```"), fixed = TRUE))

  state <- report_state()
  state$log <- c("cat(\"```\")", "```")
  rmd <- report_rmd(state)
  fences <- sum(trimws(rmd) == "```")
  expect_equal(fences %% 2L, 0L)
  expect_gte(fences, 4L)
})

test_that("the export dialog validates the format", {
  state <- report_state()
  spec <- export_report_dialog()
  result <- spec$on_ok(list(exportReport_title = "Report",
                            exportReport_format = "rmd"), state)
  expect_equal(result$report$format, "rmd")
  expect_null(result$error)
})
