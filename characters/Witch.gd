class_name Witch
extends Spatial

signal death
signal win

onready var cam := $Camera
onready var foot := $WitchFoot
onready var hud := $HUD
onready var PumpkinShot = preload("res://characters/PumpkinShot.tscn")


const WALK_SPEED_FRONT := 2.0
const WALK_SPEED_BACK := 1.0
const RUN_SPEED_MULTIPLIER := 3.0

const STEP_PERIOD := 12.0
const STEP_ALTITUDE := 3.0

const FOOT_PERIOD := Vector2(1, 1)
const DEATH_TIME := 10.0

const CAM_MAX_DY := 1.0
const CAM_SPEED_Y := 5.0

const START_HEALTH := 100.0
const EXPLOSION_RADIUS_SQUARE := 25.0
const CANDY_HEALTH := 30.0


var start_pos: Vector2
var start_foot_pos: Vector2
var start_cam_y: float
var cam_dy := 0.0
var is_pumpkin_fly := false
var timer: float
var label3d

var health := START_HEALTH
var candies := 1
var pumpkins := 1


func _ready():
	if Settings.debug:
		label3d = Label3D.new()
		label3d.billboard = SpatialMaterial.BILLBOARD_ENABLED
		label3d.translation.y = 2.1
		label3d.modulate = Color.cyan
		label3d.name = "_debug"
		add_child(label3d)
	Game.witch = self
	start_pos = Vector2(translation.x, translation.y)
	start_foot_pos = Vector2(foot.translation.x, foot.translation.y)
	start_cam_y = cam.translation.y
	hud.set_health(health)
	hud.set_pumpkins(pumpkins)
	hud.set_candies(candies)


func _process(delta:float):
	if health > 0:
		_do_movement(delta)
		_do_actions()
	else:
		_do_death(delta)


func _do_movement(delta:float):
	var dx := Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	var dy := Input.get_action_strength("ui_up") - 0.5 #Input.get_action_strength("ui_down")
	
	# Walking control.
	var speed := WALK_SPEED_FRONT if (dx > 0) else WALK_SPEED_BACK
	var period: float
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


func _do_death(delta:float):
	var speed := (1.0 / DEATH_TIME) * delta
	# Move up.
	translation.y += $Witch.get_aabb().size.y * speed
	# Fade-out from half-transparent to invisible.
	var alpha := 0.5 * (1.0 - speed)
	#material.set_parameter(0, Color(1,1,1, alpha))
	# Death timer.
	timer -= delta
	if timer <= 0:
		emit_signal("death")


func _do_actions():
	if Input.is_action_just_pressed("shoot") and not is_pumpkin_fly and (pumpkins > 0):
		shoot()
	if Input.is_action_just_pressed("heal") and (candies > 0):
		heal()


func shoot():
	if label3d:
		label3d.text = "shot"
	is_pumpkin_fly = true
	pumpkins -= 1
	hud.set_pumpkins(pumpkins)
	var pumpkin = PumpkinShot.instance()
	pumpkin.setup()
	get_parent().add_child(pumpkin)


func heal():
	candies -= 1
	hud.set_candies(candies)
	health += CANDY_HEALTH
	if health > START_HEALTH:
		health = START_HEALTH
	hud.set_health(health)


func pumpkin_exploded():
	if label3d:
		label3d.text = "ready"
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
	if health <= 0:
		return # Already dead, ignore damage.
	health -= damage
	if health <= 0:
		death()
	hud.set_health(health)


func death():
	# DEATH
	Game.witch = null
	health = 0
	timer = DEATH_TIME
