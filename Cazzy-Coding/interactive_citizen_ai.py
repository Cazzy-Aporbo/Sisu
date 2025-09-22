# interactive_citizen_ai.py
"""
Interactive Citizen AI Prototype
Educates and engages citizens on environment, health, and finance
through personalized recommendations and gamification.
"""

import random

# -----------------------------
# 1. Sample User Data
# -----------------------------
users = {
    "alice": {"domain":"environment", "behavior_score": 0.4},
    "bob": {"domain":"health", "behavior_score": 0.7},
    "carol": {"domain":"finance", "behavior_score": 0.5}
}

# -----------------------------
# 2. Personalized Recommendations
# -----------------------------
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

def assess_user(user_name):
    user = users.get(user_name)
    if not user:
        return {"error":"User not found."}
    
    score = user["behavior_score"]
    domain = user["domain"]
    
    # Generate personalized recommendation
    rec = random.choice(RECOMMENDATIONS[domain])
    
    # Generate narrative
    narrative = f"Your current {domain} behavior score is {score}. Recommended action: {rec}."
    
    # Gamification points
    points = int((1-score) * 100)  # higher points for improvement potential
    
    return {
        "user": user_name,
        "domain": domain,
        "behavior_score": score,
        "recommendation": rec,
        "narrative": narrative,
        "gamification_points": points
    }

# -----------------------------
# 3. Example Usage
# -----------------------------
if __name__ == "__main__":
    for user_name in ["alice", "bob", "carol"]:
        result = assess_user(user_name)
        print("\n=== Interactive Citizen AI ===")
        for k,v in result.items():
            print(f"{k}: {v}")