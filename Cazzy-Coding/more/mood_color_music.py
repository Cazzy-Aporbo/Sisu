# Required: pip install pandas plotly
import pandas as pd
import plotly.express as px
import random
import string
from datetime import datetime
from dataclasses import dataclass

# 1. User Input
mood = input("How are you feeling today? (one word or phrase): ").strip().lower()

# 2. Mood Analysis (simple)
mood_score = sum([ord(c) for c in mood if c.isalpha()]) % 100  # unique number from text

# 3. Generate Color Palette
def random_color(seed):
    random.seed(seed)
    return f"rgb({random.randint(0,255)},{random.randint(0,255)},{random.randint(0,255)})"

colors = [random_color(mood_score + i) for i in range(5)]

# 4. Generate Sound Pattern (simulated)
notes = ['C', 'D', 'E', 'F', 'G', 'A', 'B']
pattern = [random.choice(notes) + str(random.randint(1,5)) for _ in range(10)]

# 5. Save Mood Dashboard HTML
html_content = f"""
<html>
<head>
<title>Mood Color Music Generator</title>
</head>
<body>
<h1>Mood Color Music Dashboard</h1>
<p>Generated: {datetime.now()}</p>
<p>Your mood: <strong>{mood}</strong></p>

<h2>Color Palette Inspired by Your Mood</h2>
<div style="display:flex;">
{''.join([f'<div style="width:100px;height:100px;background-color:{c};margin:5px;"></div>' for c in colors])}
</div>

<h2>Random Musical Notes Pattern</h2>
<p>{' '.join(pattern)}</p>

</body>
</html>
"""

with open("mood_color_music.html","w") as f:
    f.write(html_content)

print("Mood Color Music HTML generated: mood_color_music.html")
print(f"Color Palette: {colors}")
print(f"Music Pattern: {' '.join(pattern)}")