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


func _ready():
	refresh()


func refresh():
	if member == null:
		return

	name_label.text = member.display_name
	role_label.text = member.role_name
	portrait.texture = member.profile_picture
	var task = GameState.get_next_task_for_member(member.id)

	if task == null:
		progress_bar.value = 100
		open_button.text = "COMPLETE"
		open_button.disabled = true
		return

	progress_bar.value = GameState.get_member_progress(member.id)

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
			# replace with your actual scene path later
			print("Music minigame not added yet")

func _on_open_button_pressed():
	if member == null:
		return

	if not GameState.can_help_member(member.id):
		return

	var task = GameState.get_next_task_for_member(member.id)

	if task == null:
		return

	GameState.current_task = task

	var dialogue_id = member.id + "_first_check"

	# Tell the NEXT scene that it should show this dialogue.
	if not GameState.has_seen_dialogue(dialogue_id):
		GameState.pending_dialogue = dialogue_id
	else:
		GameState.pending_dialogue = ""

	open_task(task)
