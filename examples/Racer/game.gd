extends Node3D

@export var speed_up = 1


# Called when the node enters the scene tree for the first time.
func _ready():
	Engine.physics_ticks_per_second = speed_up * 60
	Engine.time_scale = speed_up * 1.0
