extends Node3D

@export var rotation_speed = 1.0

func _physics_process(delta):
	rotate_y(rotation_speed * delta)
