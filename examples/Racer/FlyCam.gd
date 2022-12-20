extends CharacterBody3D

@export var look_sensitivity: float = 0.005
@export var max_speed : float = 5.0
var is_controlled = false

func _ready():
	GameManager.register_flycam(self)

func set_control(value):
	is_controlled = value
	$Camera3D.current = value
	
	
func _process(delta):
	var input_dir = Input.get_vector("turn_left", "turn_right", "accelerate", "reverse")
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
	if is_controlled and event is InputEventMouseMotion:
		rotate_y(-event.relative.x * look_sensitivity)
		$Camera3D.rotate_x(-event.relative.y * look_sensitivity)
		$Camera3D.rotation.x = clamp($Camera3D.rotation.x, -PI/2, PI/2)

