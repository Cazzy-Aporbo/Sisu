<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quantum Field Visualizer</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        
        body {
            background: linear-gradient(135deg, #000428, #004e92);
            color: #ffffff;
            min-height: 100vh;
            overflow: hidden;
            display: flex;
            flex-direction: column;
            align-items: center;
            padding: 1rem;
        }
        
        header {
            text-align: center;
            margin-bottom: 1.5rem;
            width: 100%;
            z-index: 10;
        }
        
        h1 {
            font-size: 3.2rem;
            margin-bottom: 0.5rem;
            background: linear-gradient(90deg, #00c9ff, #92fe9d);
            -webkit-background-clip: text;
            background-clip: text;
            color: transparent;
            text-shadow: 0 0 15px rgba(146, 254, 157, 0.5);
            font-weight: 300;
            letter-spacing: 2px;
        }
        
        .subtitle {
            font-size: 1.1rem;
            opacity: 0.8;
            margin-bottom: 1.5rem;
            font-weight: 300;
        }
        
        .container {
            display: flex;
            flex-direction: column;
            align-items: center;
            width: 100%;
            max-width: 1200px;
            gap: 1.5rem;
            z-index: 10;
        }
        
        .canvas-container {
            position: relative;
            width: 100%;
            max-width: 800px;
            height: 400px;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5);
            background: rgba(0, 0, 0, 0.2);
            border: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        canvas {
            width: 100%;
            height: 100%;
            display: block;
        }
        
        .controls {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1.2rem;
            width: 100%;
            max-width: 800px;
        }
        
        .control-group {
            background: rgba(0, 20, 40, 0.6);
            padding: 1.2rem;
            border-radius: 10px;
            backdrop-filter: blur(10px);
            border: 1px solid rgba(0, 156, 255, 0.3);
            box-shadow: 0 0 15px rgba(0, 156, 255, 0.2);
        }
        
        h2 {
            font-size: 1.3rem;
            margin-bottom: 1rem;
            color: #00c9ff;
            font-weight: 400;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        h2::before {
            content: "⊛";
            font-size: 1.5rem;
        }
        
        .slider-container {
            margin-bottom: 1rem;
        }
        
        label {
            display: block;
            margin-bottom: 0.5rem;
            font-weight: 500;
            font-size: 0.9rem;
            color: #92fe9d;
        }
        
        input[type="range"] {
            width: 100%;
            height: 6px;
            -webkit-appearance: none;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 4px;
            outline: none;
        }
        
        input[type="range"]::-webkit-slider-thumb {
            -webkit-appearance: none;
            width: 18px;
            height: 18px;
            border-radius: 50%;
            background: #00c9ff;
            cursor: pointer;
            box-shadow: 0 0 10px rgba(0, 201, 255, 0.8);
            transition: all 0.2s ease;
        }
        
        input[type="range"]::-webkit-slider-thumb:hover {
            transform: scale(1.2);
            background: #92fe9d;
        }
        
        .value-display {
            display: flex;
            justify-content: space-between;
            margin-top: 0.3rem;
            font-size: 0.8rem;
            opacity: 0.7;
        }
        
        .buttons {
            display: flex;
            gap: 1rem;
            flex-wrap: wrap;
            margin-top: 1rem;
        }
        
        button {
            padding: 0.7rem 1.2rem;
            border: none;
            border-radius: 6px;
            background: linear-gradient(90deg, #00c9ff, #92fe9d);
            color: #001a33;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.2s, box-shadow 0.2s;
            box-shadow: 0 4px 10px rgba(0, 201, 255, 0.4);
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        button:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 15px rgba(146, 254, 157, 0.6);
        }
        
        button::before {
            content: "⟁";
            font-size: 1.2rem;
        }
        
        .info-panel {
            background: rgba(0, 20, 40, 0.6);
            padding: 1.2rem;
            border-radius: 10px;
            width: 100%;
            max-width: 800px;
            margin-top: 0.5rem;
            backdrop-filter: blur(10px);
            border: 1px solid rgba(0, 156, 255, 0.3);
        }
        
        .info-panel h2 {
            margin-bottom: 1rem;
        }
        
        .info-content {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 1rem;
        }
        
        .info-item {
            background: rgba(0, 40, 80, 0.5);
            padding: 1rem;
            border-radius: 8px;
            text-align: center;
            border: 1px solid rgba(0, 156, 255, 0.2);
        }
        
        .info-value {
            font-size: 1.5rem;
            font-weight: 700;
            color: #00c9ff;
            text-shadow: 0 0 10px rgba(0, 201, 255, 0.5);
        }
        
        .info-label {
            font-size: 0.8rem;
            opacity: 0.8;
            margin-top: 0.3rem;
        }
        
        .dimensional-display {
            position: absolute;
            top: 1rem;
            right: 1rem;
            background: rgba(0, 20, 40, 0.8);
            padding: 0.8rem;
            border-radius: 8px;
            font-size: 0.9rem;
            backdrop-filter: blur(5px);
            border: 1px solid rgba(0, 156, 255, 0.3);
            box-shadow: 0 0 15px rgba(0, 156, 255, 0.2);
        }
        
        footer {
            margin-top: 1.5rem;
            text-align: center;
            opacity: 0.7;
            font-size: 0.8rem;
            z-index: 10;
        }
        
        .quantum-background {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: 1;
            opacity: 0.15;
        }
        
        @media (max-width: 768px) {
            h1 {
                font-size: 2.2rem;
            }
            
            .controls {
                grid-template-columns: 1fr;
            }
            
            .canvas-container {
                height: 300px;
            }
            
            .dimensional-display {
                top: 0.5rem;
                right: 0.5rem;
                font-size: 0.7rem;
            }
        }
    </style>
</head>
<body>
    <canvas class="quantum-background" id="backgroundCanvas"></canvas>
    
    <header>
        <h1>Quantum Field Visualizer</h1>
        <p class="subtitle">Exploring Unseen Dimensions Through Harmonic Resonance</p>
    </header>
    
    <div class="container">
        <div class="canvas-container">
            <canvas id="quantumCanvas"></canvas>
            <div class="dimensional-display">
                <div>Current Dimension: <span id="dimensionValue">11.6D</span></div>
                <div>Field Strength: <span id="fieldStrength">0.73</span></div>
            </div>
        </div>
        
        <div class="controls">
            <div class="control-group">
                <h2>Field Parameters</h2>
                <div class="slider-container">
                    <label for="dimensionality">Dimensionality</label>
                    <input type="range" id="dimensionality" min="3" max="26" value="11.6" step="0.1">
                    <div class="value-display">
                        <span>3D</span>
                        <span id="dimensionalityValue">11.6D</span>
                        <span>26D</span>
                    </div>
                </div>
                
                <div class="slider-container">
                    <label for="fieldFrequency">Field Frequency</label>
                    <input type="range" id="fieldFrequency" min="0.1" max="5" value="1.8" step="0.1">
                    <div class="value-display">
                        <span>Low</span>
                        <span id="frequencyValue">1.8</span>
                        <span>High</span>
                    </div>
                </div>
                
                <div class="slider-container">
                    <label for="quantumFlux">Quantum Flux</label>
                    <input type="range" id="quantumFlux" min="0" max="1" value="0.36" step="0.01">
                    <div class="value-display">
                        <span>Min</span>
                        <span id="fluxValue">0.36</span>
                        <span>Max</span>
                    </div>
                </div>
            </div>
            
            <div class="control-group">
                <h2>Resonance Controls</h2>
                <div class="slider-container">
                    <label for="entanglement">Quantum Entanglement</label>
                    <input type="range" id="entanglement" min="0" max="1" value="0.5" step="0.01">
                    <div class="value-display">
                        <span>Separated</span>
                        <span id="entanglementValue">0.50</span>
                        <span>Entangled</span>
                    </div>
                </div>
                
                <div class="slider-container">
                    <label for="superposition">Superposition States</label>
                    <input type="range" id="superposition" min="1" max="12" value="5" step="1">
                    <div class="value-display">
                        <span>Single</span>
                        <span id="superpositionValue">5 States</span>
                        <span>Multiple</span>
                    </div>
                </div>
                
                <div class="buttons">
                    <button id="resonanceBtn">Harmonic Resonance</button>
                    <button id="collapseBtn">Waveform Collapse</button>
                </div>
            </div>
        </div>
        
        <div class="info-panel">
            <h2>Quantum Field Metrics</h2>
            <div class="info-content">
                <div class="info-item">
                    <div class="info-value" id="energyValue">7.23</div>
                    <div class="info-label">Energy Level (eV)</div>
                </div>
                <div class="info-item">
                    <div class="info-value" id="coherenceValue">0.84</div>
                    <div class="info-label">Coherence</div>
                </div>
                <div class="info-item">
                    <div class="info-value" id="oscillationValue">12.5</div>
                    <div class="info-label">Oscillations/ms</div>
                </div>
                <div class="info-item">
                    <div class="info-value" id="stabilityValue">92%</div>
                    <div class="info-label">Quantum Stability</div>
                </div>
            </div>
        </div>
    </div>
    
    <footer>
        <p>Quantum Field Visualizer ⊛ 2023 ⊛ Exploring Unseen Dimensions</p>
    </footer>

    <script>
        // Main application class for the quantum field visualization
        class QuantumFieldVisualizer {
            constructor() {
                // Initialize canvases
                this.mainCanvas = document.getElementById('quantumCanvas');
                this.mainCtx = this.mainCanvas.getContext('2d');
                this.bgCanvas = document.getElementById('backgroundCanvas');
                this.bgCtx = this.bgCanvas.getContext('2d');
                
                // Configuration with default values
                this.config = {
                    dimensionality: 11.6,
                    fieldFrequency: 1.8,
                    quantumFlux: 0.36,
                    entanglement: 0.5,
                    superposition: 5,
                    resonance: 0,
                    collapse: false,
                    time: 0
                };
                
                // Field state
                this.field = [];
                this.waveFunctions = [];
                
                // Animation frame ID
                this.animationId = null;
                
                // Performance tracking
                this.lastFrameTime = Date.now();
                this.metrics = {
                    energy: 7.23,
                    coherence: 0.84,
                    oscillations: 12.5,
                    stability: 92
                };
                
                // Initialize the system
                this.init();
            }
            
            init() {
                // Set up canvas sizes
                this.resizeCanvases();
                window.addEventListener('resize', () => this.resizeCanvases());
                
                // Set up controls
                this.setupControls();
                
                // Initialize field
                this.initializeField();
                
                // Initialize wave functions
                this.initializeWaveFunctions();
                
                // Start animation
                this.animate();
            }
            
            resizeCanvases() {
                this.mainCanvas.width = this.mainCanvas.offsetWidth;
                this.mainCanvas.height = this.mainCanvas.offsetHeight;
                
                this.bgCanvas.width = window.innerWidth;
                this.bgCanvas.height = window.innerHeight;
            }
            
            initializeField() {
                this.field = [];
                const width = this.mainCanvas.width;
                const height = this.mainCanvas.height;
                
                // Create a grid of field points
                for (let y = 0; y < height; y += 4) {
                    for (let x = 0; x < width; x += 4) {
                        this.field.push({
                            x,
                            y,
                            baseX: x,
                            baseY: y,
                            phase: Math.random() * Math.PI * 2,
                            amplitude: 0.5 + Math.random() * 0.5,
                            frequency: 0.5 + Math.random() * 0.5
                        });
                    }
                }
            }
            
            initializeWaveFunctions() {
                this.waveFunctions = [];
                
                // Create multiple wave functions for superposition
                for (let i = 0; i < this.config.superposition; i++) {
                    this.waveFunctions.push({
                        x: Math.random() * this.mainCanvas.width,
                        y: Math.random() * this.mainCanvas.height,
                        radius: 20 + Math.random() * 50,
                        speed: 0.5 + Math.random() * 2,
                        phase: Math.random() * Math.PI * 2,
                        frequency: 0.5 + Math.random() * 1.5
                    });
                }
            }
            
            setupControls() {
                // Dimensionality slider
                const dimensionalitySlider = document.getElementById('dimensionality');
                const dimensionalityValue = document.getElementById('dimensionalityValue');
                const dimensionValue = document.getElementById('dimensionValue');
                
                dimensionalitySlider.addEventListener('input', (e) => {
                    this.config.dimensionality = parseFloat(e.target.value);
                    dimensionalityValue.textContent = this.config.dimensionality.toFixed(1) + 'D';
                    dimensionValue.textContent = this.config.dimensionality.toFixed(1) + 'D';
                });
                
                // Field frequency slider
                const frequencySlider = document.getElementById('fieldFrequency');
                const frequencyValue = document.getElementById('frequencyValue');
                
                frequencySlider.addEventListener('input', (e) => {
                    this.config.fieldFrequency = parseFloat(e.target.value);
                    frequencyValue.textContent = this.config.fieldFrequency.toFixed(1);
                });
                
                // Quantum flux slider
                const fluxSlider = document.getElementById('quantumFlux');
                const fluxValue = document.getElementById('fluxValue');
                const fieldStrength = document.getElementById('fieldStrength');
                
                fluxSlider.addEventListener('input', (e) => {
                    this.config.quantumFlux = parseFloat(e.target.value);
                    fluxValue.textContent = this.config.quantumFlux.toFixed(2);
                    fieldStrength.textContent = this.config.quantumFlux.toFixed(2);
                });
                
                // Entanglement slider
                const entanglementSlider = document.getElementById('entanglement');
                const entanglementValue = document.getElementById('entanglementValue');
                
                entanglementSlider.addEventListener('input', (e) => {
                    this.config.entanglement = parseFloat(e.target.value);
                    entanglementValue.textContent = this.config.entanglement.toFixed(2);
                });
                
                // Superposition slider
                const superpositionSlider = document.getElementById('superposition');
                const superpositionValue = document.getElementById('superpositionValue');
                
                superpositionSlider.addEventListener('input', (e) => {
                    this.config.superposition = parseInt(e.target.value);
                    superpositionValue.textContent = this.config.superposition + ' States';
                    this.initializeWaveFunctions();
                });
                
                // Resonance button
                const resonanceBtn = document.getElementById('resonanceBtn');
                resonanceBtn.addEventListener('click', () => {
                    this.triggerResonance();
                });
                
                // Collapse button
                const collapseBtn = document.getElementById('collapseBtn');
                collapseBtn.addEventListener('click', () => {
                    this.triggerCollapse();
                });
            }
            
            triggerResonance() {
                this.config.resonance = 1.0;
                
                // Update metrics
                this.metrics.energy = 9.85;
                this.metrics.coherence = 0.95;
                this.metrics.oscillations = 18.7;
                this.metrics.stability = 87;
                
                this.updateMetricsDisplay();
            }
            
            triggerCollapse() {
                this.config.collapse = true;
                
                // Update metrics
                this.metrics.energy = 3.12;
                this.metrics.coherence = 0.25;
                this.metrics.oscillations = 5.3;
                this.metrics.stability = 65;
                
                this.updateMetricsDisplay();
                
                // Reset collapse after a delay
                setTimeout(() => {
                    this.config.collapse = false;
                }, 2000);
            }
            
            updateMetricsDisplay() {
                document.getElementById('energyValue').textContent = this.metrics.energy.toFixed(2);
                document.getElementById('coherenceValue').textContent = this.metrics.coherence.toFixed(2);
                document.getElementById('oscillationValue').textContent = this.metrics.oscillations.toFixed(1);
                document.getElementById('stabilityValue').textContent = this.metrics.stability + '%';
            }
            
            updateField() {
                const time = this.config.time;
                const width = this.mainCanvas.width;
                const height = this.mainCanvas.height;
                
                // Update field points based on current configuration
                for (let point of this.field) {
                    // Calculate distance from center for curvature effect
                    const dx = point.baseX - width/2;
                    const dy = point.baseY - height/2;
                    const distance = Math.sqrt(dx*dx + dy*dy);
                    
                    // Calculate wave effect from wave functions
                    let waveEffect = 0;
                    for (let wave of this.waveFunctions) {
                        const waveDx = point.baseX - wave.x;
                        const waveDy = point.baseY - wave.y;
                        const waveDistance = Math.sqrt(waveDx*waveDx + waveDy*waveDy);
                        
                        waveEffect += Math.sin(waveDistance / wave.radius - time * wave.speed + wave.phase) *
                                     (wave.radius / (waveDistance + 1)) * 10;
                    }
                    
                    // Calculate dimensionality effect (higher dimensions = more complex behavior)
                    const dimensionEffect = Math.sin(time * 0.5 + point.phase) * 
                                          Math.cos(time * 0.3 + point.phase) *
                                          this.config.dimensionality * 0.1;
                    
                    // Calculate flux effect
                    const fluxEffect = Math.sin(time * point.frequency + point.phase) * 
                                     this.config.quantumFlux * 10;
                    
                    // Calculate entanglement effect
                    const entanglementEffect = Math.sin(distance * 0.01 - time * 0.7) * 
                                             this.config.entanglement * 5;
                    
                    // Calculate resonance effect
                    const resonanceEffect = this.config.resonance > 0 ? 
                        Math.sin(time * 5) * Math.cos(distance * 0.02 - time * 2) * this.config.resonance * 20 : 0;
                    
                    // Calculate collapse effect
                    const collapseEffect = this.config.collapse ? 
                        (0.5 - Math.random()) * 20 : 0;
                    
                    // Combine all effects
                    const totalEffect = waveEffect + dimensionEffect + fluxEffect + 
                                      entanglementEffect + resonanceEffect + collapseEffect;
                    
                    // Apply the effect to the point position
                    point.x = point.baseX + Math.cos(point.phase) * totalEffect;
                    point.y = point.baseY + Math.sin(point.phase) * totalEffect;
                }
                
                // Update wave functions
                for (let wave of this.waveFunctions) {
                    wave.x += Math.sin(time * 0.1 + wave.phase) * 0.5;
                    wave.y += Math.cos(time * 0.1 + wave.phase) * 0.5;
                    
                    // Wrap around edges
                    if (wave.x < 0) wave.x = width;
                    if (wave.x > width) wave.x = 0;
                    if (wave.y < 0) wave.y = height;
                    if (wave.y > height) wave.y = 0;
                }
                
                // Gradually reduce resonance
                if (this.config.resonance > 0) {
                    this.config.resonance -= 0.005;
                    if (this.config.resonance < 0) this.config.resonance = 0;
                    
                    // Update metrics as resonance fades
                    this.metrics.energy = 7.23 + (this.config.resonance * 2.62);
                    this.metrics.coherence = 0.84 + (this.config.resonance * 0.11);
                    this.metrics.oscillations = 12.5 + (this.config.resonance * 6.2);
                    this.metrics.stability = 92 - (this.config.resonance * 5);
                    
                    this.updateMetricsDisplay();
                }
            }
            
            drawField() {
                const ctx = this.mainCtx;
                const width = this.mainCanvas.width;
                const height = this.mainCanvas.height;
                
                // Clear canvas
                ctx.clearRect(0, 0, width, height);
                
                // Draw field connections
                ctx.beginPath();
                for (let i = 0; i < this.field.length; i++) {
                    const point = this.field[i];
                    
                    if (i === 0) {
                        ctx.moveTo(point.x, point.y);
                    } else {
                        ctx.lineTo(point.x, point.y);
                    }
                }
                ctx.strokeStyle = 'rgba(0, 201, 255, 0.1)';
                ctx.lineWidth = 1;
                ctx.stroke();
                
                // Draw field points
                for (let point of this.field) {
                    // Calculate color based on position and time
                    const hue = (point.x / width * 60 + 180 + this.config.time * 10) % 360;
                    const saturation = 80;
                    const lightness = 50 + Math.sin(this.config.time * 2 + point.phase) * 10;
                    
                    ctx.beginPath();
                    ctx.arc(point.x, point.y, 1.5, 0, Math.PI * 2);
                    ctx.fillStyle = `hsl(${hue}, ${saturation}%, ${lightness}%)`;
                    ctx.fill();
                }
                
                // Draw wave functions
                for (let wave of this.waveFunctions) {
                    ctx.beginPath();
                    ctx.arc(wave.x, wave.y, wave.radius, 0, Math.PI * 2);
                    ctx.strokeStyle = `rgba(146, 254, 157, ${0.2 + Math.sin(this.config.time * wave.frequency) * 0.1})`;
                    ctx.lineWidth = 1;
                    ctx.stroke();
                }
            }
            
            drawBackground() {
                const ctx = this.bgCtx;
                const width = this.bgCanvas.width;
                const height = this.bgCanvas.height;
                
                // Clear background
                ctx.clearRect(0, 0, width, height);
                
                // Draw quantum foam background
                const time = this.config.time * 0.5;
                
                for (let i = 0; i < 200; i++) {
                    const x = Math.random() * width;
                    const y = Math.random() * height;
                    const size = 1 + Math.random() * 2;
                    
                    const hue = (time * 10 + x / width * 60) % 360;
                    
                    ctx.beginPath();
                    ctx.arc(x, y, size, 0, Math.PI * 2);
                    ctx.fillStyle = `hsla(${hue}, 70%, 50%, 0.05)`;
                    ctx.fill();
                }
                
                // Draw dimensional grid
                ctx.strokeStyle = 'rgba(0, 156, 255, 0.03)';
                ctx.lineWidth = 0.5;
                
                const gridSize = 40;
                for (let x = 0; x < width; x += gridSize) {
                    ctx.beginPath();
                    ctx.moveTo(x, 0);
                    ctx.lineTo(x, height);
                    ctx.stroke();
                }
                
                for (let y = 0; y < height; y += gridSize) {
                    ctx.beginPath();
                    ctx.moveTo(0, y);
                    ctx.lineTo(width, y);
                    ctx.stroke();
                }
            }
            
            animate() {
                // Update time
                this.config.time += 0.05;
                
                // Update field
                this.updateField();
                
                // Draw everything
                this.drawBackground();
                this.drawField();
                
                // Continue animation
                this.animationId = requestAnimationFrame(() => this.animate());
            }
        }

        // Initialize the application when the page loads
        document.addEventListener('DOMContentLoaded', () => {
            const visualizer = new QuantumFieldVisualizer();
            
            // Expose to global scope for debugging
            window.quantumVisualizer = visualizer;
        });
    </script>
</body>
</html>