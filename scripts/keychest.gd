extends Area2D

signal lit_changed(lit: bool)
signal key_obtained(group_id: int)  

@export var is_key_chest: bool = true           
@export var lit_texture: Texture2D
@export var closed_texture: Texture2D
@export var decay_seconds: float = 0.12        
@export var color: Color = Color.WHITE  
@export var unlock_group: int = 0        

var _lit := false

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _decay_timer: Timer = Timer.new()

func is_lit() -> bool:
	return _lit
	
func _ready() -> void:
	_decay_timer.wait_time = decay_seconds
	_decay_timer.one_shot = true
	add_child(_decay_timer)
	_decay_timer.timeout.connect(_on_decay_timeout)

	_apply_visual()


func laser_hit(laser_color: Color, hit_point: Vector2, power: float = 1.0) -> void:
	print("[KeyChest]", name, "laser_hit, color =", laser_color, "from point", hit_point)
	if laser_color == Color.WHITE or laser_color == color:
		_set_lit(true)
		_decay_timer.start()


func _on_decay_timeout() -> void:
	_set_lit(false)


func _set_lit(v: bool) -> void:
	if _lit == v:
		return
	print("[KeyChest]", name, "set_lit from", _lit, "to", v)
	_lit = v
	emit_signal("lit_changed", _lit)
	_apply_visual()

	if _lit and is_key_chest:
		_give_key_to_player()
		print("[KeyChest]", name, "emitting key_obtained(", unlock_group, ")")
		emit_signal("key_obtained", unlock_group) 


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
