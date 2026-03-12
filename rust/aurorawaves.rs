/*
 * AURORA: Submersible Fractal Waves with Vibrational Color Bursts
 * 
 * An advanced fractal explorer with fluid dynamics, wave simulation,
 * and immersive color effects that respond to user interaction.
 */

use minifb::{Window, WindowOptions, Key, MouseButton, MouseMode};
use num_complex::Complex64;
use std::time::{Instant, Duration};
use palette::{Hsv, Srgb, LinSrgb, FromColor};
use rayon::prelude::*;
use std::f64::consts::PI;

// 1. ENHANCED FRACTAL ENGINE WITH WAVE DYNAMICS

/// Fractal type with wave parameters
#[derive(Debug, Clone, Copy, PartialEq)]
enum FractalType {
    Mandelbrot { wave_amplitude: f64, wave_frequency: f64 },
    Julia { c: Complex64, turbulence: f64 },
    BurningShip { wave_phase: f64 },
    Newton { roots: Vec<Complex64> },
}

/// Enhanced fractal configuration with wave effects
#[derive(Debug, Clone)]
struct FractalConfig {
    fractal_type: FractalType,
    max_iterations: u32,
    escape_radius: f64,
    center: Complex64,
    scale: f64,
    color_offset: f64,
    color_stretch: f64,
    time: f64,
    wave_speed: f64,
    vibration_intensity: f64,
    immersion_depth: f64,
    color_burst: bool,
    burst_intensity: f64,
    burst_center: Complex64,
    burst_radius: f64,
}

impl Default for FractalConfig {
    fn default() -> Self {
        Self {
            fractal_type: FractalType::Mandelbrot { 
                wave_amplitude: 0.1, 
                wave_frequency: 2.0 
            },
            max_iterations: 100,
            escape_radius: 4.0,
            center: Complex64::new(0.0, 0.0),
            scale: 3.0,
            color_offset: 0.0,
            color_stretch: 0.1,
            time: 0.0,
            wave_speed: 1.0,
            vibration_intensity: 0.0,
            immersion_depth: 0.0,
            color_burst: false,
            burst_intensity: 0.0,
            burst_center: Complex64::new(0.0, 0.0),
            burst_radius: 0.5,
        }
    }
}

/// Calculate point with wave effects
fn calculate_point(c: Complex64, config: &FractalConfig) -> f64 {
    let wave_effect = match config.fractal_type {
        FractalType::Mandelbrot { wave_amplitude, wave_frequency } => {
            let wave = (config.time * wave_frequency + c.im * 5.0).sin() * wave_amplitude;
            Complex64::new(wave, 0.0)
        }
        FractalType::Julia { turbulence, .. } => {
            let turb = (c.re * 10.0 + config.time * 2.0).sin() * turbulence * 0.1;
            Complex64::new(turb, turb)
        }
        FractalType::BurningShip { wave_phase } => {
            let phase = config.time * 2.0 + wave_phase;
            Complex64::new((c.re + phase).sin() * 0.1, (c.im + phase).cos() * 0.1)
        }
        FractalType::Newton { .. } => Complex64::new(0.0, 0.0),
    };

    let mut z = match config.fractal_type {
        FractalType::Mandelbrot { .. } => Complex64::new(0.0, 0.0),
        FractalType::Julia { c: julia_c, .. } => c + wave_effect,
        FractalType::BurningShip { .. } => Complex64::new(0.0, 0.0),
        FractalType::Newton { .. } => c + wave_effect,
    };

    let c = match config.fractal_type {
        FractalType::Mandelbrot { .. } => c + wave_effect,
        FractalType::Julia { c: julia_c, .. } => julia_c,
        FractalType::BurningShip { .. } => c + wave_effect,
        FractalType::Newton { .. } => c,
    };

    let mut iteration = 0;
    
    // Handle different fractal types
    match config.fractal_type {
        FractalType::Mandelbrot { .. } | 
        FractalType::Julia { .. } => {
            while iteration < config.max_iterations && z.norm_sqr() < config.escape_radius * config.escape_radius {
                z = z * z + c;
                iteration += 1;
            }
        }
        FractalType::BurningShip { .. } => {
            while iteration < config.max_iterations && z.norm_sqr() < config.escape_radius * config.escape_radius {
                z = Complex64::new(z.re.abs(), z.im.abs());
                z = z * z + c;
                iteration += 1;
            }
        }
        FractalType::Newton { ref roots } => {
            while iteration < config.max_iterations && z.norm_sqr() < config.escape_radius * config.escape_radius {
                // Newton's method for polynomial roots
                let f = z.powi(3) - Complex64::new(1.0, 0.0);
                let df = Complex64::new(3.0, 0.0) * z.powi(2);
                
                if df.norm_sqr() == 0.0 {
                    break;
                }
                
                z = z - f / df;
                iteration += 1;
            }
            
            // Find closest root for coloring
            if let Some(closest) = roots.iter().min_by_key(|r| {
                ((z - **r).norm_sqr() * 1000.0) as i32
            }) {
                iteration = ((z - *closest).norm() * 10.0) as u32;
            }
        }
    }

    if iteration == config.max_iterations {
        iteration as f64
    } else {
        iteration as f64 - z.norm_sqr().log2().log2() + 1.0
    }
}

/// Generate immersive color with vibration and burst effects
fn iteration_to_color(iteration: f64, config: &FractalConfig, x: usize, y: usize) -> u32 {
    // Apply immersion effect (depth-based darkening)
    let depth_factor = 1.0 - config.immersion_depth * 0.5;
    
    // Apply vibration effect
    let vibration = if config.vibration_intensity > 0.0 {
        (config.time * 20.0 + x as f64 * 0.1 + y as f64 * 0.1).sin() * config.vibration_intensity
    } else {
        0.0
    };
    
    // Apply color burst effect
    let burst_effect = if config.color_burst {
        let dist_from_burst = (Complex64::new(
            x as f64 / config.burst_radius - config.burst_center.re,
            y as f64 / config.burst_radius - config.burst_center.im
        ).norm() * 10.0).min(1.0);
        
        let burst = (1.0 - dist_from_burst).powf(2.0) * config.burst_intensity;
        burst * (config.time * 5.0).sin().abs()
    } else {
        0.0
    };
    
    // Normalize iteration count with effects
    let t = ((iteration * config.color_stretch + config.color_offset + vibration + burst_effect) % 1.0).max(0.0);
    
    // Underwater color palette (blues and greens)
    let hue = (240.0 + t * 60.0) as f32; // Blue to green range
    let saturation = (0.7 + 0.3 * (config.time * 0.5).sin()) as f32;
    
    // Value decreases with depth, creating underwater effect
    let value = if iteration >= config.max_iterations as f64 {
        // Points in the set get ambient light from above
        0.1 + 0.1 * (1.0 - config.immersion_depth)
    } else {
        // Escape points get brighter based on iteration count
        (0.5 + 0.5 * t) * depth_factor
    } as f32;
    
    // Convert HSV to RGB
    let hsv = Hsv::new(hue, saturation, value);
    let rgb: Srgb = Srgb::from_color(hsv);
    
    // Convert to 32-bit RGB value
    let r = (rgb.red * 255.0) as u32;
    let g = (rgb.green * 255.0) as u32;
    let b = (rgb.blue * 255.0) as u32;
    
    (r << 16) | (g << 8) | b
}

/// Render the fractal with wave effects
fn render_fractal(width: usize, height: usize, config: &FractalConfig) -> Vec<u32> {
    let aspect_ratio = width as f64 / height as f64;
    let scale_x = config.scale / width as f64;
    let scale_y = config.scale / height as f64 * aspect_ratio;
    
    // Use Rayon for parallel rendering
    (0..height).into_par_iter().flat_map(|y| {
        (0..width).into_par_iter().map(move |x| {
            // Convert pixel coordinates to complex plane coordinates
            let re = (x as f64 - width as f64 / 2.0) * scale_x + config.center.re;
            let im = (y as f64 - height as f64 / 2.0) * scale_y + config.center.im;
            let c = Complex64::new(re, im);
            
            // Calculate iteration count and convert to color
            let iteration = calculate_point(c, config);
            iteration_to_color(iteration, config, x, y)
        })
    }).collect()
}

// 2. WAVE SIMULATION AND FLUID DYNAMICS

/// Wave simulation for surface effects
struct WaveSimulation {
    width: usize,
    height: usize,
    displacement: Vec<f64>,
    velocity: Vec<f64>,
    damping: f64,
    spread: f64,
}

impl WaveSimulation {
    fn new(width: usize, height: usize) -> Self {
        Self {
            width,
            height,
            displacement: vec![0.0; width * height],
            velocity: vec![0.0; width * height],
            damping: 0.96,
            spread: 0.25,
        }
    }
    
    fn add_disturbance(&mut self, x: usize, y: usize, intensity: f64) {
        if x < self.width && y < self.height {
            let index = y * self.width + x;
            self.velocity[index] += intensity;
        }
    }
    
    fn update(&mut self) {
        // First update velocities based on neighbor displacements
        for y in 1..self.height-1 {
            for x in 1..self.width-1 {
                let index = y * self.width + x;
                
                // Calculate wave propagation from neighbors
                let mut acceleration = 0.0;
                acceleration += self.displacement[index - 1] - self.displacement[index];
                acceleration += self.displacement[index + 1] - self.displacement[index];
                acceleration += self.displacement[index - self.width] - self.displacement[index];
                acceleration += self.displacement[index + self.width] - self.displacement[index];
                
                // Apply acceleration
                self.velocity[index] += acceleration * self.spread;
            }
        }
        
        // Then update displacements based on velocities
        for i in 0..self.displacement.len() {
            self.displacement[i] += self.velocity[i];
            self.velocity[i] *= self.damping;
            self.displacement[i] *= self.damping;
        }
    }
    
    fn get_displacement(&self, x: usize, y: usize) -> f64 {
        if x < self.width && y < self.height {
            self.displacement[y * self.width + x]
        } else {
            0.0
        }
    }
}

// 3. ENHANCED APPLICATION WITH WAVE EFFECTS

/// Main application state with wave simulation
struct Aurora {
    width: usize,
    height: usize,
    buffer: Vec<u32>,
    config: FractalConfig,
    wave_sim: WaveSimulation,
    last_update: Instant,
    frame_count: u64,
    show_waves: bool,
    auto_animate: bool,
}

impl Aurora {
    fn new(width: usize, height: usize) -> Self {
        let config = FractalConfig::default();
        let buffer = render_fractal(width, height, &config);
        let wave_sim = WaveSimulation::new(width / 4, height / 4); // Lower resolution for performance
        
        Self {
            width,
            height,
            buffer,
            config,
            wave_sim,
            last_update: Instant::now(),
            frame_count: 0,
            show_waves: true,
            auto_animate: true,
        }
    }
    
    /// Update wave simulation and fractal parameters
    fn update(&mut self) {
        let now = Instant::now();
        let delta_time = now.duration_since(self.last_update).as_secs_f64();
        self.last_update = now;
        
        // Update time for animations
        self.config.time += delta_time * self.config.wave_speed;
        
        // Auto-animate if enabled
        if self.auto_animate {
            self.config.color_offset += delta_time * 0.1;
            
            // Gentle wave motion
            if let FractalType::Mandelbrot { wave_amplitude, wave_frequency } = &mut self.config.fractal_type {
                *wave_amplitude = 0.1 + 0.05 * (self.config.time * 0.5).sin();
                *wave_frequency = 2.0 + 1.0 * (self.config.time * 0.3).sin();
            }
        }
        
        // Update wave simulation
        if self.show_waves {
            self.wave_sim.update();
            
            // Add random disturbances
            if self.frame_count % 30 == 0 {
                let x = rand::random::<usize>() % self.wave_sim.width;
                let y = rand::random::<usize>() % self.wave_sim.height;
                self.wave_sim.add_disturbance(x, y, 10.0);
            }
        }
        
        self.frame_count += 1;
    }
    
    /// Handle mouse input for interactions
    fn handle_mouse(&mut self, x: f64, y: f64, buttons: &[MouseButton]) {
        let left_pressed = buttons.contains(&MouseButton::Left);
        let right_pressed = buttons.contains(&MouseButton::Right);
        let middle_pressed = buttons.contains(&MouseButton::Middle);
        
        if left_pressed {
            // Create color burst at click position
            self.config.color_burst = true;
            self.config.burst_intensity = 1.0;
            self.config.burst_center = Complex64::new(
                (x / self.width as f64) * 2.0 - 1.0,
                (y / self.height as f64) * 2.0 - 1.0,
            );
            self.config.burst_radius = 0.3;
        }
        
        if right_pressed {
            // Add wave disturbance
            let sim_x = (x as usize * self.wave_sim.width) / self.width;
            let sim_y = (y as usize * self.wave_sim.height) / self.height;
            self.wave_sim.add_disturbance(sim_x, sim_y, 20.0);
        }
        
        if middle_pressed {
            // Adjust immersion depth
            self.config.immersion_depth = (y / self.height as f64).min(1.0).max(0.0);
        }
    }
    
    /// Handle keyboard input
    fn handle_key(&mut self, key: Key) {
        match key {
            Key::Up => {
                self.config.max_iterations += 10;
                println!("Iterations: {}", self.config.max_iterations);
            }
            Key::Down => {
                self.config.max_iterations = (self.config.max_iterations - 10).max(10);
                println!("Iterations: {}", self.config.max_iterations);
            }
            Key::Left => {
                self.config.vibration_intensity = (self.config.vibration_intensity - 0.1).max(0.0);
                println!("Vibration: {:.1}", self.config.vibration_intensity);
            }
            Key::Right => {
                self.config.vibration_intensity = (self.config.vibration_intensity + 0.1).min(1.0);
                println!("Vibration: {:.1}", self.config.vibration_intensity);
            }
            Key::Space => {
                // Cycle through fractal types
                self.config.fractal_type = match self.config.fractal_type {
                    FractalType::Mandelbrot { .. } => {
                        FractalType::Julia { 
                            c: Complex64::new(-0.7, 0.27), 
                            turbulence: 0.5 
                        }
                    }
                    FractalType::Julia { .. } => {
                        FractalType::BurningShip { wave_phase: 0.0 }
                    }
                    FractalType::BurningShip { .. } => {
                        FractalType::Newton { 
                            roots: vec![
                                Complex64::new(1.0, 0.0),
                                Complex64::new(-0.5, 0.866),
                                Complex64::new(-0.5, -0.866),
                            ]
                        }
                    }
                    FractalType::Newton { .. } => {
                        FractalType::Mandelbrot { 
                            wave_amplitude: 0.1, 
                            wave_frequency: 2.0 
                        }
                    }
                };
                println!("Changed fractal type");
            }
            Key::R => {
                // Reset to default values
                self.config = FractalConfig::default();
                println!("Reset configuration");
            }
            Key::W => {
                self.show_waves = !self.show_waves;
                println!("Waves: {}", self.show_waves);
            }
            Key::A => {
                self.auto_animate = !self.auto_animate;
                println!("Auto-animate: {}", self.auto_animate);
            }
            Key::C => {
                // Create a big color burst in the center
                self.config.color_burst = true;
                self.config.burst_intensity = 2.0;
                self.config.burst_center = Complex64::new(0.0, 0.0);
                self.config.burst_radius = 1.0;
                println!("Color burst!");
            }
            _ => {}
        }
    }
    
    /// Render the fractal with wave effects
    fn render(&mut self) {
        let start = Instant::now();
        
        // Fade out color burst
        if self.config.color_burst {
            self.config.burst_intensity *= 0.9;
            if self.config.burst_intensity < 0.01 {
                self.config.color_burst = false;
            }
        }
        
        self.buffer = render_fractal(self.width, self.height, &self.config);
        
        // Apply wave displacement if enabled
        if self.show_waves {
            for y in 0..self.height {
                for x in 0..self.width {
                    let sim_x = (x * self.wave_sim.width) / self.width;
                    let sim_y = (y * self.wave_sim.height) / self.height;
                    
                    let displacement = self.wave_sim.get_displacement(sim_x, sim_y);
                    if displacement.abs() > 0.1 {
                        let offset_x = (displacement * 5.0) as isize;
                        let offset_y = (displacement * 3.0) as isize;
                        
                        let src_x = (x as isize + offset_x).max(0).min(self.width as isize - 1) as usize;
                        let src_y = (y as isize + offset_y).max(0).min(self.height as isize - 1) as usize;
                        
                        let src_index = src_y * self.width + src_x;
                        let dst_index = y * self.width + x;
                        
                        // Blend with wave effect
                        let src_color = self.buffer[src_index];
                        let dst_color = self.buffer[dst_index];
                        
                        // Extract RGB components
                        let r1 = ((src_color >> 16) & 0xFF) as f32;
                        let g1 = ((src_color >> 8) & 0xFF) as f32;
                        let b1 = (src_color & 0xFF) as f32;
                        
                        let r2 = ((dst_color >> 16) & 0xFF) as f32;
                        let g2 = ((dst_color >> 8) & 0xFF) as f32;
                        let b2 = (dst_color & 0xFF) as f32;
                        
                        // Blend based on displacement intensity
                        let intensity = displacement.abs().min(1.0) as f32;
                        let r = (r1 * intensity + r2 * (1.0 - intensity)) as u32;
                        let g = (g1 * intensity + g2 * (1.0 - intensity)) as u32;
                        let b = (b1 * intensity + b2 * (1.0 - intensity)) as u32;
                        
                        self.buffer[dst_index] = (r << 16) | (g << 8) | b;
                    }
                }
            }
        }
        
        let duration = start.elapsed();
        if self.frame_count % 60 == 0 {
            println!("Frame: {}, Render time: {:.2}ms", self.frame_count, duration.as_secs_f64() * 1000.0);
        }
    }
    
    /// Run the main application loop
    fn run(&mut self) {
        let mut window = Window::new(
            "Aurora: Submersible Fractal Waves - ESC to exit",
            self.width,
            self.height,
            WindowOptions {
                resize: true,
                ..WindowOptions::default()
            },
        )
        .expect("Unable to create window");
        
        // Limit to max ~60 fps update rate
        window.limit_update_rate(Some(std::time::Duration::from_micros(16600)));
        
        println!("🌊 Aurora: Submersible Fractal Waves");
        println!("====================================");
        println!("Controls:");
        println!("  - Left click: Create color burst");
        println!("  - Right click: Create wave disturbance");
        println!("  - Middle click + drag: Adjust immersion depth");
        println!("  - Up/Down arrows: Increase/decrease iterations");
        println!("  - Left/Right arrows: Adjust vibration intensity");
        println!("  - Space: Cycle through fractal types");
        println!("  - W: Toggle wave effects");
        println!("  - A: Toggle auto-animation");
        println!("  - C: Create center color burst");
        println!("  - R: Reset view");
        println!("  - ESC: Exit");
        println!();
        
        while window.is_open() && !window.is_key_down(Key::Escape) {
            self.update();
            
            // Handle mouse input
            if let Some((x, y)) = window.get_mouse_pos(MouseMode::Clamp) {
                let buttons = window.get_mouse_down(MouseButton::Left);
                self.handle_mouse(x, y, &buttons);
            }
            
            // Handle keyboard input
            window.get_keys().iter().for_each(|key| self.handle_key(*key));
            
            // Render the fractal
            self.render();
            
            // Update window
            window
                .update_with_buffer(&self.buffer, self.width, self.height)
                .unwrap();
        }
    }
}

// 4. MAIN FUNCTION

fn main() {
    // Initialize the application
    let width = 800;
    let height = 600;
    
    let mut aurora = Aurora::new(width, height);
    aurora.run();
}