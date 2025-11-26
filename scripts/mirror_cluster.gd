# res://scripts/mirror_cluster.gd
extends Node2D

## --- 可调参数 ---
@export var rotate_left_action := "rotate_left"
@export var rotate_right_action := "rotate_right"
@export var rotate_speed_deg := 120.0

@export var allow_move: bool = true
@export var move_action := "ui_accept"
@export var move_speed := 180.0

@export var require_player_in_area: bool = true  # 先保持 true；若仍不转，可暂时关掉用于定位问题
@export var child_group_name := "MirrorPair"     # 给三对双面镜的“根节点”加这个组名

## --- 运行状态 ---
var _player_in := false
var _child_initial_rot: Array[float] = []
@onready var area: Area2D = $InteractArea

func _ready() -> void:
	# 1) 找到并连上 Area2D 信号（防止忘连）
	if area:
		if not area.is_connected("body_entered", Callable(self, "_on_area_body_entered")):
			area.body_entered.connect(_on_area_body_entered)
		if not area.is_connected("body_exited", Callable(self, "_on_area_body_exited")):
			area.body_exited.connect(_on_area_body_exited)
		# 强制开启监测
		area.monitoring = true
		area.monitorable = true
	else:
		push_warning("MirrorCluster: InteractArea not found. Rotation will always be allowed.")
		require_player_in_area = false

	# 2) 只记录“三对双面镜”的初始局部角度（避免把 Area2D 也算进去）
	for c in get_children():
		if c is Node2D and c.is_in_group(child_group_name):
			_child_initial_rot.append(c.rotation)

	# 调试：看看收了几个孩子
	print("[MirrorCluster] pairs counted: ", _child_initial_rot.size())

func _process(delta: float) -> void:
	# 3) 把三对双面镜的局部角度“钉死”为初始值（防止单体误转）
	var i := 0
	for c in get_children():
		if c is Node2D and c.is_in_group(child_group_name):
			if i < _child_initial_rot.size():
				c.rotation = _child_initial_rot[i]
				i += 1

	# 4) 是否允许旋转（需在交互范围内）
	if require_player_in_area and not _player_in:
		return

	# 5) 旋转“父节点”本身，实现整体旋转
	var ang := 0.0
	if Input.is_action_pressed(rotate_left_action):
		ang -= deg_to_rad(rotate_speed_deg) * delta
	if Input.is_action_pressed(rotate_right_action):
		ang += deg_to_rad(rotate_speed_deg) * delta
	if ang != 0.0:
		rotation += ang

	# 6) （可选）整体平移
	if allow_move and Input.is_action_pressed(move_action):
		var dir := Vector2.ZERO
		dir.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
		dir.y = int(Input.is_action_pressed("ui_down"))  - int(Input.is_action_pressed("ui_up"))
		if dir != Vector2.ZERO:
			position += dir.normalized() * move_speed * delta

## --- Area2D 信号回调（注意方法名保持一致） ---
func _on_area_body_entered(body: Node) -> void:
	if body.is_in_group("Player") or body.name == "Player":
		_player_in = true
		print("[MirrorCluster] player entered area")

func _on_area_body_exited(body: Node) -> void:
	if body.is_in_group("Player") or body.name == "Player":
		_player_in = false
		print("[MirrorCluster] player exited area")
