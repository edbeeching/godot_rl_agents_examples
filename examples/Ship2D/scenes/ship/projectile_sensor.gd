extends ShapeCast2D
class_name ProjectileSensor

## Adds position to n nearest projectile objects detected
## maximum amount of objects included is set by max_results


func get_observation():
	force_shapecast_update()

	var detected_projectiles: Array[Projectile]
	for i in get_collision_count():
		var collider := get_collider(i)
		if collider is Projectile:
			detected_projectiles.append(collider)

	detected_projectiles.sort_custom(
		func(a: Projectile, b: Projectile):
			return (
				a.global_position.distance_squared_to(global_position)
				< b.global_position.distance_squared_to(global_position)
			)
	)

	var obs: Array[float]
	for projectile_idx in max_results:
		var projectile: Projectile
		if projectile_idx < detected_projectiles.size():
			projectile = detected_projectiles[projectile_idx]

		var projectile_obs := [0.0, 0.0, 0.0, 0.0, 0.0]
		#var projectile_obs := [0.0, 0.0, 0.0]
		if projectile:
			var relative := to_local(projectile.global_position)
			var direction := relative.normalized()
			var distance := clampf(relative.length() / shape.radius, 0.0, 1.0)
			var rel_vel = projectile.linear_velocity
			#rel_vel = rel_vel.rotated(-projectile.global_position.direction_to(global_position).angle())
			rel_vel = rel_vel.normalized() # Keep only the directional info
			projectile_obs = [direction.x, direction.y, distance, rel_vel.x, rel_vel.y]
		obs.append_array(projectile_obs)
	return obs
