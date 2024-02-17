extends Node3D

func get_spawn_point() -> Node3D:
	var child_count = get_child_count()
	if child_count > 0:
		var random_index = randi() % child_count
		return get_child(random_index)
	else:
		return null
	