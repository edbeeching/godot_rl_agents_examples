extends RayCastSensor3D

@export var robot: Robot


## Modified to include whether any detected robot is facing the player
func calculate_raycasts() -> Array:
	var result = []
	for ray in rays:
		ray.set_enabled(true)
		ray.force_raycast_update()
		var distance = _get_raycast_distance(ray)
		result.append(distance)

		var collider = ray.get_collider()
		var robot_looking_toward_player: float

		if class_sensor:
			var hit_class: float = 0
			if collider:
				var hit_collision_layer = ray.get_collider().collision_layer
				hit_collision_layer = hit_collision_layer & collision_mask
				hit_class = (hit_collision_layer & boolean_class_mask) > 0

				if collider is Robot:
					robot_looking_toward_player = collider.global_basis.z.dot(
						collider.global_position.direction_to(robot.global_position)
					)
			result.append(float(hit_class))

		result.append(robot_looking_toward_player)
		ray.set_enabled(false)
	return result
