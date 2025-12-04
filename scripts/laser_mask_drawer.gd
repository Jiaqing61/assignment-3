extends Node2D

@export var width: float = 18.0     
@export var feather: float = 24.0 

var _paths: Array[PackedVector2Array] = []
var _circles := []  # [(pos, radius, feather)]

func _ready() -> void:
	if LaserVisibilityMask:
		LaserVisibilityMask.drawer = self
		# print("LaserMaskDrawer registered successfully!")
	else:
		push_error("LaserVisibilityMask Autoload not found! Please enable it in Project Settings.")

func begin_frame() -> void:
	_paths.clear()
	_circles.clear()

func add_path(points_screen: PackedVector2Array) -> void:
	_paths.append(points_screen)
	
func add_reveal_circle_screen(pos: Vector2, radius: float, feather: float = 14.0) -> void:
	_circles.append([pos, radius, feather])
	
func _process(_dt: float) -> void:
	# ✅ 保持原逻辑：不在这里清空 _paths / _circles（外部照旧用 begin_frame）
	# ✅ 只是在每帧多收集一次 HintLight 的光圈
	for hl in get_tree().get_nodes_in_group("HintLight"):
		if hl.has_method("register_light"):
			hl.register_light(self)

	queue_redraw()

func _draw() -> void:
	# draw laser lights
	for pts in _paths:
		if pts.size() < 2:
			continue
		for i in range(pts.size() - 1):
			_draw_soft_segment(pts[i], pts[i + 1])
	# draw circles
	for c in _circles:
		_draw_soft_circle(c[0], c[1], c[2])		
		
func _draw_soft_segment(a: Vector2, b: Vector2) -> void:
	var dir := b - a
	if dir.length() < 1.0:
		return
	var n := dir.orthogonal().normalized()
	var hw := width * 0.5

	var quad := PackedVector2Array([a + n * hw, b + n * hw, b - n * hw, a - n * hw])
	draw_colored_polygon(quad, Color(1, 1, 1, 1))
	if feather > 0.0:
		var steps := 6
		for s in range(1, steps + 1):
			var t := float(s) / steps
			var f := hw + feather * t
			var alpha := pow(1.0 - t, 2.0) * 0.6
			var q := PackedVector2Array([a + n * f, b + n * f, b - n * f, a - n * f])
			draw_colored_polygon(q, Color(1, 1, 1, alpha))
			
func _draw_soft_circle(center: Vector2, radius: float, feather: float) -> void:
	draw_circle(center, radius, Color(1, 1, 1, 1))
	if feather > 0.0:
		var steps := 8
		for s in range(1, steps + 1):
			var t := float(s) / steps
			var r := radius + feather * t
			var a := pow(1.0 - t, 2.0)
			draw_circle(center, r, Color(1, 1, 1, a))
