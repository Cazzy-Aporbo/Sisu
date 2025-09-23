# Player.gd - Move the character using arrow keys
extends CharacterBody2D

# How fast the player moves
@export var speed = 200

func _physics_process(delta):
    var direction = Vector2.ZERO

    # Check keys pressed
    if Input.is_action_pressed("ui_right"):
        direction.x += 1
    if Input.is_action_pressed("ui_left"):
        direction.x -= 1
    if Input.is_action_pressed("ui_down"):
        direction.y += 1
    if Input.is_action_pressed("ui_up"):
        direction.y -= 1

    # Make diagonal movement the same speed
    direction = direction.normalized()

    # Apply movement
    velocity = direction * speed
    move_and_slide()