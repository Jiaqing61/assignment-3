extends StaticBody2D

@export var next_scene: PackedScene


@export var required_lit_chests: int = 0    

var is_open: bool = false
var _current_lit_chests: int = 0

@onready var _anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var _collider: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	if _anim and _anim.sprite_frames and _anim.sprite_frames.has_animation("close"):
		_anim.play("close")

	
	var chests := get_tree().get_nodes_in_group("GateChest")

	
	if required_lit_chests == 0:
		required_lit_chests = chests.size()

	for chest in chests:
		if chest.has_signal("lit_changed"):
			chest.lit_changed.connect(_on_chest_lit_changed.bind(chest))

			if chest.has_method("is_lit") and chest.is_lit():
				_current_lit_chests += 1

	_update_gate_state()


func _on_chest_lit_changed(lit: bool, chest: Node) -> void:
	if lit:
		_current_lit_chests += 1
	else:
		_current_lit_chests -= 1

	_update_gate_state()


func _update_gate_state() -> void:
	if _current_lit_chests >= required_lit_chests and required_lit_chests > 0:
		open_gate()
	else:
		close_gate()


func door_is_open() -> bool:
	return is_open


func open_gate() -> void:
	if is_open:
		return
	is_open = true

	if _anim and _anim.sprite_frames.has_animation("open"):
		_anim.play("open")
		await _anim.animation_finished

	if _collider:
		_collider.disabled = true


func close_gate() -> void:
	if not is_open:
		return
	is_open = false

	if _anim and _anim.sprite_frames.has_animation("close"):
		_anim.play("close")
		await _anim.animation_finished

	if _collider:
		_collider.disabled = false


func _on_area_2d_body_entered(body: Node2D) -> void:
	if not is_open:
		return
