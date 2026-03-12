# interactive_citizen_ai_dashboard.py
"""
Interactive Citizen AI Dashboard
Prototype: Multi-domain citizen engagement platform
"""

import streamlit as st
import random
import pandas as pd

# 1. Sample Recommendations & Gamification
RECOMMENDATIONS = {
    "environment": [
        "Reduce daily water usage by 20%",
        "Recycle all plastic waste",
        "Use public transport 3x per week"
    ],
    "health": [
        "Walk 10,000 steps per day",
        "Eat 5 servings of fruits and vegetables",
        "Schedule a preventive health checkup"
    ],
    "finance": [
        "Track daily expenses using a budgeting app",
        "Save 10% of monthly income",
        "Reduce unnecessary subscriptions"
    ]
}

# 2. Streamlit UI
st.title("🌱 Interactive Citizen AI")

st.sidebar.header("Enter Your Daily Habits")

# Collect user input
env_score = st.sidebar.slider("Environment (0=bad, 1=excellent)", 0.0, 1.0, 0.5)
health_score = st.sidebar.slider("Health (0=bad, 1=excellent)", 0.0, 1.0, 0.5)
finance_score = st.sidebar.slider("Finance (0=bad, 1=excellent)", 0.0, 1.0, 0.5)

user_data = {
    "environment": env_score,
    "health": health_score,
    "finance": finance_score
}

# 3. AI Assessment & Recommendation
def assess_domain(domain, score):
    recommendation = random.choice(RECOMMENDATIONS[domain])
    points = int((1-score) * 100)
    narrative = f"Your current {domain} behavior score is {score}. Recommended action: {recommendation}."
    return {"score": score, "recommendation": recommendation, "points": points, "narrative": narrative}

results = {}
for domain, score in user_data.items():
    results[domain] = assess_domain(domain, score)

# 4. Display Results
st.header("📊 Your Behavior Assessment")
for domain, res in results.items():
    st.subheader(f"{domain.capitalize()}")
    st.write(f"Score: {res['score']}")
    st.write(f"Recommendation: {res['recommendation']}")
    st.write(f"Gamification Points: {res['points']}")
    st.info(res['narrative'])

# 5. Progress Visualization
st.header("📈 Behavior Progress Simulation")
df = pd.DataFrame({
    "Domain": list(user_data.keys()),
    "Score": [user_data[d] for d in user_data.keys()],
    "Points": [results[d]['points'] for d in user_data.keys()]
})
st.bar_chart(df.set_index("Domain")["Score"])

st.header("🏆 Gamification Dashboard")
st.bar_chart(df.set_index("Domain")["Points"])

# 6. Scenario Simulation
st.header("🔮 Scenario Simulation")
st.write("Try increasing your behavior score to see potential improvements.")
sim_scores = {d: min(score + 0.2,1.0) for d, score in user_data.items()}
st.write(sim_scores)
sim_points = {d: int((1-sim_scores[d])*100) for d in sim_scores}
st.bar_chart(pd.DataFrame({"Points": list(sim_points.values())}, index=list(sim_points.keys())))