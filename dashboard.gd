extends Control


func _ready():
	var dialogue_id := "dashboard_intro"

	if not GameState.has_seen_dialogue(dialogue_id):
		var dialogue_box = get_tree().get_first_node_in_group("dialogue_box")

		if dialogue_box:
			GameState.mark_dialogue_seen(dialogue_id)
			dialogue_box.start(dialogue_id)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
