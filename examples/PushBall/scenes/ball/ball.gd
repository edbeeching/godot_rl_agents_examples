extends RigidBody3D
class_name Ball

@export var spawn_position_manager: SpawnPositionManager


func reset():
	global_transform = spawn_position_manager.get_spawn_position()
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
