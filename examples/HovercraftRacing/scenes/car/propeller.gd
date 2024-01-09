extends MeshInstance3D

## Provides rotating propeller animation
@export var propeller_rotation_speed := 30.0

func _physics_process(delta):
	rotate_object_local(Vector3.UP, propeller_rotation_speed * delta)
