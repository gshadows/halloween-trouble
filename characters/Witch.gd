class_name Witch
extends Spatial

onready var cam := $Camera
onready var foot := $WitchFoot
onready var hud := $HUD


const WALK_SPEED_FRONT := 2.0
const WALK_SPEED_BACK := 1.0

const RUN_SPEED_MULTIPLIER := 3.0

const STEP_PERIOD := 12.0
const STEP_ALTITUDE := 3.0

const FOOT_PERIOD := Vector2(1, 1)

const CAM_MAX_DY := 1.0
const CAM_SPEED_Y := 5.0

const START_HEALTH = 100.0
const EXPLOSION_RADIUS_SQUARE = 25.0
const CANDY_HEALTH = 30.0


var start_pos: Vector2
var start_foot_pos: Vector2
var start_cam_y: float
var cam_dy := 0.0
var is_pumpkin_fly := false

var health := START_HEALTH
var candies := 0
var pumpkins := 0


func _ready():
	start_pos = Vector2(translation.x, translation.y)
	start_foot_pos = Vector2(foot.translation.x, foot.translation.y)
	start_cam_y = cam.translation.y
	hud.set_health(health)
	hud.set_pumpkins(pumpkins)
	hud.set_candies(candies)


func _process(delta):
	if health > 0:
		_do_movement(delta)
		_do_actions()


func _do_movement(delta):
	var dx := Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	var dy := Input.get_action_strength("ui_up") - 0.5 #Input.get_action_strength("ui_down")
	
	# Walking control.
	var speed := WALK_SPEED_FRONT if (dx > 0) else WALK_SPEED_BACK
	var period : float
	if Input.is_action_pressed("run"):
		speed *= RUN_SPEED_MULTIPLIER
		period = STEP_PERIOD * RUN_SPEED_MULTIPLIER
	else:
		period = STEP_PERIOD
	
	# Apply movement.
	translation.x += dx * speed * delta
	if translation.x < 0:
		translation.x = 0
	translation.y = start_pos.y + sin((translation.x - start_pos.x) * period / speed) * delta * STEP_ALTITUDE
	
	# Foot animation.
	foot.translation.x = start_foot_pos.x + 0
	foot.translation.y = start_foot_pos.y + 0
	
	# Camera motion.
	cam_dy = clamp(cam_dy + dy * delta * CAM_SPEED_Y, 0.0, CAM_MAX_DY)
	cam.translation.y = start_cam_y + cam_dy


func _do_actions():
	if Input.is_action_just_pressed("shoot") and not is_pumpkin_fly and (pumpkins > 0):
		shoot()
	if Input.is_action_just_pressed("heal") and (candies > 0):
		heal()


func shoot():
	is_pumpkin_fly = true
	pumpkins -= 1
	hud.set_pumpkins(pumpkins)
	var pumpkin = PumpkinShot.new()
	pumpkin.setup(self)
	get_parent().add_child(pumpkin)


func heal():
	candies -= 1
	hud.set_candies(pumpkins)
	health += CANDY_HEALTH
	hud.set_health(health)


func pumpkin_exploded():
	is_pumpkin_fly = false


func _on_Area_area_entered(area):
	var other = area.get_parent()
	if other is PumpkinExplode:
		var dist_sqr = (other.global_transform.origin - global_transform.origin).length_squared()
		var damage = dist_sqr / EXPLOSION_RADIUS_SQUARE
		print("Exlosion hit: dist_sqr ", dist_sqr)
		take_damage(damage)
		return


func take_damage(damage: float):
	health -= damage
	hud.set_health(health)
