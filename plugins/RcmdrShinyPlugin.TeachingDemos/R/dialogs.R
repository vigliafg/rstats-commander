# Shiny dialogs for TeachingDemos ---------------------------------------

demo_dialog <- function(id, title, fields, build, help = NULL) {
  force(fields)
  force(build)
  force(title)
  ns <- function(x) paste0(id, "_", x)
  RcmdrShiny::plugin_dialog(
    id = id, title = title, help = help, help_package = "TeachingDemos",
    ui = function(state, memory) {
      htmltools::tagList(lapply(fields, function(field) {
        value <- if (is.null(memory)) NULL else memory[[field$name]]
        if (is.null(value)) value <- field$default
        switch(
          field$type,
          entry = RcmdrShiny::entry_input(ns(field$name), field$label, value),
          spin = RcmdrShiny::spin_input(ns(field$name), field$label, value,
                                        min = field$min %||% NA,
                                        max = field$max %||% NA,
                                        step = field$step %||% 1),
          combo = RcmdrShiny::combo_input(ns(field$name), field$label,
                                          field$choices, value)
        )
      }))
    },
    on_ok = function(input, state) {
      values <- list()
      for (field in fields) values[[field$name]] <- input[[ns(field$name)]]
      command <- tryCatch(build(values), error = function(e) e)
      if (inherits(command, "error")) {
        return(list(error = conditionMessage(command)))
      }
      list(commands = command, memory = values, plot = TRUE)
    }
  )
}

teaching_dialogs <- function() {
  list(
    centralLimitTheorem = demo_dialog(
      "centralLimitTheorem", "Central limit theorem",
      list(
        list(name = "distribution", label = "Population", type = "combo",
             choices = c("normal" = "normal", "uniform" = "uniform",
                         "exponential" = "exponential"), default = "normal"),
        list(name = "n", label = "Sample size", type = "spin",
             default = 30, min = 1, step = 1),
        list(name = "reps", label = "Number of samples", type = "spin",
             default = 1000, min = 10, step = 10),
        list(name = "statistic", label = "Statistic", type = "combo",
             choices = c("mean" = "mean", "sum" = "sum"), default = "mean")
      ),
      function(values) build_clt_command(
        values$distribution, values$n, values$reps, values$statistic
      )
    ),
    simulateConfidenceIntervals = demo_dialog(
      "simulateConfidenceIntervals", "Confidence interval for the mean",
      list(
        list(name = "mean", label = "Population mean", type = "entry",
             default = "0"),
        list(name = "sd", label = "Population SD", type = "entry",
             default = "1"),
        list(name = "n", label = "Sample size", type = "spin",
             default = 30, min = 2, step = 1),
        list(name = "level", label = "Confidence level", type = "entry",
             default = "0.95"),
        list(name = "reps", label = "Replicates", type = "spin",
             default = 100, min = 10, step = 10)
      ),
      function(values) build_ci_simulation_command(
        values$mean, values$sd, values$n, values$level, values$reps
      )
    ),
    powerExample = demo_dialog(
      "powerExample", "Power of the test",
      list(
        list(name = "effect", label = "Effect size", type = "entry",
             default = "0.5"),
        list(name = "n", label = "Reference sample size", type = "spin",
             default = 30, min = 2, step = 1),
        list(name = "alpha", label = "Significance level", type = "entry",
             default = "0.05")
      ),
      function(values) build_power_command(
        values$effect, values$n, values$alpha
      )
    ),
    flipCoin = demo_dialog(
      "flipCoin", "Flip a coin",
      list(
        list(name = "trials", label = "Number of flips", type = "spin",
             default = 100, min = 1, step = 1),
        list(name = "prob", label = "Probability of heads", type = "entry",
             default = "0.5")
      ),
      function(values) build_coin_command(values$trials, values$prob)
    ),
    rollDie = demo_dialog(
      "rollDie", "Roll a die",
      list(
        list(name = "rolls", label = "Number of rolls", type = "spin",
             default = 100, min = 1, step = 1)
      ),
      function(values) build_die_command(values$rolls)
    ),
    linearRegressionExample = demo_dialog(
      "linearRegressionExample", "Simple linear regression",
      list(
        list(name = "n", label = "Sample size", type = "spin",
             default = 30, min = 3, step = 1),
        list(name = "intercept", label = "Intercept", type = "entry",
             default = "0"),
        list(name = "slope", label = "Slope", type = "entry", default = "1"),
        list(name = "sd", label = "Error SD", type = "entry", default = "1")
      ),
      function(values) build_regression_demo_command(
        values$n, values$intercept, values$slope, values$sd
      )
    ),
    correlationExample = demo_dialog(
      "correlationExample", "Simple correlation",
      list(
        list(name = "n", label = "Sample size", type = "spin",
             default = 100, min = 3, step = 1),
        list(name = "rho", label = "Correlation", type = "entry",
             default = "0.7")
      ),
      function(values) build_correlation_demo_command(values$n, values$rho)
    ),
    visBinom = demo_dialog(
      "visBinom", "Binomial distributions",
      list(
        list(name = "size", label = "Number of trials", type = "spin",
             default = 10, min = 1, step = 1),
        list(name = "prob", label = "Probability", type = "entry",
             default = "0.5")
      ),
      function(values) build_distribution_plot_command("binom", values)
    ),
    visNormal = demo_dialog(
      "visNormal", "Normal distributions",
      list(
        list(name = "mean", label = "Mean", type = "entry", default = "0"),
        list(name = "sd", label = "Standard deviation", type = "entry",
             default = "1")
      ),
      function(values) build_distribution_plot_command("norm", values)
    ),
    vist = demo_dialog(
      "vist", "t distributions",
      list(
        list(name = "df", label = "Degrees of freedom", type = "spin",
             default = 5, min = 1, step = 1)
      ),
      function(values) build_distribution_plot_command("t", values)
    ),
    visGamma = demo_dialog(
      "visGamma", "Gamma distributions",
      list(
        list(name = "shape", label = "Shape", type = "entry", default = "2"),
        list(name = "rate", label = "Rate", type = "entry", default = "1")
      ),
      function(values) build_distribution_plot_command("gamma", values)
    )
  )
}
