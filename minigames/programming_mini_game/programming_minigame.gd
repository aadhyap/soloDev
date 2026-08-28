extends Control

@onready var graph: GraphEdit = $GraphEdit

var level_data: ProgrammingTaskData

# Stores where every block originally spawned.
# Restart sends the blocks back to these positions.
var spawn_positions: Dictionary = {}


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

	graph.right_disconnects = true

	# Only matching colors can connect.
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


# ---------------------------------------------------------
# CREATE LEVEL
# ---------------------------------------------------------

func create_level(data: ProgrammingTaskData):
	for i in range(data.nodes.size()):
		var node_data: ProgrammingNodeData = data.nodes[i]

		var spawn_position = get_cluster_position(i)

		spawn_positions[node_data.id] = spawn_position

		create_programming_node(
			node_data,
			spawn_position
		)


# Makes the blocks spawn close together in rows.
func get_cluster_position(index: int) -> Vector2:
	var columns := 3

	var column := index % columns
	var row := index / columns

	var start_position := Vector2(120, 100)

	var horizontal_spacing := 210
	var vertical_spacing := 150

	return start_position + Vector2(
		column * horizontal_spacing,
		row * vertical_spacing
	)


func create_programming_node(
	data: ProgrammingNodeData,
	spawn_position: Vector2
):
	var node = GraphNode.new()

	node.name = data.id
	node.title = data.title

	node.position_offset = spawn_position

	node.set_meta("node_data", data)

	graph.add_child(node)

	# START = GREEN
	if data.id.to_lower() == "start":
		set_node_header_color(
			node,
			Color("#35d05b")
		)

	# END = RED
	elif data.id.to_lower() == "end":
		set_node_header_color(
			node,
			Color("#e84c4c")
		)

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


# ---------------------------------------------------------
# START / END COLORS
# ---------------------------------------------------------

func set_node_header_color(
	node: GraphNode,
	color: Color
):
	var style := StyleBoxFlat.new()

	style.bg_color = color

	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6

	node.add_theme_stylebox_override(
		"titlebar",
		style
	)

	node.add_theme_stylebox_override(
		"titlebar_selected",
		style
	)


# ---------------------------------------------------------
# CONNECTIONS
# ---------------------------------------------------------

func _on_connection_request(
	from_node: StringName,
	from_port: int,
	to_node: StringName,
	to_port: int
):
	var connections = graph.get_connection_list()

	# OUTPUT can only connect to ONE thing.
	for connection in connections:
		if (
			connection["from_node"] == from_node
			and int(connection["from_port"]) == from_port
		):
			graph.disconnect_node(
				connection["from_node"],
				connection["from_port"],
				connection["to_node"],
				connection["to_port"]
			)

	# INPUT can only receive ONE connection.
	connections = graph.get_connection_list()

	for connection in connections:
		if (
			connection["to_node"] == to_node
			and int(connection["to_port"]) == to_port
		):
			graph.disconnect_node(
				connection["from_node"],
				connection["from_port"],
				connection["to_node"],
				connection["to_port"]
			)

	# Make the new connection.
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


# ---------------------------------------------------------
# RESTART
# ---------------------------------------------------------

func _on_restart_button_pressed():
	restart_level()


func restart_level():
	# Remove EVERY wire.
	var connections = graph.get_connection_list()

	for connection in connections:
		graph.disconnect_node(
			connection["from_node"],
			connection["from_port"],
			connection["to_node"],
			connection["to_port"]
		)

	# Move every block back to where it originally spawned.
	for child in graph.get_children():
		if child is GraphNode:
			var node := child as GraphNode
			var node_id := String(node.name)

			if spawn_positions.has(node_id):
				node.position_offset = spawn_positions[node_id]

	print("LEVEL RESTARTED")


# ---------------------------------------------------------
# TEST CODE
# ---------------------------------------------------------

func _on_test_button_pressed():
	test_code()


func test_code():
	var connections = graph.get_connection_list()

	# Make sure every required input is connected.
	for node_data in level_data.nodes:
		for input_index in range(node_data.inputs.size()):
			var input_data: ProgrammingPortData = \
				node_data.inputs[input_index]

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

	# Check every connection.
	for connection in connections:
		var from_node_id = String(
			connection["from_node"]
		)

		var from_port = int(
			connection["from_port"]
		)

		var to_node_id = String(
			connection["to_node"]
		)

		var to_port = int(
			connection["to_port"]
		)

		var from_data = get_node_data(
			from_node_id
		)

		var to_data = get_node_data(
			to_node_id
		)

		if from_data == null or to_data == null:
			print("CODE FAILED - UNKNOWN NODE")
			return

		if from_port >= from_data.outputs.size():
			print("CODE FAILED - INVALID OUTPUT")
			return

		if to_port >= to_data.inputs.size():
			print("CODE FAILED - INVALID INPUT")
			return

		var output_data: ProgrammingPortData = \
			from_data.outputs[from_port]

		var input_data: ProgrammingPortData = \
			to_data.inputs[to_port]

		if (
			output_data.connection_key
			!= input_data.connection_key
		):
			print(
				"CODE FAILED: ",
				output_data.connection_key,
				" DOES NOT MATCH ",
				input_data.connection_key
			)

			return

	programming_complete()


func get_node_data(
	node_id: String
) -> ProgrammingNodeData:

	for node_data in level_data.nodes:
		if node_data.id == node_id:
			return node_data

	return null


# ---------------------------------------------------------
# COMPLETE
# ---------------------------------------------------------

func programming_complete():
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
