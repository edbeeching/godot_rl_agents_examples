extends Node3D
class_name Goal

@onready var _mesh: MeshInstance3D = $goal/Cube_001
signal ball_entered_goal(ball_goal_category_match)
signal robot_entered_goal
var _category: int
var _material: ShaderMaterial


func set_category(category: int, category_count: int):
	_category = category
	if not (_material):
		_material = _mesh.material_override
	_material.set_shader_parameter(
		"albedo", Color.from_hsv(category / float(category_count), 0.8, 1.0)
	)


func _on_area_3d_body_entered(node: Node3D):
	if node is Ball:
		ball_entered_goal.emit(node.category == _category)
	elif node is Robot:
		robot_entered_goal.emit()


func get_category() -> int:
	return _category
