# Required: pip install pandas

import random
from dataclasses import dataclass
from datetime import datetime
import pandas as pd

@dataclass
class Character:
    name: str
    age: int
    mood: str

names = ['Alex', 'Jordan', 'Taylor', 'Morgan', 'Casey']
moods = ['happy', 'anxious', 'excited', 'tired', 'curious']

char = Character(
    name=random.choice(names),
    age=random.randint(18, 65),
    mood=random.choice(moods)
)

events = [
    'found a mysterious object',
    'met an old friend unexpectedly',
    'had a sudden insight',
    'got lost in a new place',
    'discovered a hidden talent',
    'received a surprising message'
]

outcomes = [
    'felt ecstatic', 
    'was nervous', 
    'laughed uncontrollably', 
    'learned something new', 
    'felt inspired'
]

day_events = []
for hour in range(9, 18):
    event = random.choice(events)
    outcome = random.choice(outcomes)
    day_events.append({'hour': hour, 'event': event, 'outcome': outcome})

df = pd.DataFrame(day_events)

html_content = f"""
<html>
<head><title>Random Life Simulator</title></head>
<body>
<h1>Random Life Scenario for {char.name}, Age {char.age}</h1>
<p>Mood at start: {char.mood}</p>
<p>Generated on: {datetime.now()}</p>

<h2>Events of the Day</h2>
{df.to_html(index=False)}

</body>
</html>
"""

with open("random_life_simulator.html","w") as f:
    f.write(html_content)

print("Random Life Simulator HTML generated: random_life_simulator.html")
print(df)