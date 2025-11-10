extends Node2D

@export var max_distance: float = 2000.0
@export var max_reflections: int = 10
@export_flags_2d_physics var collision_mask := 1

@export var color = Color.WHITE

var _points: PackedVector2Array = PackedVector2Array()

@onready var muzzle: Node2D = $Muzzle

func _physics_process(_delta: float) -> void:
	_update_laser()

func _update_laser() -> void:
	_points.clear()

	var from_pos: Vector2 = muzzle.global_position
	var direction: Vector2 = muzzle.global_transform.x.normalized()
	var remaining_distance: float = max_distance

	_points.append(to_local(from_pos))

	var space_state := get_world_2d().direct_space_state

	for i in range(max_reflections):
		var to_pos: Vector2 = from_pos + direction * remaining_distance

		var query := PhysicsRayQueryParameters2D.create(from_pos, to_pos)
		query.collision_mask = int(collision_mask)
		query.exclude = [self]
		query.collide_with_areas = true
		query.collide_with_bodies = true

		var result := space_state.intersect_ray(query)

		if result.is_empty():
			_points.append(to_local(to_pos))
			break

		var hit_pos: Vector2 = result.position
		var hit_normal: Vector2 = result.normal
		var collider: Object = result.collider

		_points.append(to_local(hit_pos))

		if collider != null and collider.has_method("laser_hit"):
			collider.call("laser_hit", color, hit_pos, 1.0)

		var node: Node = collider as Node
		var is_mirror: bool = (node != null and node.is_in_group("Mirror"))
		var is_area: bool = (collider is Area2D)

		if is_mirror:
			var traveled: float = from_pos.distance_to(hit_pos)
			remaining_distance -= traveled
			if remaining_distance <= 1.0:
				break

			direction = direction.bounce(hit_normal).normalized()
			from_pos = hit_pos + direction * 0.5
			continue

		if is_area and (not is_mirror):
			var traveled2: float = from_pos.distance_to(hit_pos)
			remaining_distance -= traveled2
			if remaining_distance <= 1.0:
				break

			from_pos = hit_pos + direction * 0.5
			continue

		break

	$Line2D.points = _points
	$Line2D.default_color = color
