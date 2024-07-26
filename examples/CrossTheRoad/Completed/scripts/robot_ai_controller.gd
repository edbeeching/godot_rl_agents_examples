extends AIController3D
class_name RobotAIController

@onready var player := get_parent() as Player


func get_obs() -> Dictionary:
	var observations := Array()
	var player_pos = player.get_grid_position()

	# Determines how many grid cells the AI can observe
	# e.g. front refers to "up" looking from above,
	# and does not rotate with the robot, same with others.
	# Set to observe all cells from two rows in front of player,
	# 0 behind
	var visible_rows_in_front_of_player: int = 2
	var visible_rows_behind_the_player: int = 0

	# Set to observe the entire width of the grid on both sides
	# so it will always see all cells up to 2 rows in front.
	var visible_columns_left_of_player: int = player.map.grid_size_x
	var visible_columns_right_of_player: int = player.map.grid_size_x

	# For tiles near player we provide [direction, id] (e.g: [-1, 0])
	# direction is -1 or 1 for cars, 0 for static tiles
	# if a car is in a tile, we override the id of tile underneath

	# Car ID is the ID of the last tile + 1
	var car_id = Tile.TileNames.size()
	
	# If there is no tile placed at the grid coord, we use -1 as id
	var no_tile_id: int = -1

	# Note: We don't need to include the player position directly in obs
	# as we are always including data for cells "around" the player,
	# so the player location relative to those cells is implicitly included

	for z in range(
			player_pos.z - visible_rows_in_front_of_player,
			player_pos.z + visible_rows_behind_the_player + 1
		):
		for x in range(
				player_pos.x - visible_columns_left_of_player,
				player_pos.x + visible_columns_right_of_player + 1
			):
			var grid_pos := Vector3i(x, 0, z)
			var tile: Tile = player.map.get_tile(grid_pos)

			if not tile:
				observations.append_array([0, no_tile_id])
			else:
				var is_car: bool
				for car in player.car_manager.cars:
					if grid_pos == player.map.get_grid_position(car.global_position):
						is_car = true
						observations.append(car.current_direction)
				if is_car:
					observations.append(car_id)
				else:
					observations.append_array([0, tile.id])

	return {"obs": observations}


func get_reward() -> float:
	return reward


func _process(_delta: float) -> void:
	# In case of human control, we get the user input
	if control_mode == ControlModes.HUMAN:
		get_user_input()


func _physics_process(_delta: float) -> void:
	# Reset on timeout, this is implemented in parent class to set needs_reset to true,
	# we are re-implementing here to call player.game_over() that handles the game reset.
	n_steps += 1
	if n_steps > reset_after:
		player.game_over(0)
		player.print_game_status("Episode timed out.")


## Defines the actions for the AI agent
func get_action_space() -> Dictionary:
	return {
		"movement": {"size": 5, "action_type": "discrete"},
	}


## Applies AI control actions to the robot
func set_action(action = null) -> void:
	# We have specified discrete action type with size 5,
	# which means there are 5 possible values that the agent can output
	# for each step, i.e. one of: 0, 1, 2, 3, 4,
	# we use those to allow the agent to move in 4 directions,
	# + there is a 'no movement' action.
	# First convert to int to use match as action value is of float type.
	match int(action.movement):
		0:
			player.requested_movement = Vector3.LEFT
		1:
			player.requested_movement = Vector3.RIGHT
		2:
			player.requested_movement = Vector3.FORWARD
		3:
			player.requested_movement = Vector3.BACK
		4:
			player.requested_movement = Vector3.ZERO


## Applies user input actions to the robot
func get_user_input() -> void:
	if Input.is_action_just_pressed("move_up"):
		player.requested_movement = Vector3.FORWARD
	elif Input.is_action_just_pressed("move_right"):
		player.requested_movement = Vector3.RIGHT
	elif Input.is_action_just_pressed("move_down"):
		player.requested_movement = Vector3.BACK
	elif Input.is_action_just_pressed("move_left"):
		player.requested_movement = Vector3.LEFT
