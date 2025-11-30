extends CanvasLayer

@onready var ui = $"."

func _ready() -> void:
	ui.hide()

func _process(delta: float) -> void:
	if Global.big_laser_ui:
		if not Global.big_laser_ui_is_shown:	
			ui.show()
			Global.big_laser_ui_is_shown = true
	else:
		ui.hide()
