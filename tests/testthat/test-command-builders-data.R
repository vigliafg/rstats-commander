test_that("Phase 2 command builders reproduce Rcmdr code", {
  expect_equal(
    RcmdrShiny:::cmd_compute("D", "z", "y + x"),
    "D$z <- with(D, y + x)"
  )
  expect_equal(
    RcmdrShiny:::cmd_delete_variables("D", c("s", "t")),
    "D <- within(D, {\n  s <- NULL\n  t <- NULL\n})"
  )
  expect_equal(
    RcmdrShiny:::cmd_numeric_to_factor("D", "y", name = "fy"),
    "D <- within(D, {\n  fy <- as.factor(y)\n})"
  )
  expect_equal(
    RcmdrShiny:::cmd_character_to_factor("D", "s", name = "<same as variables>"),
    "D <- within(D, {\n  s <- as.factor(s)\n})"
  )
  expect_equal(
    RcmdrShiny:::cmd_bin_variable("D", "x", "bx", 3, "intervals"),
    "D$bx <- with(D, binVariable(x, bins=3, method='intervals', labels=FALSE))"
  )
  expect_equal(
    RcmdrShiny:::cmd_reorder_factor("D", "g", "g2", c("b", "a"), TRUE),
    "D$g2 <- with(D, factor(g, levels=c('b','a'), ordered=TRUE))"
  )
  expect_equal(
    RcmdrShiny:::cmd_standardize("D", c("y", "x")),
    paste0(
      'D <- local({\n  .Z <- scale(D[,c("y","x")])\n  within(D, {\n',
      "    Z.x <- .Z[,2]\n    Z.y <- .Z[,1]\n  })\n})"
    )
  )
  expect_equal(
    RcmdrShiny:::cmd_export_data("D", "out.csv"),
    'write.table(D, "out.csv", sep=",", col.names=TRUE, row.names=FALSE, quote=TRUE, na="NA")'
  )
  expect_equal(
    RcmdrShiny:::cmd_filter_na("D", "D2", c("y", "x")),
    'D2 <- na.omit(D[,c("y","x")])'
  )
  expect_equal(
    RcmdrShiny:::cmd_subset_dataset("D", "D3", c("y", "x"), "y > 2"),
    "D3 <- subset(D, subset=y > 2, select=c(y,x))"
  )
  expect_equal(
    RcmdrShiny:::cmd_rename_variables_at("D", c(1, 2), c("yy", "xx")),
    'names(D)[c(1,2)] <- c("yy","xx")'
  )
  expect_equal(
    RcmdrShiny:::cmd_stack("D", c("y", "x"), "S"),
    c('S <- stack(D[, c("y","x")])', 'names(S) <- c("variable", "factor")')
  )
  expect_equal(
    RcmdrShiny:::cmd_remove_rows("D", "D4", "-c(1, 2)"),
    "D4 <- D[-c(1, 2),]"
  )
  expect_equal(
    RcmdrShiny:::cmd_select_rows("D", "D5", "c('1', '3')", 1),
    "D5 <- D[c('1', '3'), , drop = FALSE]"
  )
  expect_equal(
    RcmdrShiny:::cmd_merge("D", "E", "M", "columns", FALSE),
    c(
      'M <- merge(D, E, all=TRUE, by="row.names")',
      "rownames(M) <- M$Row.names",
      "M$Row.names <- NULL"
    )
  )
  expect_equal(
    RcmdrShiny:::cmd_aggregate("D", "A", c("y", "x"), "g"),
    "A <- aggregate(cbind(y, x) ~ g, data=D, FUN=mean)"
  )
  expect_equal(
    RcmdrShiny:::cmd_sort("D", "D6", c("g", "y")),
    "D6 <- with(D, D[order(g, y, decreasing=FALSE), ])"
  )
  expect_equal(
    RcmdrShiny:::cmd_recode("D", "y", "ry", "1=10;2=20", FALSE),
    paste0(
      "D <- within(D, {\n  ry <- Recode(y, '1=10;2=20', as.factor=FALSE, ",
      'to.value="=", interval=":", separator=";")\n})'
    )
  )
})

test_that("Phase 2 import commands are generated correctly", {
  expect_equal(
    RcmdrShiny:::cmd_import_excel("D", "/tmp/x.xlsx", "Sheet1"),
    'readXL("/tmp/x.xlsx", rownames=FALSE, header=TRUE, na="", sheet="Sheet1", stringsAsFactors=FALSE)'
  )
  expect_equal(
    RcmdrShiny:::cmd_import_spss("D", "/tmp/x.sav"),
    'readSPSS("/tmp/x.sav", rownames=TRUE, stringsAsFactors=TRUE, tolower=TRUE)'
  )
  expect_equal(
    RcmdrShiny:::cmd_import_stata("D", "/tmp/x.dta"),
    'readStata("/tmp/x.dta", convert.dates=TRUE, stringsAsFactors=TRUE, rownames=FALSE)'
  )
  expect_equal(
    RcmdrShiny:::cmd_import_sas("D", "/tmp/x.sas7bdat"),
    'readSAS("/tmp/x.sas7bdat", stringsAsFactors=TRUE, rownames=FALSE)'
  )
  expect_equal(
    RcmdrShiny:::cmd_import_minitab("D", "/tmp/x.mtp"),
    'D <- as.data.frame(read.mtp("/tmp/x.mtp"))'
  )
  expect_equal(
    RcmdrShiny:::cmd_import_sas_xport("D", "/tmp/x.xpt"),
    c('.Datasets <- read.xport("/tmp/x.xpt")', "D <- .Datasets[[1]]",
      "remove(.Datasets)")
  )
  expect_equal(
    RcmdrShiny:::cmd_read_package("mtcars", "datasets"),
    'data(mtcars, package="datasets")'
  )
})

test_that("cases_select validates row indices and names", {
  df <- data.frame(x = 1:4, row.names = c("a", "b", "c", "d"))
  expect_equal(RcmdrShiny:::cases_select("D", df, "1, 3")$value,
               "c('1', '3')")
  expect_equal(RcmdrShiny:::cases_select("D", df, "a, c")$value,
               "c('a', 'c')")
  expect_match(RcmdrShiny:::cases_select("D", df, "9")$error, "bad row numbers")
  expect_match(RcmdrShiny:::cases_select("D", df, "zzz")$error, "bad row names")
})

test_that("Phase 2 operations execute in the session environment", {
  make_state <- function() {
    env <- new.env()
    env$D <- data.frame(
      y = 1:6,
      x = c(2, 4, 6, 8, 10, 12),
      g = factor(rep(c("a", "b"), 3)),
      s = letters[1:6],
      stringsAsFactors = FALSE
    )
    state <- AppState(env = env)
    active_dataset(state, "D")
    state
  }
  operation <- function(commands) {
    state <- make_state()
    for (command in commands) {
      result <- run_command(state, command)
      expect_equal(result$status, "ok")
    }
    state
  }

  state <- operation(RcmdrShiny:::cmd_compute("D", "z", "y + x"))
  expect_equal(state$env$D$z, state$env$D$y + state$env$D$x)

  state <- operation(RcmdrShiny:::cmd_numeric_to_factor("D", "y", "fy"))
  expect_s3_class(state$env$D$fy, "factor")

  state <- operation(RcmdrShiny:::cmd_bin_variable("D", "x", "bx", 3))
  expect_s3_class(state$env$D$bx, "factor")

  state <- operation(RcmdrShiny:::cmd_standardize("D", c("y", "x")))
  expect_equal(unname(colMeans(state$env$D[, c("Z.y", "Z.x")])), c(0, 0))

  state <- operation(RcmdrShiny:::cmd_subset_dataset("D", "D3", c("y", "x"), "y > 2"))
  expect_equal(names(state$env$D3), c("y", "x"))
  expect_true(all(state$env$D3$y > 2))

  state <- operation(RcmdrShiny:::cmd_stack("D", c("y", "x"), "S"))
  expect_equal(names(state$env$S), c("variable", "factor"))
  expect_equal(nrow(state$env$S), 12L)

  state <- operation(RcmdrShiny:::cmd_aggregate("D", "A", c("y", "x"), "g"))
  expect_equal(nrow(state$env$A), 2L)
  expect_true(all(c("y", "x") %in% names(state$env$A)))

  state <- operation(RcmdrShiny:::cmd_sort("D", "D6", c("g", "y")))
  expect_equal(nrow(state$env$D6), 6L)

  state <- operation(RcmdrShiny:::cmd_recode("D", "y", "ry", "1=10;2=20", FALSE))
  expect_true(all(state$env$D$ry %in% c(10, 20, 3:6)))

  state <- operation(RcmdrShiny:::cmd_new_dataset("N", 5, 2))
  expect_equal(dim(state$env$N), c(5L, 2L))
})

test_that("all Phase 2 dialogs render their UI", {
  env <- new.env()
  env$D <- data.frame(
    y = 1:6, x = c(2, 4, 6, 8, 10, 12),
    g = factor(rep(c("a", "b"), 3)), s = letters[1:6],
    stringsAsFactors = FALSE
  )
  env$E <- data.frame(a = 1:6, b = letters[1:6])
  state <- AppState(env = env)
  active_dataset(state, "D")

  for (id in names(RcmdrShiny:::phase2_dialogs())) {
    spec <- get_dialog_spec(id)
    html <- htmltools::renderTags(spec$ui(state, NULL))$html
    expect_gt(nchar(html), 100)
  }
})
