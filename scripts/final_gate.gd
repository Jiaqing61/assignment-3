extends StaticBody2D

@export var next_scene: PackedScene
@export var required_lit_chests: int = 0  # required chests to open gate

var is_open := false
var _current_lit_chests := 0
var _chests: Array = []

@onready var _anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var _collider: CollisionShape2D = $CollisionShape2D
@onready var _area: Area2D = $Area2D   # Player enter area


func _ready() -> void:
	# Set initial animation state
	if _anim and _anim.sprite_frames.has_animation("close"):
		_anim.play("close")

	# Find all chests in group
	_chests = get_tree().get_nodes_in_group("GateChest")

	# If not set, require all chests to open the door
	if required_lit_chests == 0:
		required_lit_chests = _chests.size()

	# Connect signals + initialize counts
	for c in _chests:
		if c.has_signal("lit_changed"):
			c.lit_changed.connect(_on_chest_lit_changed)

			if c.has_method("is_lit") and c.is_lit():
				_current_lit_chests += 1

	_update_gate_state()

	# Connect area signal
	if _area:
		_area.body_entered.connect(_on_area_body_entered)


func _on_chest_lit_changed(lit: bool) -> void:
	# Recalculate from scratch to avoid double-counting
	_current_lit_chests = 0
	for c in _chests:
		if c.is_lit():
			_current_lit_chests += 1

	_update_gate_state()


func _update_gate_state() -> void:
	if _current_lit_chests >= required_lit_chests:
		open_gate()
	else:
		close_gate()


func open_gate() -> void:
	if is_open:
		return
	is_open = true

	if _anim and _anim.sprite_frames.has_animation("open"):
		_anim.play("open")
		AudioManager.door_open_sfx.play()
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


func _on_area_body_entered(body: Node2D) -> void:
	if not is_open:
		return

	if body.is_in_group("Player"):
		await get_tree().create_timer(0.5).timeout

		if next_scene:
			SceneTransition.load_scene(next_scene)
		else:
			get_tree().quit()
