# ============================================================
# Data Generation Script
# Theme: Wage Determinants (Extended Mincer Equation)
# ============================================================
# This script generates a realistic dataset of 500 employed individuals
# in the labor market, inspired by labor force surveys.
# Save this file and run it to obtain wages.csv

set.seed(2024)
n <- 500

# --- Explanatory variables ---
education     <- sample(8:22, n, replace = TRUE,
                        prob = c(0.02,0.03,0.05,0.08,0.10,
                                 0.12,0.12,0.12,0.10,0.08,
                                 0.07,0.05,0.04,0.01,0.01))
experience    <- pmax(0, round(rnorm(n, mean = 18, sd = 10)))
experience    <- pmin(experience, 45)                          # capped at 45 years
female        <- rbinom(n, 1, prob = 0.48)
public_sector <- rbinom(n, 1, prob = 0.30)
city_size     <- sample(c("rural","small","large"), n,
                        replace = TRUE, prob = c(0.25, 0.35, 0.40))
contract_type <- sample(c("permanent","fixed_term","self_employed"), n,
                        replace = TRUE, prob = c(0.65, 0.20, 0.15))
num_children  <- rpois(n, lambda = 1.2)
unionized     <- rbinom(n, 1, prob = 0.12)

# --- Factor encodings for the true data-generating process ---
city_eff     <- ifelse(city_size == "large", 0.12,
               ifelse(city_size == "small", 0.05, 0))
contract_eff <- ifelse(contract_type == "permanent", 0.10,
               ifelse(contract_type == "self_employed", 0.05, 0))

# --- Log-wage (true relationship + noise) ---
log_wage <- 5.80 +
            0.085  * education +           # return to education
            0.040  * experience +           # return to experience
           -0.0006 * experience^2 +         # concavity (Mincer)
           -0.180  * female +               # gender gap
            0.130  * public_sector +        # public sector premium
            city_eff +                      # urban premium
            contract_eff +                  # permanent contract premium
            0.020  * unionized +            # union premium
           -0.015  * num_children * female + # child penalty (women)
            rnorm(n, 0, 0.22)               # residual

wage <- round(exp(log_wage))

# --- Weekly hours worked ---
hours <- round(rnorm(n, mean = 38, sd = 5))
hours <- pmax(15, pmin(hours, 60))

# --- Age (derived) ---
age <- 16 + education - 6 + experience + round(rnorm(n, 0, 1))
age <- pmax(18, pmin(age, 65))

# --- Assemble dataset ---
dataset <- data.frame(
  id            = 1:n,
  wage          = wage,
  log_wage      = round(log(wage), 4),
  education     = education,
  experience    = experience,
  exp_squared   = experience^2,
  age           = age,
  female        = female,
  public_sector = public_sector,
  city_size     = city_size,
  contract_type = contract_type,
  num_children  = num_children,
  unionized     = unionized,
  hours         = hours
)

write.csv(dataset, "wages.csv", row.names = FALSE)
cat("Dataset generated: wages.csv\n")
cat("Dimensions:", nrow(dataset), "rows x", ncol(dataset), "columns\n")
cat("\nFirst few rows:\n")
print(head(dataset, 6))
