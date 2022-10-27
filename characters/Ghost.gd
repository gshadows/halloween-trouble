extends Spatial

onready var material: Material

const BORN_TIME  := 2.0
const PAUSE_TIME := 1.0
const ATTACK_TIME := 1.0
const FALLBACK_TIME := 0.5
const DEATH_TIME := 5.0

const WALK_SPEED := 1.0
const ATTACK_ALTITUDE := 3.0
const SIGHT_DISTANCE := 5.0
const ATTACK_DISTANCE := 0.5
const FALLBACK_SPEED := 3.0

const FLY_PERIOD := 6.0
const FLY_ALTITUDE := 5.0

const ATTACK_DPS = 20.0 # Attack damage per second


enum State { BORN, PAUSE, FOLLOW, ATTACK, FALLBACK, DEATH }
var state: int
var next_state: int
var state_str: String
var next_state_str = null

var size_y: float
var timer := 0.0
var base_pos: Vector2

var label3d = null
var witch


func _ready():
	if Settings.debug:
		label3d = Label3D.new()
		label3d.billboard = SpatialMaterial.BILLBOARD_ENABLED
		label3d.translation.y = 1.9
		label3d.modulate = Color.cyan
		label3d.name = "_debug"
		add_child(label3d)
	material = $Ghost.get_active_material(0)
	size_y = $Ghost.get_aabb().size.y
	find_player()
	_change_state(State.BORN)


func find_player():
	var root = get_tree().get_root()
	var parent = self
	witch = null
	while true:
		parent = parent.get_parent()
		if parent == null:
			break
		if parent == root:
			parent = null
			break
		if parent is BaseLevel:
			break
	if parent == null:
		printerr("No base level found! Can't search for witch!")
		return
	witch = parent.find_node("Witch")
	if (witch == null) || (not witch is Witch):
		printerr("No witch found!")
		return


func _process(delta: float):
	match state:
		State.BORN:
			_do_born(delta)
		State.PAUSE:
			_do_pause(delta)
		State.FOLLOW:
			_do_follow(delta)
		State.ATTACK:
			_do_attack(delta)
		State.FALLBACK:
			_do_fallback(delta)
		State.DEATH:
			_do_death(delta)


func _change_state(new_state: int, new_next_state = null):
	next_state_str = null
	match new_state:
		State.BORN:
			timer = BORN_TIME
			translation.y -= size_y
			#material.set_parameter(0, Color(1,1,1, 0.0))
		State.PAUSE:
			next_state = new_next_state
			timer = PAUSE_TIME
			next_state_str = state2str(next_state)
		State.FOLLOW:
			base_pos = Vector2(translation.x, translation.y)
		State.ATTACK:
			base_pos = Vector2(translation.x, translation.y)
			timer = ATTACK_TIME
		State.FALLBACK:
			timer = FALLBACK_TIME
		State.DEATH:
			timer = DEATH_TIME
			#material.set_parameter(0, Color(1,1,1, 0.5))
	state = new_state
	state_str = state2str(state)
	if label3d:
		label3d.text = state_str if not next_state_str else state_str + " -> " + next_state_str


func state2str(st:int):
	match st:
		State.BORN:		return "BORN"
		State.PAUSE:	return "PAUSE"
		State.FOLLOW:	return "FOLLOW"
		State.ATTACK:	return "ATTACK"
		State.FALLBACK:	return "FALLBACK"
		State.DEATH:	return "DEATH"
		_: return str(st)


func _do_born(delta: float):
	var speed := (1.0 / BORN_TIME) * delta
	# Move up.
	translation.y += size_y * speed
	# Fade-in from invisible to half-transparent.
	var alpha := 0.5 * (1.0 - speed)
	#material.set_parameter(0, Color(1,1,1, alpha))
	# Born timer.
	timer -= delta
	if timer <= 0:
		_change_state(State.PAUSE, State.FOLLOW)


func _do_pause(delta: float):
	timer -= delta
	if timer <= 0:
		_change_state(next_state)


func _do_follow(delta: float):
	if not witch:
		find_player()
		if not witch:
			_change_state(State.PAUSE, State.FOLLOW)
		return
	
	var witch_x = witch.global_transform.origin.x
	var our_x = global_transform.origin.x
	if witch_x >= our_x:
		# Walked around us.
		_change_state(State.PAUSE, State.DEATH)
		return
	
	var dist = our_x - witch_x
	if dist > SIGHT_DISTANCE:
		# Too far away from us.
		return
	if dist <= ATTACK_DISTANCE:
		_change_state(State.ATTACK)
		return
	
	translation.x -= WALK_SPEED * delta
	translation.y = base_pos.y + sin((translation.x - base_pos.x) * FLY_PERIOD / WALK_SPEED) * delta * FLY_ALTITUDE


func _do_attack(delta: float):
	translation.y = base_pos.y + ATTACK_ALTITUDE * sin(Time.get_ticks_msec() * 0.1) * delta
	timer -= delta
	witch.take_damage(ATTACK_DPS * delta)
	if timer <= 0:
		_change_state(State.FALLBACK)


func _do_fallback(delta: float):
	# TODO: Fallback animation.
	translation.x += FALLBACK_SPEED * delta
	translation.y = base_pos.y + sin(timer / FALLBACK_TIME * PI)
	timer -= delta
	if timer <= 0:
		translation = Vector3(translation.x, base_pos.y, translation.z) # Restore normal Y.
		_change_state(State.PAUSE, State.FOLLOW)


func _do_death(delta: float):
	var speed := (1.0 / DEATH_TIME) * delta
	# Move up.
	translation.y += size_y * speed
	# Fade-out from half-transparent to invisible.
	var alpha := 0.5 * (1.0 - speed)
	#material.set_parameter(0, Color(1,1,1, alpha))
	# Death timer.
	timer -= delta
	if timer <= 0:
		get_parent().remove_child(self)
		queue_free()


func _on_Area_area_entered(area):
	_change_state(State.PAUSE, State.DEATH)
