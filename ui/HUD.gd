extends Control

onready var health_bar := $HealthBar
onready var pumpkin_count := $PumpkinCount
onready var candy_count := $CandyCount

var health: float
var pumpkins: int
var candies: int


func set_health(value: float):
	if abs(health - value) >= 1:
		health = value
		health_bar.value = value

func set_pumpkins(value: int):
	if pumpkins != value:
		pumpkins = value
		pumpkin_count.text = str(value)

func set_candies(value: int):
	if candies != value:
		candies = value
		candy_count.text = str(value)
