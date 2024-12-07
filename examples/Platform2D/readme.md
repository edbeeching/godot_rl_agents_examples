# Platform2D environment
https://github.com/user-attachments/assets/c2ca1ee6-5e67-4288-9a02-df133173dbcf

## Goal:
The player must pick up all of the coins and reach the goal, while avoiding traps and falling outside of the map.
It's not allowed to move to a lower level without first picking up all of the coins in the current one.

## Observations:
```gdscript
func get_obs() -> Dictionary:
	var obs: Array[float]

	for sensor in raycast_sensors:
		obs.append_array(sensor.get_observation())

	var player_velocity := player.get_real_velocity()
	player_velocity /= Vector2(player.speed, player.jump_velocity)

	obs.append_array(
		[
			clampf(player_velocity.x, -1.0, 1.0),
			clampf(player_velocity.y, -1.0, 1.0),
			float(player.is_on_floor())
		]
	)

	var goal_pos_global := player.map_manager.goal_position
	var player_to_goal := player.to_local(goal_pos_global)
	var goal_direction := player_to_goal.normalized()
	var goal_dist := clampf(player_to_goal.length() / 640.0, 0, 1.0)

	obs.append_array([goal_direction.x, goal_direction.y, goal_dist])
	return {"obs": obs}
```

Observations include data from multiple raycast sensors (and a grid sensor with 2 cells to detect any remaining coins left or right from the player in the same row),
player velocity, whether jumping is allowed or not (`is_on_floor()`), as well as a direction vector and distance scalar toward the goal.


## Actions:
```python
func get_action_space() -> Dictionary:
	return {
		"move": {"size": 3, "action_type": "discrete"},
		"jump": {"size": 2, "action_type": "discrete"},
	}
```
The player can stand still, move left/right, and jump.

## Running inference:

If you’d just like to test the env using the pre-trained onnx model, open `res://scenes/training_scene/inference_scene.tscn` in Godot, then press `F6`.

## Training:

There’s an included onnx file that was trained with https://github.com/edbeeching/godot_rl_agents/blob/main/examples/stable_baselines3_example.py

CL arguments used (also onnx export and model saving was used, enable as needed, add `env_path` too to set the exported executable of the platform):

```python
--speedup=32
--n_parallel=8
--timesteps=10_000_000
--linear_lr_schedule
```

Stats from the training session (success rate only):

![training_stats](https://github.com/user-attachments/assets/e799623b-c049-419d-b519-9fd9e9c6be16)
