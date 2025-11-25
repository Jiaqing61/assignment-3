extends Node2D

@export var decay_seconds: float = 0.5
@export var colors: Array[Color] = []

@onready var _decay_timer_1: Timer = $"Decay Timer 1"
@onready var _decay_timer_2: Timer = $"Decay Timer 2"
@onready var laser_emitter = $LaserEmitter

@onready var color1 = Color()
@onready var color2 = Color()
@onready var color1_lit = false
@onready var color2_lit = false

# Internal variable that keeps track of whether the laser has been hit.
# For a big laser, it is hit if it has two lasers on it.
var _lit = false

func _process(delta: float) -> void:
	if color1_lit and color2_lit:
		laser_emitter.turned_on = true
	else:
		laser_emitter.turned_on = false

func _ready() -> void:
	_decay_timer_1.wait_time = decay_seconds
	_decay_timer_2.wait_time = decay_seconds
	_decay_timer_1.one_shot = true
	_decay_timer_2.one_shot = true
	_decay_timer_1.timeout.connect(_on_decay1_timeout)
	_decay_timer_2.timeout.connect(_on_decay2_timeout)

	if colors.size() >= 2:
		var mixed := colors[0] + colors[1]
		
		mixed = Color(
			clamp(mixed.r, 0.0, 1.0),
			clamp(mixed.g, 0.0, 1.0),
			clamp(mixed.b, 0.0, 1.0),
			1.0
		)
		

		laser_emitter.color = mixed



func laser_hit(laser_color, hit_point: Vector2, power: float = 1.0) -> void:
	if laser_color in colors:
		if color1 == Color():
			color1 = laser_color
			color1_lit = true
			_decay_timer_1.start()
		elif laser_color != color1:
			color2 = laser_color
			color2_lit = true
			_decay_timer_2.start()

func _on_decay1_timeout() -> void:
	color1_lit = false
	color1 = Color()

func _on_decay2_timeout() -> void:
	color2_lit = false
	color2 = Color()
