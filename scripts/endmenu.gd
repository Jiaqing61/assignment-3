extends Control


func _on_try_again_pressed() -> void:
	AudioManager.start_sfx.play()
	get_tree().change_scene_to_file("res://Scenes/Levels/Level_01.tscn")
	

func _on_end_pressed() -> void:
	get_tree().quit()
