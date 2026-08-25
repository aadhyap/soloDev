extends Control

@onready var story_label = $VBoxContainer/StoryLabel
@onready var progress_bar = $VBoxContainer/ProgressBar

var target_text := "The city was quiet until the lights went out."
var typed_count := 0


func _ready():
	if GameState.current_task == null:
		print("NO CURRENT TASK")
		return

	var data = GameState.current_task.task_data as WritingTaskData

	if data == null:
		print("WRITING TASK HAS NO WRITING DATA")
		return

	target_text = data.prompt

	typed_count = 0
	progress_bar.value = 0

	update_story_display()


func _input(event):
	if not event is InputEventKey:
		return

	if not event.pressed:
		return

	if event.echo:
		return

	if typed_count >= target_text.length():
		return

	if event.unicode == 0:
		return

	var pressed_character = String.chr(event.unicode)
	var expected_character = target_text[typed_count]

	# Wrong letter = do absolutely nothing
	if pressed_character != expected_character:
		return

	typed_count += 1

	update_story_display()
	update_progress()

	if typed_count >= target_text.length():
		writing_complete()


func update_story_display():
	var completed_text = target_text.substr(0, typed_count)
	var remaining_text = target_text.substr(typed_count)

	story_label.text = (
		"[color=white]" +
		completed_text +
		"[/color]" +
		"[color=#666666]" +
		remaining_text +
		"[/color]"
	)


func update_progress():
	progress_bar.value = (
		float(typed_count) /
		float(target_text.length())
	) * 100.0


func writing_complete():
	GameState.complete_current_task()
	GameState.current_task = null

	get_tree().change_scene_to_file("res://dashboard.tscn")


func _on_back_button_pressed():
	GameState.current_task = null
	get_tree().change_scene_to_file("res://dashboard.tscn")
