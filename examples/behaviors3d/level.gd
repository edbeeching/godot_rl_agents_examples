extends Node3D
class_name Level


#region Currently set by LevelRunner
var character: AICharacter
var target: AITarget
#endregion


var _character_aabb: AABB
var _target_aabb: AABB


func _ready():
	_set_aabbs()


## Sets the character and target aabb's
func _set_aabbs():
	_character_aabb = character.aabb
	_target_aabb = target.aabb


## Default implementation for spawn location
func get_spawn_location() -> Vector3:
	var spawn_location: Vector3
	spawn_location.y = 2
	return spawn_location

func generate_level():
	assert(false)

func get_target_location():
	assert(false)
