extends ISensor3D
class_name RBVelocitySensor

@export var objects_to_observe: Array[RigidBody3D]

@export_range(0.01, 2_500) var max_velocity := 30.0


func get_observation():
	var observations: Array[float]

	for obj in objects_to_observe:
		var relative_velocity := global_basis.inverse().orthonormalized() * obj.linear_velocity
		var vel_dir := relative_velocity.normalized()
		var vel_len := clampf(relative_velocity.length() / 1.0, 0.0, 1.0)
		observations.append_array([vel_dir.x, vel_dir.y, vel_dir.z, vel_len])
	return observations
