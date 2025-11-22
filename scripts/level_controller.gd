extends Node

#@export var chests: Array[NodePath] = []
#@export var final_gate: NodePath
#
#@export var reveal_radius := 24.0 
#@export var reveal_feather := 24.0
#
#var _lit_count := 0
#var _chest_nodes: Array[Node] = []
#
#func _process(_dt):
	#LaserVisibilityMask.begin()   # cleaning last frame
	## collect laser
	#for emitter in get_tree().get_nodes_in_group("LaserEmitters"):
		#if emitter.has_method("get_points_global"):
			#LaserVisibilityMask.add_path_world(emitter.get_points_global())
	#
	#for r in get_tree().get_nodes_in_group("Revealables"):
		#if r.has_method("is_lit") and r.is_lit():
			#var pos :Vector2 = r.get_reveal_position() if r.has_method("get_reveal_position") else r.global_position
			#var rad :float = r.reveal_radius if r.has_method("reveal_radius") else reveal_radius
			#LaserVisibilityMask.add_reveal_world(pos, rad, reveal_feather)
	#
	#var player : CharacterBody2D = get_tree().get_first_node_in_group("Player")
	#if player:
		#var pos: Vector2 = player.global_position
		#LaserVisibilityMask.add_reveal_world(pos, reveal_radius, reveal_feather)
		#
	#for door in get_tree().get_nodes_in_group("AlwaysReveal"):
		#var pos: Vector2 = door.global_position
		#LaserVisibilityMask.add_reveal_world(pos, reveal_radius, reveal_feather)			
#
#
#func _ready() -> void:
	#_wireup()
#
#func _wireup() -> void:
	#_lit_count = 0
	#_chest_nodes.clear()
#
	#for np in chests:
		#var c := get_node_or_null(np)
		#if c:
			#_chest_nodes.append(c)
			#if c.has_signal("lit_changed"):
				#c.connect("lit_changed", _on_chest_lit_changed)
#
#func _on_chest_lit_changed(lit: bool) -> void:
	#_lit_count += (1 if lit else -1)
	#_lit_count = clampi(_lit_count, 0, _chest_nodes.size())
#
	#if _lit_count == _chest_nodes.size():
		#_try_open_gate()
#
#func _try_open_gate() -> void:
	#var gate := get_node_or_null(final_gate)
	#if gate and gate.has_method("open_gate"):
		#gate.open_gate()
