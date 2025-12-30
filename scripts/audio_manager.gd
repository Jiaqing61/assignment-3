# AudioManager.gd (Autoload)

extends Node

signal music_changed(new_track: StringName)

# ===== SFX =====
@onready var click_sfx: AudioStreamPlayer = $clickSfx
@onready var walk_sfx: AudioStreamPlayer = $walkSfx
@onready var move_sfx: AudioStreamPlayer = $moveSfx
@onready var chest_open_sfx: AudioStreamPlayer = $chestOpenfx
@onready var door_open_sfx: AudioStreamPlayer = $doorOpenSfx

# ===== BGM=====
@onready var bgm: AudioStreamPlayer2D = $BGM
@onready var dark: AudioStreamPlayer2D = $Dark

@export var music_enabled: bool = true
@export var sfx_enabled: bool = true
@export var default_fade_time: float = 0.8

var _music_players: Dictionary = {}          # track_name -> player
var _music_default_db: Dictionary = {}       # track_name -> default volume_db
var _current_music: StringName = &""
var _music_tween: Tween

var _dark_zone_count: int = 0

func enter_dark_zone() -> void:
	_dark_zone_count += 1
	if _dark_zone_count == 1:
		play_music(&"Dark")

func exit_dark_zone() -> void:
	_dark_zone_count = max(_dark_zone_count - 1, 0)
	if _dark_zone_count == 0:
		play_music(&"BGM") 


func _ready() -> void:
	
	_music_players = {
		&"BGM": bgm,
		&"Dark": dark,
	}

	
	for k in _music_players.keys():
		var p: AudioStreamPlayer2D = _music_players[k]
		if p:
			_music_default_db[k] = p.volume_db

	
	for k in _music_players.keys():
		var p: AudioStreamPlayer2D = _music_players[k]
		if p and p.playing:
			p.stop()



func play_click() -> void:
	_play_sfx(click_sfx)

func play_walk() -> void:
	_play_sfx(walk_sfx)

func play_chest_open() -> void:
	_play_sfx(chest_open_sfx)

func play_door_open() -> void:
	_play_sfx(door_open_sfx)

func play_move() -> void:
	if not sfx_enabled:
		return
	if move_sfx and not move_sfx.playing:
		move_sfx.play()

func stop_move() -> void:
	if move_sfx and move_sfx.playing:
		move_sfx.stop()

func _play_sfx(p: AudioStreamPlayer) -> void:
	if not sfx_enabled:
		return
	if p:
		p.play()

func play_music(track: StringName, fade_time: float = -1.0, restart: bool = false) -> void:
	if not music_enabled:
		return

	if fade_time < 0.0:
		fade_time = default_fade_time

	var target: AudioStreamPlayer2D = _music_players.get(track, null)
	if target == null:
		push_warning("AudioManager: unknown music track: %s" % [track])
		return


	if _current_music == track and target.playing and not restart:
		return

	var old_track := _current_music
	var old: AudioStreamPlayer2D = _music_players.get(old_track, null)


	if _music_tween and _music_tween.is_running():
		_music_tween.kill()


	var target_db: float = float(_music_default_db.get(track, 0.0))
	var old_db: float = float(_music_default_db.get(old_track, 0.0))


	target.volume_db = -80.0
	target.play()

	_music_tween = create_tween()
	_music_tween.set_parallel(true)


	if old and old.playing:
		_music_tween.tween_property(old, "volume_db", -80.0, fade_time)


	_music_tween.tween_property(target, "volume_db", target_db, fade_time)

	_music_tween.set_parallel(false)


	if old and old.playing:
		_music_tween.tween_callback(Callable(old, "stop"))
		_music_tween.tween_callback(func(): old.volume_db = old_db)

	_music_tween.tween_callback(func():
		_current_music = track
		emit_signal("music_changed", track)
	)


func stop_music(fade_time: float = -1.0) -> void:
	if fade_time < 0.0:
		fade_time = default_fade_time

	if _current_music == &"":
		return

	var p: AudioStreamPlayer2D = _music_players.get(_current_music, null)
	if p == null or not p.playing:
		_current_music = &""
		return

	if _music_tween and _music_tween.is_running():
		_music_tween.kill()

	var track := _current_music
	var default_db: float = float(_music_default_db.get(track, 0.0))

	_music_tween = create_tween()
	_music_tween.tween_property(p, "volume_db", -80.0, fade_time)
	_music_tween.tween_callback(Callable(p, "stop"))
	_music_tween.tween_callback(func():
		p.volume_db = default_db
		_current_music = &""
	)


func set_music_enabled(enabled: bool) -> void:
	music_enabled = enabled
	if not enabled:
		stop_music(0.2)

func set_sfx_enabled(enabled: bool) -> void:
	sfx_enabled = enabled
