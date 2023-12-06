extends RigidBody3D
class_name Item

var item_category: int = 0

@onready var material: StandardMaterial3D = $MeshInstance3D.get_active_material(0)
@export var category_material: StandardMaterial3D
@export var category2_material: StandardMaterial3D

func set_category(category: int):
	item_category = category
	var color: Color
	
	if category == 0:
		color = category_material.albedo_color
	else:
		color = category2_material.albedo_color
		
	color.a = 1
	material.albedo_color = color
