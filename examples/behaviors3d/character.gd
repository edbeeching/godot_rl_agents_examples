extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5


func _physics_process(delta: float) -> void:
	# Add the gravity.
	var drag = 1.0
	if not is_on_floor():
		velocity += get_gravity() * delta
		drag = 0.8

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED * drag
		velocity.z = direction.z * SPEED * drag
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	# Player turning logic
	var turn = Input.get_action_strength("turn_left") - Input.get_action_strength("turn_right")
	if turn:
		var target_rotation = rotation.y + turn
		rotation.y = move_toward(rotation.y, target_rotation, 5.0 * delta)

	move_and_slide()

func _on_collector_area_entered(area: Area3D) -> void:
	print("Player found collectable")
