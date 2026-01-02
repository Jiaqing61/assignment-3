# res://scripts/intro_scroll.gd
extends Control

@export var next_scene: String = "res://scenes/Levels/Level_1.tscn"
@export var open_anim: String = "open"
@export var open_anim_time: float = 1.2
@export var type_speed: float = 0.02
@export var line_pause: float = 0.35
@export var end_pause: float = 1.8

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var text: RichTextLabel = $Scroll/Padding/StoryText

var lines := [
	"You fell into a Realm of Light.",
	"Drag emitters. Rotate mirrors.",
	"Guide beams to unlock every chest.",
	"Open the gates. Escape the labyrinth."
]

var _skipped := false

func _ready() -> void:
	text.text = ""
	anim.play(open_anim)
	_run()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel") or (event is InputEventMouseButton and event.pressed):
		if not _skipped:
			_skipped = true
			get_tree().change_scene_to_file(next_scene)

func _run() -> void:
	await get_tree().create_timer(open_anim_time).timeout
	if _skipped: return

	text.text = ""
	for line in lines:
		await _type_line(line)
		if _skipped: return
		text.text += "\n"
		await get_tree().create_timer(line_pause).timeout
		if _skipped: return

	await get_tree().create_timer(end_pause).timeout
	if _skipped: return
	get_tree().change_scene_to_file(next_scene)

func _type_line(line: String) -> void:
	for ch in line:
		text.text += ch
		await get_tree().create_timer(type_speed).timeout
		if _skipped: return
