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

	# Only same colors can connect.
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

	# Save the level-data reference on the generated GraphNode.
	node.set_meta("node_data", data)

	graph.add_child(node)

	var row_count = max(
		data.inputs.size(),
		data.outputs.size()
	)

	for i in range(row_count):
		var row = Label.new()
		row.text = " "
		row.custom_minimum_size = Vector2(140, 35)

		node.add_child(row)

		var has_input = i < data.inputs.size()
		var has_output = i < data.outputs.size()

		var input_type = 0
		var input_color = Color.WHITE

		var output_type = 0
		var output_color = Color.WHITE

		if has_input:
			var input_data: ProgrammingPortData = data.inputs[i]

			if PORT_TYPES.has(input_data.color):
				input_type = PORT_TYPES[input_data.color]["type"]
				input_color = PORT_TYPES[input_data.color]["color"]

		if has_output:
			var output_data: ProgrammingPortData = data.outputs[i]

			if PORT_TYPES.has(output_data.color):
				output_type = PORT_TYPES[output_data.color]["type"]
				output_color = PORT_TYPES[output_data.color]["color"]

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
	var connections = graph.get_connection_list()

	# First make sure EVERY required input is connected.
	for node_data in level_data.nodes:
		for input_index in range(node_data.inputs.size()):
			var input_data: ProgrammingPortData = node_data.inputs[input_index]

			if input_data.connection_key == "":
				continue

			var found := false

			for connection in connections:
				if (
					String(connection["to_node"]) == node_data.id
					and int(connection["to_port"]) == input_index
				):
					found = true
					break

			if not found:
				print(
					"CODE FAILED - MISSING INPUT: ",
					node_data.id,
					" / ",
					input_data.connection_key
				)
				return

	# Then verify every wire connects matching hidden keys.
	for connection in connections:
		var from_node_id = String(connection["from_node"])
		var from_port = int(connection["from_port"])

		var to_node_id = String(connection["to_node"])
		var to_port = int(connection["to_port"])

		var from_data = get_node_data(from_node_id)
		var to_data = get_node_data(to_node_id)

		if from_data == null or to_data == null:
			print("CODE FAILED - UNKNOWN NODE")
			return

		if from_port >= from_data.outputs.size():
			print("CODE FAILED - INVALID OUTPUT")
			return

		if to_port >= to_data.inputs.size():
			print("CODE FAILED - INVALID INPUT")
			return

		var output_data: ProgrammingPortData = from_data.outputs[from_port]
		var input_data: ProgrammingPortData = to_data.inputs[to_port]

		if output_data.connection_key != input_data.connection_key:
			print(
				"CODE FAILED: ",
				output_data.connection_key,
				" DOES NOT MATCH ",
				input_data.connection_key
			)
			return

	programming_complete()


func get_node_data(node_id: String) -> ProgrammingNodeData:
	for node_data in level_data.nodes:
		if node_data.id == node_id:
			return node_data

	return null


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
