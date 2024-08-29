extends RigidBody3D

class_name Ball

var category: int
var correct_goal: Goal

var _material: StandardMaterial3D


func set_random_category(category_count: int):
	if not (_material):
		var mesh: MeshInstance3D = $MeshInstance3D
		_material = mesh.get_active_material(0)
	category = randi_range(0, category_count - 1)
	_material.albedo_color = Color.from_hsv(category / float(category_count), 0.8, 1.0)


func get_category() -> int:
	return category
