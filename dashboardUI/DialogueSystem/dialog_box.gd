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

	name_label.text = line["speaker"]
	dialogue_label.text = line["text"]
	continue_label.text = "PRESS ENTER"


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
