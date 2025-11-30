extends CanvasLayer

@onready var ui = $"."

func _ready() -> void:
	ui.hide()

func _process(delta: float) -> void:
	if Global.dark_room_ui:
		if not Global.dark_room_ui_is_shown:	
			ui.show()
			Global.dark_room_ui_is_shown = true
	else:
		ui.hide()
