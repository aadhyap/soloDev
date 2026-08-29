extends PanelContainer

@export var member: TeamMember

@onready var portrait: TextureRect = \
	$MarginContainer/HBoxContainer/Portrait

@onready var name_label: Label = \
	$MarginContainer/HBoxContainer/InfoColumn/NameLabel

@onready var role_label: Label = \
	$MarginContainer/HBoxContainer/InfoColumn/RoleLabel

@onready var progress_bar: ProgressBar = \
	$MarginContainer/HBoxContainer/InfoColumn/ProgressBar

@onready var open_button: Button = \
	$MarginContainer/HBoxContainer/OpenButton

var rimbo_dialogue_active := false


func _ready():
	refresh()


func refresh():
	if member == null:
		return

	name_label.text = member.display_name
	role_label.text = member.role_name
	portrait.texture = member.profile_picture

	# Rimbo is always 0% and always clickable.
	if member.id == "rimbo":
		progress_bar.value = 0
		open_button.text = "CHECK WORK"
		open_button.disabled = false
		return

	var task = GameState.get_next_task_for_member(member.id)

	progress_bar.value = GameState.get_member_progress(member.id)

	if task == null:
		progress_bar.value = 100
		open_button.text = "COMPLETE"
		open_button.disabled = true
		return

	if GameState.can_help_member(member.id):
		open_button.text = "CHECK WORK"
		open_button.disabled = false
	else:
		open_button.text = "LET ME WORK"
		open_button.disabled = true


func open_task(task: GameTask) -> void:
	match task.role_name:
		"Art":
			get_tree().change_scene_to_file(
				"res://minigames/art_minigame.tscn"
			)

		"Writing":
			get_tree().change_scene_to_file(
				"res://minigames/writing_minigame.tscn"
			)

		"Programming":
			get_tree().change_scene_to_file(
				"res://minigames/programming_minigame.tscn"
			)

		"Music":
			print("Music minigame not added yet")


func _on_open_button_pressed():
	if member == null:
		return

	# Rimbo only plays dialogue.
	if member.id == "rimbo":
		if rimbo_dialogue_active:
			return

		var dialogue_box = get_tree().get_first_node_in_group(
			"dialogue_box"
		)

		if dialogue_box:
			rimbo_dialogue_active = true
			open_button.disabled = true

			dialogue_box.start("rimbo_leave_me_alone")

			await dialogue_box.finished

			open_button.disabled = false
			rimbo_dialogue_active = false

		return

	if not GameState.can_help_member(member.id):
		return

	var task = GameState.get_next_task_for_member(member.id)

	if task == null:
		return

	GameState.current_task = task

	var dialogue_id = member.id + "_first_check"

	if not GameState.has_seen_dialogue(dialogue_id):
		GameState.pending_dialogue = dialogue_id
	else:
		GameState.pending_dialogue = ""

	open_task(task)
