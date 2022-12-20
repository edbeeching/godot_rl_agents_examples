extends PlayerState
var input_dir: Vector2

func unhandled_input(event):
	if event is InputEventMouseMotion:
		player.rotate_y(-event.relative.x * player.look_sensitivity)
		player.camera_pivot.rotate_x(-event.relative.y * player.look_sensitivity)
		player.camera_pivot.rotation.x = clamp(player.camera_pivot.rotation.x, -PI/2, PI/2)
		player.character.set_camera_angle(player.camera_pivot.rotation.x)
	
func process(delta):
	return
	
func physics_process(delta):
	# Add the gravity.
	if not player.is_on_floor():
		player.velocity.y -= player.gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		player.velocity.y = player.JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	input_dir = Input.get_vector("move_left", "move_right", 
	"move_forward", "move_backward")
	var direction = (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		player.velocity.x = direction.x * player.SPEED
		player.velocity.z = direction.z * player.SPEED
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, player.SPEED)
		player.velocity.z = move_toward(player.velocity.z, 0, player.SPEED)

	player.move_and_slide()
	
	if Input.is_action_just_pressed("ui_cancel"): 
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE else Input.MOUSE_MODE_VISIBLE

	if Input.is_action_just_pressed("shoot"):
		player.shoot()

func enter(msg: ={}):
	return
	
func exit():
	pass
