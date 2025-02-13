extends AnimatableBody3D

@export var spawn_position_manager: SpawnPositionManager


func reset() -> void:
	global_transform = spawn_position_manager.get_spawn_position()
