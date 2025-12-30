extends Area2D

func _ready() -> void:

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		AudioManager.enter_dark_zone()

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		AudioManager.exit_dark_zone()
