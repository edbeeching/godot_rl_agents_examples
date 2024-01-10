extends Camera3D
@export var robot: Robot


func _physics_process(_delta):
	global_position.z = robot.global_position.z
