extends Node

var drawer: Node2D
var _cam: Camera2D

func _ready():
	drawer = get_tree().get_first_node_in_group("LaserMask")
	if drawer == null:
		drawer = get_tree().get_root().find_child("LaserMaskDrawer", true, false)
	_cam = get_viewport().get_camera_2d()

func begin():
	if drawer: drawer.call("begin_frame")

func add_path_world(points_world: PackedVector2Array) -> void:
	if drawer == null: return
	var ct := get_viewport().get_canvas_transform()
	var pts_screen := PackedVector2Array()
	for p in points_world:
		pts_screen.append(ct * p)
	drawer.call("add_path", pts_screen)
	
func add_reveal_world(pos_world: Vector2, radius: float, feather: float = 14.0) -> void:
	if drawer == null: return
	var ct := get_viewport().get_canvas_transform()
	var screen_pos: Vector2 = ct * pos_world
	drawer.call("add_reveal_circle_screen", screen_pos, radius, feather)


	
