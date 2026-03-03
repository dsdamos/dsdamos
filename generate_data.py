"""
generate_data.py
================
Generates the 'wages.csv' dataset used in the Multiple Regression Econometrics Lab.
Dataset: 500 workers — Extended Mincer wage equation (simulated).

Run with:
    python3 generate_data.py

Requirements: numpy, pandas
    pip install numpy pandas
"""

import numpy as np
import pandas as pd

np.random.seed(2024)
n = 500

# ── Explanatory variables ────────────────────────────────────────────────────
probs_educ = [0.02, 0.03, 0.05, 0.08, 0.10,
              0.12, 0.12, 0.12, 0.10, 0.08,
              0.07, 0.05, 0.04, 0.01, 0.01]
education     = np.random.choice(range(8, 23), size=n, replace=True, p=probs_educ)
experience    = np.clip(np.round(np.random.normal(18, 10, n)).astype(int), 0, 45)
female        = np.random.binomial(1, 0.48, n)
public_sector = np.random.binomial(1, 0.30, n)
city_size     = np.random.choice(["rural", "small", "large"],         n, p=[0.25, 0.35, 0.40])
contract_type = np.random.choice(["permanent", "fixed_term", "self_employed"], n, p=[0.65, 0.20, 0.15])
num_children  = np.random.poisson(1.2, n)
unionized     = np.random.binomial(1, 0.12, n)

# ── True data-generating process ─────────────────────────────────────────────
city_eff     = np.where(city_size == "large", 0.12,
               np.where(city_size == "small", 0.05, 0.0))
contract_eff = np.where(contract_type == "permanent", 0.10,
               np.where(contract_type == "self_employed", 0.05, 0.0))

log_wage = (5.80
            + 0.085  * education           # return to education
            + 0.040  * experience          # return to experience
            - 0.0006 * experience ** 2     # concavity (Mincer)
            - 0.180  * female              # gender gap
            + 0.130  * public_sector       # public sector premium
            + city_eff                     # urban premium
            + contract_eff                 # permanent contract premium
            + 0.020  * unionized           # union premium
            - 0.015  * num_children * female  # child penalty (women)
            + np.random.normal(0, 0.22, n))   # residual noise

wage  = np.round(np.exp(log_wage)).astype(int)
hours = np.clip(np.round(np.random.normal(38, 5, n)).astype(int), 15, 60)
age   = np.clip(16 + education - 6 + experience +
                np.round(np.random.normal(0, 1, n)).astype(int), 18, 65)

# ── Assemble DataFrame ────────────────────────────────────────────────────────
df = pd.DataFrame({
    "id"           : range(1, n + 1),
    "wage"         : wage,
    "log_wage"     : np.round(np.log(wage), 4),
    "education"    : education,
    "experience"   : experience,
    "exp_squared"  : experience ** 2,
    "age"          : age,
    "female"       : female,
    "public_sector": public_sector,
    "city_size"    : city_size,
    "contract_type": contract_type,
    "num_children" : num_children,
    "unionized"    : unionized,
    "hours"        : hours,
})

df.to_csv("wages.csv", index=False)
print(f"Dataset saved: wages.csv  ({df.shape[0]} rows × {df.shape[1]} columns)")
print(df[["wage", "log_wage", "education", "experience"]].describe().round(2))
