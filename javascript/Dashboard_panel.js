// src/DashboardPanel.js
import React from 'react';
import { Bar } from 'react-chartjs-2';
import 'chart.js/auto';

function DashboardPanel({ title, data, color }) {
  // Convert data to chart format if numeric
  const labels = Object.keys(data);
  const values = Object.values(data);

  const chartData = {
    labels,
    datasets: [
      {
        label: title,
        data: values,
        backgroundColor: color,
      },
    ],
  };

  return (
    <div className="panel">
      <h3>{title}</h3>
      {labels.length > 0 ? (
        <Bar data={chartData} />
      ) : (
        <p>No data available</p>
      )}
    </div>
  );
}

export default DashboardPanel;