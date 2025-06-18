library(dplyr)
library(lme4)
library(mvtnorm)

set.seed(20240618)

# Parameters
n_groups <- 15
n_per_group <- 20
n <- n_groups * n_per_group

group_df <- tibble(
  group = factor(1:n_groups),
  U = rnorm(n_groups, 2),
  n_per_group = sample(seq(5, 25), n_groups, replace = TRUE)
)

mu_b <- c(intercept = 0, slope = -2)
sd_intercept <- .5
sd_slope <- 1
cor_b <- 0.7

res <- faux::rnorm_multi(
  n_groups, 2, mu_b, c(sd_intercept, sd_slope), cor_b
)

df <-
  bind_cols(group_df, res) |>
  mutate(
    # confound hits X
    speed_mean = 5 + .5 * U
  ) |>
  rowwise() |>
  mutate(
    speed = list(rnorm(n_per_group, mean = speed_mean, sd = 1)),
    # confound hits Y as well
    accuracy = list(intercept + slope * speed + 2 * U + rnorm(n_per_group, sd = 2))
  ) |>
  ungroup() |>
  tidyr::unnest(cols = c(speed, accuracy)) |>
  group_by(group) %>%
  mutate(
    speed_bar = mean(speed),
    speed_c = speed - speed_bar
  ) %>%
  ungroup()


ggplot(df) + aes(x = speed, y = accuracy) + geom_point() +
  stat_smooth(method = "lm", color = "gold") +
  stat_smooth(aes(group = group), method = "lm", se = FALSE)


ggplot(df) + aes(x = U, y = speed) + geom_point() +
  stat_smooth(method = "lm", color = "gold") +
  stat_smooth(aes(group = group), method = "lm")

ggplot(df) + aes(x = U, y = accuracy) + geom_point() +
  stat_smooth(method = "lm", color = "gold") +
  stat_smooth(aes(group = group), method = "lm")


# Fit models
model_naive <- lmer(accuracy ~ speed + (1 | group), data = df)
model_mundlak <- lmer(accuracy ~ speed + speed_bar + (1 | group), data = df)
model_bw <- lmer(accuracy ~ speed_c + speed_bar + (1 | group), data = df)

confint(model_naive)
confint(model_mundlak)

model_random_slopes <- lmer(accuracy ~ speed + speed_bar + (speed | group), data = df)
confint(model_random_slopes)

model_random_slopes_b <- lmer(accuracy ~ speed_c + speed_bar + (speed_c | group), data = df)
confint(model_random_slopes_b)

# Show summaries
summary(model_naive)
summary(model_mundlak)
summary(model_random_slopes)
