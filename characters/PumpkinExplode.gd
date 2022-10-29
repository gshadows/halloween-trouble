class_name PumpkinExplode
extends Area

const FLY_SPEED_X := 3.0
const FLY_SPEED_Y := 6.0
const EXPLODE_TIME := 1.0

var parts: Array # of MeshInstance nodes.
var vectors: PoolVector2Array
var timer := EXPLODE_TIME


func _ready():
	# Prepare list of all parts.
	parts = get_children()
	for i in range(parts.size() - 1, 0, -1):
		if not parts[i] is MeshInstance:
			parts.remove(i)
	
	# Prepare fly direction vectors.
	for i in parts.size():
		var dir:Vector3 = parts[i].get_aabb().get_center().normalized()
		vectors.push_back(Vector2(dir.x * FLY_SPEED_X, dir.y * FLY_SPEED_Y))


func _physics_process(delta: float):
	for i in parts.size():
		parts[i].translation.x += vectors[i].x * delta
		parts[i].translation.y += vectors[i].y * delta
		if (parts[i].translation.y <= 0):
			vectors[i].y = -vectors[i].y
		else:
			vectors[i].y -= gravity * delta

	timer -= delta
	if timer <= 0:
		get_parent().remove_child(self)
		queue_free()
