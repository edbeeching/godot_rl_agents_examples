extends Node3D
class_name Player

## Whether to print the game success/failed messsages to console
@export var print_game_status_enabled: bool

## How far the robot can move per step
@export var movement_step := 2.0

@export var map: Map
@export var car_manager: CarManager

@onready var _ai_controller := $AIController3D
@onready var visual_robot: Node3D = $robot

var last_dist_to_goal

#region Set by AIController
var requested_movement: Vector3
#endregion


func _ready():
	reset()


func _physics_process(delta):
	# Set to true by the sync node when reset is requested from Python (starting training, evaluation, etc.)
	if _ai_controller.needs_reset:
		game_over()
	_process_movement(delta)


func _process_movement(_delta):
	for car in car_manager.cars:
		if get_grid_position() == map.get_grid_position(car.global_position):
			# If a car has moved to the current player position, end episode
			game_over(0)
			print_game_status("Failed, hit car while standing")

	if requested_movement:
		# Move the robot to the requested position
		global_position += (requested_movement * movement_step)
		# Update the visual rotation of the robot to look toward the direction of last requested movement
		visual_robot.global_rotation_degrees.y = rad_to_deg(atan2(-requested_movement.x, -requested_movement.z))
		
		var grid_position: Vector3i = get_grid_position()
		var tile: Tile = map.get_tile(grid_position)
		
		if not tile:
			# Push the robot back if there's no tile to move to (out of map boundary)
			global_position -= (requested_movement * movement_step)
		elif tile.id == tile.TileNames.tree:
			# Push the robot back if it has moved to a tree tile
			global_position -= (requested_movement * movement_step)
		elif tile.id == tile.TileNames.goal:
			# If a goal tile is reached, end episode with reward +1
			game_over(1)
			print_game_status("Success, reached goal")
		else:
			for car in car_manager.cars:
				if get_grid_position() == map.get_grid_position(car.global_position):
					# If the robot moved to a car's current position, end episode
					game_over(0)
					print_game_status("Failed, hit car while walking")

		# After processing the move, zero the movement for the next step
		# (only in case of human control)
		if _ai_controller.control_mode == AIController3D.ControlModes.HUMAN:
			requested_movement = Vector3.ZERO 
			
	reward_approaching_goal()


## Adds a positive reward if the robot approaches the goal
func reward_approaching_goal():
	var grid_pos: Vector3i = get_grid_position()
	var dist_to_goal = grid_pos.distance_to(map.goal_position)
	if last_dist_to_goal == null: last_dist_to_goal = dist_to_goal
	
	if dist_to_goal < last_dist_to_goal:
		_ai_controller.reward += (last_dist_to_goal - dist_to_goal) / 10.0
		last_dist_to_goal = dist_to_goal


func get_grid_position() -> Vector3i:
	return map.get_grid_position(global_position)


func game_over(reward = 0.0):
	_ai_controller.done = true
	_ai_controller.reward += reward
	_ai_controller.reset()
	reset()


func reset():
	last_dist_to_goal = null
	# Order of resetting is important:
	# We reset the map first, which sets a new player start position
	# and the road segments (needed to know where to spawn the cars)
	map.reset()
	# after that, we can set the player position
	global_position = Vector3(map.player_start_position) + Vector3.UP * 1.5
	# and also reset or create (on first start) the cars
	car_manager.reset()


func print_game_status(message: String):
	if print_game_status_enabled:
		print(message)
