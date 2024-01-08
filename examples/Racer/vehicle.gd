extends VehicleBody3D
class_name Player

const STEER_SPEED = 6.0
const STEER_LIMIT = 0.4
var steer_target = 0

@export var controlled = false
@export var engine_force_value = 40
@export var brake_force_value = 60

enum VEHICLE_TYPES {
	RedConvertible, Car, GreenJeep, PoliceCar, FireTruck, Delivery, GarbageTruck, Hatchback
}
var VEHICLE_TYPES_STRINGS = [
	"RedConvertible",
	"Car",
	"GreenJeep",
	"PoliceCar",
	"FireTruck",
	"Delivery",
	"GarbageTruck",
	"Hatchback"
]
@export var vehicle_type: VEHICLE_TYPES = VEHICLE_TYPES.RedConvertible

# ------------------ Godot RL Agents Logic ------------------------------------#
var turn_action := 0.0
var acc_action := false
var brake_action := false
var starting_position: Vector3
var starting_rotation: Vector3
var best_goal_distance
@onready var sensor = $RayCastSensor3D
@onready var ai_controller = $AIController3D


func reset():
	position = starting_position
	rotation = starting_rotation
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	GameManager.reset_waypoints(self)
	best_goal_distance = position.distance_to(GameManager.get_next_waypoint(self).position)
	ai_controller.reset()


# ----------------------------------------------------------------------------#


func get_steer_target():
	if ai_controller.heuristic == "human":
		return Input.get_axis("turn_right", "turn_left")
	else:
		return clamp(turn_action, -1.0, 1.0)


func get_accelerate_value():
	if ai_controller.heuristic == "human":
		return Input.is_action_pressed("accelerate")
	else:
		return acc_action


func get_brake_value():
	if ai_controller.heuristic == "human":
		return Input.is_action_pressed("reverse")
	else:
		return brake_action


func _ready():
	ai_controller.init(self)
	GameManager.register_player(self)
	best_goal_distance = position.distance_to(GameManager.get_next_waypoint(self).position)
	$Node/Camera3D.current = controlled
	starting_position = position
	starting_rotation = rotation

	$Meshes.set_mesh(VEHICLE_TYPES_STRINGS[vehicle_type])


func set_control(value: bool):
	controlled = value
	$Node/Camera3D.current = value


func crossed_waypoint():
	ai_controller.reward += 100.0

	best_goal_distance = position.distance_to(GameManager.get_next_waypoint(self).position)


func bonus_reward():
	print("bonus reward")
	ai_controller.reward += 50.0


func check_reset_conditions():
	if ai_controller.done:
		return

	if ai_controller.n_steps_without_positive_reward > 1000:
		print(
			(
				"resetting "
				+ VEHICLE_TYPES_STRINGS[vehicle_type]
				+ " due to n_steps_without_positive_reward > 1000"
			)
		)
		ai_controller.reward -= 10.0
		reset()
		return

	if transform.basis.y.dot(Vector3.UP) < 0.0:
		print(
			(
				"resetting "
				+ VEHICLE_TYPES_STRINGS[vehicle_type]
				+ " due to transform.basis.y.dot(Vector3.UP) < 0.0"
			)
		)
		reset()
		return

	if position.y < -5.0:
		print("resetting " + VEHICLE_TYPES_STRINGS[vehicle_type] + " due to position.y < -5.0")
		ai_controller.reward -= 10.0
		reset()
		return


func _print_goal_info():
	var next_waypoint_position = GameManager.get_next_waypoint(self).position

	var goal_distance = position.distance_to(next_waypoint_position)
	goal_distance = clamp(goal_distance, 0.0, 20.0)
	var goal_vector = (next_waypoint_position - position).normalized()
	goal_vector = goal_vector.rotated(Vector3.UP, -rotation.y)

	prints(goal_distance, goal_vector)


func _physics_process(delta):
	if ai_controller.heuristic == "human" and not controlled:
		return
	if ai_controller.needs_reset or Input.is_action_just_pressed("r_key"):
		reset()
		return
	check_reset_conditions()
	#_print_goal_info()
	var fwd_mps = (linear_velocity * transform.basis).x
	#shaping_reward()
	steer_target = get_steer_target()
	steer_target *= STEER_LIMIT
	var accelerating = false
	if get_accelerate_value():
		accelerating = true
		# Increase engine force at low speeds to make the initial acceleration faster.
		var speed = linear_velocity.length()
		if speed < 5 and speed != 0:
			engine_force = clamp(engine_force_value * 5 / speed, 0, 100)
		else:
			engine_force = engine_force_value
	else:
		engine_force = 0

	$Arrow3D.look_at(GameManager.get_next_waypoint(self).position)

	if not accelerating and get_brake_value():
		# Increase engine force at low speeds to make the initial acceleration faster.
		if fwd_mps >= -1:
			var speed = linear_velocity.length()
			if speed < 5 and speed != 0:
				engine_force = -clamp(engine_force_value * 5 / speed, 0, 100)
			else:
				engine_force = -engine_force_value
		else:
			brake = 1 * brake_force_value
	else:
		brake = 0.0

	steering = move_toward(steering, steer_target, STEER_SPEED * delta)
