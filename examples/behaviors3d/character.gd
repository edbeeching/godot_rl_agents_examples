extends CharacterBody3D


@export var target: Node3D
const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var ai_controller = $AIController3D
var forward_backward_action: float = 0.0
var straf_left_right_action: float = 0.0
var turn_left_right_action: float = 0.0
var jump_action: bool = false


func _ready() -> void:
    ai_controller.init(self)


func _physics_process(delta: float) -> void:
    # Add the gravity.
    var drag = 1.0
    if not is_on_floor():
        velocity += get_gravity() * delta
        drag = 0.8

    # Handle jump.
      

    if get_jump_action() and is_on_floor():
        velocity.y = JUMP_VELOCITY

    # Get the input direction and handle the movement/deceleration.
    # As good practice, you should replace UI actions with custom gameplay actions.
    var direction := get_input_dir()
    if direction:
        velocity.x = direction.x * SPEED * drag
        velocity.z = direction.z * SPEED * drag
    else:
        velocity.x = move_toward(velocity.x, 0, SPEED)
        velocity.z = move_toward(velocity.z, 0, SPEED)

    # Player turning logic
    var turn = get_turn_dir()
    if turn:
        var target_rotation = rotation.y + turn
        rotation.y = move_toward(rotation.y, target_rotation, 5.0 * delta)

    move_and_slide()

func get_jump():
    if ai_controller.heuristic == "model":
        return jump_action
    else:
        return Input.is_action_just_pressed("ui_accept")


func get_input_dir() -> Vector3:
    if ai_controller.heuristic == "model":
        return (transform.basis * Vector3(straf_left_right_action, 0, forward_backward_action)).normalized()
    
    var input_dir := Input.get_vector("right", "left",  "backward", "forward")
    return (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

func get_turn_dir() -> float:
    if ai_controller.heuristic == "model":
        return turn_left_right_action

    return Input.get_action_strength("turn_left") - Input.get_action_strength("turn_right")

func get_jump_action() -> bool:
    if ai_controller.done:
        jump_action = false
        return jump_action

    if ai_controller.heuristic == "model":
        return jump_action

    return Input.is_action_just_pressed("jump")


func _on_collector_area_entered(_area: Area3D) -> void:
    ai_controller.reset_best_goal_distance()
    print("Player found collectable")

func reset():
    velocity = Vector3()
    rotation = Vector3()
    ai_controller.reset()
    target.scale = Vector3(1, 1, 1)
    target.rotation_degrees = Vector3(0, 0, 0)