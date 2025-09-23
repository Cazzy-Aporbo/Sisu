extends Area2D

@export var flower_name = "Alien Flower"

signal collected(flower_name)

func _ready():
    # Optional: add pulse animation
    $AnimationPlayer.play("pulse")
    $CollisionShape2D.disabled = false

func _on_area_entered(area):
    if area.name == "Player":
        emit_signal("collected", flower_name)
        queue_free()