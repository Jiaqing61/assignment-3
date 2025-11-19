extends Node2D

@export var rotation_degree: float = 15.0
@export var is_locked: bool = true       # initialize as locked
@export var unlocked_modulate := Color(1,1,1)
@export var locked_modulate := Color(0.5,0.5,0.5)

var player_touching: bool = false

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _area: Area2D = $Area2D

func _ready() -> void:
	# Changes colour according to lock status
	_sprite.modulate = (locked_modulate if is_locked else unlocked_modulate)

	# Area for detecting players
	if _area:
		_area.body_entered.connect(_on_area_body_entered)
		_area.body_exited.connect(_on_area_body_exited)

func _on_area_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		player_touching = true

		# If locked + player possesses key then automatically unlocks
		if is_locked and body.has_key:
			is_locked = false
			# use up the keys
			body.has_key = false
			_sprite.modulate = unlocked_modulate

func _on_area_body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		player_touching = false

func _process(delta: float) -> void:
	# In locked state, rotation is not possible
	if is_locked:
		return

	# Rotation is permitted only when the player is within range
	if player_touching:
		if Input.is_action_just_pressed("rotate_left"):
			rotation_degrees -= rotation_degree
		elif Input.is_action_just_pressed("rotate_right"):
			rotation_degrees += rotation_degree
