extends Node2D

@export var rotation_degree: float = 15.0  
@export var rotation_speed: float = 85.0  
var player_touching: bool = false        


func _process(delta):
	if player_touching:
		if Input.is_action_pressed("rotate_left"):
			rotation_degrees -= rotation_speed * delta
		elif Input.is_action_pressed("rotate_right"):
			rotation_degrees += rotation_speed * delta


func _on_Area2D_body_entered(body):
	if body.name == "player":
		player_touching = true


func _on_Area2D_body_exited(body):
	if body.name == "player":
		player_touching = false
