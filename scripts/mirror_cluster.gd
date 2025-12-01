extends Node2D

@export var rotate_left_action := "rotate_left"
@export var rotate_right_action := "rotate_right"


@export var step_degrees: float = 45.0


@export var require_player_in_area: bool = true


@export var hold_repeat: bool = true
@export var first_repeat_delay: float = 0.28
@export var repeat_interval: float = 0.12

@export var allow_move: bool = false
@export var move_action := "ui_accept"
@export var move_speed := 180.0


@export var child_group_name := "MirrorPair"


var _player_in := false
var _child_initial_rot: Array[float] = []


var _hold_dir := 0
var _repeat_t := 0.0

@onready var area: Area2D = $InteractArea

func _ready() -> void:

	if area:
		if not area.is_connected("body_entered", Callable(self, "_on_area_body_entered")):
			area.body_entered.connect(_on_area_body_entered)
		if not area.is_connected("body_exited", Callable(self, "_on_area_body_exited")):
			area.body_exited.connect(_on_area_body_exited)
		area.monitoring = true
		area.monitorable = true
	else:

		require_player_in_area = false

	for c in get_children():
		if c is Node2D and (child_group_name == "" or c.is_in_group(child_group_name)):
			_child_initial_rot.append(c.rotation)

func _process(delta: float) -> void:
	var i := 0
	for c in get_children():
		if c is Node2D and (child_group_name == "" or c.is_in_group(child_group_name)):
			if i < _child_initial_rot.size():
				c.rotation = _child_initial_rot[i]
				i += 1

	if hold_repeat and _hold_dir != 0 and (not require_player_in_area or _player_in):
		_repeat_t -= delta
		if _repeat_t <= 0.0:
			_rotate_step(_hold_dir)
			_repeat_t = repeat_interval

	#if allow_move and Input.is_action_pressed(move_action):
		#var dir := Vector2(
			#int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left")),
			#int(Input.is_action_pressed("ui_down"))  - int(Input.is_action_pressed("ui_up"))
		#)
		#if dir != Vector2.ZERO:
			#position += dir.normalized() * move_speed * delta

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(rotate_left_action):
		if not require_player_in_area or _player_in:
			_rotate_step(-1)
			if hold_repeat:
				_hold_dir = -1
				_repeat_t = first_repeat_delay
	elif event.is_action_pressed(rotate_right_action):
		if not require_player_in_area or _player_in:
			_rotate_step(+1)
			if hold_repeat:
				_hold_dir = +1
				_repeat_t = first_repeat_delay

	if event.is_action_released(rotate_left_action) and _hold_dir == -1:
		_hold_dir = 0
	if event.is_action_released(rotate_right_action) and _hold_dir == +1:
		_hold_dir = 0

func _rotate_step(dir: int) -> void:
	rotation_degrees = wrapf(rotation_degrees + dir * step_degrees, -180.0, 180.0)

func _on_area_body_entered(body: Node) -> void:
	if body.is_in_group("Player") or body.name == "Player":
		_player_in = true

func _on_area_body_exited(body: Node) -> void:
	if body.is_in_group("Player") or body.name == "Player":
		_player_in = false
