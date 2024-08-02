# Cross The Road Env Tutorial

Learn how to use Godot RL Agents by building a grid-like cross-the-road mini-game that will be trained using Deep Reinforcement Learning!

## **Introduction:**

Welcome to this tutorial, where you will train a robot to reach the goal while navigating around trees and avoiding cars.

At the end, you will have a trained agent that can complete the game like in the video:

https://github.com/user-attachments/assets/17fb94e6-771e-42ea-a530-cea028545a67

## Objectives:

- Learn how to use Godot RL Agents by training an agent to complete a grid-like mini-game environment.

## Prerequisites and requirements:

- Recommended: Complete [Godot RL Agents](https://huggingface.co/learn/deep-rl-course/unitbonus3/godotrl) before starting this tutorial,
- Some familiarity with Godot is also recommended,
- Godot 4.3 with .NET support (tested on Beta 3, should work with newer versions),
- Godot RL Agents (you can use `pip install godot-rl` in the venv/conda env)

# The environment

![the_environment](https://github.com/user-attachments/assets/b47aec6c-0112-4ec1-898c-209ec2652cf6)

- In the environment, the robot needs to navigate around trees and cars in order to reach the goal tile successfully within the time limit.
- The positions of goal, trees and car starting position/orientation are randomized within their own grid row. The env layout can be further customized in the code (we’ll cover this in the later sections), and you can e.g. add more cars and trees to make the game more challenging.
- As it is a grid-like env, all movements are done by 1 grid coordinate at a time, and the episode lengths are relatively short.

# Getting started:

To get started, download the project by cloning [this](https://github.com/edbeeching/godot_rl_agents_examples/tree/main) repository.

We will work on the starter project, focusing on:

- Implementing the code for the `Robot` and `AIController` nodes,
- We will briefly go over how to adjust the map size,
- Finally we will train the agent and export an .onnx file of the trained agent, so that we can run inference directly from Godot.

### Open the starter project in Godot

Open Godot, click “Import” and navigate to the `Starter` folder `godot_rl_agents_examples/examples/CrossTheRoad
/Starter/`.

On first import, you may get an error message such as: 

> Unable to load addon script from path: 'res://addons/godot_rl_agents/godot_rl_agents.gd'. This might be due to a code error in that script.
Disabling the addon at 'res://addons/godot_rl_agents/plugin.cfg' to prevent further errors.
    
Just re-open the project in the editor, the error should not appear again. 

### Open the `robot.tscn` scene

> [!TIP]
> You can search for “robot” in the FileSystem search.

<img width="544" alt="robot_scene" src="https://github.com/user-attachments/assets/315fe2b9-c107-4ff0-84a9-4c5fc9352838">

This scene contains a few nodes:
- `Robot` is the main node that controls the robot
- `AIController3D` handles observations, rewards, and setting actions,
- `robot` contains the visual geometry and animation.

### Open the `Robot.gd` script for editing:

> [!TIP]
> To open the script, click on the scroll next to the `Robot` node.

You will find there are commented method names in the script that need to be implemented. Most of the provided code will contain comments explaining the implementation, but we will also provide an additional overview of the methods.

**Replace `_ready()`, `_physics_process(delta)`, `_process_movement(_delta)` and `reward_approaching_goal()` with the following implementation:**

```gdscript
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
```

A brief overview of the methods:

- In `_ready()` we reset the game on start.
- In `_process_movement()` we move the Robot, handle collision with tree tiles, goal (in this case we add a positive reward and end the episode), and cars (if a car is hit, we add 0 to the reward and end the episode).
- In `reward_approaching_goal()` we give a positive reward when the robot approaches the goal, based on best/smallest distance to the goal, which is reset for each episode/game.

**Replace `get_grid_position()`, `game_over()`, `reset()`, and `print_game_status()` with the following implementation:**

```gdscript
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
```

A brief overview of the methods:

- `get_grid_position()` tells us where the car is on the grid.
- `game_over()` takes care of resetting the player, but also ending the episode for the RL agent and resetting the AIController, and the environment (e.g. generating a new map for the next episode) as well.
- `print_game_status()` prints out game status messages (e.g. game successfully completed) in the console when this flag is enabled on the Player node in the inspector. This is disabled by default.

That’s it for the Player node. Press `CTRL + S` to save the changes, and let’s implement the AIController code.

### Open the `robot_ai_controller.gd` script for editing:

> [!TIP]
> To open the script, click on the scroll next to the `AIController3D` node.

**Replace `get_obs()` with the following implementation:**

```gdscript
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
```

In this method, we provide observations to the RL agent about the grid tiles (or cars) that are near the player. As info from grid cells near the player is provided, we don’t need to include the player position in the grid directly in the obs.

With the implementation above, the agent can “see" up to two rows in front of it (toward the goal), zero rows behind, and all of the cells left/right from the player are visible. You can adjust this as needed if you change the map size, or to experiment.

For each cell, we provide a `tile id` (e.g. 0, 1, 2, 3) so that the agent can differentiate between different tiles. If there’s a car above a specific tile, we provide the `car id` instead of the tile id, so that the agent knows there’s a car to avoid there. As cars can move and change direction, we also provide the direction (-1 or 1 for cars, 0 for tiles). We also provide `-1` as id if there’s nothing at that coordinate (out of grid boundaries).

**Replace `get_reward()`, `_process()`, `_physics_process()`, and `get_action_space()` with the following implementation:**

```gdscript
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
```

- `get_reward()` just returns the current reward value, this is used by the Godot RL Agents `sync` node to send the reward the data to the training algorithm,
- `_process()` handles user input if human control mode is selected,
- `_physics_process()` handles restarting the game on episode time out,
- `get_action_space()` defines the actions we need to receive from the RL agent to control the robot. In this case that is a discrete action with size 5 (allowing the robot to move in any of 4 directions, or stand still).

**Replace `set_action()`, and `get_user_input()` with the following implementation:**

```gdscript
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
```

- `set_action()` converts the action received from the RL agent to a movement direction for the robot.
- `get_user_input()` converts user input into a movement direction for the robot (if human control mode is selected).

Now the implementation is done and we’re ready to export the game and start training!

### Export the game for training:

You can export the game from Godot using `Project > Export`.

# Training:

### **Download a copy of the [SB3 Example script](https://github.com/edbeeching/godot_rl_agents/blob/main/examples/stable_baselines3_example.py) from the Godot RL Repository.**

### **Run training using the arguments below:**

```gdscript
stable_baselines3_example.py --timesteps=250_000 --onnx_export_path=model.onnx --env_path="PathToExportedExecutable" --n_parallel=4 --speedup=32
```

**Set the env path to the exported game and start training.**

Training time may take a while, depending on the hardware and settings. 

The `ep_rew_mean` after the 250 000 training steps should be `1.5+` for the preconfigured map layout.

In case you’d like to tweak the settings, you could change `n_parallel` to get more FPS on some computers, note this could affect the number of timesteps needed to train successfully as well. If you’re familiar with Stable Baselines 3, you can also adjust the [PPO hyperparameters](https://stable-baselines3.readthedocs.io/en/master/modules/ppo.html) by modifying the Python script.

### **Copy the onnx file or the path to the exported onnx file.**

After training completes, you will get a message in the console such as `Exporting onnx to: ...`. You can copy or move the `.onnx` file from there to the Godot project folder, or you can just copy the full path to the file.

### Open the `onnx_inference_scene.tscn` scene:

> [!TIP]
> You can search for “onnx_inference” in the FileSystem search.

Click on the Sync node, then paste the path to the onnx model file from the previous step into the `Onnx Model Path` property. You can adjust the `speed_up` optionally to make the env run faster, recommended for preview is the `0.1` default.

![onnx_scene](https://github.com/user-attachments/assets/38c25d91-6846-45de-9411-728212482628)

### Start the game and watch the agent play:

With the `onnx_inference_scene` open, press `F6` to start the game from this scene. 

> [!TIP]
> You can also open `robot.tscn`, click on the `Robot` node, and enable `Print Game Status Enabled` in inspector to see the debug info printed in the console (whether an episode was successful or not), then get back to the `onnx_inference_scene` before pressing `F6`.

The trained agent should behave similarly as in the video below:

https://github.com/user-attachments/assets/82858efb-1af0-41c5-a211-0d5a85665bf0

If so, 🎉 congratulations! 🌟 You’ve completed the tutorial successfully!

If there are issues with the performance of the agent, you could try retraining with some more time-steps. 

If there are some errors when trying to run the onnx file, check if there is an error message. You could also try importing and running the `Completed` Godot project to see if it works well, then compare for any differences.

# Customizing the map layout:

If you’d like to change the layout of the map, open the `scripts/grid_map.gd` script (you can find it in the FileSystem). 

You will find the relevant code section in the `set_cells()` method:

```gdscript
## You can set the layout by adjusting each row with set_row_cells()
## Note: Changing size after initial start is not supported
## you can change the order or rows or how many of the second tiles to add
## as long as the total size (number of rows, width) remains the same

func set_cells():
	remove_all_tiles()
	
	add_row(Tile.TileNames.orange, Tile.TileNames.goal, 1)
	add_row(Tile.TileNames.orange)
	add_row(Tile.TileNames.orange, Tile.TileNames.tree, 2)
	add_row(Tile.TileNames.road)
	add_row(Tile.TileNames.orange, Tile.TileNames.tree, 2)
	add_row(Tile.TileNames.orange)
	add_row(Tile.TileNames.orange)
	
	set_player_position_to_last_row()

	tiles_instantiated = true
```

In the code above, each `add_row()` method call adds another row to the map. The method takes 3 arguments:

- The name of the tile to use for the first/main tile of that row
- The name of the tile to use for the second tile of that row (the second tile gets randomly positioned along grid x coordinate)
- How many of the second tiles to place in that row.

For instance, a call to:

```gdscript
add_row(Tile.TileNames.orange, Tile.TileNames.tree, 2)
```

will add a grid row with mostly orange (walkable) tiles, and 2 randomly positioned trees (along the x axis).

Note that for any road segment that you add using:

```gdscript
add_row(Tile.TileNames.road)
```

a car will also be added automatically that will move along the road. When using road tiles, you shouldn’t add a second tile as this wasn’t intended by the current design. 

Here’s a more complex layout example you can try:

```gdscript
## You can set the layout by adjusting each row with set_row_cells()
## Note: Changing size after initial start is not supported
## you can change the order or rows or how many of the second tiles to add
## as long as the total size (number of rows, width) remains the same

func set_cells():
	remove_all_tiles()
	
	add_row(Tile.TileNames.orange, Tile.TileNames.goal, 1)
	add_row(Tile.TileNames.orange)
	add_row(Tile.TileNames.orange, Tile.TileNames.tree, 3)
	add_row(Tile.TileNames.road)
	add_row(Tile.TileNames.orange, Tile.TileNames.tree, 3)
	add_row(Tile.TileNames.road)
	add_row(Tile.TileNames.orange, Tile.TileNames.tree, 3)
	add_row(Tile.TileNames.road)
	add_row(Tile.TileNames.orange)
	add_row(Tile.TileNames.orange)
	
	set_player_position_to_last_row()

	tiles_instantiated = true
```

That would generate maps that looks similar to below:

![larger_map](https://github.com/user-attachments/assets/b638f4e8-d2f2-4ee4-a18c-5bac7f8b3aec)

If you’d like to shuffle the rows to create a more randomized map layout, you can try something similar to below:

```gdscript
## You can set the layout by adjusting each row with set_row_cells()
## Note: Changing size after initial start is not supported
## you can change the order or rows or how many of the second tiles to add
## as long as the total size (number of rows, width) remains the same

func set_cells():
	remove_all_tiles()
	
	# Keeps the goal row fixed
	set_row_tiles(0, Tile.TileNames.orange, Tile.TileNames.goal, 1)
	
	var row_ids = range(1, 5)
	row_ids.shuffle()
	set_row_tiles(row_ids[0], Tile.TileNames.orange, Tile.TileNames.tree, 2)
	set_row_tiles(row_ids[1], Tile.TileNames.orange, Tile.TileNames.tree, 2)
	set_row_tiles(row_ids[2], Tile.TileNames.road)
	set_row_tiles(row_ids[3], Tile.TileNames.road)
	
	# Keeps the player starting row fixed
	set_row_tiles(5, Tile.TileNames.orange)
	grid_size_z = 6
	
	set_player_position_to_last_row()

	tiles_instantiated = true
```

Note that these layouts can take longer to train. For example, I tried training the “shuffle” variant above with `n_steps=32,batch_size=256` set in the Python training script, `n_parallel=6` set as CL argument, and I've also increased the observation settings so that the agent can see more rows in front of the player, and one row behind. I’ve trained it for a couple of hours on my PC (I stopped manually, it’s possible the behavior was learned earlier). It resulted in a high success rate during onnx inference.

Some notes:

- During training, you could randomize/shuffle the row order, the number of cars (automatically set based on number of rows with road) can also change, but changing the map size (number of rows or grid width) between episodes is not supported (it’s possible to extend the script to support this case).
- While you can run inference using the same onnx you previously trained on a different map, the results may not be good (might be a bit better if training a shuffled variant to learn a more generalized behavior). Retraining might be needed.
- To see a different map layout properly, you may need to adjust the camera position in Godot editor (found in `res://scenes/game_scene.tscn`).
- Training may take longer for more complex maps. Tuning the Python script hyperparameters might help.
- When the map is larger and takes longer to complete, you may need to increase the timeout steps, this is adjustable from Godot editor as the `reset after` property of AIController3D (check screenshot below):

![reset_after](https://github.com/user-attachments/assets/bf09bb10-c4b0-4942-a04c-c2ea59c3632c)

# Conclusion:

Congrats! You’ve learned how to train a RL agent to successfully complete a grid-like env using Godot, Godot RL Agents, and Stable Baselines 3.

For more inspiration, feel free to check out our other [example environments](https://github.com/edbeeching/godot_rl_agents_examples/tree/main/examples), and our two tutorials on the HF Deep RL Course (https://huggingface.co/learn/deep-rl-course/unitbonus3/godotrl, https://huggingface.co/learn/deep-rl-course/unitbonus5/introduction).
