extends Node2D

@export var rotation_speed: float = 85.0
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
	var root = get_tree().current_scene
	if not root:
		return

	# 找所有 key chest
	var key_chests = root.get_tree().get_nodes_in_group("KeyChest")
	for chest in key_chests:
		if chest.has_signal("key_obtained"):
			chest.key_obtained.connect(_unlock)

func _unlock() -> void:
	if is_locked:
		is_locked = false
		_sprite.modulate = unlocked_modulate


func _on_area_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		player_touching = true

		
		if is_locked and body.has_key:
			is_locked = false
			body.has_key = false
			_sprite.modulate = unlocked_modulate


func _on_area_body_exited(body: Node) -> void:
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
