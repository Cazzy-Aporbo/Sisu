# Required packages:
# pip install pandas plotly

import antigravity
import this
import pandas as pd
import plotly.express as px
import plotly.io as pio
import random
import statistics
from collections import Counter
import math
from dataclasses import dataclass
from datetime import datetime

num_records = 500
positions = ['Engineer', 'Analyst', 'Scientist', 'Manager', 'Designer']
teams = ['Alpha', 'Beta', 'Gamma', 'Delta', 'Omega']

@dataclass
class Employee:
    id: int
    name: str
    team: str
    position: str
    skill_score: float
    efficiency: float
    creativity: float

synthetic_data = []
for i in range(num_records):
    skill = random.uniform(50, 100)
    efficiency = random.uniform(0, 1)
    creativity = random.uniform(0, 1)
    emp = Employee(
        id=i+1,
        name=f'Employee_{i+1}',
        team=random.choice(teams),
        position=random.choice(positions),
        skill_score=skill,
        efficiency=efficiency,
        creativity=creativity
    )
    synthetic_data.append(emp)

df = pd.DataFrame([e.__dict__ for e in synthetic_data])

df['impact_score'] = df['skill_score'] * (df['efficiency'] + df['creativity'])
df['performance_index'] = df['impact_score'] / df['impact_score'].max()

mean_impact = statistics.mean(df['impact_score'])
median_impact = statistics.median(df['impact_score'])
team_counts = Counter(df['team'])

print(f"Mean Impact Score: {mean_impact:.2f}")
print(f"Median Impact Score: {median_impact:.2f}")
print(f"Team Distribution: {team_counts}")

fig1 = px.scatter(
    df,
    x='efficiency',
    y='creativity',
    color='impact_score',
    size='skill_score',
    hover_data=['name','team','position'],
    color_continuous_scale='Viridis',
    title='Efficiency vs Creativity Impact'
)

fig2 = px.bar(
    df.groupby('team')['impact_score'].mean().reset_index(),
    x='team',
    y='impact_score',
    color='impact_score',
    color_continuous_scale='Turbo',
    title='Average Impact Score by Team'
)

pio.write_html(fig1, file='impact_scatter.html', auto_open=False)
pio.write_html(fig2, file='team_bar.html', auto_open=False)

html_content = f"""
<html>
<head><title>Advanced Python Dashboard</title></head>
<body>
<h1>Advanced Python Analytics Dashboard</h1>
<p>Generated: {datetime.now()}</p>

<h2>Top 10 Employees by Impact Score</h2>
{df.sort_values('impact_score', ascending=False).head(10)[['name','team','position','impact_score','performance_index']].to_html(index=False)}

<h2>Efficiency vs Creativity</h2>
<iframe src="impact_scatter.html" width="100%" height="600"></iframe>

<h2>Average Impact Score by Team</h2>
<iframe src="team_bar.html" width="100%" height="600"></iframe>

<h2>Python Easter Eggs</h2>
<p>Try <code>import antigravity</code> for XKCD and <code>import this</code> for the Zen of Python.</p>

</body>
</html>
"""

with open('advanced_dashboard_fun.html', 'w') as f:
    f.write(html_content)

print("Advanced Python Dashboard generated: advanced_dashboard_fun.html")