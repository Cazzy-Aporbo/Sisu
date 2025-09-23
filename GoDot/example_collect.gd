# Star.gd - Detect when the player touches the star
extends Area2D

signal caught

func _ready():
    connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body):
    if body.name == "Player":
        emit_signal("caught")
        print("Player caught the star!")