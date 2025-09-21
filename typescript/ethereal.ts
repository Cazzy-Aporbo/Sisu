<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ethereal Resonance | Multidimensional Harmony</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        
        body {
            background: linear-gradient(135deg, #f5f7fa, #c3cfe2);
            color: #6c7582;
            min-height: 100vh;
            overflow-x: hidden;
            display: flex;
            flex-direction: column;
            align-items: center;
            padding: 2rem;
        }
        
        header {
            text-align: center;
            margin-bottom: 2rem;
            width: 100%;
            max-width: 800px;
        }
        
        h1 {
            font-size: 3.5rem;
            margin-bottom: 0.5rem;
            font-weight: 300;
            color: #a8c0c9;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.05);
            letter-spacing: 3px;
        }
        
        .subtitle {
            font-size: 1.2rem;
            opacity: 0.8;
            margin-bottom: 2rem;
            font-weight: 300;
        }
        
        .container {
            display: flex;
            flex-direction: column;
            align-items: center;
            width: 100%;
            max-width: 1200px;
            gap: 2rem;
        }
        
        .canvas-container {
            position: relative;
            width: 100%;
            max-width: 800px;
            height: 450px;
            border-radius: 20px;
            overflow: hidden;
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.05);
            background: rgba(255, 255, 255, 0.5);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.6);
        }
        
        canvas {
            width: 100%;
            height: 100%;
            display: block;
        }
        
        .controls {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1.5rem;
            width: 100%;
            max-width: 800px;
        }
        
        .control-group {
            background: rgba(255, 255, 255, 0.7);
            padding: 1.5rem;
            border-radius: 18px;
            backdrop-filter: blur(5px);
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.03);
            border: 1px solid rgba(255, 255, 255, 0.8);
        }
        
        h2 {
            font-size: 1.5rem;
            margin-bottom: 1rem;
            color: #9ab3c5;
            font-weight: 400;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        h2::before {
            content: "◯";
            font-size: 1.2rem;
        }
        
        .slider-container {
            margin-bottom: 1rem;
        }
        
        label {
            display: block;
            margin-bottom: 0.5rem;
            font-weight: 500;
            font-size: 0.9rem;
            color: #8aa2b3;
        }
        
        input[type="range"] {
            width: 100%;
            height: 6px;
            -webkit-appearance: none;
            background: rgba(200, 210, 220, 0.5);
            border-radius: 10px;
            outline: none;
        }
        
        input[type="range"]::-webkit-slider-thumb {
            -webkit-appearance: none;
            width: 20px;
            height: 20px;
            border-radius: 50%;
            background: #d4e1e9;
            cursor: pointer;
            box-shadow: 0 0 10px rgba(164, 190, 204, 0.5);
            border: 1px solid #b8d0da;
            transition: all 0.2s ease;
        }
        
        input[type="range"]::-webkit-slider-thumb:hover {
            transform: scale(1.2);
            background: #e1ebf0;
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
            padding: 0.8rem 1.5rem;
            border: none;
            border-radius: 12px;
            background: rgba(220, 230, 240, 0.8);
            color: #8aa2b3;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.05);
            display: flex;
            align-items: center;
            gap: 0.5rem;
            border: 1px solid rgba(200, 210, 220, 0.6);
        }
        
        button:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.08);
            background: rgba(230, 240, 250, 0.9);
        }
        
        button::before {
            content: "◎";
            font-size: 1.1rem;
        }
        
        .info-panel {
            background: rgba(255, 255, 255, 0.7);
            padding: 1.5rem;
            border-radius: 18px;
            width: 100%;
            max-width: 800px;
            margin-top: 1rem;
            backdrop-filter: blur(5px);
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.03);
            border: 1px solid rgba(255, 255, 255, 0.8);
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
            background: rgba(240, 245, 250, 0.7);
            padding: 1rem;
            border-radius: 12px;
            text-align: center;
            border: 1px solid rgba(220, 230, 240, 0.6);
        }
        
        .info-value {
            font-size: 1.5rem;
            font-weight: 300;
            color: #9ab3c5;
        }
        
        .info-label {
            font-size: 0.8rem;
            opacity: 0.8;
            margin-top: 0.3rem;
        }
        
        .dimensional-display {
            position: absolute;
            top: 1.5rem;
            right: 1.5rem;
            background: rgba(255, 255, 255, 0.7);
            padding: 0.8rem 1.2rem;
            border-radius: 12px;
            font-size: 0.9rem;
            backdrop-filter: blur(5px);
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.8);
            display: flex;
            flex-direction: column;
            gap: 0.3rem;
        }
        
        footer {
            margin-top: 2rem;
            text-align: center;
            opacity: 0.7;
            font-size: 0.9rem;
        }
        
        .background-element {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: -1;
            opacity: 0.15;
        }
        
        @media (max-width: 768px) {
            h1 {
                font-size: 2.5rem;
            }
            
            .controls {
                grid-template-columns: 1fr;
            }
            
            .canvas-container {
                height: 350px;
            }
            
            .dimensional-display {
                top: 1rem;
                right: 1rem;
                font-size: 0.8rem;
            }
        }
    </style>
</head>
<body>
    <canvas class="background-element" id="backgroundCanvas"></canvas>
    
    <header>
        <h1>Ethereal Resonance</h1>
        <p class="subtitle">Harmonic Multidimensional Space in Pastel</p>
    </header>
    
    <div class="container">
        <div class="canvas-container">
            <canvas id="mainCanvas"></canvas>
            <div class="dimensional-display">
                <div>Harmonic Frequency: <span id="frequencyValue">0.73</span></div>
                <div>Resonance Level: <span id="resonanceValue">5.2</span></div>
            </div>
        </div>
        
        <div class="controls">
            <div class="control-group">
                <h2>Harmonic Parameters</h2>
                <div class="slider-container">
                    <label for="dimensionality">Dimensional Harmony</label>
                    <input type="range" id="dimensionality" min="3" max="11" value="7" step="0.1">
                    <div class="value-display">
                        <span>Simple</span>
                        <span id="dimensionalityValue">7.0D</span>
                        <span>Complex</span>
                    </div>
                </div>
                
                <div class="slider-container">
                    <label for="harmonicity">Harmonic Resonance</label>
                    <input type="range" id="harmonicity" min="0.1" max="5" value="2.3" step="0.1">
                    <div class="value-display">
                        <span>Soft</span>
                        <span id="harmonicityValue">2.3</span>
                        <span>Strong</span>
                    </div>
                </div>
                
                <div class="slider-container">
                    <label for="symmetry">Symmetry Level</label>
                    <input type="range" id="symmetry" min="0" max="10" value="7" step="1">
                    <div class="value-display">
                        <span>Organic</span>
                        <span id="symmetryValue">7</span>
                        <span>Structured</span>
                    </div>
                </div>
            </div>
            
            <div class="control-group">
                <h2>Resonance Controls</h2>
                <div class="slider-container">
                    <label for="convergence">Convergence Rate</label>
                    <input type="range" id="convergence" min="0.1" max="2" value="0.8" step="0.1">
                    <div class="value-display">
                        <span>Slow</span>
                        <span id="convergenceValue">0.8</span>
                        <span>Fast</span>
                    </div>
                </div>
                
                <div class="slider-container">
                    <label for="entropy">Entropy Level</label>
                    <input type="range" id="entropy" min="0" max="1" value="0.3" step="0.01">
                    <div class="value-display">
                        <span>Ordered</span>
                        <span id="entropyValue">0.30</span>
                        <span>Chaotic</span>
                    </div>
                </div>
                
                <div class="buttons">
                    <button id="resonateBtn">Resonate</button>
                    <button id="calmBtn">Calm Resonance</button>
                </div>
            </div>
        </div>
        
        <div class="info-panel">
            <h2>Resonance Metrics</h2>
            <div class="info-content">
                <div class="info-item">
                    <div class="info-value" id="energyValue">4.72</div>
                    <div class="info-label">Harmonic Energy</div>
                </div>
                <div class="info-item">
                    <div class="info-value" id="stabilityValue">86%</div>
                    <div class="info-label">Dimensional Stability</div>
                </div>
                <div class="info-item">
                    <div class="info-value" id="coherenceValue">0.78</div>
                    <div class="info-label">Field Coherence</div>
                </div>
                <div class="info-item">
                    <div class="info-value" id="nodesValue">12</div>
                    <div class="info-label">Resonance Nodes</div>
                </div>
            </div>
        </div>
    </div>
    
    <footer>
        <p>Ethereal Resonance ⊙ 2023 ⊙ Exploring Multidimensional Harmony</p>
    </footer>

    <script>
        // Main application class for the harmonic resonance visualization
        class HarmonicResonance {
            constructor() {
                // Initialize canvases
                this.mainCanvas = document.getElementById('mainCanvas');
                this.mainCtx = this.mainCanvas.getContext('2d');
                this.bgCanvas = document.getElementById('backgroundCanvas');
                this.bgCtx = this.bgCanvas.getContext('2d');
                
                // Configuration with default values
                this.config = {
                    dimensionality: 7.0,
                    harmonicity: 2.3,
                    symmetry: 7,
                    convergence: 0.8,
                    entropy: 0.3,
                    time: 0,
                    resonance: 0,
                    calm: false
                };
                
                // Resonance field
                this.field = [];
                this.nodes = [];
                
                // Animation frame ID
                this.animationId = null;
                
                // Metrics
                this.metrics = {
                    energy: 4.72,
                    stability: 86,
                    coherence: 0.78,
                    nodes: 12
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
                
                // Initialize nodes
                this.initializeNodes();
                
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
                const gridSize = 20;
                for (let y = 0; y < height; y += gridSize) {
                    for (let x = 0; x < width; x += gridSize) {
                        this.field.push({
                            x,
                            y,
                            baseX: x,
                            baseY: y,
                            phase: Math.random() * Math.PI * 2,
                            amplitude: 0.3 + Math.random() * 0.4,
                            frequency: 0.5 + Math.random() * 1.0
                        });
                    }
                }
            }
            
            initializeNodes() {
                this.nodes = [];
                const width = this.mainCanvas.width;
                const height = this.mainCanvas.height;
                
                // Create resonance nodes
                for (let i = 0; i < 12; i++) {
                    this.nodes.push({
                        x: Math.random() * width,
                        y: Math.random() * height,
                        radius: 30 + Math.random() * 50,
                        speed: 0.2 + Math.random() * 0.8,
                        phase: Math.random() * Math.PI * 2,
                        frequency: 0.3 + Math.random() * 0.7,
                        color: this.generatePastelColor()
                    });
                }
            }
            
            generatePastelColor() {
                // Generate soft pastel colors
                const hue = Math.floor(Math.random() * 360);
                return `hsl(${hue}, 40%, 85%)`;
            }
            
            setupControls() {
                // Dimensionality slider
                const dimensionalitySlider = document.getElementById('dimensionality');
                const dimensionalityValue = document.getElementById('dimensionalityValue');
                
                dimensionalitySlider.addEventListener('input', (e) => {
                    this.config.dimensionality = parseFloat(e.target.value);
                    dimensionalityValue.textContent = this.config.dimensionality.toFixed(1) + 'D';
                });
                
                // Harmonicity slider
                const harmonicitySlider = document.getElementById('harmonicity');
                const harmonicityValue = document.getElementById('harmonicityValue');
                const resonanceValue = document.getElementById('resonanceValue');
                
                harmonicitySlider.addEventListener('input', (e) => {
                    this.config.harmonicity = parseFloat(e.target.value);
                    harmonicityValue.textContent = this.config.harmonicity.toFixed(1);
                    resonanceValue.textContent = this.config.harmonicity.toFixed(1);
                });
                
                // Symmetry slider
                const symmetrySlider = document.getElementById('symmetry');
                const symmetryValue = document.getElementById('symmetryValue');
                
                symmetrySlider.addEventListener('input', (e) => {
                    this.config.symmetry = parseInt(e.target.value);
                    symmetryValue.textContent = this.config.symmetry;
                });
                
                // Convergence slider
                const convergenceSlider = document.getElementById('convergence');
                const convergenceValue = document.getElementById('convergenceValue');
                
                convergenceSlider.addEventListener('input', (e) => {
                    this.config.convergence = parseFloat(e.target.value);
                    convergenceValue.textContent = this.config.convergence.toFixed(1);
                });
                
                // Entropy slider
                const entropySlider = document.getElementById('entropy');
                const entropyValue = document.getElementById('entropyValue');
                
                entropySlider.addEventListener('input', (e) => {
                    this.config.entropy = parseFloat(e.target.value);
                    entropyValue.textContent = this.config.entropy.toFixed(2);
                });
                
                // Resonate button
                const resonateBtn = document.getElementById('resonateBtn');
                resonateBtn.addEventListener('click', () => {
                    this.triggerResonance();
                });
                
                // Calm button
                const calmBtn = document.getElementById('calmBtn');
                calmBtn.addEventListener('click', () => {
                    this.triggerCalm();
                });
            }
            
            triggerResonance() {
                this.config.resonance = 1.0;
                
                // Update metrics
                this.metrics.energy = 7.85;
                this.metrics.stability = 72;
                this.metrics.coherence = 0.92;
                
                this.updateMetricsDisplay();
            }
            
            triggerCalm() {
                this.config.calm = true;
                
                // Update metrics
                this.metrics.energy = 2.36;
                this.metrics.stability = 94;
                this.metrics.coherence = 0.62;
                
                this.updateMetricsDisplay();
                
                // Reset calm after a delay
                setTimeout(() => {
                    this.config.calm = false;
                }, 3000);
            }
            
            updateMetricsDisplay() {
                document.getElementById('energyValue').textContent = this.metrics.energy.toFixed(2);
                document.getElementById('stabilityValue').textContent = this.metrics.stability + '%';
                document.getElementById('coherenceValue').textContent = this.metrics.coherence.toFixed(2);
                document.getElementById('nodesValue').textContent = this.metrics.nodes;
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
                    
                    // Calculate wave effect from nodes
                    let waveEffect = 0;
                    for (let node of this.nodes) {
                        const nodeDx = point.baseX - node.x;
                        const nodeDy = point.baseY - node.y;
                        const nodeDistance = Math.sqrt(nodeDx*nodeDx + nodeDy*nodeDy);
                        
                        waveEffect += Math.sin(nodeDistance / node.radius - time * node.speed + node.phase) *
                                     (node.radius / (nodeDistance + 1)) * 8;
                    }
                    
                    // Calculate dimensionality effect
                    const dimensionEffect = Math.sin(time * 0.3 + point.phase) * 
                                          Math.cos(time * 0.5 + point.phase) *
                                          this.config.dimensionality * 0.1;
                    
                    // Calculate harmonicity effect
                    const harmonicityEffect = Math.sin(time * point.frequency + point.phase) * 
                                            this.config.harmonicity * 3;
                    
                    // Calculate symmetry effect
                    const symmetryEffect = Math.sin(distance * 0.01 - time * 0.4) * 
                                         (this.config.symmetry / 10) * 4;
                    
                    // Calculate resonance effect
                    const resonanceEffect = this.config.resonance > 0 ? 
                        Math.sin(time * 4) * Math.cos(distance * 0.02 - time * 1.5) * this.config.resonance * 15 : 0;
                    
                    // Calculate calm effect
                    const calmEffect = this.config.calm ? 
                        Math.sin(time * 0.2) * 2 : 0;
                    
                    // Combine all effects
                    const totalEffect = waveEffect + dimensionEffect + harmonicityEffect + 
                                      symmetryEffect + resonanceEffect - calmEffect;
                    
                    // Apply the effect to the point position
                    point.x = point.baseX + Math.cos(point.phase) * totalEffect;
                    point.y = point.baseY + Math.sin(point.phase) * totalEffect;
                }
                
                // Update nodes
                for (let node of this.nodes) {
                    node.x += Math.sin(time * 0.1 + node.phase) * 0.3;
                    node.y += Math.cos(time * 0.1 + node.phase) * 0.3;
                    
                    // Wrap around edges
                    if (node.x < 0) node.x = width;
                    if (node.x > width) node.x = 0;
                    if (node.y < 0) node.y = height;
                    if (node.y > height) node.y = 0;
                }
                
                // Gradually reduce resonance
                if (this.config.resonance > 0) {
                    this.config.resonance -= 0.003;
                    if (this.config.resonance < 0) this.config.resonance = 0;
                    
                    // Update metrics as resonance fades
                    this.metrics.energy = 4.72 + (this.config.resonance * 3.13);
                    this.metrics.stability = 86 - (this.config.resonance * 14);
                    this.metrics.coherence = 0.78 + (this.config.resonance * 0.14);
                    
                    this.updateMetricsDisplay();
                }
            }
            
            drawField() {
                const ctx = this.mainCtx;
                const width = this.mainCanvas.width;
                const height = this.mainCanvas.height;
                
                // Clear canvas with soft pastel background
                ctx.fillStyle = 'rgba(245, 247, 250, 0.3)';
                ctx.fillRect(0, 0, width, height);
                
                // Draw field connections
                for (let i = 0; i < this.field.length; i++) {
                    const point = this.field[i];
                    
                    // Draw connections to neighbors
                    if (i % 20 !== 0) { // Not the first in row
                        const prevPoint = this.field[i-1];
                        this.drawConnection(ctx, point, prevPoint);
                    }
                    
                    if (i >= 20) { // Not the first row
                        const abovePoint = this.field[i-20];
                        this.drawConnection(ctx, point, abovePoint);
                    }
                }
                
                // Draw field points
                for (let point of this.field) {
                    // Calculate color based on position and time
                    const hue = (point.x / width * 60 + 200 + this.config.time * 5) % 360;
                    
                    ctx.beginPath();
                    ctx.arc(point.x, point.y, 1.2, 0, Math.PI * 2);
                    ctx.fillStyle = `hsla(${hue}, 30%, 75%, 0.7)`;
                    ctx.fill();
                }
                
                // Draw nodes
                for (let node of this.nodes) {
                    ctx.beginPath();
                    ctx.arc(node.x, node.y, node.radius, 0, Math.PI * 2);
                    ctx.strokeStyle = `${node.color}80`; // 50% opacity
                    ctx.lineWidth = 1.5;
                    ctx.stroke();
                    
                    // Draw node center
                    ctx.beginPath();
                    ctx.arc(node.x, node.y, 3, 0, Math.PI * 2);
                    ctx.fillStyle = node.color;
                    ctx.fill();
                }
            }
            
            drawConnection(ctx, point1, point2) {
                const dx = point1.x - point2.x;
                const dy = point1.y - point2.y;
                const distance = Math.sqrt(dx*dx + dy*dy);
                
                if (distance < 60) { // Only draw connections for nearby points
                    const opacity = 1 - (distance / 60);
                    ctx.beginPath();
                    ctx.moveTo(point1.x, point1.y);
                    ctx.lineTo(point2.x, point2.y);
                    ctx.strokeStyle = `rgba(180, 200, 220, ${opacity * 0.3})`;
                    ctx.lineWidth = 0.8;
                    ctx.stroke();
                }
            }
            
            drawBackground() {
                const ctx = this.bgCtx;
                const width = this.bgCanvas.width;
                const height = this.bgCanvas.height;
                
                // Clear background
                ctx.fillStyle = '#f5f7fa';
                ctx.fillRect(0, 0, width, height);
                
                // Draw soft background elements
                const time = this.config.time * 0.3;
                
                for (let i = 0; i < 50; i++) {
                    const x = Math.random() * width;
                    const y = Math.random() * height;
                    const size = 2 + Math.random() * 4;
                    
                    const hue = (time * 5 + x / width * 30) % 360;
                    
                    ctx.beginPath();
                    ctx.arc(x, y, size, 0, Math.PI * 2);
                    ctx.fillStyle = `hsla(${hue}, 20%, 80%, 0.1)`;
                    ctx.fill();
                }
            }
            
            animate() {
                // Update time
                this.config.time += 0.03;
                
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
            const visualizer = new HarmonicResonance();
            
            // Expose to global scope for debugging
            window.harmonicVisualizer = visualizer;
        });
    </script>
</body>
</html>