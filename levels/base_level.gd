class_name BaseLevel
extends Spatial

signal quit
signal loose
signal win

onready var sndLoose = preload("res://audio/Loose - 488963__dominictreis__sad-or-scary-scene-change-music.mp3")
onready var sndWin = preload("res://audio/Win - 530265__dominictreis__morning-transition-music.wav")
onready var player: AudioStreamPlayer = $MusicPlayer


func _input(event):
	# Quit or back.
	if event.is_action_pressed("ui_cancel"):
		get_tree().set_input_as_handled()
		emit_signal("quit")
	# Full screen switch.
	if event.is_action_pressed("fullscreen"):
		get_tree().set_input_as_handled()
		OS.window_fullscreen = !OS.window_fullscreen


func _on_Witch_death():
	player.stream = sndLoose
	player.play()
	yield(player, "finished")
	emit_signal("loose")


func _on_Witch_win():
	player.stream = sndWin
	player.play()
	yield(get_tree().create_timer(1), "timeout")
	Game.witch.win = true
	yield(player, "finished")
	emit_signal("win")
