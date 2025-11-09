# level_controller.gd (Godot 4.x)
extends Node

@export var chests: Array[NodePath] = []
@export var final_gate: NodePath

var _lit_count := 0
var _chest_nodes: Array[Node] = []

func _ready() -> void:
	_wireup()

func _wireup() -> void:
	_lit_count = 0
	_chest_nodes.clear()

	for np in chests:
		var c := get_node_or_null(np)
		if c:
			_chest_nodes.append(c)
			if c.has_signal("lit_changed"):
				c.connect("lit_changed", _on_chest_lit_changed)

func _on_chest_lit_changed(lit: bool) -> void:
	_lit_count += (1 if lit else -1)
	_lit_count = clampi(_lit_count, 0, _chest_nodes.size())

	if _lit_count == _chest_nodes.size():
		_try_open_gate()

func _try_open_gate() -> void:
	var gate := get_node_or_null(final_gate)
	if gate and gate.has_method("open_gate"):
		gate.open_gate()
