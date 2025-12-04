extends CanvasLayer

var is_open := false

func _ready():
	hide()

func _input(event):
	if event.is_action_pressed("pause"): # pause = Esc
		toggle_pause()

func toggle_pause():
	is_open = !is_open
	visible = is_open
	get_tree().paused = is_open
	

func _on_resume_pressed() -> void:
	get_tree().paused = false
	hide()
	is_open = false
	AudioManager.click_sfx.play()

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
	AudioManager.click_sfx.play()

func _on_back_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/UI/StartMenu.tscn")
	AudioManager.click_sfx.play()

func _on_exit_pressed() -> void:
	get_tree().quit()
	AudioManager.click_sfx.play()
