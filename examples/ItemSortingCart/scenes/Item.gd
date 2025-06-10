extends RigidBody3D
class_name Item

var item_category: int = 0

@onready var material: StandardMaterial3D = $MeshInstance3D.get_active_material(0)
@export var category_material: StandardMaterial3D
@export var category2_material: StandardMaterial3D

func set_category(category: int):
	# Prevents errors if trying to set category before the material is set
	if not is_node_ready():
		await ready

	item_category = category
	var color: Color
	
	if category == 0:
		color = category_material.albedo_color
	else:
		color = category2_material.albedo_color
		
	color.a = 1
	material.albedo_color = color


func reset():
	var item_position : Vector3 = Vector3(0, 20, randf_range(-5.0, 5.0))
	position = item_position
	rotation = Vector3.ZERO
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	force_update_transform()
	sleeping = false
	set_category(randi_range(0, 1))
