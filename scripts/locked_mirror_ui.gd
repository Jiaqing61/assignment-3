extends CanvasLayer

@onready var ui = $"."

func _ready() -> void:
	ui.hide()

func _process(delta: float) -> void:
	if Global.locked_mirror_ui:
		if not Global.locked_mirror_ui_is_shown:	
			ui.show()
			Global.locked_mirror_ui_is_shown = true
	else:
		ui.hide()
