# final_gate.gd (Godot 4.x)
extends Node2D

var is_open: bool = false

@onready var _collider: CollisionShape2D = get_node_or_null("CollisionShape2D") as CollisionShape2D
@onready var _anim: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
@onready var _spr: Sprite2D = get_node_or_null("Sprite2D") as Sprite2D

func open_gate() -> void:
	if is_open:
		return
	is_open = true

	if _anim:
		if _anim.has_animation("open"):
			_anim.play("open")
	elif _spr:
		_spr.modulate = Color(0.6, 1.0, 0.6, 1)

	if _collider:
		_collider.disabled = true

func close_gate() -> void:
	if not is_open:
		return
	is_open = false

	if _anim:
		if _anim.has_animation("close"):
			_anim.play("close")
	elif _spr:
		_spr.modulate = Color(1, 1, 1, 1)

	if _collider:
		_collider.disabled = false
