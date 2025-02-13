extends Node3D
class_name SpawnPositionManager

@onready var position_nodes = get_children()
var spawn_transforms: Array[Transform3D]


func _ready() -> void:
	for position_node in position_nodes:
		spawn_transforms.append(position_node.global_transform)


func get_spawn_position() -> Transform3D:
	return spawn_transforms.pick_random()
