extends VBoxContainer

#func _ready():
#	update_gate_list()
#
#func update_gate_list():
#	var gate_types = {
#		"Логика": {
#			"AND":"res://src/gates/logic/AND.tscn",
#			"OR":"res://src/gates/logic/OR.tscn",
#			"NOT":"res://src/gates/logic/NOT.tscn",
#			"NAND":"res://src/gates/logic/NAND.tscn",
#			"NOR":"res://src/gates/logic/NOR.tscn",
#			"XOR":"res://src/gates/logic/XOR.tscn"
#		},
#		"Ввод/Вывод": {
#			"Кнопка":"res://src/gates/io/Press.tscn",
#			"Переключатель":"res://src/gates/io/Toggle.tscn",
#			"Светодиод":"res://src/gates/io/LED.tscn",
#			"Часы":"res://src/gates/io/Clock.tscn"
#		},
#	}
#
#	for gate_type in gate_types.keys():
#
#		var label_instance := Label.new()
#		label_instance.text = gate_type
#		label_instance.align = Label.ALIGN_LEFT
#		label_instance.valign = Label.VALIGN_CENTER
#		label_instance.rect_min_size = Vector2(32, 32)
#		label_instance.size_flags_horizontal = Control.SIZE_EXPAND_FILL
#
#		self.add_child(label_instance)
#
#		for gate in gate_types[gate_type].keys():
#			var gate_path = gate_types[gate_type][gate]
#
#			spawn_button(
#				self,
#				load("res://src/ui/GatesButton.tscn"),
#				gate,
#				gate_path
#			)
#
#func spawn_button(parent_node : Node, button : PackedScene, text : String, path : String):
#	var button_instance := button.instance()
#	button_instance.text = text
#	button_instance.load_path = path
#
#	button_instance.connect("pressed", self, "on_button_pressed")
#
#	parent_node.add_child(button_instance)
