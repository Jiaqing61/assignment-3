extends Node2D

@export var max_distance: float = 2000.0
@export var max_reflections: int = 10
@export_flags_2d_physics var collision_mask := 1

var _points: PackedVector2Array = PackedVector2Array()

@onready var muzzle: Node2D = $Muzzle

func _physics_process(_delta: float) -> void:
	_update_laser()

func _update_laser() -> void:
	_points.clear()

	# 激光从 Muzzle 的位置发射
	var from_pos: Vector2 = muzzle.global_position
	# 激光方向 = Muzzle 的本地 X 轴方向（红色箭头）
	var direction: Vector2 = muzzle.global_transform.x.normalized()
	var remaining_distance: float = max_distance

	# 第一个点：Muzzle 的位置（转到发射器本地坐标）
	_points.append(to_local(from_pos))

	var space_state := get_world_2d().direct_space_state

	for i in range(max_reflections):
		var to_pos: Vector2 = from_pos + direction * remaining_distance

		var query := PhysicsRayQueryParameters2D.create(from_pos, to_pos)
		query.collision_mask = int(collision_mask)
		query.exclude = [self]

		var result := space_state.intersect_ray(query)

		if result.is_empty():
			_points.append(to_local(to_pos))
			break

		var hit_pos: Vector2 = result.position
		var hit_normal: Vector2 = result.normal
		var collider = result.collider

		_points.append(to_local(hit_pos))

		if collider != null and collider.is_in_group("Mirror"):
			var traveled: float = from_pos.distance_to(hit_pos)
			remaining_distance -= traveled
			if remaining_distance <= 1.0:
				break

			# 反射：根据法线计算新方向
			direction = direction.bounce(hit_normal).normalized()
			from_pos = hit_pos + direction * 0.5
			continue
		else:
			break

	$Line2D.points = _points
