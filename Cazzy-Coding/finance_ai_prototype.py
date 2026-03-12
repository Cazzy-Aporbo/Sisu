# finance_ai_prototype.py
"""
Finance AI Prototype
Demonstrates predictive modeling for stock trends, portfolio risk scoring,
and interpretability. Prototype level for demonstration only.
"""

import pandas as pd
import numpy as np
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error
import matplotlib.pyplot as plt
import seaborn as sns

# 1. Load / Generate Financial Data
def generate_synthetic_finance_data(n=500):
    np.random.seed(42)
    df = pd.DataFrame({
        "open_price": np.random.uniform(50, 500, size=n),
        "high_price": np.random.uniform(50, 500, size=n),
        "low_price": np.random.uniform(50, 500, size=n),
        "volume": np.random.randint(1000, 1000000, size=n),
        "market_sentiment": np.random.uniform(-1,1, size=n),
        "economic_index": np.random.uniform(0, 100, size=n)
    })
    # Target: next day's closing price
    df["close_price"] = df["open_price"] + np.random.normal(0, 5, size=n)
    return df

data = generate_synthetic_finance_data()

# 2. Preprocess Data
X = data.drop("close_price", axis=1)
y = data["close_price"]

scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

X_train, X_test, y_train, y_test = train_test_split(
    X_scaled, y, test_size=0.2, random_state=42
)

# 3. Build AI Model
model = RandomForestRegressor(
    n_estimators=150,
    max_depth=6,
    random_state=42
)
model.fit(X_train, y_train)
y_pred = model.predict(X_test)

mse = mean_squared_error(y_test, y_pred)
print("Mean Squared Error:", round(mse,2))

# 4. Feature Importance (Explainability)
feature_importances = pd.Series(model.feature_importances_, index=X.columns)
feature_importances = feature_importances.sort_values(ascending=False)

plt.figure(figsize=(8,5))
sns.barplot(x=feature_importances, y=feature_importances.index)
plt.title("Feature Importance - Finance AI Prototype")
plt.show()

# 5. High-Level Reasoning Example
def interpret_trade_risk(trade_features):
    """
    Interpret risk and prediction for a single trade.
    """
    predicted_close = model.predict([trade_features])[0]
    reasoning = []

    if trade_features[1] > trade_features[0]*1.05:
        reasoning.append("High intraday volatility detected.")
    if trade_features[4] < -0.5:
        reasoning.append("Market sentiment is strongly negative.")
    if trade_features[5] < 30:
        reasoning.append("Economic index indicates possible market slowdown.")
    if trade_features[3] > 500000:
        reasoning.append("High trading volume could increase risk.")

    return predicted_close, reasoning

# Example usage
sample_trade = X_test[0]
predicted_price, insights = interpret_trade_risk(sample_trade)
print("\nPredicted Close Price:", round(predicted_price,2))
print("Reasoning / Insights:")
for r in insights:
    print("-", r)