extends RayCastSensor3D

var team = -1
var team_collision_mask = 0
var enemy_collision_mask = 0

func calculate_raycasts() -> Array:
	var result = []
	for ray in rays:
		ray.set_enabled(true)
		ray.force_raycast_update()
		var distance = _get_raycast_distance(ray)

		result.append(distance)
		if class_sensor:
			
			if team == -1:
				var hit_class = 0 
				if ray.get_collider():
					var hit_collision_layer = ray.get_collider().collision_layer
					hit_collision_layer = hit_collision_layer & collision_mask
					hit_class = (hit_collision_layer & boolean_class_mask) > 0
				result.append(hit_class)
			else:
				var hit_categories = [0,0]
				var collider = ray.get_collider()
				if collider:
					var hit_collision_layer = collider.collision_layer
					hit_categories[0] = (hit_collision_layer & team_collision_mask) > 0
					hit_categories[1] = (hit_collision_layer & enemy_collision_mask) > 0
					
				result.append_array(hit_categories)
		ray.set_enabled(false)
	return result
