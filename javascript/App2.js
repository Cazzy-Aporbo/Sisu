// src/App.js
import React, { useState, useEffect } from 'react';
import DashboardPanel from './DashboardPanel';
import { fetchAIInsights } from './api';
import './App.css';

function App() {
  const [insights, setInsights] = useState({});
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // Fetch AI insights from backend
  const getInsights = async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await fetchAIInsights();
      setInsights(data);
    } catch (err) {
      setError('Failed to fetch AI insights.');
    } finally {
      setLoading(false);
    }
  };

  // Initial fetch + interval refresh
  useEffect(() => {
    getInsights();
    const interval = setInterval(getInsights, 15000); // refresh every 15 sec
    return () => clearInterval(interval);
  }, []);

  return (
    <div className="app-container">
      <header className="app-header">
        <h1>🌌 Superintelligent AI Dashboard</h1>
        <button onClick={getInsights} className="refresh-btn">
          🔄 Refresh
        </button>
      </header>

      {loading && <p className="loading">Loading AI insights...</p>}
      {error && <p className="error">{error}</p>}

      {!loading && !error && (
        <div className="dashboard-grid">
          <DashboardPanel
            title="Environment AI"
            data={insights.environment || {}}
            color="#4caf50"
          />
          <DashboardPanel
            title="Health AI"
            data={insights.health || {}}
            color="#2196f3"
          />
          <DashboardPanel
            title="Finance AI"
            data={insights.finance || {}}
            color="#ff9800"
          />
          <DashboardPanel
            title="Ethical AI Detector"
            data={insights.ethical || {}}
            color="#f44336"
          />
        </div>
      )}
    </div>
  );
}

export default App;