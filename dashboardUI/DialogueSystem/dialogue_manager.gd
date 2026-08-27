extends Node

var dialogues: Dictionary = {}


func _ready() -> void:
	load_dialogues()


func load_dialogues() -> void:
	var file := FileAccess.open(
		"res://dashboardUI/DialogueSystem/dialogue/dialogue.json",
		FileAccess.READ
	)

	if file == null:
		push_error("Could not open dialogue.json")
		return

	var text := file.get_as_text()
	file.close()

	var data = JSON.parse_string(text)

	if data == null:
		push_error("Could not parse dialogue.json")
		return

	dialogues = data

	print("Loaded dialogues: ", dialogues.keys())


func get_dialogue(dialogue_id: String) -> Array:
	if not dialogues.has(dialogue_id):
		push_error("Dialogue doesn't exist: " + dialogue_id)
		return []

	return dialogues[dialogue_id]
