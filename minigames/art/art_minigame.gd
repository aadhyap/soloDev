extends Control

@onready var grid = $GridContainer

var grid_width := 0
var grid_height := 0
var target_pattern: Array[int] = []

var filled_count := 0
var total_needed := 0


func _ready():
	if GameState.current_task == null:
		print("NO CURRENT TASK")
		return

	var data = GameState.current_task.task_data as ArtTaskData

	if data == null:
		print("ART TASK HAS NO ART DATA")
		return

	grid_width = data.grid_width
	grid_height = data.grid_height
	target_pattern = parse_pattern(data.pattern)

	grid.columns = grid_width

	create_pixel_grid()
	
	if GameState.pending_dialogue != "":
		var dialogue_box = get_tree().get_first_node_in_group("dialogue_box")

		if dialogue_box:
			var dialogue_id = GameState.pending_dialogue

			GameState.pending_dialogue = ""
			GameState.mark_dialogue_seen(dialogue_id)

			dialogue_box.start(dialogue_id)


func create_pixel_grid():
	total_needed = 0

	for value in target_pattern:
		if value == 1:
			total_needed += 1

	for i in range(grid_width * grid_height):
		var pixel = Button.new()

		pixel.custom_minimum_size = Vector2(60, 60)
		pixel.text = ""

		# Faded target pixel
		if target_pattern[i] == 1:
			set_pixel_color(
				pixel,
				Color(0.3, 0.1, 0.1)
			)

		pixel.pressed.connect(
			func():
				on_pixel_pressed(pixel, i)
		)

		grid.add_child(pixel)


func on_pixel_pressed(pixel: Button, index: int):
	if target_pattern[index] != 1:
		print("WRONG PIXEL")
		return

	if pixel.has_meta("filled"):
		return

	pixel.set_meta("filled", true)

	# Filled pixel
	set_pixel_color(
		pixel,
		Color(0.571, 0.155, 0.466, 1.0)
	)

	filled_count += 1

	if filled_count >= total_needed:
		art_complete()


func set_pixel_color(pixel: Button, color: Color):
	var style = StyleBoxFlat.new()
	style.bg_color = color

	pixel.add_theme_stylebox_override("normal", style)
	pixel.add_theme_stylebox_override("hover", style)
	pixel.add_theme_stylebox_override("pressed", style)


func art_complete():
	if GameState.current_task == null:
		print("NO CURRENT TASK")
		return

	print(
		"TASK COMPLETE: ",
		GameState.current_task.display_name
	)

	var member_id = GameState.current_task.assigned_member_id

	GameState.complete_current_task()

	var dialogue_box = get_tree().get_first_node_in_group("dialogue_box")

	if dialogue_box != null:
		var dialogue_id = member_id + "_kickout"

		dialogue_box.start(dialogue_id)

		await dialogue_box.finished

	GameState.current_task = null

	get_tree().change_scene_to_file(
		"res://dashboard.tscn"
	)

func parse_pattern(pattern: String) -> Array[int]:
	var result: Array[int] = []

	for character in pattern:
		if character == "0":
			result.append(0)

		elif character == "1":
			result.append(1)

	return result


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file(
		"res://dashboard.tscn"
	)
