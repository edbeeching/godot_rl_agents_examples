extends Camera3D

## Camera extended to follow the lander. 

@onready var _lander = $"../Lander"._lander

func _ready():
	global_transform = Transform3D.IDENTITY.rotated_local(Vector3.LEFT, 0.25) 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var temporary_transform = Transform3D(global_transform)
	
	temporary_transform.origin = (
		_lander.global_position + global_transform.basis.y + global_transform.basis.z * 7.0
	)
	
	global_transform = global_transform.interpolate_with(temporary_transform, 10.0 * delta)
	pass
