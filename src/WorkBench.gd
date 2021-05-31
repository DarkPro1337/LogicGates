extends GraphEdit

var lastNodePosition = Vector2(0,0)
onready var LogicList = get_parent().get_node("MarginContainer/Menu/LogicList")
onready var IOList = get_parent().get_node("MarginContainer/Menu/IOList")
onready var LegendList = get_parent().get_node("MarginContainer/Menu/LegendList")

func _ready():
	WorkbenchManager.workbench = self
	EditorSingleton.graph = self

func get_list_item_text(list : ItemList, index):
	return list.get_item_text(index)

# inneficient, optimize later if possible
func get_node_connections(node_name):
	var conns := { "inputs":[], "outputs":[] }
	
	for conn in get_connection_list():
		if node_name == conn.from: conns.outputs.append(conn)
		if node_name == conn.to: conns.inputs.append(conn)
	
	return conns

func update_gate_inputs(gate):
	# inneficient, optimize later
	for i in range( gate.inputs.size() ):
		gate.inputs[i] = false
	
	for conn in get_node_connections(gate.name).inputs:
		get_node(conn.to).inputs[conn.to_port] = get_node(conn.from).outputs[conn.from_port]
	gate.update_io()

func save(save_game : Resource):
	save_game.data["graph_edit"] = ({
		"scroll_offset":var2str(scroll_offset),
		"zoom":zoom,
		"connection_list":get_connection_list()
	})

func _on_WorkBench_connection_request(from, from_slot, to, to_slot):
	connect_node(from, from_slot, to, to_slot)
	update_gate_inputs( get_node(to) )

func _on_WorkBench_disconnection_request(from, from_slot, to, to_slot):
	disconnect_node(from, from_slot, to, to_slot)
	update_gate_inputs( get_node(to) )

func _on_WorkBench_delete_nodes_request():
	for child in get_children():
		if child is GraphNode and child.is_selected():
			disconnect_gate_connections(child)
			child.queue_free()

func disconnect_gate_connections(gate):
	var conns = get_node_connections(gate)
		
	for conn in conns.inputs:
		disconnect_node(conn.from, conn.from_port, conn.to, conn.to_port)
	
	for conn in conns.outputs:
		disconnect_node(conn.from, conn.from_port, conn.to, conn.to_port)
		update_gate_inputs( get_node(conn.to) )

func _on_Gate_output_updated(gate):
	for conn in get_node_connections(gate.name).outputs:
		update_gate_inputs( get_node(conn.to) )

func _on_LogicList_item_activated(index):
	if(index == 0):
		WorkbenchManager.add_gate("AND.tscn", "logic")
	if(index == 2):
		WorkbenchManager.add_gate("OR.tscn", "logic")
	if(index == 5):
		WorkbenchManager.add_gate("NOT.tscn", "logic")
	if(index == 1):
		WorkbenchManager.add_gate("NAND.tscn", "logic")
	if(index == 3):
		WorkbenchManager.add_gate("NOR.tscn", "logic")
	if(index == 4):
		WorkbenchManager.add_gate("XOR.tscn", "logic")

func _on_IOList_item_activated(index):
	if(index == 0):
		WorkbenchManager.add_gate("CLK.tscn", "io")
	if(index == 1):
		WorkbenchManager.add_gate("LED.tscn", "io")
	if(index == 2):
		WorkbenchManager.add_gate("BTN.tscn", "io")
	if(index == 3):
		WorkbenchManager.add_gate("SW.tscn", "io")

func init_scene(e, location):
	var scene = load("res://src/gates/"+e)
	var node = scene.instance()
	var offset
	
	if !location:
		offset = Vector2(lastNodePosition.x + 20, lastNodePosition.y + 20)
	else:
		offset = Vector2(location.x, location.y)
	
	get_parent().get_node("WorkBench").add_child(node)
	node.set_offset(offset)
	node.set_name(node.get_name().replace('@', ''))
	lastNodePosition = node.get_offset()
	
	#history management
	EditorSingleton.overwrite_history()
	EditorSingleton.add_history(e.split('.tscn')[0], node.name, offset, '', [], 'add')
	EditorSingleton.update_stats(node.name, '1')
	EditorSingleton.has_graph = true
	
	return node.name

func can_drop_data(pos, data):
	return true

func drop_data(pos, data):
	var nodes = EditorSingleton.node_names
	var io = EditorSingleton.io_names
	var localMousePos = self.get_node("CLAYER").get_local_mouse_position()
	for i in range(0, nodes.size()):
		if nodes[i] in data:
			if nodes[i] == data:
				WorkbenchManager.add_gate_pos(nodes[i]+".tscn", localMousePos, "logic")
				
	for i in range(0, io.size()):
		if io[i] in data:
			if io[i] == data:
				WorkbenchManager.add_gate_pos(io[i]+".tscn", localMousePos, "io")

func _on_LogicList_item_selected(index):
	var text : String
	match get_list_item_text(LogicList, index):
		"NOT":
			text = "НЕ"
		"AND":
			text = "И"
		"OR":
			text = "ИЛИ"
		"NAND":
			text = "НЕ И (И-НЕ)"
		"NOR":
			text = "НЕ ИЛИ (ИЛИ-НЕ)"
		"XOR":
			text = "Исключающее ИЛИ"
	LegendList.set_item_text(0, text)
	LegendList.set_item_text(1, "")
	LegendList.set_item_icon(1, load("res://src/ui/legend/"+get_list_item_text(LogicList, index)+".png"))
