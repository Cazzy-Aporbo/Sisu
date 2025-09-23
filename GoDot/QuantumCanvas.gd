extends Node2D

class_name QuantumCanvas

# Particle data
var particles = []

# Number of particles
@export var particle_count = 200

func _ready():
    randomize()
    for i in range(particle_count):
        particles.append({
            "pos": Vector2(rand_range(0, 1024), rand_range(0, 768)),
            "vel": Vector2(randf()-0.5, randf()-0.5) * 2,
            "color": Color(randf(), randf(), randf())
        })
    set_process(true)

func _process(delta):
    for p in particles:
        # Quantum oscillation
        var angle = sin(OS.get_ticks_msec()*0.001 + p["pos"].x*0.01) * PI
        p["vel"].rotate(angle*0.01)
        
        # Random jitter
        p["vel"] += Vector2(randf()-0.5, randf()-0.5) * 0.05
        
        # Move particle
        p["pos"] += p["vel"]
        
        # Wrap around screen
        p["pos"].x = fmod(p["pos"].x + 1024, 1024)
        p["pos"].y = fmod(p["pos"].y + 768, 768)
    
    update()

func _draw():
    for p in particles:
        draw_circle(p["pos"], 3, p["color"])

func _input(event):
    if event is InputEventMouseMotion:
        # Ripples effect based on mouse
        for p in particles:
            var dist = p["pos"].distance_to(event.position)
            if dist < 100:
                p["vel"] += (p["pos"] - event.position).normalized() * 0.5
                p["color"] = Color(randf(), randf(), randf())