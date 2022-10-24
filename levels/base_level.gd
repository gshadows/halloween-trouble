extends Spatial

signal quit


func _input(event):
	# Quit or back.
	if event.is_action_pressed("ui_cancel"):
		get_tree().set_input_as_handled()
		emit_signal("quit")
	# Full screen switch.
	if event.is_action_pressed("fullscreen"):
		get_tree().set_input_as_handled()
		OS.window_fullscreen = !OS.window_fullscreen
