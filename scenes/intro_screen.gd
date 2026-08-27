extends Control

@export_file("*.tscn") var next_scene: String = "res://scenes/splash_screen.tscn"


func _process(_delta):
	if Input.is_key_pressed(KEY_P):
		skip_intro()


func skip_intro():
	get_tree().change_scene_to_file(next_scene)


func _on_video_stream_player_finished():
	skip_intro()
