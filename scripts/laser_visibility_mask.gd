extends Node

var drawer: Node2D

func _ready() -> void:
	drawer = get_tree().get_root().find_child("LaserMaskDrawer", true, false)

func begin() -> void:
	if drawer:
		drawer.call("begin_frame")

# 统一的 世界 → 屏幕 坐标转换（避免错位）
func _world_to_screen(p_world: Vector2) -> Vector2:
	var ct := get_viewport().get_canvas_transform()
	return ct * p_world

func add_path_world(points_world: PackedVector2Array) -> void:
	if drawer == null:
		return
	var pts_screen := PackedVector2Array()
	for p in points_world:
		pts_screen.append(_world_to_screen(p))
	drawer.call("add_path", pts_screen)

func add_reveal_world(pos_world: Vector2, radius: float, feather: float = 14.0) -> void:
	if drawer == null:
		return
	var screen_pos := _world_to_screen(pos_world)
	drawer.call("add_reveal_circle_screen", screen_pos, radius, feather)
