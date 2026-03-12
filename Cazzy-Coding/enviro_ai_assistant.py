# enviro_ai_assistant.py
"""
Environmental AI Assistant Prototype
Purpose: Provide insights, recommendations, and reasoning for:
- Waste management
- Water conservation
- Gas emissions
- Pricing / sustainability incentives
Demonstrates multi-layer AI reasoning with prototype-level intelligence.
"""

import random
from datetime import datetime, timedelta

# 1. Environmental Knowledge Base (Prototype)
GARBAGE_TIPS = [
    "Implement city-wide recycling programs",
    "Encourage composting at household level",
    "Optimize garbage collection routes using AI"
]

WATER_TIPS = [
    "Install smart water meters to track usage",
    "Promote rainwater harvesting",
    "Detect leaks using IoT sensors"
]

GAS_EMISSIONS_TIPS = [
    "Shift to electric public transport",
    "Encourage renewable energy usage",
    "Monitor factories with emission sensors"
]

PRICING_TIPS = [
    "Implement carbon tax on heavy polluters",
    "Provide subsidies for green technology",
    "Use dynamic pricing to encourage sustainable behavior"
]

# 2. Multi-Layer AI Reasoning
def assess_environmental_issue(issue_type, severity_level=None):
    """
    Layer 1: Identify key problem and severity
    """
    severity = severity_level if severity_level else random.choice(["low","medium","high"])
    
    recommendations = []
    if issue_type == "garbage":
        recommendations = random.sample(GARBAGE_TIPS, k=2)
    elif issue_type == "water":
        recommendations = random.sample(WATER_TIPS, k=2)
    elif issue_type == "gas":
        recommendations = random.sample(GAS_EMISSIONS_TIPS, k=2)
    elif issue_type == "pricing":
        recommendations = random.sample(PRICING_TIPS, k=2)
    else:
        recommendations = ["Consult local environmental data"]
    
    return severity, recommendations

def high_level_strategy(issue_type, location=None):
    """
    Layer 2: Provide high-level strategic advice based on domain
    """
    strategies = {
        "garbage": f"Optimize waste lifecycle in {location or 'the city'} using AI prediction and citizen engagement.",
        "water": f"Monitor water networks in {location or 'your area'} with IoT sensors to reduce waste.",
        "gas": f"Create emission monitoring dashboards for {location or 'industries'} to minimize environmental footprint.",
        "pricing": f"Design pricing incentives to encourage sustainable consumer behavior in {location or 'the region'}."
    }
    return strategies.get(issue_type, "Perform environmental assessment for accurate strategy.")

def simulate_environmental_impact(issue_type, level):
    """
    Layer 3: Predict potential impact (prototype simulation)
    """
    impact_scale = {"low": 0.1, "medium": 0.5, "high": 0.9}
    base_impact = impact_scale.get(level, 0.5)
    
    # Simulate potential environmental benefit after intervention
    improvement = base_impact * random.uniform(0.3, 0.7)
    return round(1 - improvement, 2)  # lower number = better outcome

# 3. Environmental AI Assistant
def enviro_ai_assistant(user_input, location=None):
    """
    Main interface: processes user input and provides multi-layered reasoning
    """
    issue_keywords = {
        "garbage": ["trash","garbage","waste","recycling"],
        "water": ["water","leak","consumption","pipes","shortage"],
        "gas": ["gas","emission","co2","fumes","carbon"],
        "pricing": ["tax","price","subsidy","incentive","cost"]
    }
    
    detected_issue = None
    for key, keywords in issue_keywords.items():
        if any(word in user_input.lower() for word in keywords):
            detected_issue = key
            break
    
    if not detected_issue:
        return {"response":"Could not identify the environmental issue. Please clarify."}
    
    # Layer 1: Assessment
    severity, tips = assess_environmental_issue(detected_issue)
    
    # Layer 2: Strategic Advice
    strategy = high_level_strategy(detected_issue, location)
    
    # Layer 3: Simulated Impact
    impact_score = simulate_environmental_impact(detected_issue, severity)
    
    response = {
        "issue_type": detected_issue,
        "severity_level": severity,
        "practical_tips": tips,
        "high_level_strategy": strategy,
        "estimated_impact_score": impact_score
    }
    
    return response

# 4. Example Usage
if __name__ == "__main__":
    queries = [
        "Our city has too much garbage piling up",
        "Water pipes are leaking and consumption is high",
        "Factories are producing too much CO2",
        "We need incentives to reduce pollution"
    ]
    
    for q in queries:
        result = enviro_ai_assistant(q, location="Metropolis")
        print("\n=== Environmental AI Assistant Response ===")
        for k,v in result.items():
            print(f"{k}: {v}")