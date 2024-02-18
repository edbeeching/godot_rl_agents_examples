extends CollisionShape3D

func get_spawn_point() -> Vector3:
	var half_extents = shape.extents / 2.0
	var random_point = Vector3(
		randf_range(-half_extents.x, half_extents.x),
		randf_range(-half_extents.y, half_extents.y),
		randf_range(-half_extents.z, half_extents.z)
	)
	#print(position, random_point)
	return random_point + global_position
	
