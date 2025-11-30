extends CanvasLayer

@onready var ui = $"."

func _ready() -> void:
	ui.hide()

func _process(delta: float) -> void:
	if Global.laser_rail_ui:
		if not Global.laser_rail_ui_is_shown:	
			ui.show()
			Global.laser_rail_ui_is_shown = true
	else:
		ui.hide()
