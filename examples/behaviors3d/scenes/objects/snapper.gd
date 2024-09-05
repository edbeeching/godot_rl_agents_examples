extends RayCast3D

var attached := false

func _physics_process(_delta: float) -> void:
	if attached:
		return
	if is_colliding():
		var hit_position = get_collision_point()
		get_parent().global_position = hit_position
		attached = true
