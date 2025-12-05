extends Camera2D

@export var zoom_step: float = 0.25        # 每次缩放的步长
@export var min_zoom: float = 0.5          # 最远视角（数字越小，看得越多）
@export var max_zoom: float = 3.0          # 最近视角（数字越大，看得越近）

func _process(delta: float) -> void:
	var changed := false

	# 缩小视角（看到更多地图）
	if Input.is_action_just_pressed("camera_zoom_out"):
		var z := zoom.x - zoom_step
		z = clamp(z, min_zoom, max_zoom)
		zoom = Vector2(z, z)
		changed = true

	# 放大视角（看到更近）
	if Input.is_action_just_pressed("camera_zoom_in"):
		var z := zoom.x + zoom_step
		z = clamp(z, min_zoom, max_zoom)
		zoom = Vector2(z, z)
		changed = true

	# 如果你想按住键平滑缩放，可以把 just_pressed 改成 is_action_pressed
