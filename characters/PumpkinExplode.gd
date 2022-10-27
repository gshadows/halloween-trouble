class_name PumpkinExplode
extends Spatial

var parts


func _ready():
	parts = get_children()
	for i in range(parts.size() - 1, 0, -1):
		if not parts[i] is MeshInstance:
			parts.remove(i)


func _physics_process(delta):
	pass
