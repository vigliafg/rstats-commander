test_that("read_text_command matches Rcmdr's read.table call", {
  command <- RcmdrShiny:::read_text_command(
    "Dataset", path = "/tmp/a.csv", delimiter = "commas"
  )
  expect_equal(
    command,
    paste0(
      'Dataset <- read.table("/tmp/a.csv", header=TRUE, ',
      'stringsAsFactors=TRUE, sep=",", na.strings="NA", dec=".", strip.white=TRUE)'
    )
  )

  command <- RcmdrShiny:::read_text_command(
    "D", path = "a.txt", header = FALSE, stringsAsFactors = FALSE,
    delimiter = "tabs", missing = "-9", decimal = "comma"
  )
  expect_equal(
    command,
    paste0(
      'D <- read.table("a.txt", header=FALSE, stringsAsFactors=FALSE, ',
      'sep="\\t", na.strings="-9", dec=",", strip.white=TRUE)'
    )
  )
})

test_that("read_text_command handles other separators, URLs and clipboard", {
  expect_match(
    RcmdrShiny:::read_text_command("D", path = "x", delimiter = "other", other = "|"),
    'sep="\\|"'
  )
  expect_match(
    RcmdrShiny:::read_text_command("D", location = "url", url = "https://e.org/x.csv"),
    'read.table\\("https://e.org/x.csv"'
  )
  expect_equal(
    RcmdrShiny:::read_text_command("D", location = "clipboard"),
    paste0(
      'D <- read.table("clipboard", header=TRUE, stringsAsFactors=TRUE, ',
      'sep="", na.strings="NA", dec=".", strip.white=TRUE)'
    )
  )
})

test_that("num_summary_commands reproduces the default summary", {
  commands <- RcmdrShiny:::num_summary_commands(
    dataset = "Dataset", x = c("y", "x"),
    mean = TRUE, sd = TRUE, IQR = FALSE, quantiles = FALSE
  )
  expect_equal(
    commands,
    paste0(
      'numSummary(Dataset[,c("y", "x"), drop=FALSE], ',
      'statistics=c("mean", "sd"), quantiles=c(0,.25,.5,.75,1))'
    )
  )
})

test_that("num_summary_commands handles one variable and all statistics", {
  commands <- RcmdrShiny:::num_summary_commands(
    dataset = "D", x = "y",
    mean = TRUE, sd = TRUE, se.mean = TRUE, var = TRUE, IQR = TRUE,
    cv = TRUE, quantiles = TRUE, skewness = TRUE, kurtosis = TRUE,
    type = "1", quantiles_values = "0, .5, 1"
  )
  expect_equal(
    commands,
    paste0(
      'numSummary(D[,"y", drop=FALSE], statistics=c("mean", "sd", "se(mean)", ',
      '"var", "IQR", "quantiles", "cv", "skewness", "kurtosis"), ',
      'quantiles=c(0,.5,1), type="1")'
    )
  )
})

test_that("num_summary_commands supports grouping and frequency counts", {
  commands <- RcmdrShiny:::num_summary_commands(
    dataset = "D", x = c("y", "x"), mean = TRUE, sd = FALSE, IQR = FALSE,
    quantiles = FALSE, groups = "g", counts = TRUE,
    discrete = "x", group_levels = c("a", "b")
  )
  expect_equal(commands, c(
    paste0(
      'numSummary(D[,c("y", "x"), drop=FALSE], groups=D$g, ',
      'statistics=c("mean"), quantiles=c(0,.25,.5,.75,1))'
    ),
    "binnedCounts(D[D$g == 'a', \"y\", drop=FALSE])\n  # g = a",
    "discreteCounts(D[D$g == 'a', \"x\", drop=FALSE])\n  # g = a",
    "binnedCounts(D[D$g == 'b', \"y\", drop=FALSE])\n  # g = b",
    "discreteCounts(D[D$g == 'b', \"x\", drop=FALSE])\n  # g = b"
  ))
})

test_that("counts without statistics produce only count commands", {
  commands <- RcmdrShiny:::num_summary_commands(
    dataset = "D", x = "y", mean = FALSE, sd = FALSE, IQR = FALSE,
    quantiles = FALSE, counts = TRUE, discrete = character()
  )
  expect_equal(commands, 'binnedCounts(D[,"y", drop=FALSE])')
})

test_that("quantiles arguments are normalised like Rcmdr", {
  expect_equal(RcmdrShiny:::quantiles_argument("0, .25, .5, .75, 1"),
               "c(0,.25,.5,.75,1)")
  expect_equal(RcmdrShiny:::quantiles_argument("0,  .5"), "c(0,.5)")
  expect_equal(RcmdrShiny:::quantiles_argument(""), "c()")
})

test_that("lm_commands reproduces Rcmdr's linear model commands", {
  expect_equal(
    RcmdrShiny:::lm_commands("Dataset", "LinearModel.1", "y", "x"),
    c("LinearModel.1 <- lm(y ~ x, data=Dataset)", "summary(LinearModel.1)")
  )

  expect_equal(
    RcmdrShiny:::lm_commands(
      "Dataset", "M", "y", "x + z",
      subset = "z > 0", weights = "w", remove_rows = "-c(1, 2)"
    ),
    c(
      "M <- lm(y ~ x + z, data=Dataset, subset=z > 0, weights=w, subset =-c(1, 2))",
      "summary(M)"
    )
  )
})

test_that("cases_subset follows Rcmdr's getCases", {
  df <- data.frame(x = 1:4, row.names = c("a", "b", "c", "d"))

  expect_equal(
    RcmdrShiny:::cases_subset("D", df, "1, 3")$value,
    "-c(1, 3)"
  )
  expect_equal(
    RcmdrShiny:::cases_subset("D", df, "a, c")$value,
    "!(rownames(D) %in% c('a', 'c'))"
  )
  expect_match(RcmdrShiny:::cases_subset("D", df, "10")$error, "bad row numbers")
  expect_match(RcmdrShiny:::cases_subset("D", df, "zzz")$error, "bad row names")
})
