extends Node2D

# Stats
var energy = 100
var curiosity = 50
var randomness = 0.5
var mood = 1.0 # 0 sad -> 1 happy

# Recursive depth
var depth = 0
var max_depth = 5

func _ready():
    set_process(true)
    randomize()
    draw_fractal(Vector2.ZERO, 100, 0)

func _process(delta):
    # Evolve over time
    energy -= 0.1
    curiosity += randf() * 0.2 - 0.1
    randomness += sin(OS.get_ticks_msec() * 0.001) * 0.01
    mood = clamp(mood + (randf()-0.5)*0.02, 0,1)
    
    if randi()%50==0:
        update_fractal()

func _input(event):
    if event is InputEventMouseButton and event.pressed:
        mood = 1.0 # player interaction boosts mood
        randomness = randf()
        update_fractal()

func draw_fractal(origin:Vector2, size:float, current_depth:int):
    if current_depth > max_depth:
        return
    
    var color = Color(randf()*mood, randf()*curiosity*0.5, randf()*randomness)
    draw_circle(origin, size*0.1 + randf()*5, color)
    
    for i in range(2 + randi()%3):
        var angle = randf()*PI*2
        var offset = Vector2(cos(angle), sin(angle)) * size * (0.3 + randf()*0.3)
        draw_fractal(origin + offset, size*0.6, current_depth + 1)

func update_fractal():
    depth = (depth+1)%max_depth
    update() # redraw fractal