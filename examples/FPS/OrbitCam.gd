extends Node3D

@export var max_speed : float = 1.0
var is_controlled = false

func _ready():
	CameraManager.register_orbitcam(self)

func set_control(value):
	is_controlled = value
	$Camera3D.current = value
	
	
func _process(delta):
	rotate_y(delta*max_speed)
	
	
