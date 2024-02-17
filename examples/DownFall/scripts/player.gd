extends CharacterBody3D
class_name Player

signal reset(player:Player, end: bool)

@export var speed = 5.0
@export var acceleration = 4.0
@export var jump_speed = 5.0
@export var mouse_sensitivity = 0.0015
@export var ai_mouse_sensitivity = 0.03
@export var rotation_speed = 12.0


var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var jumping = false
var last_floor = true
var best_goal_distance := 10000.0
var goal

var turn_action = Vector2.ZERO
var jump_action = false
var move_action = Vector2.ZERO
var current_level = 0

@onready var spring_arm = $SpringArm3D
@onready var model = $MeshInstance3D
@onready var ai_controller = $AIController3D

func _ready():
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	ai_controller._player = self
	await get_tree().root.ready
	emit_signal("reset", self, false)
	
func _physics_process(delta):
	if Input.is_action_just_pressed("escape"):
		get_tree().quit()

	if Input.is_action_just_pressed("mouse_toggle"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if position.y < -10.0:
		ai_controller.reward -= 5.0
		game_over()

	if ai_controller.needs_reset:
		game_over()

	velocity.y += -gravity * delta * 2.0
	get_move_input(delta)

	move_and_slide()
	rotation.y = get_input_rotation()
	
	var horizontal_velocity = Vector2(velocity.x, velocity.z)
	# We just hit the floor after being in the air
	if is_on_floor() and not last_floor:
		jumping = false
	last_floor = is_on_floor()


	if is_on_floor() and get_jump_action():
		velocity.y = jump_speed
		jumping = true
	
	if jumping:
		$AnimatedChar.play_anim("Idle")
	else:
		if horizontal_velocity.length() > 0.1:
			$AnimatedChar.play_anim("Run")

			$AnimatedChar.rotation.y = atan2(horizontal_velocity.x, horizontal_velocity.y) - rotation.y

		else:
			$AnimatedChar.play_anim("Idle")

	

	update_reward()

func get_input_rotation():
	if ai_controller.heuristic == "model":
		rotation.x -= turn_action.y * ai_mouse_sensitivity
		rotation_degrees.x = clamp(rotation_degrees.x, -10.0, 10.0)
		rotation.y -= turn_action.x * ai_mouse_sensitivity
	return rotation.y

func get_jump_action() -> bool:
	if ai_controller.heuristic == "model":
		return jump_action

	if !$SpringArm3D/Camera3D.is_current():
		return false

	return Input.is_action_just_pressed("jump")

func get_move_input(delta):
	var vy = velocity.y
	velocity.y = 0

	var input = Vector2.ZERO

	if ai_controller.heuristic == "model":
		input = move_action
	elif $SpringArm3D/Camera3D.is_current():
		input = Input.get_vector("right", "left", "back", "forward")
		
	var dir = Vector3(input.x, 0, input.y).rotated(Vector3.UP, rotation.y)
	velocity = lerp(velocity, dir * speed, acceleration * delta)
	velocity.y = vy

func _unhandled_input(event):
	if ai_controller.heuristic == "model":
		return

	if !$SpringArm3D/Camera3D.is_current():
		return


	if event is InputEventMouseMotion:
		rotation.x -= event.relative.y * mouse_sensitivity
		rotation_degrees.x = clamp(rotation_degrees.x, -10.0, 10.0)
		rotation.y -= event.relative.x * mouse_sensitivity

func game_over(end:=false):
	ai_controller.done = true
	ai_controller.reset()
	emit_signal("reset", self, end)
	best_goal_distance = global_transform.origin.distance_to(goal.global_transform.origin)
	look_at(goal.global_transform.origin, Vector3.UP)
	rotate_y(deg_to_rad(180))

func update_reward():
	ai_controller.reward -= 0.01  # step penalty
	ai_controller.reward += shaping_reward()


func shaping_reward():
	var s_reward = 0.0
	var goal_distance = 0
	goal_distance = global_transform.origin.distance_to(goal.global_transform.origin)

	if goal_distance < best_goal_distance:
		s_reward += best_goal_distance - goal_distance
		best_goal_distance = goal_distance

	return s_reward


func hit_by_bomb():
	ai_controller.reward -= 5.0
	game_over()

func _on_hurt_box_area_entered(area:Area3D):
	if area is HitBox:
		# negative reward
		ai_controller.reward -= 5.0
		game_over()

func level_complete():
	ai_controller.reward += 10.0
	# positive reward
	game_over(true)


func activate_cam():
	$SpringArm3D/Camera3D.set_current(true)

func deactivate_cam():
	$SpringArm3D/Camera3D.set_current(false)
