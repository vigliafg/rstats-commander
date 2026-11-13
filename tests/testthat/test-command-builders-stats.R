test_that("Statistics command builders reproduce Rcmdr code", {
  expect_equal(
    RcmdrShiny:::cmd_frequency_table("D", "g", TRUE),
    paste0(
      "local({\n  .Table <- with(D, table(g))\n",
      '  cat("\\ncounts:\\n")\n  print(.Table)\n',
      '  cat("\\npercentages:\\n")\n',
      "  print(round(100*.Table/sum(.Table), 2))\n\n",
      "  chisq.test(.Table)\n})"
    )
  )
  expect_equal(
    RcmdrShiny:::cmd_statistics_table("D", "y", c("g", "h"), "mean"),
    "Tapply(y ~ g + h, mean, na.action=na.omit, data=D) # mean by groups"
  )
  expect_equal(
    RcmdrShiny:::cmd_correlation_matrix("D", c("y", "x")),
    'cor(D[,c("y","x")], use="complete")'
  )
  expect_equal(
    RcmdrShiny:::cmd_correlation_test("D", "y", "x"),
    'with(D, cor.test(y, x, alternative="two.sided", method="pearson"))'
  )
  expect_equal(
    RcmdrShiny:::cmd_normality_test("D", "y"),
    'normalityTest(~y, test="shapiro.test", data=D)'
  )
  expect_equal(
    RcmdrShiny:::cmd_two_way_table("D", "g", "h") ,
    paste0(
      "local({\n  .Table <- xtabs(~g+h, data=D)\n",
      '  cat("\\nFrequency table:\\n")\n  print(.Table)\n',
      "  .Test <- chisq.test(.Table, correct=FALSE)\n  print(.Test)\n})"
    )
  )
  expect_equal(
    RcmdrShiny:::cmd_independent_t("D", "y", "g"),
    "t.test(y~g, alternative='two.sided', conf.level=0.95, var.equal=FALSE, data=D)"
  )
  expect_equal(
    RcmdrShiny:::cmd_paired_t("D", "y", "x"),
    "with(D, (t.test(y, x, alternative='two.sided', conf.level=0.95, paired=TRUE)))"
  )
  expect_equal(
    RcmdrShiny:::cmd_single_t("D", "y", mu = 1),
    "with(D, (t.test(y, alternative='two.sided', mu=1, conf.level=0.95)))"
  )
  expect_equal(
    RcmdrShiny:::cmd_one_way_anova("D", "M", "y", "g"),
    c(
      "M <- aov(y ~ g, data=D)",
      "summary(M)",
      'with(D, numSummary(y, groups=g, statistics=c("mean", "sd")))'
    )
  )
  expect_equal(
    RcmdrShiny:::cmd_multi_way_anova("D", "M", "y", c("g", "h"))[1:2],
    c(
      'M <- lm(y ~ g*h, data=D, contrasts=list(g="contr.Sum", h="contr.Sum"))',
      "Anova(M)"
    )
  )
  expect_equal(
    RcmdrShiny:::cmd_two_variances_f("D", "y", "g")[[2]],
    "var.test(y ~ g, alternative='two.sided', conf.level=0.95, data=D)"
  )
  expect_equal(
    RcmdrShiny:::cmd_bartlett("D", "y", "g")[[2]],
    "bartlett.test(y ~ g, data=D)"
  )
  expect_equal(
    RcmdrShiny:::cmd_levene("D", "y", "g")[[2]],
    'leveneTest(y ~ g, data=D, center="median")'
  )
  expect_equal(
    RcmdrShiny:::cmd_single_proportion("D", "g"),
    paste0(
      "local({\n  .Table <- xtabs(~g, data=D)\n",
      '  cat("\\nFrequency counts (test is for first level):\\n")\n  print(.Table)\n',
      "  prop.test(rbind(.Table), alternative='two.sided', p=0.5, conf.level=0.95, correct=FALSE)\n})"
    )
  )
  expect_equal(
    RcmdrShiny:::cmd_two_sample_wilcoxon("D", "y", "g")[[2]],
    'wilcox.test(y ~ g, alternative="two.sided", data=D)'
  )
  expect_equal(
    RcmdrShiny:::cmd_kruskal_wallis("D", "y", "g")[[2]],
    "kruskal.test(y ~ g, data=D)"
  )
  expect_equal(
    RcmdrShiny:::cmd_reliability("D", c("y", "x", "z")),
    'reliability(cov(D[,c("y","x","z")], use="complete.obs"))'
  )
  expect_match(
    RcmdrShiny:::cmd_pca("D", c("y", "x")),
    "princomp\\(~y\\+x, cor=FALSE, data=D\\)"
  )
  expect_equal(
    RcmdrShiny:::cmd_glm("D", "G", "y", "x")[1],
    "G <- glm(y ~ x, family=binomial(logit), data=D)"
  )
  expect_equal(
    RcmdrShiny:::cmd_polr("D", "O", "y", "x")[1],
    'O <- polr(y ~ x, method="logistic", data=D, Hess=TRUE)'
  )
  expect_equal(
    RcmdrShiny:::cmd_multinom("D", "M", "y", "x")[1],
    "M <- multinom(y ~ x, data=D, trace=FALSE)"
  )
  expect_equal(
    RcmdrShiny:::cmd_lmer("D", "L", "y", "x + (1 | g)")[1],
    "L <- lmer(y ~ x + (1 | g), data=D, REML=TRUE)"
  )
})

test_that("Statistics builders execute for representative analyses", {
  make_state <- function() {
    set.seed(1)
    env <- new.env()
    env$D <- data.frame(
      y = rnorm(30),
      x = rnorm(30),
      z = rnorm(30),
      g = factor(rep(c("a", "b", "c"), 10)),
      h = factor(rep(c("u", "v"), 15))
    )
    state <- AppState(env = env)
    active_dataset(state, "D")
    state
  }
  run_commands <- function(commands) {
    state <- make_state()
    for (command in commands) {
      result <- run_command(state, command)
      expect_equal(result$status, "ok", info = command)
    }
    state
  }

  run_commands(RcmdrShiny:::cmd_frequency_table("D", "g"))
  run_commands(RcmdrShiny:::cmd_statistics_table("D", "y", "g"))
  run_commands(RcmdrShiny:::cmd_correlation_matrix("D", c("y", "x")))
  run_commands(RcmdrShiny:::cmd_correlation_test("D", "y", "x"))
  run_commands(RcmdrShiny:::cmd_independent_t("D", "y", "h"))
  run_commands(RcmdrShiny:::cmd_paired_t("D", "y", "x"))
  run_commands(RcmdrShiny:::cmd_single_t("D", "y"))
  run_commands(RcmdrShiny:::cmd_one_way_anova("D", "Anova.1", "y", "g"))
  run_commands(RcmdrShiny:::cmd_two_way_table("D", "g", "h"))
  run_commands(RcmdrShiny:::cmd_kruskal_wallis("D", "y", "g"))
  run_commands(RcmdrShiny:::cmd_pca("D", c("y", "x")))
  run_commands(RcmdrShiny:::cmd_glm("D", "G", "h", "y"))
})

test_that("all Statistics dialogs render and validate their UI", {
  set.seed(1)
  env <- new.env()
  env$D <- data.frame(
    y = rnorm(30), x = rnorm(30), z = rnorm(30),
    g = factor(rep(c("a", "b", "c"), 10)),
    h = factor(rep(c("u", "v"), 15)),
    s = letters[rep(1:5, 6)]
  )
  env$D$y2 <- env$D$y + rnorm(30)
  env$D$y3 <- env$D$y + rnorm(30)
  state <- AppState(env = env)
  active_dataset(state, "D")

  for (id in names(RcmdrShiny:::phase3_dialogs())) {
    spec <- get_dialog_spec(id)
    html <- htmltools::renderTags(spec$ui(state, NULL))$html
    expect_gt(nchar(html), 100)
  }
})
