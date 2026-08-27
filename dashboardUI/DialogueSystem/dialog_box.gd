extends PanelContainer

signal finished

@export var test_dialogue_id: String = "risa_first_check"

@onready var portrait: TextureRect = \
	$MarginContainer/HBoxContainer/Portrait

@onready var name_label: Label = \
	$MarginContainer/HBoxContainer/TextColumn/NameLabel

@onready var dialogue_label: Label = \
	$MarginContainer/HBoxContainer/TextColumn/DialogueLabel

@onready var continue_label: Label = \
	$MarginContainer/HBoxContainer/TextColumn/ContinueLabel

@export var ashi_portrait: Texture2D


var lines: Array = []
var line_index: int = 0
var active: bool = false


func _ready() -> void:
	start(test_dialogue_id)


func start(dialogue_id: String) -> void:
	lines = DialogueManager.get_dialogue(dialogue_id)

	if lines.is_empty():
		print("NO DIALOGUE FOUND: ", dialogue_id)
		return

	line_index = 0
	active = true

	show()
	show_current_line()


func show_current_line() -> void:
	if line_index >= lines.size():
		end_dialogue()
		return

	var line = lines[line_index]

	var speaker_name: String = line["speaker"]
	var text: String = line["text"]

	name_label.text = speaker_name
	dialogue_label.text = text
	continue_label.text = "PRESS ENTER"

	portrait.texture = get_portrait_for_speaker(speaker_name)
	
func get_portrait_for_speaker(speaker_name: String) -> Texture2D:
	if speaker_name.to_lower() == "ashi":
		
		return ashi_portrait

	for member in GameState.team_members:
		
		if member.id == speaker_name.to_lower():
			return member.profile_picture

	return null


func next_line() -> void:
	line_index += 1
	show_current_line()


func end_dialogue() -> void:
	active = false
	hide()
	finished.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not active:
		return

	if event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		next_line()
