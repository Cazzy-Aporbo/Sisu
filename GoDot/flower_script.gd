extends Area2D

@export var flower_name = "Unknown Flower"

signal collected(flower_name)

func _ready():
    $CollisionShape2D.disabled = false

func _on_area_entered(area):
    if area.name == "Player":
        emit_signal("collected", flower_name)
        queue_free() # remove flower from scene