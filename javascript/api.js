// src/api.js
// Example API module to connect to Python AI backend
export async function fetchAIInsights() {
  // Replace with your Python backend URL
  const response = await fetch('http://localhost:5000/api/insights');
  if (!response.ok) throw new Error('Network response was not ok');
  const data = await response.json();
  return data;
}