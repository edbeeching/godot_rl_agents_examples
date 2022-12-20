extends Node3D


# Called when the node enters the scene tree for the first time.
@export var speed_up = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	Engine.physics_ticks_per_second = speed_up*60 # Replace with function body.
	Engine.time_scale = speed_up * 1.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
