extends Node2D
class_name SpawnedObjects


## Used as a container for spawned objects that need to be removed when resetting the level
## (for now, we do not remove asteroids)
func remove_all_spawned_items():
	for node in get_children():
		node.queue_free()
