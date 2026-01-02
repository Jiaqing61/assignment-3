extends Node2D

@export var rotation_degree: float = 5.0  
@export var rotation_speed: float = 50.0  
@export var cluster_controlled: bool = false 

var player_touching: bool = false        
var _dialogue_shown := false

func _process(delta):
	if cluster_controlled:
		_update_move_sfx(false)
		return
		
	var rotating_now := false	
	if player_touching:

		if Input.is_action_pressed("rotate_left"):
			rotation_degrees -= rotation_speed * delta
			rotating_now  = true
		elif Input.is_action_pressed("rotate_right"):
			rotation_degrees += rotation_speed * delta
			rotating_now  = true
			
			if not _dialogue_shown:
					DialogueUI.show_line("You see it differently now.")
					_dialogue_shown = true
		
	_update_move_sfx(rotating_now)	

func _update_move_sfx(rotating: bool) -> void:
	if rotating:
		AudioManager.play_move()
	else:
		AudioManager.stop_move()

func _on_Area2D_body_entered(body):
	if body.name == "Player":
		player_touching = true
		Global.mirror_ui = true


func _on_Area2D_body_exited(body):
	if body.name == "Player":
		player_touching = false
		Global.mirror_ui = false
		_update_move_sfx(false)
		
		

		
