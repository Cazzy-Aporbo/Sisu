/*
 * =========================================================
 * SISU — Era Transitions
 * =========================================================
 * 
 * DENSITY:     ████████░░  [8/10]
 * ENDURANCE:   █████████░  [9/10]  
 * ABSTRACTION: ███████░░░  [7/10]
 *
 * COLOR PHASE: #34D399 (Canopy - JavaScript's natural habitat)
 *
 * Historical Context:
 *   Born from: Netscape JavaScript, 1995
 *   Survived:  Browser wars, Node revolution, framework chaos
 *   Evolves:   Into everything, remains itself
 *
 * Compression Ratio: 70 years : 700 lines
 *
 * =========================================================
 */

// The Sisu color spectrum encoded
const SISU_SPECTRUM = {
  // Core greens
  whisper: '#F0FDF4',
  emergence: '#ECFDF5',
  dawn: '#DCFCE7',
  seed: '#D4FFE4',
  tender: '#C6F7E2',
  spring: '#BBF7D0',
  primary: '#A7F3D0',  // The heartbeat
  vitality: '#94F2C2',
  chlorophyll: '#86EFAC',
  verdant: '#73E9A0',
  peak: '#6EE7B7',     // Maximum green
  forest: '#5CE1A6',
  deep: '#4ADE80',
  canopy: '#34D399',
  pine: '#22C55E',
  ancient: '#16A34A',
  moss: '#15803D',
  shadow: '#166534',
  floor: '#14532D',
  root: '#0F462A',
  void: '#052E16',
  
  // Aquatic bridge
  mintcream: '#F5FFFA',
  springgreen: '#00FF7F',
  mediumspring: '#00FA9A',
  seagreen: '#2E8B57',
  mediumsea: '#3CB371',
  aquamarine: '#7FFFD4',
  turquoise: '#40E0D0',
  lightsea: '#20B2AA',
  teal: '#008080',
  darkcyan: '#008B8B'
};

// Era definitions with their color phases
const ERAS = [
  { year: 1950, color: SISU_SPECTRUM.void, name: 'Assembly Age' },
  { year: 1960, color: SISU_SPECTRUM.floor, name: 'FORTRAN Dawn' },
  { year: 1970, color: SISU_SPECTRUM.shadow, name: 'C Revolution' },
  { year: 1980, color: SISU_SPECTRUM.ancient, name: 'Object Orientation' },
  { year: 1990, color: SISU_SPECTRUM.pine, name: 'Web Emergence' },
  { year: 2000, color: SISU_SPECTRUM.canopy, name: 'Dynamic Era' },
  { year: 2010, color: SISU_SPECTRUM.deep, name: 'Concurrent Paradigm' },
  { year: 2020, color: SISU_SPECTRUM.peak, name: 'ML Explosion' },
  { year: 2024, color: SISU_SPECTRUM.primary, name: 'Quantum Horizon' }
];

/**
 * Convert hex to RGB
 * Survived since: IE6 compatibility hacks
 */
function hexToRgb(hex) {
  const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
  return result ? {
    r: parseInt(result[1], 16),
    g: parseInt(result[2], 16),
    b: parseInt(result[3], 16)
  } : null;
}

/**
 * Interpolate between two colors
 * The foundation of all gradients
 */
function interpolateColor(color1, color2, factor) {
  const c1 = hexToRgb(color1);
  const c2 = hexToRgb(color2);
  
  const r = Math.round(c1.r + (c2.r - c1.r) * factor);
  const g = Math.round(c1.g + (c2.g - c1.g) * factor);
  const b = Math.round(c1.b + (c2.b - c1.b) * factor);
  
  return `rgb(${r}, ${g}, ${b})`;
}

/**
 * The breathing function
 * Mimics human respiration: 4-7-8 pattern
 */
function breathe(element, fromColor, toColor) {
  const INHALE = 4000;   // 4 seconds
  const HOLD = 7000;     // 7 seconds  
  const EXHALE = 8000;   // 8 seconds
  
  let startTime = null;
  let phase = 'inhale';
  
  function animate(timestamp) {
    if (!startTime) startTime = timestamp;
    const elapsed = timestamp - startTime;
    
    let factor = 0;
    
    if (phase === 'inhale' && elapsed < INHALE) {
      // Inhaling: whisper to peak
      factor = elapsed / INHALE;
      element.style.backgroundColor = interpolateColor(fromColor, toColor, factor);
    } else if (phase === 'inhale') {
      phase = 'hold';
      startTime = timestamp;
    } else if (phase === 'hold' && elapsed < HOLD) {
      // Holding: stay at peak
      element.style.backgroundColor = toColor;
    } else if (phase === 'hold') {
      phase = 'exhale';
      startTime = timestamp;
    } else if (phase === 'exhale' && elapsed < EXHALE) {
      // Exhaling: peak to void
      factor = 1 - (elapsed / EXHALE);
      element.style.backgroundColor = interpolateColor(fromColor, toColor, factor);
    } else {
      // Reset cycle
      phase = 'inhale';
      startTime = timestamp;
    }
    
    requestAnimationFrame(animate);
  }
  
  requestAnimationFrame(animate);
}

/**
 * Timeline morphing animation
 * Shows the compression of 70 years
 */
class Timeline {
  constructor(container) {
    this.container = container;
    this.currentEra = 0;
    this.isTransitioning = false;
  }
  
  /**
   * Render the timeline
   */
  render() {
    this.container.innerHTML = '';
    
    ERAS.forEach((era, index) => {
      const node = document.createElement('div');
      node.className = 'era-node';
      node.style.backgroundColor = era.color;
      node.style.width = '100px';
      node.style.height = '100px';
      node.style.display = 'inline-block';
      node.style.margin = '10px';
      node.style.transition = 'all 1s ease';
      node.style.cursor = 'pointer';
      
      const label = document.createElement('div');
      label.textContent = `${era.year}`;
      label.style.textAlign = 'center';
      label.style.color = this.getContrastColor(era.color);
      node.appendChild(label);
      
      const name = document.createElement('div');
      name.textContent = era.name;
      name.style.fontSize = '10px';
      name.style.textAlign = 'center';
      name.style.color = this.getContrastColor(era.color);
      node.appendChild(name);
      
      node.addEventListener('click', () => this.transitionToEra(index));
      
      this.container.appendChild(node);
    });
  }
  
  /**
   * Get contrasting text color
   */
  getContrastColor(hex) {
    const rgb = hexToRgb(hex);
    const luminance = (0.299 * rgb.r + 0.587 * rgb.g + 0.114 * rgb.b) / 255;
    return luminance > 0.5 ? '#052E16' : '#F0FDF4';
  }
  
  /**
   * Transition to specific era
   */
  transitionToEra(index) {
    if (this.isTransitioning) return;
    this.isTransitioning = true;
    
    const fromColor = ERAS[this.currentEra].color;
    const toColor = ERAS[index].color;
    
    // Morph background
    this.morphBackground(fromColor, toColor);
    
    // Update current era
    this.currentEra = index;
    
    setTimeout(() => {
      this.isTransitioning = false;
    }, 2000);
  }
  
  /**
   * Morph the background color
   */
  morphBackground(from, to) {
    const steps = 60;
    const duration = 2000;
    const stepTime = duration / steps;
    
    let step = 0;
    const interval = setInterval(() => {
      const factor = step / steps;
      document.body.style.backgroundColor = interpolateColor(from, to, factor);
      
      step++;
      if (step > steps) {
        clearInterval(interval);
      }
    }, stepTime);
  }
  
  /**
   * Auto-play through eras
   */
  autoPlay() {
    setInterval(() => {
      const nextEra = (this.currentEra + 1) % ERAS.length;
      this.transitionToEra(nextEra);
    }, 5000);
  }
}

/**
 * Compression visualization
 * Shows how code compresses over time
 */
class CompressionVisualizer {
  constructor(canvas) {
    this.canvas = canvas;
    this.ctx = canvas.getContext('2d');
    this.particles = [];
    this.init();
  }
  
  init() {
    // Create particles representing code
    for (let i = 0; i < 1000; i++) {
      this.particles.push({
        x: Math.random() * this.canvas.width,
        y: Math.random() * this.canvas.height,
        vx: (Math.random() - 0.5) * 0.5,
        vy: (Math.random() - 0.5) * 0.5,
        color: Object.values(SISU_SPECTRUM)[Math.floor(Math.random() * 21)],
        size: Math.random() * 3 + 1
      });
    }
  }
  
  compress() {
    // Gradually move particles toward center
    const centerX = this.canvas.width / 2;
    const centerY = this.canvas.height / 2;
    
    this.particles.forEach(particle => {
      const dx = centerX - particle.x;
      const dy = centerY - particle.y;
      
      particle.vx += dx * 0.0001;
      particle.vy += dy * 0.0001;
      
      // Apply friction (compression resistance)
      particle.vx *= 0.99;
      particle.vy *= 0.99;
      
      // Update position
      particle.x += particle.vx;
      particle.y += particle.vy;
      
      // Shrink size (compression)
      particle.size *= 0.999;
    });
  }
  
  render() {
    // Clear with slight trail effect
    this.ctx.fillStyle = 'rgba(5, 46, 22, 0.05)'; // Void green with transparency
    this.ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);
    
    // Draw particles
    this.particles.forEach(particle => {
      this.ctx.beginPath();
      this.ctx.arc(particle.x, particle.y, particle.size, 0, Math.PI * 2);
      this.ctx.fillStyle = particle.color;
      this.ctx.fill();
    });
  }
  
  animate() {
    this.compress();
    this.render();
    requestAnimationFrame(() => this.animate());
  }
}

/**
 * Matrix rain effect with Sisu colors
 * Because every programming visualization needs matrix rain
 */
class SisuMatrix {
  constructor(canvas) {
    this.canvas = canvas;
    this.ctx = canvas.getContext('2d');
    this.columns = Math.floor(canvas.width / 20);
    this.drops = [];
    
    for (let i = 0; i < this.columns; i++) {
      this.drops[i] = Math.random() * canvas.height;
    }
  }
  
  rain() {
    // Fade effect
    this.ctx.fillStyle = 'rgba(5, 46, 22, 0.05)';
    this.ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);
    
    this.ctx.font = '15px monospace';
    
    for (let i = 0; i < this.drops.length; i++) {
      // Use gradient of greens
      const greenIndex = Math.floor((this.drops[i] / this.canvas.height) * 21);
      this.ctx.fillStyle = Object.values(SISU_SPECTRUM)[greenIndex];
      
      // Random character (binary or hex)
      const char = Math.random() > 0.5 ? 
        Math.floor(Math.random() * 2) : 
        Math.floor(Math.random() * 16).toString(16).toUpperCase();
      
      this.ctx.fillText(char, i * 20, this.drops[i]);
      
      if (this.drops[i] > this.canvas.height && Math.random() > 0.975) {
        this.drops[i] = 0;
      }
      
      this.drops[i] += 20;
    }
  }
  
  animate() {
    this.rain();
    requestAnimationFrame(() => this.animate());
  }
}

/**
 * Initialize on DOM ready
 */
document.addEventListener('DOMContentLoaded', () => {
  // Initialize breathing on body
  breathe(document.body, SISU_SPECTRUM.whisper, SISU_SPECTRUM.void);
  
  // Initialize timeline if container exists
  const timelineContainer = document.getElementById('timeline');
  if (timelineContainer) {
    const timeline = new Timeline(timelineContainer);
    timeline.render();
    // timeline.autoPlay(); // Uncomment for auto-progression
  }
  
  // Initialize compression visualizer if canvas exists
  const compressionCanvas = document.getElementById('compression-canvas');
  if (compressionCanvas) {
    const compressor = new CompressionVisualizer(compressionCanvas);
    compressor.animate();
  }
  
  // Initialize matrix rain if canvas exists
  const matrixCanvas = document.getElementById('matrix-canvas');
  if (matrixCanvas) {
    const matrix = new SisuMatrix(matrixCanvas);
    matrix.animate();
  }
});

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
  module.exports = {
    SISU_SPECTRUM,
    ERAS,
    Timeline,
    CompressionVisualizer,
    SisuMatrix,
    breathe,
    interpolateColor
  };
}

// The compression: 70 years of UI evolution in one file
// This will survive because movement is eternal
