extends RayCastSensor3D
class_name RayCastSensorAddSetCollisionMaskValue

func set_collision_mask_value(layer_number: int, value: bool):
	for ray in rays:
		ray.set_collision_mask_value(layer_number, value)
