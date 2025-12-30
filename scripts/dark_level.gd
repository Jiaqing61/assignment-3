extends Node2D

@export var player_reveal_radius := 20.0
@export var player_reveal_feather := 20.0
@export var reveal_radius   := 18.0
@export var reveal_feather  := 18.0


func _ready():
	var drawer = get_node_or_null("DarknessLayer/MaskViewport/LaserMaskDrawer")
	AudioManager.play_music(&"BGM", 0.0)
	
	if drawer == null and has_node("%LaserMaskDrawer"):
		drawer = get_node("%LaserMaskDrawer")
	if drawer:
		LaserVisibilityMask.drawer = drawer
		# print("✅ Success: LaserMaskDrawer found and registered!")
	else:
		push_error("❌ CRITICAL: Could not find LaserMaskDrawer! Check the path in dark_level.gd")
	
func _process(_dt):
	LaserVisibilityMask.begin()   # cleaning last frame
	# collect LaserEmitters
	for emitter in get_tree().get_nodes_in_group("LaserEmitters"):
		if emitter.has_method("get_points_global"):
			LaserVisibilityMask.add_path_world(emitter.get_points_global())
	# collect Revealables
	for r in get_tree().get_nodes_in_group("Revealables"):
		if r.has_method("is_lit") and r.is_lit():
			var pos :Vector2 = r.get_reveal_position() if r.has_method("get_reveal_position") else r.global_position
			var rad :float = r.reveal_radius if r.has_method("reveal_radius") else reveal_radius
			LaserVisibilityMask.add_reveal_world(pos, rad, reveal_feather)
	# collect player
	var player : CharacterBody2D = get_tree().get_first_node_in_group("Player")
	if player:
		var pos: Vector2 = player.global_position
		LaserVisibilityMask.add_reveal_world(pos, player_reveal_radius, player_reveal_feather)
	# collect AlwaysReveal	
	for node in get_tree().get_nodes_in_group("AlwaysReveal"):
		if "global_position" in node:
			var pos: Vector2 = node.global_position
			LaserVisibilityMask.add_reveal_world(pos, reveal_radius, reveal_feather)			



func _on_dark_room_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") or body.name == "Player":
		# print("Player entered Dark Room") # 调试信息
		# 通知所有黑暗控制器开始变黑
		get_tree().call_group("DarknessController", "fade_in_darkness", 1.0)
		


func _on_dark_room_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player") or body.name == "Player":
		# print("Player exited Dark Room") # 调试信息
		# 通知所有黑暗控制器变亮
		get_tree().call_group("DarknessController", "fade_out_darkness", 1.0) 
