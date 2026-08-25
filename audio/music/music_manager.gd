# music_manager.gd
extends Node

var main_song = preload("res://audio/music/jelly.wav")
var dj_song = preload("res://audio/music/title.wav")

var player: AudioStreamPlayer

var current_track: AudioStream = null

var loop_start: float = 0.0
var loop_end: float = -1.0
var custom_loop_enabled := false


func _ready():
	player = AudioStreamPlayer.new()
	add_child(player)

	player.process_mode = Node.PROCESS_MODE_ALWAYS


func _process(_delta):
	if not player.playing:
		return

	if custom_loop_enabled and loop_end > loop_start:
		if player.get_playback_position() >= loop_end:
			player.seek(loop_start)


func play_track(
	track: AudioStream,
	start_position: float = 0.0,
	custom_loop_start: float = -1.0,
	custom_loop_end: float = -1.0
):
	if current_track != track:
		current_track = track
		player.stream = track
		player.play(start_position)

	elif not player.playing:
		player.play(start_position)

	if custom_loop_start >= 0.0 and custom_loop_end > custom_loop_start:
		custom_loop_enabled = true
		loop_start = custom_loop_start
		loop_end = custom_loop_end
	else:
		custom_loop_enabled = false


func set_loop_section(start_time: float, end_time: float):
	loop_start = start_time
	loop_end = end_time
	custom_loop_enabled = true


func disable_custom_loop():
	custom_loop_enabled = false


func stop_music():
	player.stop()
	current_track = null


func set_volume_db(volume_db: float):
	player.volume_db = volume_db
