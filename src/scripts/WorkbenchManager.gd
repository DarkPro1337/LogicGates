extends Node

var workbench : GraphEdit
var node_offset = Vector2(0,0)

func add_gate(gate, type : String):
	var scene = load("res://src/gates/"+type+"/"+gate)
	var node = scene.instance()
	workbench.add_child(node, true)
	
	if node_offset >= Vector2(360,360):
		node_offset == Vector2(0,0)
	
	node_offset = Vector2(node_offset.x + 40, node_offset.y + 40)
	node.offset = node_offset

func add_gate_pos(gate, pos : Vector2, type : String):
	var scene = load("res://src/gates/"+type+"/"+gate)
	var node = scene.instance()
	workbench.add_child(node, true)
	node.offset = pos

