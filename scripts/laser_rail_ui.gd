extends CanvasLayer

@onready var ui = $"."

func _ready() -> void:
	ui.hide()

func _process(delta: float) -> void:
	if Global.laser_rail_ui:
		ui.show()
	else:
		ui.hide()
