extends Node3D
class_name Enemy

var speed: float = 5.0
var movement_direction: int = 1
var rotation_speed: float = 10.0

var wheels: Array[Node3D]


func _init():
	wheels.append(find_child("Wheels*"))


func _physics_process(delta):
	global_position += (-global_basis.z * speed * delta)
	update_wheels_and_visual_rotation(delta)


func on_wall_hit(_wall):
	movement_direction = -movement_direction
	rotate_y(PI)


func update_wheels_and_visual_rotation(delta):
	for wheel in wheels:
		wheel.rotate_object_local(Vector3.LEFT, speed * delta)
