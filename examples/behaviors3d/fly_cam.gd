extends Camera3D
var sensitivity: float = 0.5
var speed: float = 10.0

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sensitivity))
		rotate_object_local(Vector3(1, 0, 0), deg_to_rad(-event.relative.y * sensitivity))
	
	if event is InputEventMouse:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if event is InputEventKey:
		if event.is_action_pressed("ui_cancel"):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(delta: float) -> void:
	var direction: Vector3 = Vector3.ZERO
	if Input.is_action_pressed("forward"):
		direction += Vector3.FORWARD
	if Input.is_action_pressed("backward"):
		direction += Vector3.BACK
	if Input.is_action_pressed("left"):
		direction += Vector3.LEFT
	if Input.is_action_pressed("right"):
		direction += Vector3.RIGHT
	if Input.is_action_pressed("ui_page_up"):
		direction += Vector3.UP
	if Input.is_action_pressed("ui_page_down"):
		direction += Vector3.DOWN
	
	direction = direction.normalized()
	translate(direction * speed * delta)
