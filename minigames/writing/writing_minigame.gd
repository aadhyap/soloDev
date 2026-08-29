extends Control

@onready var story_label = $DocumentPanel/MarginContainer/VBoxContainer/WritingRow/StoryLabel
@onready var progress_bar = $ProgressBar
@onready var title_label = $DocumentPanel/MarginContainer/VBoxContainer/TitleLabel2
@onready var type_sound: AudioStreamPlayer2D = $TypeSound

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
	title_label.text = data.Title

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

func _process(_delta):
	if type_sound.playing and type_sound.get_playback_position() >= 1.60:
		type_sound.stop()


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

	type_sound.stop()
	type_sound.play(1.21)
	typed_count += 1

	update_story_display()

	if typed_count >= target_text.length():
		progress_bar.value = 100
		writing_complete()
	else:
		update_progress()


func update_story_display():
	var completed_text := target_text.substr(0, typed_count)

	var preview_text := ""
	var letters_found := 0
	var index := typed_count

	while index < target_text.length() and letters_found < 2:
		var character := target_text[index]

		preview_text += character

		# Only letters/numbers count toward the 2-character preview.
		# Spaces and punctuation do NOT count.
		if character != " " and character not in [".", ",", "!", "?", "'", "\"", ":", ";", "-"]:
			letters_found += 1

		index += 1

	story_label.text = (
		"[color=#222222]" + completed_text + "[/color]" +
		"[color=#AAAAAA]" + preview_text + "[/color]"
	)

func update_progress():
	var percent = (
		float(typed_count) /
		float(target_text.length())
	) * 100.0

	progress_bar.value = percent

func writing_complete():
	GameState.complete_current_task()
	
	var member_id = (
		GameState.current_task.assigned_member_id
	)
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



func _on_back_button_pressed():
	GameState.current_task = null

	get_tree().change_scene_to_file(
		"res://dashboard.tscn"
	)
