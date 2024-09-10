extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var ai_controller_3d = $AIController3D

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Set horizontal movement based on AI controller input
	velocity.x = ai_controller_3d.move.x * SPEED
	velocity.z = ai_controller_3d.move.y * SPEED
	
	# Jump if the AI controller signals to jump and the body is on the floor
	if ai_controller_3d.jump and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	move_and_slide()

func _on_area_3d_body_entered(body):
	position = Vector3(0, 1, 0)
	ai_controller_3d.reward += 1

func _on_kill_void_body_entered(body):
	position = Vector3(0, 1, 0)
