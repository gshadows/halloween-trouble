extends Control

signal quit
signal start


func _ready():
	$SfxEnable.pressed = Settings.sfx_enable
	$SfxSlider.value = Settings.sfx_volume
	$MusicEnable.pressed = Settings.music_enable
	$MusicSlider.value = Settings.music_volume
	$FullScreenEnable.pressed = Settings.full_screen


func _input(event):
	# Quit or back.
	if event.is_action_pressed("ui_cancel"):
		get_tree().set_input_as_handled()
		emit_signal("quit")
	# Full screen switch.
	if event.is_action_pressed("fullscreen"):
		get_tree().set_input_as_handled()
		OS.window_fullscreen = !OS.window_fullscreen


func _on_Start_pressed():
	emit_signal("start")


func _on_Quit_pressed():
	emit_signal("quit")


func _on_SfxEnable_toggled(button_pressed):
	AudioServer.set_bus_mute(Settings.AUDIO_BUS_SFX, !button_pressed)
	Settings.sfx_enable = button_pressed
	Settings.save()


func _on_SfxSlider_value_changed(value):
	AudioServer.set_bus_volume_db(Settings.AUDIO_BUS_SFX, linear2db(value))
	Settings.sfx_volume = value


func _on_MusicEnable_toggled(button_pressed):
	AudioServer.set_bus_mute(Settings.AUDIO_BUS_MUSIC, !button_pressed)
	Settings.music_enable = button_pressed
	Settings.save()


func _on_MusicSlider_value_changed(value):
	AudioServer.set_bus_volume_db(Settings.AUDIO_BUS_MUSIC, linear2db(value))
	Settings.music_volume = value


func _on_FullScreenEnable_toggled(button_pressed):
	OS.window_fullscreen = button_pressed
	Settings.full_screen = button_pressed
	Settings.save()


func _on_MusicSlider_drag_ended(_value_changed):
	Settings.save()


func _on_SfxSlider_drag_ended(_value_changed):
	Settings.save()
