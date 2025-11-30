extends Node2D

@export var rotation_degree: float = 15.0  
@export var rotation_speed: float = 85.0  
@export var unlock_group: int = 0
@export var is_locked: bool = true
@export var unlocked_modulate := Color(1,1,1)
@export var locked_modulate := Color(0.5,0.5,0.5)

var player_touching: bool = false

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _area: Area2D = $Area2D


func _ready() -> void:

	_sprite.modulate = (locked_modulate if is_locked else unlocked_modulate)

	if _area:
		_area.body_entered.connect(_on_area_body_entered)
		_area.body_exited.connect(_on_area_body_exited)
		
	_connect_to_key_chest()


func _connect_to_key_chest() -> void:
	for chest in get_tree().get_nodes_in_group("KeyChest"):
		if chest.has_signal("key_obtained"):
			chest.key_obtained.connect(_on_key_obtained)


func _on_key_obtained(group_id: int) -> void:
	if group_id == unlock_group:
		_unlock()


func _unlock() -> void:
	if not is_locked:
		return
	is_locked = false
	_sprite.modulate = unlocked_modulate


func _on_area_body_entered(body: Node) -> void:
	if is_locked and body.is_in_group("Player"):
		Global.locked_mirror_ui = true
	if not is_locked and body.is_in_group("Player"):
		player_touching = true
		


func _on_area_body_exited(body: Node) -> void:
	Global.locked_mirror_ui = false
	if body.is_in_group("Player"):
		player_touching = false


func _process(delta: float) -> void:
	if is_locked:
		return
	if player_touching:
		if Input.is_action_pressed("rotate_left"):
			rotation_degrees -= rotation_speed * delta
		elif Input.is_action_pressed("rotate_right"):
			rotation_degrees += rotation_speed * delta
