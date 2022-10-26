extends Node

onready var AUDIO_BUS_MASTER = AudioServer.get_bus_index("Master")
onready var AUDIO_BUS_MUSIC = AudioServer.get_bus_index("Music")
onready var AUDIO_BUS_SFX = AudioServer.get_bus_index("SFX")

const CFG_PATH = "config.ini"


var sfx_volume := 1.0
var sfx_enable := true

var music_volume := 1.0
var music_enable := true

var full_screen := false

var debug := OS.is_debug_build()


func _ready():
	reload()
	apply()


func save():
	var config = ConfigFile.new()

	config.set_value("audio", "sfx_volume", sfx_volume)
	config.set_value("audio", "sfx_enable", sfx_enable)

	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "music_enable", music_enable)

	config.set_value("video", "full_screen", full_screen)

	config.set_value("game", "debug", debug)

	config.save(CFG_PATH)


func reload():
	var config = ConfigFile.new()
	var err = config.load(CFG_PATH)
	if err != OK:
		return

	sfx_volume = config.get_value("audio", "sfx_volume", sfx_volume)
	sfx_enable = config.get_value("audio", "sfx_enable", sfx_enable)

	music_volume = config.get_value("audio", "music_volume", music_volume)
	music_enable = config.get_value("audio", "music_enable", music_enable)

	full_screen = config.get_value("video", "full_screen", full_screen)

	debug = config.get_value("game", "debug", debug)


func apply():
	AudioServer.set_bus_volume_db(AUDIO_BUS_SFX, linear2db(sfx_volume))
	AudioServer.set_bus_mute(AUDIO_BUS_SFX, !sfx_enable)

	AudioServer.set_bus_volume_db(AUDIO_BUS_MUSIC, linear2db(music_volume))
	AudioServer.set_bus_mute(AUDIO_BUS_MUSIC, !music_enable)

	OS.window_fullscreen = full_screen
