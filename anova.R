d <- readr::read_tsv("https://raw.githubusercontent.com/tjmahr/GelmanHill/refs/heads/master/examples/Ch22/pilots.dat")


props <- aggregate(recovered ~ group + scenario, d, mean)
m <- lm(recovered ~ group + scenario, props)

# sum of squares as the sum of the coefficients
predict(m, type = "terms") |>
  as.data.frame() |>
  transform(residual = residuals(m)) |>
  lapply(function(x) sum(x ^ 2))

# for the scheme to work in general, the factors need to be coded so that the
# "effects" sum to 0. I don't want to get sidetracked on it.

contr.treatment(5) # columns do not sum to 0
contr.sum(5)
contr.helmert(5)

m2 <- lm(
  recovered ~ group * scenario, props,
  contrasts = list(group = "contr.helmert", scenario = "contr.helmert")
)

predict(m2, type = "terms") |>
  as.data.frame() |>
  transform(residual = residuals(m2)) |>
  lapply(function(x) sum(x ^ 2))

aov(recovered ~ group * scenario, props)

# wrong answer
m2_tx_coded <- lm(
  recovered ~ group * scenario, props
)
predict(m2_tx_coded, type = "terms") |>
  as.data.frame() |>
  transform(residual = residuals(m2)) |>
  lapply(function(x) sum(x ^ 2))

# proj() seems to do the right thing on any linear model
proj(m2_tx_coded) |>
  as.data.frame() |>
  lapply(function(x) sum(x ^ 2))

proj(m2) |>
  as.data.frame() |>
  lapply(function(x) sum(x ^ 2))

model.tables(aov(recovered ~ group + scenario, props), type = "effects")

model.tables(aov(recovered ~ group + scenario, props), type = "effects") |> _$tables$group |> sum()
model.tables(aov(recovered ~ group + scenario, props), type = "effects") |> _$tables$scenario |> sum()
model.tables(aov(recovered ~ group + scenario, props), type = "means")

# I got sidetracked....

## The Gelman-Hill mixed-effects ANOVA-on-coefficient-batches thing
library(brms)
library(tidyverse)

b <- brm(
  recovered ~ 1 + (1 | group) + (1 | scenario),
  data = props,
  backend = "cmdstanr"
)

# compute SDs of each batch of random effects
effects <- ranef(b, summary = FALSE) |>
  lapply(posterior::rvar) |>
  lapply(posterior::rvar_sd) |>
  dplyr::bind_rows() |>
  # add SDs of residuals
  mutate(
    # residuals from epreds is crucial!
    error = residuals(b, summary = FALSE, method = "posterior_epred") |>
      posterior::rvar() |>
      posterior::rvar_sd()
  ) |>
  rename(treatment = group, airport = scenario)

effects |>
  pivot_longer(cols = everything(), names_to = "effect", values_to = "sd") |>
  mutate(
    effect = factor(effect, c("treatment", "airport", "error"))
  ) |>
  ggplot() +
    aes(xdist = sd, y = forcats::fct_rev(effect)) |>
    ggdist::stat_pointinterval() +
    labs(x = "SD of effects", y = "Source") +
    theme_minimal() +
    geom_vline(xintercept = 0) +
    theme(
      plot.background = element_rect(fill = "lemonchiffon3"),
      panel.grid = element_blank(),
      panel.border = element_rect(colour = "grey10", fill = NA)
    )




# do we have to sweep out the mean before taking sd?

center_rows <- function(m) {
  sweep(m, 1, rowMeans(m), FUN = "-")
}


sd_ranefs2 <- coef(b, summary = FALSE) |>
  lapply(posterior::rvar) |>
  lapply(function(x) {
    x |>
      posterior::draws_of() |>
      center_rows() |>
      posterior::rvar()
  }) |>
  lapply(posterior::rvar_sd) |>
  dplyr::bind_rows()

props |>
  tidybayes::add_residual_draws(b, method = "posterior_epred") |>
  group_by(.draw) |>
  mutate(
    avg_error = mean(.residual),
    n = n(),
    adj_residual = .residual - avg_error
  ) |>
  group_by(.draw) |>
  summarise(
    avg_error = sd(avg_error),
    sd_naive = sd(.residual),
    sd_error = sd(adj_residual)
  ) |>
  posterior::as_draws_rvars()
