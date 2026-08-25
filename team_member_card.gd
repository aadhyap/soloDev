extends PanelContainer

@export var member: TeamMember

@onready var name_label = $VBoxContainer/NameLabel
@onready var role_label = $VBoxContainer/RoleLabel
@onready var progress_bar = $VBoxContainer/ProgressBar
@onready var blurb_label = $VBoxContainer/BlurbLabel
@onready var open_button = $VBoxContainer/OpenButton


func _ready():
	refresh()


func refresh():
	if member == null:
		return

	name_label.text = member.display_name
	role_label.text = member.role_name

	var next_task = GameState.get_next_task_for_member(member.id)

	# All of this member's tasks are finished
	if next_task == null:
		progress_bar.value = 100
		blurb_label.text = "DONE"
		open_button.disabled = true
		open_button.text = "COMPLETE"
		return

	# Player just helped this person
	if not GameState.can_help_member(member.id):
		blurb_label.text = "aight stop doing all the work bro"
		open_button.disabled = true
		open_button.text = "LET ME WORK"
	else:
		blurb_label.text = member.blurb
		open_button.disabled = false
		open_button.text = "CHECK WORK"

	progress_bar.value = next_task.progress

func open_task(task: GameTask):
	if task.role_name == "Art":
		get_tree().change_scene_to_file("res://art_minigame.tscn")

	elif task.role_name == "Writing":
		get_tree().change_scene_to_file("res://writing_minigame.tscn")

func _on_open_button_pressed():
	if member == null:
		return

	if not GameState.can_help_member(member.id):
		return

	var task = GameState.get_next_task_for_member(member.id)

	if task == null:
		print("NO TASKS LEFT FOR ", member.display_name)
		return

	GameState.current_task = task

	open_task(task)
