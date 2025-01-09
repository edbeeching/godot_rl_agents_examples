extends Level

const AABB_MARGIN := 0.5
var aabbs : Array[AABB] = []

@export var object_pool : Array[PackedScene]

@onready var ground = $Ground   

@onready var character_location: Vector3
@onready var target_location: Vector3

var _free_character_locations: Array[Vector3]
var _free_character_location_idx: int
var _free_target_locations: Array[Vector3]
var _free_target_location_idx: int

func generate_level() -> void:
	_adjust_ground()
	_spawn_objects()


## Returns a free position for the character
func get_spawn_location() -> Vector3:
	var location := _free_character_locations[_free_character_location_idx]
	_free_character_location_idx = (_free_character_location_idx + 1) % _free_character_locations.size() 
	return location


## Returns a free position for the target
func get_target_location() -> Vector3:
	var location := _free_target_locations[_free_target_location_idx]
	_free_target_location_idx = (_free_target_location_idx + 1) % _free_target_locations.size() 
	return location

func get_random_location(y_offset := 1.0, xz_padding := 0.0) -> Vector3:
	return Vector3(
		randf_range(-ground.size.x/2 + xz_padding, ground.size.x/2 - xz_padding), 
		y_offset,
		randf_range(-ground.size.z/2 + xz_padding, ground.size.z/2 - xz_padding)
	)

func _intersects_aabb(aabb:AABB) -> bool:
	for other_aabb in aabbs:
		if aabb.intersects(other_aabb):
			return true
	return false


func _adjust_ground() -> void:
	ground.size = Vector3(randf_range(10, 40), 1, randf_range(10, 40))

	get_node("Walls/Left").position = Vector3(-ground.size.x/2, 0, 0)
	get_node("Walls/Left").size.x = ground.size.z
	get_node("Walls/Right").position = Vector3(ground.size.x/2, 0, 0)
	get_node("Walls/Right").size.x = ground.size.z
	get_node("Walls/Forward").position = Vector3(0, 0, -ground.size.z/2)
	get_node("Walls/Forward").size.x = ground.size.x
	get_node("Walls/Backward").position = Vector3(0, 0, ground.size.z/2)
	get_node("Walls/Backward").size.x = ground.size.x

func _spawn_objects() -> void:
	var total_area = ground.size.x * ground.size.z
	var max_objects = int(total_area)
	
#region Sets a few free positions for character and target to spawn
	var free_locations_count: int = 10
	for i in free_locations_count:
		character_location = get_random_location(ground.size.y/2.0 + _character_aabb.size.y / 2.0, 1) 
		target_location = get_random_location(ground.size.y/2.0 + _target_aabb.size.y / 2.0, 1)
		
		var character_aabb_global: AABB = _character_aabb
		character_aabb_global.position += to_global(character_location)
		character_aabb_global = character_aabb_global.grow(AABB_MARGIN)
		
		var target_aabb_global: AABB = _character_aabb
		target_aabb_global.position += to_global(target_location)
		target_aabb_global = target_aabb_global.grow(AABB_MARGIN)
		
		aabbs.append(character_aabb_global)
		aabbs.append(target_aabb_global)
		
		_free_character_locations.append(character_location)
		_free_target_locations.append(target_location)
#endregion
	
	for i in range(max_objects):
		var object = object_pool.pick_random().instantiate()
		add_child(object)
		# object.rotate_y(deg_to_rad(randf_range(0, 360)))
		object.position = Vector3(
			randf_range(-ground.size.x/2 + object.mesh.size.x/2, ground.size.x/2 - object.mesh.size.x/2), 
			ground.size.y/2 + object.mesh.size.y / 2.0, 
			#5,
			randf_range(-ground.size.z/2 + object.mesh.size.z/2, ground.size.z/2 - object.mesh.size.z/2)
		)
		# TODO: this is not perfect, but it's good enough for now
		var object_global_aabb: AABB = object.aabb
		object_global_aabb.position += object.global_position
		object_global_aabb = object_global_aabb.grow(AABB_MARGIN)

		if _intersects_aabb(object_global_aabb):
			object.queue_free()
			continue
		

		aabbs.append(object_global_aabb)
