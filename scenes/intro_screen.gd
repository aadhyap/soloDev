extends Control

@export_file("*.tscn") var next_scene: String = "res://scenes/splash_screen.tscn"


func _on_video_stream_player_finished() -> void:
	get_tree().change_scene_to_file(next_scene)
