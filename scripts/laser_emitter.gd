extends Node2D

# === Laser configuration ===
@export var max_distance: float = 2000.0        # Maximum laser length in pixels
@export var max_reflections: int = 10          # Maximum number of reflections
@export_flags_2d_physics var collision_mask := 1  # Physics layers the laser ray should hit
@export var color: Color = Color.WHITE         # Laser color (also used for laser_hit())
@export var turned_on = false

# === Player interaction (grab & rotate) ===
@export var follow_offset: Vector2 = Vector2.ZERO   # Offset from player while grabbed

# === Player interaction (grab & rotate) ===

@export var rotate_speed_deg: float = 90.0          # Degrees per second when holding rotate key
@export var max_grab_distance: float = 64.0         # Max distance between player and emitter while grabbed

# === Rail movement ===
@export var rail_tilemap: TileMapLayer             # TileMapLayer that defines the rail/path

var _points: PackedVector2Array = PackedVector2Array()

@onready var muzzle: Node2D = $Muzzle              # Laser origin point
@onready var area: Area2D = $Area2D                # Interaction area for the player
@onready var line: Line2D = $Line2D                # Line2D used to draw the laser

var _player_in_range: Node2D = null                # Last player detected inside Area2D
var _grabbed: bool = false                         # Is the emitter currently grabbed?
var _grabber: Node2D = null                        # Player that is currently grabbing the emitter


func _ready() -> void:
	# Auto-bind rail_tilemap: if not set in the inspector, search for a TileMapLayer
	# in the group "LaserRail" in the current scene tree.
	if rail_tilemap == null:
		var node := get_tree().get_first_node_in_group("LaserRail")
		if node != null and node is TileMapLayer:
			rail_tilemap = node
		else:
			push_warning("LaserEmitter: No TileMapLayer in group 'LaserRail' found. Emitter will move freely off-rail.")

	# Connect area signals for detecting when the player enters / exits the interaction range
	area.body_entered.connect(_on_area_body_entered)
	area.body_exited.connect(_on_area_body_exited)

	# Set initial laser color on the Line2D
	line.default_color = color




func _physics_process(delta: float) -> void:
	_handle_input(delta)
	_update_grab_follow(delta)
	if turned_on:
		_update_laser()
	else:
		_points.clear()
		line.points = _points


# ============================
# Player interaction
# ============================
func _handle_input(delta: float) -> void:
	# V key (grab_emitter): pick up or drop the emitter
	if Input.is_action_just_pressed("grab_emitter"):
		if _grabbed:
			_release()
		elif _player_in_range != null:
			_grab(_player_in_range)




func _update_grab_follow(_delta: float) -> void:
	if not _grabbed:
		return

	if not is_instance_valid(_grabber):
		_release()
		return

	var target_pos: Vector2 = _grabber.global_position + follow_offset
	target_pos = _snap_to_rail(target_pos)

	# If snapping kept us at the old position (no rail under target_pos),
	# we may end up being very far from the player; if too far, release.
	if global_position.distance_to(_grabber.global_position) > max_grab_distance * 2.0:
		_release()
		return

	global_position = target_pos


	# If the grabbing player no longer exists, release the emitter
	if not is_instance_valid(_grabber):
		_release()
		return


	# Snap the desired position to the rail; this will keep the emitter on the rail tiles
	target_pos = _snap_to_rail(target_pos)

	# Update actual position
	global_position = target_pos


func _grab(player: Node2D) -> void:
	_grabbed = true
	_grabber = player
	# Record current offset relative to the player so movement feels natural
	follow_offset = global_position - player.global_position


func _release() -> void:
	_grabbed = false
	_grabber = null


func _on_area_body_entered(body: Node2D) -> void:
	# Only care about nodes that are tagged as "Player"
	if body.is_in_group("Player"):
		_player_in_range = body


func _on_area_body_exited(body: Node2D) -> void:
	if body == _player_in_range:
		_player_in_range = null
		# Auto-release when the player leaves the interaction area
		if _grabbed and body == _grabber:
			_release()


# ============================
# Rail logic
# ============================
func _snap_to_rail(world_pos: Vector2) -> Vector2:
	"""
	Given a desired world position, snap it to the nearest rail tile.
	If there is no rail tile at that position, keep the current emitter position
	so it cannot move off the rail.
	"""
	if rail_tilemap == null:
		# No rail assigned: allow free movement
		return world_pos

	# Convert world position into the rail tilemap's local space
	var local_pos: Vector2 = rail_tilemap.to_local(world_pos)

	# Convert local position to tile coordinates
	var cell: Vector2i = rail_tilemap.local_to_map(local_pos)

	# Check if there is a tile in layer 0 at that cell
	var source_id := rail_tilemap.get_cell_source_id(cell)
	if source_id == -1:
		# No rail tile here -> do not move onto non-rail ground
		return global_position

	# There is a rail tile: snap to the center of this cell
	var snapped_local: Vector2 = rail_tilemap.map_to_local(cell)
	var snapped_world: Vector2 = rail_tilemap.to_global(snapped_local)
	return snapped_world


# ============================
# Laser casting & drawing
# ============================
func _update_laser() -> void:
	_points.clear()

	var from_pos: Vector2 = muzzle.global_position
	var direction: Vector2 = muzzle.global_transform.x.normalized()
	var remaining_distance: float = max_distance

	# First point = muzzle position in emitter's local space
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
			# No collision: draw to the full remaining distance
			_points.append(to_local(to_pos))
			break

		var hit_pos: Vector2 = result.position
		var hit_normal: Vector2 = result.normal
		var collider: Object = result.collider

		# Add hit position to the polyline (in local coordinates)
		_points.append(to_local(hit_pos))

		# Optional: call laser_hit() on objects that implement it
		if collider != null and collider.has_method("laser_hit"):
			collider.call("laser_hit", color, hit_pos, 1.0)

		var node: Node = collider as Node
		var is_mirror: bool = (node != null and node.is_in_group("Mirror"))
		var is_area: bool = (collider is Area2D)

		if is_mirror:
			# Reflect on mirror
			var traveled: float = from_pos.distance_to(hit_pos)
			remaining_distance -= traveled
			if remaining_distance <= 1.0:
				break

			direction = direction.bounce(hit_normal).normalized()
			from_pos = hit_pos + direction * 0.5
			continue

		if is_area and not is_mirror:
			# Hit an Area2D that is not a mirror; continue in same direction
			var traveled2: float = from_pos.distance_to(hit_pos)
			remaining_distance -= traveled2
			if remaining_distance <= 1.0:
				break

			from_pos = hit_pos + direction * 0.5
			continue

		# Hit a solid object that is not a mirror: stop the laser
		break

	line.points = _points
	line.default_color = color


func get_points_global() -> PackedVector2Array:
	"""
	Returns the current laser polyline points in global coordinates.
	"""
	var gp := PackedVector2Array()
	for p in _points:
		gp.append(to_global(p))
	return gp
