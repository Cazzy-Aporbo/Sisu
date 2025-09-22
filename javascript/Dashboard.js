// src/Dashboard.js
import React, { useState, useEffect } from 'react';
import { fetchAIInsights } from './api';

function Dashboard() {
  const [loading, setLoading] = useState(false);
  const [insights, setInsights] = useState(null);
  const [error, setError] = useState(null);

  const getInsights = async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await fetchAIInsights();
      setInsights(data);
    } catch (err) {
      setError('Error fetching AI insights');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    getInsights();
  }, []);

  if (loading) return <p>Loading AI insights...</p>;
  if (error) return <p>{error}</p>;

  return (
    <div className="dashboard">
      <h2>AI Insights</h2>
      {insights ? (
        <pre>{JSON.stringify(insights, null, 2)}</pre>
      ) : (
        <p>No insights available</p>
      )}
      <button onClick={getInsights}>Refresh Insights</button>
    </div>
  );
}

export default Dashboard;