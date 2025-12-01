extends CanvasLayer

@onready var ui = $"."

func _ready() -> void:
	ui.hide()

func _process(delta: float) -> void:
	if Global.big_laser_ui:
		ui.show()
	else:
		ui.hide()
