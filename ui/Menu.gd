extends Control

signal quit
signal start

onready var sndClick = preload("res://audio/MenuClick - 448080__breviceps__wet-click.wav")
onready var sndHover = preload("res://audio/MenuHover - 422971__dkiller2204__sfxkeypickup.wav")
onready var sndJoke = preload("res://audio/MenuJoke - 420615__glaneur-de-sons__sword-swing-b-strong-01.wav")

var debug_button_start_x: float
var debug_button_jumped := false
var in_redy = true


func _ready():
	$SfxEnable.pressed = Settings.sfx_enable
	$SfxSlider.value = Settings.sfx_volume
	$MusicEnable.pressed = Settings.music_enable
	$MusicSlider.value = Settings.music_volume
	$FullScreenEnable.pressed = Settings.full_screen
	$DebugEnable.pressed = Settings.debug
	debug_button_start_x = $DebugEnable.margin_left
	in_redy = false


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
	clickSnd()
	yield(get_tree().create_timer(0.2), "timeout")
	emit_signal("start")
	


func _on_Quit_pressed():
	clickSnd()
	yield(get_tree().create_timer(0.2), "timeout")
	emit_signal("quit")


func _on_SfxEnable_toggled(button_pressed):
	clickSnd()
	AudioServer.set_bus_mute(Settings.AUDIO_BUS_SFX, !button_pressed)
	Settings.sfx_enable = button_pressed
	Settings.save()


func _on_SfxSlider_value_changed(value):
	AudioServer.set_bus_volume_db(Settings.AUDIO_BUS_SFX, linear2db(value))
	Settings.sfx_volume = value


func _on_MusicEnable_toggled(button_pressed):
	clickSnd()
	AudioServer.set_bus_mute(Settings.AUDIO_BUS_MUSIC, !button_pressed)
	Settings.music_enable = button_pressed
	Settings.save()


func _on_MusicSlider_value_changed(value):
	AudioServer.set_bus_volume_db(Settings.AUDIO_BUS_MUSIC, linear2db(value))
	Settings.music_volume = value


func _on_FullScreenEnable_toggled(button_pressed):
	clickSnd()
	OS.window_fullscreen = button_pressed
	Settings.full_screen = button_pressed
	Settings.save()


func _on_MusicSlider_drag_ended(_value_changed):
	Settings.save()


func _on_SfxSlider_drag_ended(_value_changed):
	Settings.save()


func _on_DebugEnable_toggled(button_pressed):
	clickSnd()
	Settings.debug = button_pressed
	Settings.save()


func _on_DebugEnable_mouse_entered():
	if Settings.debug or Input.is_action_pressed("shoot"):
		return
	$AudioStreamPlayer.stream = sndJoke
	$AudioStreamPlayer.play()
	if debug_button_jumped:
		$DebugEnable.margin_left = debug_button_start_x
	else:
		$DebugEnable.margin_left = debug_button_start_x + $DebugEnable.rect_size.x
	debug_button_jumped = not debug_button_jumped


func _on_Copyrights_mouse_entered():
	_on_Hover()
	$Copyrights/CopyrightText.visible = true


func _on_Copyrights_mouse_exited():
	_on_Hover()
	$Copyrights/CopyrightText.visible = false


func clickSnd():
	if not in_redy:
		$AudioStreamPlayer.stream = sndClick
		$AudioStreamPlayer.play()


func _on_Hover():
	$AudioStreamPlayer.stream = sndHover
	$AudioStreamPlayer.play()


func _on_Help_mouse_entered():
	_on_Hover()
	$Help/HelpText.visible = true


func _on_Help_mouse_exited():
	_on_Hover()
	$Help/HelpText.visible = false
