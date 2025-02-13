extends Area3D

@export var spawn_position_manager: SpawnPositionManager
@onready var initial_transform := transform
@onready var pointer := $goal/GoalPointer


func _physics_process(delta: float) -> void:
	pointer.rotate_y(delta * 2)


func reset():
	global_transform = spawn_position_manager.get_spawn_position()
