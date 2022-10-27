class_name PumpkinShot
extends Spatial

onready var Explosion = preload("res://characters/PumpkinExplode.tscn")

const GRAVITY = 9.81
const SPEED_X = 5.0
const SPEED_Y = GRAVITY * SPEED_X

var vertical_velocity: float
var witch


func _ready():
	vertical_velocity = SPEED_Y


func setup(the_witch):
	witch = the_witch


func _process(delta: float):
	translation.x += SPEED_X * delta
	translation.y += vertical_velocity * delta
	vertical_velocity -= GRAVITY * delta
	if translation.y <= 0:
		explode() # Hit ground.


func explode():
	var explosion = Explosion.new()
	explosion.global_transform.origin = global_transform.origin
	var parent = get_parent()
	parent.add_child(explosion)
	parent.remove_child(self)
	queue_free()
	witch.pumpkin_exploded()


func _on_PumpkinShot_area_entered(_area):
	explode()
