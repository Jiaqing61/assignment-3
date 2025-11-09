extends StaticBody2D

@export var next_scene: PackedScene
var is_open: bool = false

@onready var _anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var _collider: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	if _anim and _anim.sprite_frames and _anim.sprite_frames.has_animation("close"):
		_anim.play("close")

func open_gate() -> void:
	if is_open:
		return
	is_open = true

	if _anim and _anim.sprite_frames and _anim.sprite_frames.has_animation("open"):
		_anim.play("open")
		await _anim.animation_finished

	if _collider:
		_collider.disabled = true

func close_gate() -> void:
	if not is_open:
		return
	is_open = false

	if _anim and _anim.sprite_frames and _anim.sprite_frames.has_animation("close"):
		_anim.play("close")
		await _anim.animation_finished

	if _collider:
		_collider.disabled = false


func _on_area_2d_body_entered(body: Node2D) -> void:
	if not is_open:
		return

	if body.is_in_group("Player"):
		await get_tree().create_timer(1.0).timeout

		#if next_scene:
			#SceneTransition.load_scene(next_scene)
		#else:
		get_tree().quit()
