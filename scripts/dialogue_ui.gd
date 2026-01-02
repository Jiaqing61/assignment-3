extends CanvasLayer

@onready var label: Label = $DialogueLabel
var _showing := false

func _ready():
	hide()

func show_line(text: String, duration := 2.5):
	if _showing:
		return

	_showing = true
	show()
	label.text = text
	label.modulate.a = 0.0

	var tween := create_tween()
	tween.tween_property(label, "modulate:a", 1.0, 0.3)
	tween.tween_interval(duration)
	tween.tween_property(label, "modulate:a", 0.0, 0.3)

	tween.finished.connect(func():
		hide()
		_showing = false
	)
