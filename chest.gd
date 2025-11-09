extends Area2D

signal lit_changed(lit: bool)

@export var closed_texture: Texture2D
@export var lit_texture: Texture2D
@export var decay_seconds: float = 0.12

var _lit := false

@onready var _decay_timer: Timer = $DecayTimer
@onready var _sprite: Sprite2D = get_node_or_null("Sprite2D")

func _ready() -> void:
	_decay_timer.wait_time = decay_seconds
	_decay_timer.one_shot = true
	_decay_timer.timeout.connect(_on_decay_timeout)
	_apply_visual()

func laser_hit(hit_point: Vector2, power: float = 1.0) -> void:
	_set_lit(true)
	_decay_timer.start()

func _on_decay_timeout() -> void:
	_set_lit(false)

func _set_lit(v: bool) -> void:
	if _lit == v:
		return
	_lit = v
	_apply_visual()
	emit_signal("lit_changed", _lit)

func _apply_visual() -> void:
	if not _sprite:
		return
	if _lit and lit_texture:
		_sprite.texture = lit_texture
	elif (not _lit) and closed_texture:
		_sprite.texture = closed_texture
	else:
		_sprite.modulate = (Color(1,1,1,1) if _lit else Color(0.7,0.7,0.7,1))
