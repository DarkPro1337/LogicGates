extends Control

# All UI elements onready init for ease of using them
onready var FileButton = $VSplitContainer/HSplitContainer/HBoxContainer/FileButton
onready var EditButton = $VSplitContainer/HSplitContainer/HBoxContainer/EditButton
onready var HelpButton = $VSplitContainer/HSplitContainer/HBoxContainer/HelpButton
onready var NewDialog  = $NewDialog
onready var QuitDialog = $QuitDialog
onready var OpenFileDialog = $OpenFileDialog
onready var SaveFileDialog = $SaveFileDialog
onready var AboutDialog = $AboutDialog
onready var FileTypeError = $FileTypeError
onready var WorkBench = $VSplitContainer/HSplitContainer2/WorkBench

func _ready():
	TranslationServer.set_locale("ru") # RU locale as default
	
	# MenuButton popup shotcuts init
	## Yes, this looks like shit, but it works :P
	
	## File Menu popup shortcuts
	### CTRL + N
	var ctrl_new = ShortCut.new()
	var input_new = InputEventKey.new()
	input_new.set_scancode(KEY_N)
	input_new.control = true
	ctrl_new.set_shortcut(input_new)
	### CTRL + O
	var ctrl_open = ShortCut.new()
	var input_open = InputEventKey.new()
	input_open.set_scancode(KEY_O)
	input_open.control = true
	ctrl_open.set_shortcut(input_open)
	### CTRL + S
	var ctrl_save = ShortCut.new()
	var input_save = InputEventKey.new()
	input_save.set_scancode(KEY_S)
	input_save.control = true
	ctrl_save.set_shortcut(input_save)
	
	## Edit Menu popup shortcuts
	### CTRL + z
	var ctrl_undo = ShortCut.new()
	var input_undo = InputEventKey.new()
	input_undo.set_scancode(KEY_Z)
	input_undo.control = true
	ctrl_undo.set_shortcut(input_undo)
	### CTRL + Y
	var ctrl_redo = ShortCut.new()
	var input_redo = InputEventKey.new()
	input_redo.set_scancode(KEY_Y)
	input_redo.control = true
	ctrl_redo.set_shortcut(input_redo)
	
	## Edit Menu popup shortcuts
	### F1
	var ctrl_help = ShortCut.new()
	var input_help = InputEventKey.new()
	input_help.set_scancode(KEY_F1)
	input_help.control = false
	ctrl_help.set_shortcut(input_help)
	
	## File Menu popup shortcuts assign
	FileButton.get_popup().set_item_shortcut(0, ctrl_new, true)
	FileButton.get_popup().set_item_shortcut(1, ctrl_open, true)
	FileButton.get_popup().set_item_shortcut(3, ctrl_save, true)
	## Edit Menu popup shortcuts assign
	EditButton.get_popup().set_item_shortcut(0, ctrl_undo, true)
	EditButton.get_popup().set_item_shortcut(1, ctrl_redo, true)
	## Help Menu popup shortcuts assign
	HelpButton.get_popup().set_item_shortcut(0, ctrl_help, true)
	
	# File Menu connections
	FileButton.get_popup().connect("id_pressed", self, "_file_on_item_pressed")
	# Edit Menu connections
	EditButton.get_popup().connect("id_pressed", self, "_edit_on_item_pressed")
	# Help Menu connections
	HelpButton.get_popup().connect("id_pressed", self, "_help_on_item_pressed")
	
	# Disable auto close on X pressed
	get_tree().set_auto_accept_quit(false)

# Handle X pressing, open QuitDialog instead of closing
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		QuitDialog.show()

# FileMenu items press event
func _file_on_item_pressed(id):
	if id == 0:
		NewDialog.show()
	elif id == 1:
		OpenFileDialog.show()
		OpenFileDialog.invalidate()
	elif id == 3:
		SaveFileDialog.show()
		SaveFileDialog.invalidate()
	elif id == 5:
		QuitDialog.show()

# EditMenu items press event
## Not working for now
func _edit_on_item_pressed(id):
	if id == 0:
		#TODO
		pass
	
	elif id == 1:
		#TODO
		pass

# HelpMenu item press event
func _help_on_item_pressed(id):
	if id == 0:
		pass
	elif id == 2:
		AboutDialog.show()

# Project Saving
func save_project(path : String):
	var project_save := ProjectSave.new()
	
	project_save.data.gates = []
	
	for node in get_tree().get_nodes_in_group("save"):
		node.save(project_save)
	
	var error := ResourceSaver.save(
		path,
		project_save
	)
	OS.set_window_title("LogicGates - " + SaveFileDialog.current_file)

# Project Loading
func load_project(path : String):
	WorkBench.clear_connections()
	for child in WorkBench.get_children():
		if child is GraphNode:
			child.free()
	
	# Check if file has .tres in file type and then check if it is a resource or not
	if path.find(".tres") == -1 or load(path).get_class() != "Resource":
		FileTypeError.show()
	else:
		var project_save : ProjectSave = load( path )
		
		for gate in project_save.data.gates:
			var gate_node = load(gate.filename).instance()
			
			for key in gate.keys():
				var value = gate[key]
				
				match key:
					"filename":
						continue
					"offset":
						value = str2var(value)
				
				gate_node.set(key, value)
			
			WorkBench.add_child(gate_node)
		
		for key in project_save.data.graph_edit.keys():
			var value = project_save.data.graph_edit[key]
			
			match key:
				"connection_list":
					for cnn in value:
						WorkBench.call_deferred("_on_WorkBench_connection_request", cnn.from, cnn.from_port, cnn.to, cnn.to_port)
				"scroll_offset":
					value = str2var(value)
				_:
					WorkBench.set(key, value)
		
		# Set project name in the window title
		OS.set_window_title("LogicGates - " + OpenFileDialog.current_file)

# New file confirm
func _on_NewDialog_confirmed():
	WorkBench.clear_connections()
	for child in WorkBench.get_children():
		if child is GraphNode:
			child.free()
	OS.set_window_title("LogicGates")

# Quit dialog confirm
func _on_QuitDialog_confirmed():
	get_tree().quit()

# SaveFile dialog selection
func _on_SaveFileDialog_file_selected(path):
	save_project(path)

# OpenFile dialog selection
func _on_OpenFileDialog_file_selected(path):
	load_project(path)

# GitHub link press
func _on_GitHub_pressed():
	OS.shell_open("https://github.com/DarkPro1337/LogicGates")

# KFGUMRF link press
func _on_KFGUMRF_pressed():
	OS.shell_open("https://www.kfgumrf.ru")
