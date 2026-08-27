extends Control

@export_file("*.tscn") var next_scene: String = "res://scenes/titleScreen.tscn"

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_back_pressed() -> void:
	GameState.current_task = null
	get_tree().change_scene_to_file("res://dashboard.tscn")
	
func _ready() -> void:
	# Start the main song if it isn't already playing
	if not MusicManager.player.playing:
		MusicManager.play_track(
			MusicManager.main_song,
			0.0,   # start position
			0.0,   # loop start
			90.0   # loop end
		)
	else:
		# If music is already playing, just change the loop
		MusicManager.set_loop_section(
			0.0,
			90.0
		)

	animation_player.animation_finished.connect(
		_on_animation_finished
	)

	animation_player.play("splash")


func _on_animation_finished(animation_name: StringName) -> void:
	if animation_name != "splash":
		return

	load_next_scene()


func load_next_scene() -> void:
	if next_scene.is_empty():
		push_error("Next scene is not assigned.")
		return

	var error: Error = get_tree().change_scene_to_file(next_scene)

	if error != OK:
		push_error("Could not load scene: " + next_scene)
