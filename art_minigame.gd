extends Control

@onready var grid = $GridContainer

const GRID_SIZE = 5

# 1 = should be filled
# 0 = should stay empty
var target_pattern = [
	0, 1, 0, 1, 0,
	1, 1, 1, 1, 1,
	1, 1, 1, 1, 1,
	0, 1, 1, 1, 0,
	0, 0, 1, 0, 0
]

var filled_count := 0
var total_needed := 0


func _ready():
	create_pixel_grid()


func create_pixel_grid():
	for value in target_pattern:
		if value == 1:
			total_needed += 1

	for i in range(GRID_SIZE * GRID_SIZE):
		var pixel = Button.new()

		pixel.custom_minimum_size = Vector2(60, 60)
		pixel.text = ""

		# Show the pixels that need to be filled as faded red
		if target_pattern[i] == 1:
			set_pixel_color(pixel, Color(0.3, 0.1, 0.1))

		pixel.pressed.connect(
			func():
				on_pixel_pressed(pixel, i)
		)

		grid.add_child(pixel)


func on_pixel_pressed(pixel: Button, index: int):
	if target_pattern[index] != 1:
		print("WRONG PIXEL")
		return

	# Already filled
	if pixel.has_meta("filled"):
		return

	pixel.set_meta("filled", true)

	# Solid red
	set_pixel_color(pixel, Color(0.571, 0.155, 0.466, 1.0))

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

	print("TASK COMPLETE: ", GameState.current_task.display_name)

	GameState.complete_current_task()

	GameState.current_task = null

	get_tree().change_scene_to_file("res://dashboard.tscn")
