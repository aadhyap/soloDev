extends Control

@onready var story_label = $DocumentPanel/MarginContainer/VBoxContainer/WritingRow/StoryLabel
@onready var progress_bar = $ProgressBar

var target_text := "The city was quiet until the lights went out."
var typed_count := 0
var dialogue_active := false


func _ready():
	if GameState.current_task == null:
		print("NO CURRENT TASK")
		return

	var data = GameState.current_task.task_data as WritingTaskData

	if data == null:
		print("WRITING TASK HAS NO WRITING DATA")
		return

	target_text = data.prompt.strip_edges()

	typed_count = 0
	progress_bar.value = 0

	# If there's first-check dialogue, don't show the writing yet
	if GameState.pending_dialogue != "":
		story_label.hide()

		var dialogue_box = get_tree().get_first_node_in_group("dialogue_box")

		if dialogue_box:
			var dialogue_id = GameState.pending_dialogue

			GameState.pending_dialogue = ""
			GameState.mark_dialogue_seen(dialogue_id)

			dialogue_box.start(dialogue_id)

			# Wait until the player finishes the dialogue
			await dialogue_box.finished

		# NOW reveal the writing prompt
		story_label.show()

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

	if pressed_character != expected_character:
		return

	typed_count += 1

	update_story_display()

	if typed_count >= target_text.length():
		progress_bar.value = 100
		writing_complete()
	else:
		update_progress()


func update_story_display():
	var completed_text = target_text.substr(0, typed_count)
	var remaining_text = target_text.substr(typed_count)

	story_label.text = (
		"[color=#222222]" +
		completed_text +
		"[/color]" +
		"[color=#AAAAAA]" +
		remaining_text +
		"[/color]"
	)


func update_progress():
	var percent = (
		float(typed_count) /
		float(target_text.length())
	) * 100.0

	progress_bar.value = percent

func writing_complete():
	GameState.complete_current_task()
	GameState.current_task = null

	get_tree().change_scene_to_file(
		"res://dashboard.tscn"
	)


func _on_back_button_pressed():
	GameState.current_task = null

	get_tree().change_scene_to_file(
		"res://dashboard.tscn"
	)
