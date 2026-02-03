# Load libraries
library(tidyverse)
library(tidymodels)

# 1. To Simulate MIMIC-IV-ED Schema (Triage Data)
set.seed(421)
n <- 2000
triage_data <- tibble(
  acuity = sample(1:5, n, replace = TRUE),
  heart_rate = rnorm(n, 80, 15),
  temp = rnorm(n, 37, 1),
  ox_sat = rnorm(n, 96, 3),
  prior_ed_visits = rpois(n, 2),
  # ICU admission logic: lower acuity and lower ox_sat increase risk
  prob = plogis(-2 - 1.5 * acuity + 0.1 * prior_ed_visits - 0.2 * (ox_sat - 98)),
  admit_icu = rbinom(n, 1, prob) %>% as.factor())

# 2. Train, Calibrate, Test
# This 3-way split is what differentiates a student from a researcher.
data_split <- initial_validation_split(triage_data, prop = c(0.6, 0.2))
train_data <- training(data_split)
calib_data <- validation(data_split)
test_data  <- testing(data_split)

# 3. Train Baseline Logistic Regression
model_spec <- logistic_reg() %>% 
    set_engine("glm")
model_fit <- model_spec %>% 
    fit(admit_icu ~ acuity + heart_rate + ox_sat + prior_ed_visits, data = train_data)

# 4. Generate Scores on Calibration Set
calib_probs <- predict(model_fit, calib_data, type = "prob") %>%
  bind_cols(calib_data)

# Non-conformity score: 1 - P(correct class)
# For binary, it is the probability assigned to the class that didn't happen
calib_probs <- calib_probs %>%
  mutate(score = if_else(admit_icu == 1, 1 - .pred_1, 1 - .pred_0))

# 5. Determine the Threshold (Quantile) for 95% Confidence (alpha = 0.05)
alpha <- 0.05
q_hat <- quantile(calib_probs$score, probs = (1 - alpha) * (1 + 1/nrow(calib_probs)))

# 6. Apply to Test Data
test_results <- predict(model_fit, test_data, type = "prob") %>%
  bind_cols(test_data) %>%
  mutate(
    # A class is in the "Confidence Set" if its probability is > (1 - q_hat)
    in_set_0 = if_else(.pred_0 >= (1 - q_hat), TRUE, FALSE),
    in_set_1 = if_else(.pred_1 >= (1 - q_hat), TRUE, FALSE),
    set_size = as.numeric(in_set_0) + as.numeric(in_set_1))

# 7. Visualization: The "Startup ROI" Plot
ggplot(test_results, aes(x = .pred_1, fill = as.factor(set_size))) +
  geom_histogram(bins = 30, alpha = 0.7, position = "identity") +
  labs(
    title = "Clinical Decision Support: Confidence Sets",
    subtitle = "Blue (1) = High Certainty | Green (2) = Ambiguous (Requires Human Review)",
    x = "Predicted Probability of ICU",
    fill = "Set Size") +
  theme_minimal()