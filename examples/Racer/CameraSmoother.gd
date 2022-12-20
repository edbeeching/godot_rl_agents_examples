extends Node3D

#@export var running_size = 30
#
#@onready var camera : Camera3D = $Camera3D
#
#var positions := []
#var rotations := []
#
#func _ready():
#	positions.append(global_position)
#	rotations.append(global_rotation+Vector3.ONE*2*PI)
#
#
#func running_average(array:Array):
#	var s = (array[0]) /len(array)
#	for i in (len(array)-1):
#		s += (array[i]) / len(array)
#	return s
#
#func _physics_process(delta):
#	positions.append(global_position)
#
#	if len(positions) > running_size:
#		positions.pop_front()
#	camera.global_position = running_average(positions)
#
#	rotations.append(global_rotation+Vector3.ONE*2*PI)
#	if len(rotations) > running_size:
#		rotations.pop_front()
#	camera.global_rotation = running_average(rotations)-Vector3.ONE*2*PI
