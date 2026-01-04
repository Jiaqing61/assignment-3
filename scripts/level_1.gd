extends Node2D

@export var player_reveal_radius := 20.0
@export var player_reveal_feather := 20.0
@export var reveal_radius   := 18.0
@export var reveal_feather  := 18.0

func _ready() -> void:
	AudioManager.play_music(&"BGM", 0.0)
