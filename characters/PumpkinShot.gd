extends Spatial

onready var Explosion = preload("res://characters/PumpkinExplode.tscn")

const SPEED_X = 3.0
const SPEED_Y = 7.0
const START_Y_POS = 1.2

var vertical_velocity: float
var gravity: float


func setup():
	name = "PumpkinShot"
	global_transform.origin = Game.witch.global_transform.origin
	translation.y += START_Y_POS
	vertical_velocity = SPEED_Y
	gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta: float):
	translation.x += SPEED_X * delta
	translation.y += vertical_velocity * delta
	vertical_velocity -= gravity * delta
	if translation.y <= 0:
		explode() # Hit ground.


func explode():
	var explosion = Explosion.instance()
	explosion.global_transform.origin = global_transform.origin
	var parent = get_parent()
	parent.add_child(explosion)
	parent.remove_child(self)
	queue_free()
	Game.witch.pumpkin_exploded()


func _on_PumpkinShot_area_entered(_area):
	explode()
