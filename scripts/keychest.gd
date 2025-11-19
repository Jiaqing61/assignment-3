extends Area2D

signal lit_changed(lit: bool)

@export var is_key_chest: bool = true        # whether is key chest
@export var lit_texture: Texture2D           
@export var closed_texture: Texture2D       

var _lit := false

@onready var _sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	_apply_visual()

func laser_hit(color: Color, hit_point: Vector2, power: float = 1.0) -> void:
	_set_lit(true)

func _set_lit(v: bool) -> void:
	if _lit == v:
		return
	_lit = v
	emit_signal("lit_changed", _lit)
	_apply_visual()

	# If it is a key chest → Give the player the key
	if _lit and is_key_chest:
		_give_key_to_player()

func _apply_visual() -> void:
	if _lit and lit_texture:
		_sprite.texture = lit_texture
	elif not _lit and closed_texture:
		_sprite.texture = closed_texture

func _give_key_to_player() -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		player.has_key = true
		print("🗝️ Player obtained a key!")
