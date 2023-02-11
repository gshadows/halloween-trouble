class_name Witch
extends Spatial

signal death

onready var cam := $Camera
onready var hat := $WitchHat
onready var body := $Witch
onready var foot := $WitchFoot
onready var hud := $HUD
onready var PumpkinShot = preload("res://characters/PumpkinShot.tscn")
onready var PumpkinItem = preload("res://objects/PumpkinItem.tscn")
onready var CandiesBowl = preload("res://objects/CandyBowl.tscn")
onready var sndPickup = preload("res://audio/Pickup - 531175__ryusa__synth-glockenspiel-bell-item-money-gold-coin-pick-up.wav")
onready var sndShoot = preload("res://audio/Throw - 515625__mrickey13__throw-swipe.wav")
onready var voiceTrick = preload("res://audio/my/trick or treat.mp3")
onready var voiceCandies = preload("res://audio/my/take candies.mp3")
onready var voiceLoose = preload("res://audio/my/curse you.mp3")


const WALK_SPEED_FRONT := 2.0
const WALK_SPEED_BACK := 1.0
const RUN_SPEED_MULTIPLIER := 3.0

const STEP_PERIOD := 12.0
const STEP_ALTITUDE := 1.7

const FOOT_PERIOD := Vector2(1, 1)
const DEATH_TIME := 10.0

const CAM_MAX_DY := 1.0
const CAM_SPEED_Y := 5.0

const START_HEALTH := 100.0
const EXPLOSION_DAMAGE := 25.0
const CANDY_HEALTH := 30.0


var start_pos: Vector2
var start_rot: float
var start_foot_pos: Vector2
var start_cam_y: float
var cam_dy := 0.0
var is_pumpkin_fly := false
var timer: float
var in_house = null
var win := false
var moment_speed_x: float

var label3d
var material_witch: SpatialMaterial
var material_hat: SpatialMaterial
var material_foot: SpatialMaterial

var health := START_HEALTH
var candies := 0
var pumpkins := 0


func _ready():
	if Settings.debug:
		_set_debug_mode()
	Game.witch = self
	start_pos = Vector2(body.translation.x, body.translation.y)
	start_rot = body.rotation.y
	start_foot_pos = Vector2(foot.translation.x, foot.translation.y)
	start_cam_y = cam.translation.y
	hud.set_health(health)
	hud.set_pumpkins(pumpkins)
	hud.set_candies(candies)
	material_witch = prepare_material($Witch)
	material_hat   = prepare_material($WitchHat)
	material_foot  = prepare_material($WitchFoot)


func _set_debug_mode():
	label3d = Label3D.new()
	label3d.billboard = SpatialMaterial.BILLBOARD_ENABLED
	label3d.translation.y = 2.1
	label3d.modulate = Color.cyan
	label3d.name = "_debug"
	add_child(label3d)
	health = 9999
	candies = 9999
	pumpkins = 9999
	translation.x = 32


func prepare_material(mi:MeshInstance) -> SpatialMaterial:
	var material:SpatialMaterial = mi.mesh.surface_get_material(0)
	material.albedo_color.a = 1
	material.flags_transparent = false
	return material


func update_alpha(alpha:float):
	material_witch.albedo_color.a = alpha
	material_hat  .albedo_color.a = alpha
	material_foot .albedo_color.a = alpha


func make_transparent():
	material_witch.flags_transparent = true
	material_hat  .flags_transparent = true
	material_foot .flags_transparent = true


func _physics_process(delta:float):
	if win:
		return
	if health > 0:
		_do_movement(delta)
		_do_actions()
	else:
		_do_death(delta)


func _do_movement(delta:float):
	var dx := Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	var dy := Input.get_action_strength("ui_up") #- 0.5
	
	# Walking control.
	var speed := WALK_SPEED_FRONT if (dx > 0) else WALK_SPEED_BACK
	var period: float
	if Input.is_action_pressed("run"):
		speed *= RUN_SPEED_MULTIPLIER
		period = STEP_PERIOD * RUN_SPEED_MULTIPLIER
	else:
		period = STEP_PERIOD
	
	# Apply movement.
	moment_speed_x = dx * speed
	translation.x += moment_speed_x * delta
	if translation.x < 0:
		translation.x = 0
	var mov_y = sin((translation.x - start_pos.x) * period / speed) * delta * STEP_ALTITUDE
	body.translation.y = start_pos.y + mov_y
	body.rotation.y = start_rot + mov_y * 4
	
	# Foot animation.
	foot.translation.x = start_foot_pos.x + mov_y
	foot.translation.y = start_foot_pos.y + mov_y
	
	# Camera motion.
	if cam_dy > 0:
		dy -= 0.5
	cam_dy = clamp(cam_dy + dy * delta * CAM_SPEED_Y, 0.0, CAM_MAX_DY)
	cam.translation.y = start_cam_y + cam_dy
	
	# Sound
	if (abs(dx) > 0.01) and not $AudioSteps.playing:
		$AudioSteps.play()


func _do_death(delta:float):
	var speed := (1.0 / DEATH_TIME) * delta
	# Move up.
	var dy = $Witch.get_aabb().size.y * speed
	translation.y += dy
	cam.translation.y += dy
	# Fade-out from half-transparent to invisible.
	update_alpha(timer / DEATH_TIME)
	# Death timer.
	timer -= delta


func _do_actions():
	if (not is_pumpkin_fly) and (pumpkins > 0) and Input.is_action_just_pressed("shoot"):
		shoot()
	if (candies > 0) and Input.is_action_just_pressed("heal"):
		heal()
	if in_house and Input.is_action_just_pressed("ui_down"):
		ask_candies()


func shoot():
	if label3d:
		label3d.text = "shot"
	$AudioEffects.stream = sndShoot
	$AudioEffects.play()
	is_pumpkin_fly = true
	pumpkins -= 1
	hud.set_pumpkins(pumpkins)
	var pumpkin = PumpkinShot.instance()
	pumpkin.setup(moment_speed_x)
	get_parent().add_child(pumpkin)


func heal():
	$AudioEffects.stream = sndPickup
	$AudioEffects.play()
	candies -= 1
	hud.set_candies(candies)
	health += CANDY_HEALTH
	if health > START_HEALTH:
		health = START_HEALTH
	hud.set_health(health)


func ask_candies():
	var house = in_house
	# Knock to the door.
	$AudioKnock.play()
	yield($AudioKnock, "finished")
	# Make music quieter.
	house.do_quiet(true)
	$AudioEffects.stream = voiceTrick
	$AudioEffects.play()
	yield($AudioEffects, "finished")
	# If no more candies - restore music and quit.
	if not house.has_candies:
		house.do_quiet(false)
		return
	# Answer "take candies, please!"
	$AudioEffects.stream = voiceCandies
	$AudioEffects.play()
	yield($AudioEffects, "finished")
	# Restore music volume.
	house.do_quiet(false)
	# Put candies.
	house.has_candies = false
	var bowl = CandiesBowl.instance()
	get_parent().add_child(bowl)
	bowl.global_transform.origin = global_transform.origin
	var dir = -1 if (randi() % 100) >= 50 else +1
	bowl.transform.origin.x += dir


func pumpkin_exploded():
	if label3d:
		label3d.text = "ready"
	is_pumpkin_fly = false


func _on_Area_area_entered(area:Area):
	if area is PumpkinExplode:
		var dist = abs(area.global_transform.origin.x - global_transform.origin.x)
		var damage = abs(1.0 - dist) * EXPLOSION_DAMAGE
		take_damage(damage)
		return
	if area.is_in_group("Pumpkins"):
		pumpkins += 1
		hud.set_pumpkins(pumpkins)
		pick_up(area)
		return
	if area.is_in_group("Candies"):
		candies += 1
		hud.set_candies(candies)
		pick_up(area)
		return
	if area.is_in_group("Houses"):
		in_house = area
		if label3d:
			label3d.text = "HOUSE"


func _on_Area_area_exited(area:Area):
	if area.is_in_group("Houses"):
		in_house = null
		if label3d:
			label3d.text = ""


func pick_up(n:Node):
	$AudioEffects.stream = sndPickup
	$AudioEffects.play()
	n.get_parent().remove_child(n)
	n.queue_free()


func take_damage(damage: float):
	if health <= 0:
		return # Already dead, ignore damage.
	health -= damage
	if health <= 0:
		death()
	elif not $AudioPain.playing:
		$AudioPain.play()
	hud.set_health(health)


func death():
	# DEATH
	Game.witch = null
	health = 0
	timer = DEATH_TIME
	make_transparent()
	update_alpha(1)
	$AudioEffects.stream = voiceLoose
	$AudioEffects.play()
	emit_signal("death")


func _on_SpiderArea_area_entered(_area):
	var sp_area = get_parent().get_node("SpiderArea")
	get_parent().remove_child(sp_area)
	sp_area.queue_free()
	$Camera/Spider.start()
