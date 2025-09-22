/* src/App.css */
.app-container {
  font-family: 'Arial', sans-serif;
  background-color: #0d0d0d;
  color: #f0f0f0;
  min-height: 100vh;
  padding: 0;
  margin: 0;
}

.app-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background-color: #1a1a1a;
  padding: 20px 40px;
  border-bottom: 2px solid #333;
}

.refresh-btn {
  background-color: #555;
  color: #fff;
  border: none;
  padding: 10px 20px;
  border-radius: 6px;
  cursor: pointer;
}
.refresh-btn:hover {
  background-color: #777;
}

.loading, .error {
  text-align: center;
  margin: 20px 0;
}

.dashboard-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
  gap: 20px;
  padding: 20px 40px;
}

.panel {
  background-color: #1f1f1f;
  padding: 20px;
  border-radius: 10px;
  border: 1px solid #333;
  box-shadow: 0 0 15px rgba(0,0,0,0.5);
}

.panel h3 {
  margin-top: 0;
  margin-bottom: 10px;
  text-align: center;
}