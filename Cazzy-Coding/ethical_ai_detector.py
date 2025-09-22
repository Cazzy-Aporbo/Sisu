# ethical_ai_detector.py
"""
Ethical AI Detector Prototype
Analyzes AI outputs, models, and datasets for ethical risks and bias.
"""

import pandas as pd
import numpy as np
from collections import Counter

# -----------------------------
# 1. Sample Dataset & Predictions
# -----------------------------
sample_data = pd.DataFrame({
    "age": [25, 40, 18, 65, 30, 22],
    "gender": ["M","F","F","M","F","M"],
    "income": [50000, 60000, 20000, 80000, 30000, 25000],
    "loan_approved": [1,1,0,1,0,0]
})

# -----------------------------
# 2. Bias Detection Functions
# -----------------------------
def detect_gender_bias(df, target_column="loan_approved"):
    genders = df["gender"].unique()
    approval_rates = {}
    for g in genders:
        subset = df[df["gender"]==g]
        approval_rate = subset[target_column].mean()
        approval_rates[g] = approval_rate
    
    disparity = max(approval_rates.values()) - min(approval_rates.values())
    return approval_rates, disparity

def detect_age_bias(df, target_column="loan_approved", threshold=0.2):
    # Compare average approval for <30 vs >=30
    young = df[df["age"]<30][target_column].mean()
    adult = df[df["age"]>=30][target_column].mean()
    disparity = abs(young - adult)
    return {"<30": young, ">=30": adult}, disparity

# -----------------------------
# 3. Ethical Analysis
# -----------------------------
def ethical_analysis(df, target_column="loan_approved"):
    report = {}
    
    gender_rates, gender_disparity = detect_gender_bias(df, target_column)
    age_rates, age_disparity = detect_age_bias(df, target_column)
    
    report["gender_bias"] = {
        "approval_rates": gender_rates,
        "disparity": gender_disparity,
        "ethical_flag": gender_disparity > 0.2
    }
    
    report["age_bias"] = {
        "approval_rates": age_rates,
        "disparity": age_disparity,
        "ethical_flag": age_disparity > 0.2
    }
    
    # Overall recommendation
    recommendations = []
    if report["gender_bias"]["ethical_flag"]:
        recommendations.append("Balance gender representation or retrain model.")
    if report["age_bias"]["ethical_flag"]:
        recommendations.append("Investigate age-based disparities in decision rules.")
    report["recommendations"] = recommendations or ["No major ethical issues detected."]
    
    return report

# -----------------------------
# 4. Example Usage
# -----------------------------
if __name__ == "__main__":
    report = ethical_analysis(sample_data)
    print("=== Ethical AI Detector Report ===")
    for key, val in report.items():
        print(f"{key}: {val}")