extends CharacterBody3D
class_name Player

const SPEED = 10.0
const JUMP_VELOCITY = 4.5
const TURN_SENS = 2.0

func _physics_process(delta):

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var fb = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	var turn = Input.get_action_strength("turn_left") - Input.get_action_strength("turn_right")
	rotation.y += deg_to_rad(turn*TURN_SENS)
	var direction = (transform.basis * Vector3(0.0, 0, fb)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


func chest_collected():
	print("chest collected")
