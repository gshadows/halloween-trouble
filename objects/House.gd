extends Area

var has_candies = true

onready var music_vol = $AudioStreamMusic.unit_db


func do_quiet(quiet:bool):
	if quiet:
		$AudioStreamMusic.unit_db -= 25
	else:
		$AudioStreamMusic.unit_db = music_vol
