extends CharacterBody3D
@export var look_sensitivity: float = 0.005
@export var max_speed : float = 20.0
func _process(_delta):
	if !$Camera3D.is_current():
		return

	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction.y =  Input.get_axis("cam_down", "cam_up")
	if direction:
		velocity.x = direction.x * max_speed
		velocity.y = direction.y * max_speed
		velocity.z = direction.z * max_speed
	else:
		velocity.x = move_toward(velocity.x, 0, max_speed)
		velocity.y = move_toward(velocity.y, 0, max_speed)
		velocity.z = move_toward(velocity.z, 0, max_speed)
	
	
	move_and_slide()
	
	
func _unhandled_input(event):
	if !$Camera3D.is_current():
		return
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * look_sensitivity)
		$Camera3D.rotate_x(-event.relative.y * look_sensitivity)
		$Camera3D.rotation.x = clamp($Camera3D.rotation.x, -PI/2, PI/2)
