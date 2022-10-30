extends Spatial

const DOWN_TIME := 4.0
const IDLE_TIME := 4.0
const UP_TIME := 3.5

const DOWN_SPEED := 0.5
const UP_SPEED := 0.5

enum Stage { DOWN, IDLE, UP }
var stage: int
var timer: float


func _ready():
	set_physics_process(false)


func _physics_process(delta:float):
	if not visible:
		return
	match stage:
		Stage.DOWN:
			_go_down(delta)
		Stage.IDLE:
			_go_idle(delta)
		Stage.UP:
			_go_up(delta)


func start():
	set_physics_process(true)
	visible = true
	stage = Stage.DOWN
	timer = DOWN_TIME
	$AudioStreamPlayer.play()


func _go_down(delta:float):
	translation.y -= DOWN_SPEED * delta
	timer -= delta
	if timer <= 0:
		timer = IDLE_TIME
		stage = Stage.IDLE
		return


func _go_idle(delta:float):
	timer -= delta
	if timer <= 0:
		timer = UP_TIME
		stage = Stage.UP
		return


func _go_up(delta:float):
	translation.y += UP_SPEED * delta
	timer -= delta
	if timer <= 0:
		get_parent().remove_child(self)
		queue_free()
