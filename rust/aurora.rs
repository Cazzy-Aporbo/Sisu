/*
 * AURORA: A Beautiful Rust Fractal Explorer
 * 
 * This application renders mesmerizing fractals with smooth coloring,
 * interactive zooming, and real-time parameter adjustments.
 * It demonstrates advanced Rust concepts with beautiful, clean code.
 */

use minifb::{Window, WindowOptions, Key};
use num_complex::Complex64;
use std::time::Instant;
use palette::{Hsv, Srgb};
use rayon::prelude::*;

// 1. FRACTAL ENGINE WITH SMOOTH COLORING

/// Fractal type enumeration
#[derive(Debug, Clone, Copy, PartialEq)]
enum FractalType {
    Mandelbrot,
    Julia(Complex64),
}

/// Fractal configuration
#[derive(Debug, Clone)]
struct FractalConfig {
    fractal_type: FractalType,
    max_iterations: u32,
    escape_radius: f64,
    center: Complex64,
    scale: f64,
    color_offset: f64,
    color_stretch: f64,
}

impl Default for FractalConfig {
    fn default() -> Self {
        Self {
            fractal_type: FractalType::Mandelbrot,
            max_iterations: 100,
            escape_radius: 4.0,
            center: Complex64::new(0.0, 0.0),
            scale: 3.0,
            color_offset: 0.0,
            color_stretch: 0.1,
        }
    }
}

/// Calculate smooth iteration count for a point in the complex plane
fn calculate_point(c: Complex64, config: &FractalConfig) -> f64 {
    let mut z = match config.fractal_type {
        FractalType::Mandelbrot => Complex64::new(0.0, 0.0),
        FractalType::Julia(julia_c) => c,
    };
    
    let c = match config.fractal_type {
        FractalType::Mandelbrot => c,
        FractalType::Julia(julia_c) => julia_c,
    };
    
    let mut iteration = 0;
    while iteration < config.max_iterations && z.norm_sqr() < config.escape_radius * config.escape_radius {
        z = z * z + c;
        iteration += 1;
    }
    
    if iteration == config.max_iterations {
        iteration as f64
    } else {
        iteration as f64 - z.norm_sqr().log2().log2() + 1.0
    }
}

/// Generate a beautiful color from iteration count
fn iteration_to_color(iteration: f64, config: &FractalConfig) -> u32 {
    // Normalize iteration count
    let t = (iteration * config.color_stretch + config.color_offset) % 1.0;
    
    // Use HSV color space for smooth transitions
    let hue = (t * 360.0) as f32;
    let saturation = 0.8;
    let value = if iteration >= config.max_iterations as f64 {
        0.0 // Black for points in the set
    } else {
        1.0 // Full brightness for escape points
    };
    
    // Convert HSV to RGB
    let hsv = Hsv::new(hue, saturation, value);
    let rgb: Srgb = hsv.into();
    
    // Convert to 32-bit RGB value
    let r = (rgb.red * 255.0) as u32;
    let g = (rgb.green * 255.0) as u32;
    let b = (rgb.blue * 255.0) as u32;
    
    (r << 16) | (g << 8) | b
}

/// Render the fractal to a buffer
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
            iteration_to_color(iteration, config)
        })
    }).collect()
}

// 2. INTERACTIVE RENDERING ENGINE

/// Main application state
struct Aurora {
    width: usize,
    height: usize,
    buffer: Vec<u32>,
    config: FractalConfig,
    last_render_time: f64,
    is_dragging: bool,
    drag_start: (f64, f64),
    original_center: Complex64,
}

impl Aurora {
    fn new(width: usize, height: usize) -> Self {
        let config = FractalConfig::default();
        let buffer = render_fractal(width, height, &config);
        
        Self {
            width,
            height,
            buffer,
            config,
            last_render_time: 0.0,
            is_dragging: false,
            drag_start: (0.0, 0.0),
            original_center: Complex64::new(0.0, 0.0),
        }
    }
    
    /// Handle mouse input for zooming and panning
    fn handle_mouse(&mut self, x: f64, y: f64, left_pressed: bool, right_pressed: bool) {
        if left_pressed {
            if !self.is_dragging {
                self.is_dragging = true;
                self.drag_start = (x, y);
                self.original_center = self.config.center;
            } else {
                let dx = (x - self.drag_start.0) * self.config.scale / self.width as f64;
                let dy = (y - self.drag_start.1) * self.config.scale / self.height as f64;
                self.config.center = Complex64::new(
                    self.original_center.re - dx,
                    self.original_center.re + dy,
                );
                self.render();
            }
        } else {
            self.is_dragging = false;
        }
        
        if right_pressed {
            // Zoom in at cursor position
            let cursor_re = (x - self.width as f64 / 2.0) * self.config.scale / self.width as f64 + self.config.center.re;
            let cursor_im = (y - self.height as f64 / 2.0) * self.config.scale / self.height as f64 + self.config.center.im;
            
            self.config.scale *= 0.9;
            self.config.center = Complex64::new(cursor_re, cursor_im);
            self.render();
        }
    }
    
    /// Handle keyboard input for parameter adjustments
    fn handle_key(&mut self, key: Key) {
        match key {
            Key::Up => {
                self.config.max_iterations += 10;
                self.render();
            }
            Key::Down => {
                self.config.max_iterations = (self.config.max_iterations - 10).max(10);
                self.render();
            }
            Key::Left => {
                self.config.color_offset -= 0.1;
                self.render();
            }
            Key::Right => {
                self.config.color_offset += 0.1;
                self.render();
            }
            Key::Space => {
                // Switch between Mandelbrot and Julia sets
                self.config.fractal_type = match self.config.fractal_type {
                    FractalType::Mandelbrot => {
                        let julia_c = Complex64::new(-0.7, 0.27);
                        FractalType::Julia(julia_c)
                    }
                    FractalType::Julia(_) => FractalType::Mandelbrot,
                };
                self.render();
            }
            Key::R => {
                // Reset to default values
                self.config = FractalConfig::default();
                self.render();
            }
            _ => {}
        }
    }
    
    /// Render the fractal and update the buffer
    fn render(&mut self) {
        let start = Instant::now();
        self.buffer = render_fractal(self.width, self.height, &self.config);
        let duration = start.elapsed();
        self.last_render_time = duration.as_secs_f64() * 1000.0;
        
        println!("Rendered in {:.2}ms", self.last_render_time);
        println!("Center: {:.6} + {:.6}i", self.config.center.re, self.config.center.im);
        println!("Scale: {:.6}", self.config.scale);
        println!("Iterations: {}", self.config.max_iterations);
    }
    
    /// Run the main application loop
    fn run(&mut self) {
        let mut window = Window::new(
            "Aurora: Fractal Explorer - ESC to exit",
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
        
        while window.is_open() && !window.is_key_down(Key::Escape) {
            // Handle mouse input
            if let Some((x, y)) = window.get_mouse_pos(minifb::MouseMode::Clamp) {
                let left_pressed = window.get_mouse_down(minifb::MouseButton::Left);
                let right_pressed = window.get_mouse_down(minifb::MouseButton::Right);
                self.handle_mouse(x, y, left_pressed, right_pressed);
            }
            
            // Handle keyboard input
            window.get_keys().iter().for_each(|key| self.handle_key(*key));
            
            // Update window
            window
                .update_with_buffer(&self.buffer, self.width, self.height)
                .unwrap();
        }
    }
}

// 3. ADDITIONAL FRACTAL TYPES AND ENHANCEMENTS

/// Burning Ship fractal variant
fn burning_ship(c: Complex64, max_iterations: u32) -> f64 {
    let mut z = Complex64::new(0.0, 0.0);
    let mut iteration = 0;
    
    while iteration < max_iterations && z.norm_sqr() < 4.0 {
        let x = z.re.abs();
        let y = z.im.abs();
        z = Complex64::new(x * x - y * y + c.re, 2.0 * x * y + c.im);
        iteration += 1;
    }
    
    if iteration == max_iterations {
        iteration as f64
    } else {
        iteration as f64 - z.norm_sqr().log2().log2() + 1.0
    }
}

/// Multibrot fractal (generalization of Mandelbrot)
fn multibrot(c: Complex64, power: f64, max_iterations: u32) -> f64 {
    let mut z = Complex64::new(0.0, 0.0);
    let mut iteration = 0;
    
    while iteration < max_iterations && z.norm_sqr() < 4.0 {
        z = z.powf(power) + c;
        iteration += 1;
    }
    
    if iteration == max_iterations {
        iteration as f64
    } else {
        iteration as f64 - z.norm_sqr().log2().log2() + 1.0
    }
}

/// Color palette presets
enum ColorPalette {
    Aurora,
    Ocean,
    Fire,
    Forest,
    Pastel,
}

impl ColorPalette {
    fn get_color(&self, t: f64) -> u32 {
        match self {
            ColorPalette::Aurora => {
                let r = (0.5 + 0.5 * (t * 6.0 - 0.5).cos() * 255.0) as u32;
                let g = (0.5 + 0.5 * (t * 6.0 - 1.0).cos() * 255.0) as u32;
                let b = (0.5 + 0.5 * (t * 6.0 - 1.5).cos() * 255.0) as u32;
                (r << 16) | (g << 8) | b
            }
            ColorPalette::Ocean => {
                let r = (t * 50.0) as u32;
                let g = (100.0 + t * 100.0) as u32;
                let b = (200.0 + t * 55.0) as u32;
                (r << 16) | (g << 8) | b
            }
            ColorPalette::Fire => {
                let r = (200.0 + t * 55.0) as u32;
                let g = (100.0 + t * 100.0) as u32;
                let b = (t * 50.0) as u32;
                (r << 16) | (g << 8) | b
            }
            ColorPalette::Forest => {
                let r = (t * 100.0) as u32;
                let g = (150.0 + t * 100.0) as u32;
                let b = (t * 100.0) as u32;
                (r << 16) | (g << 8) | b
            }
            ColorPalette::Pastel => {
                let r = (150.0 + 105.0 * (t * 6.0).cos()) as u32;
                let g = (150.0 + 105.0 * (t * 6.0 + 2.0).cos()) as u32;
                let b = (150.0 + 105.0 * (t * 6.0 + 4.0).cos()) as u32;
                (r << 16) | (g << 8) | b
            }
        }
    }
}

// 4. MAIN FUNCTION AND INITIALIZATION

fn main() {
    println!("🌌 Aurora Fractal Explorer");
    println!("==========================");
    println!("Controls:");
    println!("  - Left click and drag: Pan");
    println!("  - Right click: Zoom in at cursor");
    println!("  - Up/Down arrows: Increase/decrease iterations");
    println!("  - Left/Right arrows: Change color offset");
    println!("  - Space: Toggle between Mandelbrot and Julia sets");
    println!("  - R: Reset view");
    println!("  - ESC: Exit");
    println!();
    
    // Initialize the application
    let width = 800;
    let height = 600;
    
    let mut aurora = Aurora::new(width, height);
    aurora.run();
}