extends Node

var graph : GraphEdit
var in_menu : = false
var test : = true

var loaded_player_vars : = false
var loaded_player_funcs : = false
var has_player_singleton : = false

# For history
var current_history : = 0
var history_objects = Dictionary()
var last_save : = 0

var node_names : = ['AND', 'OR', 'NOT', 'NAND', 'NOR', 'XOR']
var io_names : = ['CLK', 'LED', 'BTN', 'SW']
var has_graph : = false

func get_node_type(name : String):
	var regex : = RegEx.new()
	regex.compile("[a-zA-Z]+")
	var result : RegExMatch = regex.search(name)
	if result:
		return result.get_string()

#===== History Management
func overwrite_history() -> void:
	if current_history > 0:
		var new_history : = Dictionary()
		for i in range(0, current_history):
			new_history[i] = history_objects[i]
		# Overwrite history with our new one
		history_objects = new_history

func add_history(node, name, offset, text, connects_from, action) -> void:
	overwrite_history()
	history_objects[current_history] = {
			'node': node,
			'name': name,
			'offset': offset,
			'text': text,
			'connects_from': connects_from,
			'action': action
	}
	EditorSingleton.update_tab_title(true)
	current_history += 1

func undo_history() -> void:
	if history_objects.size() > 0 and current_history >= 2:
		# We're in the past
		var action : String = history_objects[current_history - 1]['action']
		var object : Dictionary = history_objects[current_history - 1]
		
		print(action)
		if action == 'remove':
			graph.load_node(object['node']+'.tscn', object['offset'], object['name'], object['text'], false)
		if action == 'move':
			if last_instance_of(object['name']):
				var last_instance = history_objects[last_instance_of(object['name'])]
				graph.get_node(object['name']).set_offset(last_instance['offset'])
		if action == 'text':
			var last_instance = history_objects[last_instance_of(object['name'])]
			graph.get_node(object['name']).get_node("Lines").get_child(0).set_text(last_instance['text'])
		if action == 'add':
			graph.get_node(object['name']).queue_free()
			update_stats(object['name'], '-1')
		
		if 'connect' in action:
			if action == 'connect':
				print('disconnect node')
				var connections = graph.get_connection_list()
				for i in range(0, connections.size()):
					if connections[i].to == object['name'] and not connections[i].from in object['connects_from']:
						graph.disconnect_node(connections[i].from, 0, object['name'], 0) 
			else:
				var last_instance = history_objects[last_instance_of(object['name'])]
				for i in range(0, last_instance['connects_from'].size()):
					graph.connect_node(last_instance['connects_from'][i+1], 0, object['name'], 0)
		
		current_history -= 1
		
		if last_save == current_history:
			update_tab_title(false)
			print('we are on last save')
		else:
			update_tab_title(true)
			print('we are unsaved!')

func last_instance_of(name : String) -> int:
	var last_instance_position : int
	for i in range(0, current_history - 1):
		if history_objects[i]['name'] == name:
			last_instance_position = i
	return last_instance_position

func connection_in_timeline(name : String) -> void:
	var list : Array = graph.get_connection_list()
	var connections : = Dictionary()
	var connects_from : = Array()
	
	for i in range(0, current_history - 1):
		if name == history_objects[i]['name']:
			connections = history_objects[i]['connects_from']

	var connection_count : int = connections.size()
	for i in range(0, connection_count):
		if connection_count > 0:
			connects_from.append(connections[i+1])

	for i in range(0, list.size()):
		if graph.has_node(list[i]['to']) and not list[i]['from'] in connects_from:
			graph.disconnect_node(list[i]['from'], 0, name, 0)
	
	for i in range(0, current_history - 1):
		if history_objects[i]['connects_from']:
			for j in range(0, history_objects[i]['connects_from'].size()):
				if history_objects[i]['connects_from'][j+1] != name and history_objects[i]['name'] == name:
					graph.connect_node(history_objects[i]['connects_from'][j+1], 0, name, 0)

func redo_history() -> void:
	if current_history < history_objects.size():
		# We're in the past
		var action : String = history_objects[current_history]['action']
		var object : Dictionary = history_objects[current_history]
		
		if action == 'remove':
			graph.get_node(object['name']).queue_free()
			update_stats(object['name'], '-1')
		if action == 'move':
			graph.get_node(object['name']).set_offset(object['offset'])
		if action == 'text':
			graph.get_node(object['name']).get_node("Lines").get_child(0).set_text(object['text'])
		if action == 'add':
			graph.load_node(object['node']+'.tscn', object['offset'], object['name'], object['text'], false)
		
		if 'connect' in action:
			if action == 'connect':
				for i in range(0, object['connects_from'].size()):
					graph.connect_node(object['connects_from'][i+1], 0, object['name'], 0)
			else:
				print('disconnect node')
				var connections = graph.get_connection_list()
				for i in range(0, connections.size()):
					if connections[i].to == object['name'] and not connections[i].from in object['connects_from']:
						graph.disconnect_node(connections[i].from, 0, object['name'], 0) 
		
		current_history += 1
	
		if last_save == current_history:
			update_tab_title(false)
			print('we are on last save')
		else:
			update_tab_title(true)
			print('we are unsaved!')

func update_tab_title(unsaved : bool) -> void:
##	if unsaved:
#		graph.set_tab_title(0, 'Dialogue Graph*')
#	else:
#		graph.set_tab_title(0, 'Dialogue Graph')
#
#	graph.update()
	pass

func update_stats(what : String, amount : String) -> void:
#	if 'Option' in what:
#		var amount_node = get_node("/root/Editor/Mount/MainWindow/Editor/Info/Nodes/Stats/PanelContainer/StatsCon/ONodes/Amount")
#		amount_node.set_text(str(int(amount_node.get_text()) + int(amount)))
#	if 'Dialogue' in what:
#		var amount_node = get_node("/root/Editor/Mount/MainWindow/Editor/Info/Nodes/Stats/PanelContainer/StatsCon/DNodes/Amount")
#		amount_node.set_text(str(int(amount_node.get_text()) + int(amount)))
	pass
