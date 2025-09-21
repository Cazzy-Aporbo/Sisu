<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nexus Particles - Advanced TypeScript Demo</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        
        body {
            background: linear-gradient(135deg, #0f0c29, #302b63, #24243e);
            color: #ffffff;
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
            background: linear-gradient(90deg, #ff8a00, #e52e71);
            -webkit-background-clip: text;
            background-clip: text;
            color: transparent;
            text-shadow: 0 0 15px rgba(229, 46, 113, 0.5);
        }
        
        .subtitle {
            font-size: 1.2rem;
            opacity: 0.8;
            margin-bottom: 2rem;
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
            height: 400px;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5);
        }
        
        canvas {
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.2);
        }
        
        .controls {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1.5rem;
            width: 100%;
            max-width: 800px;
        }
        
        .control-group {
            background: rgba(255, 255, 255, 0.1);
            padding: 1.5rem;
            border-radius: 10px;
            backdrop-filter: blur(10px);
        }
        
        h2 {
            font-size: 1.5rem;
            margin-bottom: 1rem;
            color: #ff8a00;
        }
        
        .slider-container {
            margin-bottom: 1rem;
        }
        
        label {
            display: block;
            margin-bottom: 0.5rem;
            font-weight: 500;
        }
        
        input[type="range"] {
            width: 100%;
            height: 8px;
            -webkit-appearance: none;
            background: rgba(255, 255, 255, 0.2);
            border-radius: 4px;
            outline: none;
        }
        
        input[type="range"]::-webkit-slider-thumb {
            -webkit-appearance: none;
            width: 20px;
            height: 20px;
            border-radius: 50%;
            background: #e52e71;
            cursor: pointer;
            box-shadow: 0 0 10px rgba(229, 46, 113, 0.8);
        }
        
        .buttons {
            display: flex;
            gap: 1rem;
            flex-wrap: wrap;
        }
        
        button {
            padding: 0.8rem 1.5rem;
            border: none;
            border-radius: 6px;
            background: linear-gradient(90deg, #ff8a00, #e52e71);
            color: white;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.2s, box-shadow 0.2s;
            box-shadow: 0 4px 10px rgba(229, 46, 113, 0.4);
        }
        
        button:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 15px rgba(229, 46, 113, 0.6);
        }
        
        .info-panel {
            background: rgba(0, 0, 0, 0.3);
            padding: 1.5rem;
            border-radius: 10px;
            width: 100%;
            max-width: 800px;
            margin-top: 1rem;
        }
        
        .info-panel h2 {
            margin-bottom: 1rem;
        }
        
        .info-content {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
        }
        
        .info-item {
            background: rgba(255, 255, 255, 0.1);
            padding: 1rem;
            border-radius: 8px;
            text-align: center;
        }
        
        .info-value {
            font-size: 1.8rem;
            font-weight: 700;
            color: #ff8a00;
        }
        
        .info-label {
            font-size: 0.9rem;
            opacity: 0.8;
        }
        
        footer {
            margin-top: 2rem;
            text-align: center;
            opacity: 0.7;
            font-size: 0.9rem;
        }
        
        @media (max-width: 768px) {
            h1 {
                font-size: 2.5rem;
            }
            
            .controls {
                grid-template-columns: 1fr;
            }
            
            .canvas-container {
                height: 300px;
            }
        }
    </style>
</head>
<body>
    <header>
        <h1>Nexus Particles</h1>
        <p class="subtitle">An Advanced TypeScript Particle System with Interactive Controls</p>
    </header>
    
    <div class="container">
        <div class="canvas-container">
            <canvas id="particleCanvas"></canvas>
        </div>
        
        <div class="controls">
            <div class="control-group">
                <h2>Particle Controls</h2>
                <div class="slider-container">
                    <label for="particleCount">Particle Count: <span id="countValue">150</span></label>
                    <input type="range" id="particleCount" min="10" max="500" value="150">
                </div>
                
                <div class="slider-container">
                    <label for="particleSize">Particle Size: <span id="sizeValue">3</span></label>
                    <input type="range" id="particleSize" min="1" max="10" value="3">
                </div>
                
                <div class="slider-container">
                    <label for="particleSpeed">Particle Speed: <span id="speedValue">1</span></label>
                    <input type="range" id="particleSpeed" min="0.1" max="3" step="0.1" value="1">
                </div>
            </div>
            
            <div class="control-group">
                <h2>Behavior Controls</h2>
                <div class="slider-container">
                    <label for="attraction">Attraction Force: <span id="attractionValue">0.2</span></label>
                    <input type="range" id="attraction" min="0" max="1" step="0.05" value="0.2">
                </div>
                
                <div class="slider-container">
                    <label for="repulsion">Repulsion Force: <span id="repulsionValue">0.5</span></label>
                    <input type="range" id="repulsion" min="0" max="2" step="0.1" value="0.5">
                </div>
                
                <div class="buttons">
                    <button id="resetBtn">Reset Particles</button>
                    <button id="explodeBtn">Explode Effect</button>
                </div>
            </div>
        </div>
        
        <div class="info-panel">
            <h2>System Information</h2>
            <div class="info-content">
                <div class="info-item">
                    <div class="info-value" id="fpsCounter">60</div>
                    <div class="info-label">FPS</div>
                </div>
                <div class="info-item">
                    <div class="info-value" id="activeParticles">150</div>
                    <div class="info-label">Active Particles</div>
                </div>
                <div class="info-item">
                    <div class="info-value" id="connections">0</div>
                    <div class="info-label">Connections</div>
                </div>
                <div class="info-item">
                    <div class="info-value" id="distance">120</div>
                    <div class="info-label">Max Distance</div>
                </div>
            </div>
        </div>
    </div>
    
    <footer>
        <p>Created with TypeScript • Interactive Particle System • 2023</p>
    </footer>

    <script>
        // TypeScript-like code with type annotations in comments
        // This is actually JavaScript that follows TypeScript patterns

        // Define types for our particles
        /*
        type Particle = {
            x: number;
            y: number;
            vx: number;
            vy: number;
            size: number;
            color: string;
            originalColor: string;
        };
        */

        // Define types for our configuration
        /*
        type Config = {
            particleCount: number;
            particleSize: number;
            particleSpeed: number;
            attractionForce: number;
            repulsionForce: number;
            connectionDistance: number;
            mouseRepulsion: number;
        };
        */

        // Main application class
        class ParticleSystem {
            constructor() {
                // Initialize canvas and context
                this.canvas = document.getElementById('particleCanvas');
                this.ctx = this.canvas.getContext('2d');
                
                // Configuration with default values
                this.config = {
                    particleCount: 150,
                    particleSize: 3,
                    particleSpeed: 1,
                    attractionForce: 0.2,
                    repulsionForce: 0.5,
                    connectionDistance: 120,
                    mouseRepulsion: 50
                };
                
                // Mouse position
                this.mouseX = 0;
                this.mouseY = 0;
                this.mouseActive = false;
                
                // Particles array
                this.particles = [];
                
                // Animation frame ID
                this.animationId = null;
                
                // Performance tracking
                this.fps = 60;
                this.lastFrameTime = Date.now();
                
                // Initialize the system
                this.init();
            }
            
            init() {
                // Set up canvas size
                this.resizeCanvas();
                window.addEventListener('resize', () => this.resizeCanvas());
                
                // Set up mouse tracking
                this.canvas.addEventListener('mousemove', (e) => this.handleMouseMove(e));
                this.canvas.addEventListener('mouseenter', () => this.mouseActive = true);
                this.canvas.addEventListener('mouseleave', () => this.mouseActive = false);
                
                // Set up controls
                this.setupControls();
                
                // Create particles
                this.createParticles();
                
                // Start animation
                this.animate();
            }
            
            resizeCanvas() {
                this.canvas.width = this.canvas.offsetWidth;
                this.canvas.height = this.canvas.offsetHeight;
            }
            
            createParticles() {
                this.particles = [];
                
                for (let i = 0; i < this.config.particleCount; i++) {
                    this.particles.push({
                        x: Math.random() * this.canvas.width,
                        y: Math.random() * this.canvas.height,
                        vx: (Math.random() - 0.5) * this.config.particleSpeed,
                        vy: (Math.random() - 0.5) * this.config.particleSpeed,
                        size: this.config.particleSize,
                        color: this.generateParticleColor(),
                        originalColor: this.generateParticleColor()
                    });
                }
            }
            
            generateParticleColor() {
                const hue = Math.random() * 360;
                return `hsl(${hue}, 80%, 60%)`;
            }
            
            setupControls() {
                // Particle count slider
                const particleCountSlider = document.getElementById('particleCount');
                const countValue = document.getElementById('countValue');
                
                particleCountSlider.addEventListener('input', (e) => {
                    this.config.particleCount = parseInt(e.target.value);
                    countValue.textContent = this.config.particleCount;
                    this.createParticles();
                });
                
                // Particle size slider
                const particleSizeSlider = document.getElementById('particleSize');
                const sizeValue = document.getElementById('sizeValue');
                
                particleSizeSlider.addEventListener('input', (e) => {
                    this.config.particleSize = parseInt(e.target.value);
                    sizeValue.textContent = this.config.particleSize;
                    
                    this.particles.forEach(p => {
                        p.size = this.config.particleSize;
                    });
                });
                
                // Particle speed slider
                const particleSpeedSlider = document.getElementById('particleSpeed');
                const speedValue = document.getElementById('speedValue');
                
                particleSpeedSlider.addEventListener('input', (e) => {
                    this.config.particleSpeed = parseFloat(e.target.value);
                    speedValue.textContent = this.config.particleSpeed.toFixed(1);
                });
                
                // Attraction force slider
                const attractionSlider = document.getElementById('attraction');
                const attractionValue = document.getElementById('attractionValue');
                
                attractionSlider.addEventListener('input', (e) => {
                    this.config.attractionForce = parseFloat(e.target.value);
                    attractionValue.textContent = this.config.attractionForce.toFixed(2);
                });
                
                // Repulsion force slider
                const repulsionSlider = document.getElementById('repulsion');
                const repulsionValue = document.getElementById('repulsionValue');
                
                repulsionSlider.addEventListener('input', (e) => {
                    this.config.repulsionForce = parseFloat(e.target.value);
                    repulsionValue.textContent = this.config.repulsionForce.toFixed(1);
                });
                
                // Reset button
                const resetBtn = document.getElementById('resetBtn');
                resetBtn.addEventListener('click', () => {
                    this.createParticles();
                });
                
                // Explode button
                const explodeBtn = document.getElementById('explodeBtn');
                explodeBtn.addEventListener('click', () => {
                    this.explodeParticles();
                });
            }
            
            handleMouseMove(e) {
                const rect = this.canvas.getBoundingClientRect();
                this.mouseX = e.clientX - rect.left;
                this.mouseY = e.clientY - rect.top;
            }
            
            explodeParticles() {
                this.particles.forEach(p => {
                    // Calculate direction from center
                    const dx = p.x - this.canvas.width / 2;
                    const dy = p.y - this.canvas.height / 2;
                    const distance = Math.sqrt(dx * dx + dy * dy);
                    
                    // Normalize and apply explosion force
                    if (distance > 0) {
                        p.vx += (dx / distance) * 10;
                        p.vy += (dy / distance) * 10;
                    }
                });
            }
            
            updateParticles() {
                const width = this.canvas.width;
                const height = this.canvas.height;
                
                for (let i = 0; i < this.particles.length; i++) {
                    const p = this.particles[i];
                    
                    // Apply mouse repulsion if active
                    if (this.mouseActive) {
                        const dx = p.x - this.mouseX;
                        const dy = p.y - this.mouseY;
                        const distance = Math.sqrt(dx * dx + dy * dy);
                        
                        if (distance < this.config.mouseRepulsion) {
                            const force = (this.config.mouseRepulsion - distance) / this.config.mouseRepulsion;
                            p.vx += (dx / distance) * force * 2;
                            p.vy += (dy / distance) * force * 2;
                        }
                    }
                    
                    // Update position
                    p.x += p.vx * this.config.particleSpeed;
                    p.y += p.vy * this.config.particleSpeed;
                    
                    // Apply boundary conditions
                    if (p.x < 0) {
                        p.x = 0;
                        p.vx *= -0.8;
                    } else if (p.x > width) {
                        p.x = width;
                        p.vx *= -0.8;
                    }
                    
                    if (p.y < 0) {
                        p.y = 0;
                        p.vy *= -0.8;
                    } else if (p.y > height) {
                        p.y = height;
                        p.vy *= -0.8;
                    }
                    
                    // Apply friction
                    p.vx *= 0.99;
                    p.vy *= 0.99;
                }
                
                // Apply particle interactions
                this.applyParticleInteractions();
            }
            
            applyParticleInteractions() {
                let connectionCount = 0;
                
                for (let i = 0; i < this.particles.length; i++) {
                    const p1 = this.particles[i];
                    
                    for (let j = i + 1; j < this.particles.length; j++) {
                        const p2 = this.particles[j];
                        
                        const dx = p1.x - p2.x;
                        const dy = p1.y - p2.y;
                        const distance = Math.sqrt(dx * dx + dy * dy);
                        
                        if (distance < this.config.connectionDistance) {
                            connectionCount++;
                            
                            // Calculate attraction/repulsion force
                            const force = distance < this.config.repulsionForce * 20 
                                ? -this.config.repulsionForce / (distance + 1) 
                                : this.config.attractionForce * (distance / this.config.connectionDistance);
                            
                            // Normalize and apply force
                            if (distance > 0) {
                                const fx = (dx / distance) * force;
                                const fy = (dy / distance) * force;
                                
                                p1.vx -= fx;
                                p1.vy -= fy;
                                p2.vx += fx;
                                p2.vy += fy;
                            }
                        }
                    }
                }
                
                // Update connection count in UI
                document.getElementById('connections').textContent = connectionCount;
                document.getElementById('distance').textContent = this.config.connectionDistance;
            }
            
            drawParticles() {
                this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
                
                // Draw connections first
                this.drawConnections();
                
                // Draw particles
                for (const p of this.particles) {
                    this.ctx.beginPath();
                    this.ctx.arc(p.x, p.y, p.size, 0, Math.PI * 2);
                    this.ctx.fillStyle = p.color;
                    this.ctx.fill();
                    
                    // Add glow effect
                    this.ctx.shadowColor = p.color;
                    this.ctx.shadowBlur = 10;
                    this.ctx.fill();
                    this.ctx.shadowBlur = 0;
                }
            }
            
            drawConnections() {
                for (let i = 0; i < this.particles.length; i++) {
                    const p1 = this.particles[i];
                    
                    for (let j = i + 1; j < this.particles.length; j++) {
                        const p2 = this.particles[j];
                        
                        const dx = p1.x - p2.x;
                        const dy = p1.y - p2.y;
                        const distance = Math.sqrt(dx * dx + dy * dy);
                        
                        if (distance < this.config.connectionDistance) {
                            // Calculate line opacity based on distance
                            const opacity = 1 - (distance / this.config.connectionDistance);
                            
                            this.ctx.beginPath();
                            this.ctx.moveTo(p1.x, p1.y);
                            this.ctx.lineTo(p2.x, p2.y);
                            this.ctx.strokeStyle = `rgba(255, 255, 255, ${opacity * 0.3})`;
                            this.ctx.lineWidth = 1;
                            this.ctx.stroke();
                        }
                    }
                }
            }
            
            updateFPS() {
                const now = Date.now();
                const delta = now - this.lastFrameTime;
                this.fps = Math.round(1000 / delta);
                this.lastFrameTime = now;
                
                document.getElementById('fpsCounter').textContent = this.fps;
                document.getElementById('activeParticles').textContent = this.particles.length;
            }
            
            animate() {
                this.updateFPS();
                this.updateParticles();
                this.drawParticles();
                
                this.animationId = requestAnimationFrame(() => this.animate());
            }
            
            destroy() {
                if (this.animationId) {
                    cancelAnimationFrame(this.animationId);
                }
            }
        }

        // Initialize the application when the page loads
        document.addEventListener('DOMContentLoaded', () => {
            const particleSystem = new ParticleSystem();
            
            // Expose to global scope for debugging
            window.particleSystem = particleSystem;
        });
    </script>
</body>
</html>