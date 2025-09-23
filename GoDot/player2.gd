extends CharacterBody2D

var speed = 200
var jump_force = -400
var gravity = 200

func _physics_process(delta):
    var input_vector = Vector2.ZERO
    input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
    
    if Input.is_action_just_pressed("ui_up") and is_on_floor():
        velocity.y = jump_force
    
    velocity.y += gravity * delta
    velocity.x = input_vector.x * speed
    move_and_slide()