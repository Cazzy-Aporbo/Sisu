# appliance_ai_assistant.py
"""
Appliance Repair AI Booking Assistant Prototype
Demonstrates multi-layer reasoning:
1. Customer intent detection
2. Fault prediction and troubleshooting guidance
3. Scheduling & optimization
4. Integration with multi-layered AI "superintelligence" reasoning
"""

import random
from datetime import datetime, timedelta

# 1. Simulated Appliance Knowledge Base
APPLIANCE_DB = {
    "washer": ["not spinning", "leaking water", "won't start"],
    "dryer": ["not heating", "tumbler not spinning", "strange noise"],
    "fridge": ["not cooling", "leaking water", "strange odor"],
    "oven": ["not heating", "uneven temperature", "door won't close"]
}

# 2. Multi-Layer AI Reasoning (Prototype)
def predict_fault(appliance, symptoms):
    """
    Layer 1: Predict likely fault based on symptoms
    """
    possible_issues = APPLIANCE_DB.get(appliance.lower(), [])
    match_score = {}
    for issue in possible_issues:
        # Simple heuristic: random similarity to simulate reasoning
        match_score[issue] = random.uniform(0.5, 1.0) if issue in symptoms else random.uniform(0.0, 0.6)
    predicted_fault = max(match_score, key=match_score.get)
    return predicted_fault, match_score[predicted_fault]

def suggest_troubleshooting(fault):
    """
    Layer 2: Suggest high-level troubleshooting steps
    """
    steps = {
        "not spinning": ["Check power supply", "Inspect belt", "Check motor"],
        "leaking water": ["Check hoses", "Inspect seals", "Tighten connections"],
        "won't start": ["Check circuit breaker", "Inspect plug", "Reset appliance"],
        "not heating": ["Check heating element", "Inspect fuse", "Test thermostat"],
        "strange noise": ["Inspect moving parts", "Lubricate if needed", "Tighten screws"],
        "uneven temperature": ["Calibrate thermostat", "Check heating coils", "Clean interior"],
        "door won't close": ["Inspect hinges", "Check gasket", "Remove obstruction"],
        "strange odor": ["Clean filters", "Check for mold", "Inspect drainage"]
    }
    return steps.get(fault, ["Request technician visit"])

def schedule_booking(preferred_date=None):
    """
    Layer 3: Schedule booking intelligently
    """
    if not preferred_date:
        preferred_date = datetime.now() + timedelta(days=random.randint(1,5))
    return preferred_date.strftime("%Y-%m-%d %H:%M")

# 3. Superintelligence Multi-Layer Reasoning Simulation
def appliance_ai_assistant(user_input):
    """
    Layer 4: Superintelligent decision-making
    """
    # Parse user input (simple simulated NLP)
    appliance = None
    symptoms = []
    for key in APPLIANCE_DB.keys():
        if key in user_input.lower():
            appliance = key
            for issue in APPLIANCE_DB[key]:
                if issue in user_input.lower():
                    symptoms.append(issue)
    
    if not appliance:
        return "Sorry, I couldn't identify your appliance. Could you specify?"

    # Layer 1: Fault Prediction
    predicted_fault, confidence = predict_fault(appliance, symptoms)
    
    # Layer 2: Troubleshooting
    steps = suggest_troubleshooting(predicted_fault)
    
    # Layer 3: Booking
    booking_date = schedule_booking()
    
    # Layer 4: High-Level Recommendation
    recommendation = "Schedule a technician if steps do not resolve the issue."
    
    # Compile multi-layer response
    response = {
        "appliance": appliance,
        "predicted_fault": predicted_fault,
        "confidence": round(confidence,2),
        "troubleshooting_steps": steps,
        "suggested_booking": booking_date,
        "superintelligent_advice": recommendation
    }
    return response

# 4. Example Usage
if __name__ == "__main__":
    user_query = "My washer is leaking water and not spinning"
    result = appliance_ai_assistant(user_query)
    
    print("=== Appliance AI Assistant Response ===")
    for k, v in result.items():
        print(f"{k}: {v}")