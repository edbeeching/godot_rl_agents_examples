extends ShapeCast2D
class_name ProjectileSensor

## Adds position to n nearest projectile objects detected
## maximum amount of objects included is set by max_results


func get_observation():
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

		var projectile_obs := [0.0, 0.0, 0.0]
		if projectile:
			var relative := to_local(projectile.global_position)
			var direction := relative.normalized()
			var distance := clampf(relative.length() / shape.radius, 0.0, 1.0)
			projectile_obs = [direction.x, direction.y, distance]
		obs.append_array(projectile_obs)
	return obs
