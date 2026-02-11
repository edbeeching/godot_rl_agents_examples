extends Node2D
class_name Car

@export var ai_controller: CarAIController
@export var wheel_torque_multiplier = 1500000

@onready var wheels = find_children("Wheel*")
@onready var wheel_initial_transforms = wheels.map(func(wheel): return wheel.transform)

@onready var base: RigidBody2D = $Base
@onready var base_initial_transform = base.global_transform

var requested_movement: float

var terrain_manager: TerrainManager
var car_reached_goal: bool

## Set by AI controller
var requested_torque: float

var goal_position: float


func _physics_process(delta):
	var torque = requested_torque * wheel_torque_multiplier
	for wheel_idx in range(0, wheels.size()):
		var wheel_state: PhysicsDirectBodyState2D = PhysicsServer2D.body_get_direct_state(
			wheels[wheel_idx].get_rid()
		)
		wheel_state.apply_torque(torque)

	process_car_fell_down()


func apply_wheel_torque(torque):
	if is_zero_approx(torque):
		return
	for wheel in wheels:
		wheel.apply_torque(torque)


func process_car_fell_down():
	if not ai_controller.done and base.position.y > terrain_manager.y_offset_multiplier * 1.01:
		ai_controller.game_over(-1)


func reset(position_global: Vector2):
	var base_state: PhysicsDirectBodyState2D = PhysicsServer2D.body_get_direct_state(base.get_rid())
	base_state.transform = Transform2D(0.0, position_global)
	base_state.linear_velocity = Vector2.ZERO
	base_state.angular_velocity = 0
	base.global_transform = base_state.transform

	for wheel_idx in range(0, wheels.size()):
		var wheel_state: PhysicsDirectBodyState2D = PhysicsServer2D.body_get_direct_state(
			wheels[wheel_idx].get_rid()
		)
		wheel_state.transform = base_state.transform * wheel_initial_transforms[wheel_idx]
		wheel_state.angular_velocity = 0
		wheel_state.linear_velocity = Vector2.ZERO
		wheels[wheel_idx].global_transform = wheel_state.transform
