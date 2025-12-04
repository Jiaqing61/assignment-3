extends Control	

func _on_start_pressed() -> void:
	AudioManager.door_open_sfx.play()
	get_tree().change_scene_to_file("res://Scenes/Levels/Level_1.tscn")

func _on_exit_pressed() -> void:
	AudioManager.click_sfx.play()
	get_tree().quit()
