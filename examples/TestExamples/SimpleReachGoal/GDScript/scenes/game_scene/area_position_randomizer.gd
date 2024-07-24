extends Node3D
class_name AreaPositionRandomizer

var area: Area3D
var area_spawn_points: Array[MeshInstance3D]


func _ready():
	for node in get_children():
		if node is Area3D:
			area = node
		else:
			area_spawn_points.append(node)
			node.visible = false


func reset():
	var new_area_position: Vector3 = area_spawn_points.pick_random().global_position
	area.global_position = new_area_position
