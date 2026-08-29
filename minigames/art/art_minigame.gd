extends Control

@onready var grid = $GridContainer
@onready var palette_container = $PalettePanel/PaletteContainer

@onready var brush_1_button = \
	$BrushPanel/VBoxContainer/BrushContainer/Brush1Button

@onready var brush_3_button = \
	$BrushPanel/VBoxContainer/BrushContainer/Brush3Button

@onready var brush_5_button = \
	$BrushPanel/VBoxContainer/BrushContainer/Brush5Button

@onready var cursor_color: Panel = $CursorColor
@onready var title_label = $TitleLabel2


var palette: Array[Color] = []
var image: Image

var selected_color_index := -1

var total_pixels_to_fill := 0
var filled_pixels := 0

var brush_size: int = 1


func _ready():
	cursor_color.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cursor_color.z_index = 50
	cursor_color.hide()

	if GameState.current_task == null:
		print("NO CURRENT TASK")
		return

	var data = GameState.current_task.task_data as ArtTaskData

	if data == null:
		print("ART TASK HAS NO ART DATA")
		return

	if data.sprite == null:
		print("ART TASK HAS NO SPRITE")
		return

	image = data.sprite.get_image()
	title_label.text = data.level_name

	var unique_colors: Array[Color] = []

	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var color: Color = image.get_pixel(x, y)

			if color.a < 0.1:
				continue

			if not unique_colors.has(color):
				unique_colors.append(color)

	unique_colors.sort_custom(
		func(a: Color, b: Color):
			return color_brightness(a) > color_brightness(b)
	)

	palette = unique_colors

	create_pixel_grid()
	create_palette()

	update_brush_buttons()
	update_cursor_size()

	if GameState.pending_dialogue != "":
		var dialogue_box = get_tree().get_first_node_in_group(
			"dialogue_box"
		)

		if dialogue_box:
			var dialogue_id = GameState.pending_dialogue
			
			GameState.pending_dialogue = ""
			GameState.mark_dialogue_seen(dialogue_id)

			dialogue_box.start(dialogue_id)


func _process(_delta):
	if selected_color_index == -1:
		cursor_color.hide()
		return

	cursor_color.show()

	cursor_color.global_position = (
		get_viewport().get_mouse_position()
		- cursor_color.size / 2.0
	)


func create_palette():
	for i in range(palette.size()):
		var button := Button.new()

		button.text = str(i + 1)
		button.custom_minimum_size = Vector2(55, 55)

		var style := StyleBoxFlat.new()
		style.bg_color = palette[i]

		button.add_theme_stylebox_override(
			"normal",
			style
		)

		button.add_theme_stylebox_override(
			"hover",
			style
		)

		var index := i

		button.pressed.connect(
			func():
				selected_color_index = index
				update_cursor_color()
		)

		palette_container.add_child(button)


func create_pixel_grid():
	grid.columns = image.get_width()

	var cell_size := get_cell_size()

	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var target_color: Color = image.get_pixel(x, y)

			var cell := Button.new()

			cell.custom_minimum_size = Vector2(
				cell_size,
				cell_size
			)

			cell.set_meta("grid_x", x)
			cell.set_meta("grid_y", y)

			if target_color.a < 0.1:
				cell.disabled = true
				cell.text = ""
				cell.modulate.a = 0.0

				grid.add_child(cell)
				continue

			var color_index := palette.find(target_color)

			cell.text = str(color_index + 1)

			cell.set_meta(
				"target_color_index",
				color_index
			)

			cell.set_meta(
				"filled",
				false
			)

			total_pixels_to_fill += 1

			cell.pressed.connect(
				func():
					paint_with_brush(
						cell.get_meta("grid_x"),
						cell.get_meta("grid_y")
					)
			)

			cell.mouse_entered.connect(
				func():
					if Input.is_mouse_button_pressed(
						MOUSE_BUTTON_LEFT
					):
						paint_with_brush(
							cell.get_meta("grid_x"),
							cell.get_meta("grid_y")
						)
			)

			grid.add_child(cell)


func paint_with_brush(
	center_x: int,
	center_y: int
) -> void:

	if selected_color_index == -1:
		return

	var radius: int = brush_size / 2

	for offset_y in range(
		-radius,
		radius + 1
	):
		for offset_x in range(
			-radius,
			radius + 1
		):
			var x := center_x + offset_x
			var y := center_y + offset_y

			if x < 0:
				continue

			if y < 0:
				continue

			if x >= image.get_width():
				continue

			if y >= image.get_height():
				continue

			var index := (
				y * image.get_width()
				+ x
			)

			var cell := grid.get_child(index) as Button

			if cell == null:
				continue

			try_paint_cell(cell)


func try_paint_cell(cell: Button) -> void:
	if cell.disabled:
		return

	if not cell.has_meta("filled"):
		return

	if cell.get_meta("filled"):
		return

	var target_index: int = cell.get_meta(
		"target_color_index"
	)

	# Only paint cells matching the selected color
	if target_index != selected_color_index:
		return

	var correct_color := palette[target_index]

	var style := StyleBoxFlat.new()
	style.bg_color = correct_color

	cell.add_theme_stylebox_override(
		"normal",
		style
	)

	cell.add_theme_stylebox_override(
		"hover",
		style
	)

	cell.add_theme_stylebox_override(
		"pressed",
		style
	)

	cell.text = ""

	cell.set_meta(
		"filled",
		true
	)

	filled_pixels += 1

	if filled_pixels >= total_pixels_to_fill:
		art_complete()


func get_cell_size() -> float:
	return 24.0


func update_cursor_size() -> void:
	var cell_size := get_cell_size()

	var ball_size := cell_size * brush_size

	cursor_color.size = Vector2(
		ball_size,
		ball_size
	)

	cursor_color.pivot_offset = (
		cursor_color.size / 2.0
	)

	update_cursor_color()


func update_cursor_color() -> void:
	if selected_color_index == -1:
		cursor_color.hide()
		return

	var style := StyleBoxFlat.new()

	style.bg_color = palette[selected_color_index]

	var radius := int(
		cursor_color.size.x / 2.0
	)

	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius

	cursor_color.add_theme_stylebox_override(
		"panel",
		style
	)

	cursor_color.show()


func color_brightness(color: Color) -> float:
	return (
		color.r * 0.299
		+ color.g * 0.587
		+ color.b * 0.114
	)


func art_complete():
	if GameState.current_task == null:
		print("NO CURRENT TASK")
		return

	print(
		"TASK COMPLETE: ",
		GameState.current_task.display_name
	)

	var member_id = (
		GameState.current_task.assigned_member_id
	)

	GameState.complete_current_task()

	var dialogue_box = get_tree().get_first_node_in_group(
		"dialogue_box"
	)

	if dialogue_box != null:
		var dialogue_id = member_id + "_kickout"

		dialogue_box.start(dialogue_id)

		await dialogue_box.finished

	GameState.current_task = null

	get_tree().change_scene_to_file(
		"res://dashboard.tscn"
	)


func _on_brush_1_button_pressed() -> void:
	brush_size = 1
	update_brush_buttons()
	update_cursor_size()


func _on_brush_3_button_pressed() -> void:
	brush_size = 3
	update_brush_buttons()
	update_cursor_size()


func _on_brush_5_button_pressed() -> void:
	brush_size = 5
	update_brush_buttons()
	update_cursor_size()


func update_brush_buttons() -> void:
	brush_1_button.disabled = brush_size == 1
	brush_3_button.disabled = brush_size == 3
	brush_5_button.disabled = brush_size == 5


func _on_back_button_pressed() -> void:
	GameState.current_task = null

	get_tree().change_scene_to_file(
		"res://dashboard.tscn"
	)
