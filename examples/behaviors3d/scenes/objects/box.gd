extends CSGBox3D

@onready var raycast = $RayCast3D

var placed = false

func _physics_process(_delta: float) -> void:
	if not placed and raycast.is_colliding():
		# Set position to hit position
		global_position.y = raycast.get_collision_point().y + 0.5*size.y
		placed = true
		raycast.queue_free()