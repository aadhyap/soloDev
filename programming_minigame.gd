extends Control

@onready var graph: GraphEdit = $GraphEdit

var level_data: ProgrammingTaskData


const PORT_TYPES = {
	"blue": {
		"type": 0,
		"color": Color("#27c7d9")
	},
	"green": {
		"type": 1,
		"color": Color("#35d05b")
	},
	"red": {
		"type": 2,
		"color": Color("#e84c4c")
	},
	"yellow": {
		"type": 3,
		"color": Color("#e8d44c")
	},
	"purple": {
		"type": 4,
		"color": Color("#a75cff")
	}
}


func _ready():
	graph.connection_request.connect(_on_connection_request)
	graph.disconnection_request.connect(_on_disconnection_request)

	# Only allow matching port types/colors.
	for port_data in PORT_TYPES.values():
		var type = port_data["type"]
		graph.add_valid_connection_type(type, type)

	if GameState.current_task == null:
		print("NO CURRENT TASK")
		return

	level_data = GameState.current_task.task_data as ProgrammingTaskData

	if level_data == null:
		print("NO PROGRAMMING TASK DATA")
		return

	create_level(level_data)


func create_level(data: ProgrammingTaskData):
	for node_data in data.nodes:
		create_programming_node(node_data)


func create_programming_node(data: ProgrammingNodeData):
	var node = GraphNode.new()

	node.name = data.id
	node.title = data.title
	node.position_offset = data.start_position

	graph.add_child(node)

	# Number of rows needed is whichever side has more ports.
	var row_count = max(
		data.input_colors.size(),
		data.output_colors.size()
	)

	for i in range(row_count):
		var row = Label.new()

		row.text = " "
		row.custom_minimum_size = Vector2(140, 35)

		node.add_child(row)

		var has_input = i < data.input_colors.size()
		var has_output = i < data.output_colors.size()

		var input_type = 0
		var input_color = Color.WHITE

		var output_type = 0
		var output_color = Color.WHITE


		if has_input:
			var input_name = data.input_colors[i]

			if PORT_TYPES.has(input_name):
				input_type = PORT_TYPES[input_name]["type"]
				input_color = PORT_TYPES[input_name]["color"]


		if has_output:
			var output_name = data.output_colors[i]

			if PORT_TYPES.has(output_name):
				output_type = PORT_TYPES[output_name]["type"]
				output_color = PORT_TYPES[output_name]["color"]


		node.set_slot(
			i,
			has_input,
			input_type,
			input_color,
			has_output,
			output_type,
			output_color
		)


func _on_connection_request(
	from_node: StringName,
	from_port: int,
	to_node: StringName,
	to_port: int
):
	if graph.is_node_connected(
		from_node,
		from_port,
		to_node,
		to_port
	):
		return

	graph.connect_node(
		from_node,
		from_port,
		to_node,
		to_port
	)


func _on_disconnection_request(
	from_node: StringName,
	from_port: int,
	to_node: StringName,
	to_port: int
):
	graph.disconnect_node(
		from_node,
		from_port,
		to_node,
		to_port
	)


func _on_test_button_pressed():
	test_code()


func test_code():
	if level_data == null:
		print("NO LEVEL DATA")
		return

	var current_connections = graph.get_connection_list()

	# Wrong number of wires = immediately incorrect.
	if current_connections.size() != level_data.correct_connections.size():
		print("CODE FAILED")
		return

	# Check every required connection exists.
	for correct_connection in level_data.correct_connections:
		var found := false

		for current_connection in current_connections:
			var from_node = String(current_connection["from_node"])
			var from_port = int(current_connection["from_port"])

			var to_node = String(current_connection["to_node"])
			var to_port = int(current_connection["to_port"])

			if (
				from_node == correct_connection.from_node_id
				and from_port == correct_connection.from_port
				and to_node == correct_connection.to_node_id
				and to_port == correct_connection.to_port
			):
				found = true
				break

		if not found:
			print("CODE FAILED")
			return

	# If we made it through every required connection:
	programming_complete()


func programming_complete():
	print("CODE WORKS!")

	GameState.complete_current_task()
	GameState.current_task = null

	get_tree().change_scene_to_file(
		"res://dashboard.tscn"
	)


func _on_back_pressed():
	GameState.current_task = null

	get_tree().change_scene_to_file(
		"res://dashboard.tscn"
	)
