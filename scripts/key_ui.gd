extends CanvasLayer

@onready var label: Label = $KeyMessageLabel
@export var display_time := 2.0

var _tween: Tween

func show_message(text: String) -> void:
	label.text = text

	if _tween:
		_tween.kill()

	_tween = create_tween()

	label.modulate.a = 0.0
	_tween.tween_property(label, "modulate:a", 1.0, 0.4)
	_tween.tween_interval(display_time)
	_tween.tween_property(label, "modulate:a", 0.0, 0.4)
