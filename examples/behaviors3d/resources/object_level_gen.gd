extends BaseLevelGen
class_name ObjectLevelGen

const AABB_MARGIN := Vector3(1.0, 1.0, 1.0)
var aabbs : Array[AABB] = []


func intersects_aabb(aabb:AABB) -> bool:
	for other_aabb in aabbs:
		if aabb.intersects(other_aabb):
			return true
	return false


func adjust_ground(parent: Node3D) -> void:
	parent.ground.size = Vector3(randf_range(10, 40), 1, randf_range(10, 40))

	parent.get_node("Walls/Left").position = Vector3(-parent.ground.size.x/2, 0, 0)
	parent.get_node("Walls/Right").position = Vector3(parent.ground.size.x/2, 0, 0)
	parent.get_node("Walls/Forward").position = Vector3(0, 0, -parent.ground.size.z/2)
	parent.get_node("Walls/Backward").position = Vector3(0, 0, parent.ground.size.z/2)

func spawn_objects(parent: Node3D) -> void:
	var ground = parent.ground
	var total_area = ground.size.x * ground.size.z
	var max_objects = int(total_area)
	for i in range(max_objects):
		var object = object_pool.pick_random().instantiate()
		object.position = Vector3(
			randf_range(-ground.size.x/2 + object.size.x/2, ground.size.x/2 - object.size.x/2), 
			5, 
			randf_range(-ground.size.z/2 + object.size.z/2, ground.size.z/2 - object.size.z/2)
		)
		object.rotate_y(deg_to_rad(randf_range(0, 360)))
		# TODO: this is not perfect, but it's good enough for now
		var object_aabb = AABB(Vector3.ZERO, object.size + AABB_MARGIN)
		var rotated_aabb = object.transform * object_aabb
		rotated_aabb.position = object.position
		if intersects_aabb(rotated_aabb):
			object.queue_free()
			continue
		parent.add_child(object)

		aabbs.append(rotated_aabb)


func generate_level(parent) -> void:
	print("generating level")
	adjust_ground(parent)
	spawn_objects(parent)
