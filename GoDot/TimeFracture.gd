extends Node2D

class_name TimeFracture

var shards = []

@export var shard_count = 50

func _ready():
    randomize()
    for i in range(shard_count):
        shards.append({
            "pos": Vector2(rand_range(0, 1024), rand_range(0, 768)),
            "size": rand_range(20, 80),
            "angle": randf()*PI*2,
            "color": Color(randf(), randf(), randf())
        })
    set_process(true)

func _process(delta):
    for s in shards:
        # Subtle rotation
        s["angle"] += (randf()-0.5)*0.02
        
        # Fragments slowly move
        s["pos"] += Vector2(cos(s["angle"]), sin(s["angle"])) * 0.2

    update()

func _draw():
    for s in shards:
        draw_rect(Rect2(s["pos"] - Vector2(s["size"]/2, s["size"]/2), Vector2(s["size"], s["size"])), s["color"], false, 2)
        draw_line(s["pos"], s["pos"] + Vector2(cos(s["angle"]), sin(s["angle"]))*s["size"], s["color"], 2)

func _input(event):
    if event is InputEventMouseMotion:
        for s in shards:
            var dist = s["pos"].distance_to(event.position)
            if dist < 150:
                s["pos"] += (s["pos"] - event.position).normalized() * 1.5
                s["angle"] += 0.1
                s["color"] = Color(randf(), randf(), randf())