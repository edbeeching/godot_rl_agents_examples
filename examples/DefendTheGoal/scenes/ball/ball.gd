extends RigidBody3D
class_name Ball

@export var max_velocity := 30.0

var category: int
var correct_goal: Goal
var _material: StandardMaterial3D

@onready var initial_transform = transform


func shoot(shoot_ball_toward := Vector3.ZERO, shoot_strength := 5.0):
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	apply_central_impulse(global_position.direction_to(shoot_ball_toward) * shoot_strength)


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	state.linear_velocity = state.linear_velocity.limit_length(max_velocity)


func set_random_category(category_count: int):
	if not (_material):
		var mesh: MeshInstance3D = $MeshInstance3D
		_material = mesh.get_active_material(0)
	category = randi_range(0, category_count - 1)
	_material.albedo_color = Color.from_hsv(category / float(category_count), 0.8, 1.0)


func get_category() -> int:
	return category
