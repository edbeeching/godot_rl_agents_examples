extends CSGBox3D

@onready var raycast = $RayCast3D

var placed = false

func _physics_process(delta: float) -> void:
	if not placed and raycast.is_colliding():
		# Set position to hit position
		position = raycast.get_collision_point() + Vector3(0, 0.5*size.y, 0)
		placed = true
		raycast.queue_free()