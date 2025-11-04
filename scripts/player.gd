extends CharacterBody2D

@export var move_speed : float = 60
@export var animator : AnimatedSprite2D

var last_facing: String = "down" # start facing down

func _physics_process(delta: float) -> void:
	var input_vec := Input.get_vector("left", "right", "up", "down")
	velocity = input_vec * move_speed
	# Choose and play the right animation
	if input_vec != Vector2.ZERO:
		var anim := ""
		if abs(input_vec.x) > abs(input_vec.y):
			if input_vec.x > 0.0:
				anim = "walk_right"
				last_facing = "right"
			else:
				anim = "walk_left"
				last_facing = "left"
		else:
			if input_vec.y > 0.0:
				anim = "walk_down"
				last_facing = "down"
			else:
				anim = "walk_up"
				last_facing = "up"

		if animator and (animator.animation != anim or !animator.is_playing()):
			animator.play(anim)
	else:
		var idle_anim := "idle_%s" % last_facing
		if animator and (animator.animation != idle_anim or !animator.is_playing()):
			animator.play(idle_anim)

	move_and_slide()
