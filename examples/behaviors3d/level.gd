extends Node3D
class_name Level

@export var character: AICharacter


func generate_level():
	assert(false)


func get_target_location():
	assert(false)


func point_outside_character(point_global: Vector3) -> bool:
	var character_shape := character.collision_shape.shape as SphereShape3D
	return point_global.distance_to(character.global_position) > character_shape.radius
