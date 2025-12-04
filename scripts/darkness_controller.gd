extends ColorRect   

@onready var _mat: ShaderMaterial = material

func _ready() -> void:
	if _mat == null and material is ShaderMaterial:
		_mat = material
		
	set_darkness_amount(0.0)	



func set_darkness_amount(v: float) -> void:
	if _mat:
		_mat.set_shader_parameter("darkness_amount", clamp(v, 0.0, 1.0))



func fade_out_darkness(duration: float = 0.8) -> void:
	if not _mat:
		return
	var from_value: float = _mat.get_shader_parameter("darkness_amount")
	var tween := create_tween()
	tween.tween_method(set_darkness_amount, from_value, 0.0, duration)

func fade_in_darkness(duration: float = 0.8) -> void:
	if not _mat: return
	var from_value: float = _mat.get_shader_parameter("darkness_amount")
	var tween := create_tween()
	tween.tween_method(set_darkness_amount, from_value, 1.0, duration)
	
func turn_off_immediately() -> void:
	set_darkness_amount(0.0)
