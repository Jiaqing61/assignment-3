extends Node2D

@export var radius: float = 80.0
@export var feather: float = 40.0
@export var enabled: bool = true

func register_light(mask_drawer: Node2D) -> void:
	if not enabled:
		return

	# 世界坐标 → 屏幕坐标（Godot 4：Transform2D 用 *）
	var xform: Transform2D = mask_drawer.get_viewport().canvas_transform
	var screen_pos: Vector2 = xform * global_position

	mask_drawer.add_reveal_circle_screen(screen_pos, radius, feather)
