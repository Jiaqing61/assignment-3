# This script is an autoload, that can be accessed from any other script!

extends Node

@onready var click_sfx = $clickSfx
@onready var walk_sfx = $walkSfx
@onready var move_sfx = $moveSfx
@onready var chest_open_sfx = $chestOpenfx
@onready var door_open_sfx = $doorOpenSfx


func play_move() -> void:
	if move_sfx and not move_sfx.playing:
		move_sfx.play()

func stop_move() -> void:
	if move_sfx and move_sfx.playing:
		move_sfx.stop()
