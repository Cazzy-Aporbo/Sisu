# health_ai_prototype.py
"""
Health AI Prototype
Demonstrates advanced reasoning for analyzing patient health data,
highlighting potential misdiagnoses, and providing interpretability insights.
Note: Prototype level, not complete for clinical use.
"""

import pandas as pd
import numpy as np
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report
import matplotlib.pyplot as plt
import seaborn as sns

# 1. Load Sample Health Data
# Using synthetic example; replace with CSV or database in real application
def generate_synthetic_data(n=500):
    np.random.seed(42)
    df = pd.DataFrame({
        "age": np.random.randint(18, 90, size=n),
        "blood_pressure": np.random.randint(90, 180, size=n),
        "cholesterol": np.random.randint(150, 300, size=n),
        "bmi": np.round(np.random.uniform(18, 40, size=n), 1),
        "smoker": np.random.choice([0,1], size=n),
        "gender": np.random.choice([0,1], size=n),  # 0=female, 1=male
        "disease": np.random.choice([0,1], size=n)  # 0=healthy, 1=condition
    })
    return df

data = generate_synthetic_data()

# 2. Preprocess Data
X = data.drop("disease", axis=1)
y = data["disease"]

scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

X_train, X_test, y_train, y_test = train_test_split(
    X_scaled, y, test_size=0.2, random_state=42
)

# 3. Build AI Model
model = RandomForestClassifier(
    n_estimators=100,
    max_depth=5,
    random_state=42
)
model.fit(X_train, y_train)
y_pred = model.predict(X_test)

print("Classification Report:\n")
print(classification_report(y_test, y_pred))

# 4. Feature Importance (Explainability)
feature_importances = pd.Series(model.feature_importances_, index=X.columns)
feature_importances = feature_importances.sort_values(ascending=False)

plt.figure(figsize=(8,5))
sns.barplot(x=feature_importances, y=feature_importances.index)
plt.title("Feature Importance - Health AI Prototype")
plt.show()

# 5. High-Level Reasoning Example
def interpret_patient_risk(patient):
    """
    Interpret a single patient's risk with reasoning.
    """
    risk_score = model.predict_proba([patient])[0][1]
    reasoning = []

    if patient[0] > 65:
        reasoning.append("Age is high, increasing risk.")
    if patient[1] > 140:
        reasoning.append("Elevated blood pressure detected.")
    if patient[2] > 240:
        reasoning.append("High cholesterol level detected.")
    if patient[3] > 30:
        reasoning.append("BMI indicates obesity.")
    if patient[4] == 1:
        reasoning.append("Patient is a smoker.")
    if patient[5] == 1:
        reasoning.append("Male gender may slightly increase risk for some conditions.")

    return risk_score, reasoning

# Example usage
sample_patient = X_test[0]
risk, insights = interpret_patient_risk(sample_patient)
print("\nSample Patient Risk Score:", round(risk, 2))
print("Reasoning / Insights:")
for r in insights:
    print("-", r)