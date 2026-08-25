extends Control

@export_file("*.tscn") var next_scene: String = "res://dashboard.tscn"

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	
	print("STARTING MUSIC")

	MusicManager.play_track(
		MusicManager.main_song,
		0.0,
		0.0,
		90.0
	)


	animation_player.animation_finished.connect(
		_on_animation_finished
	)

	animation_player.play("jam_intro")

	animation_player.animation_finished.connect(
		_on_animation_finished
	)

	animation_player.play("jam_intro")


func _on_animation_finished(animation_name: StringName) -> void:
	if animation_name != "jam_intro":
		return

	load_next_scene()


func load_next_scene() -> void:
	if next_scene.is_empty():
		push_error("Next scene is not assigned.")
		return

	var error: Error = get_tree().change_scene_to_file(next_scene)

	if error != OK:
		push_error("Could not load scene: " + next_scene)
