extends StaticBody3D
class_name StaticCar

var _material: StandardMaterial3D
var _car_body: MeshInstance3D

func _ready():
	_car_body = $"car_base/Body" as MeshInstance3D
	_material = _car_body.get_active_material(0)

func randomize_color():
	var instance_material = _material.duplicate()
	instance_material.albedo_color = Color(
		randf_range(0.2, 0.8),
		randf_range(0.2, 0.8),
		randf_range(0.2, 0.8),
		1
	)
	_car_body.set_surface_override_material(0, instance_material)
