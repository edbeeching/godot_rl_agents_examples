# Ship2D environment


## Goal:
The ship needs to avoid asteroids for as long as possible.
The agent is trained on two scenarios, one where shooting the asteroids is possible, and one with shooting disabled.

## Observations:
Note: `raycast_stack_frames` is set to 2.
```gdscript
func get_obs() -> Dictionary:
	var obs: Array[float]

	var raycast_obs: Array[float] = get_raycast_obs()

	if raycast_stack_frames > 1:
		if obs_stack.is_empty():
			obs_stack.resize(1)
			obs_stack.fill(raycast_obs)

		obs_stack.remove_at(0)
		obs_stack.append(raycast_obs)
		#
		for obs_array in obs_stack:
			obs.append_array(obs_array)
	else:
		obs.append_array(raycast_obs)

	obs.append(float(player.can_shoot))
	obs.append(clampf(player.time_since_ball_spawned / player.ball_fire_interval_seconds, 0, 1.0))
	return {"obs": obs}
```

## Actions:
```python
func get_action_space() -> Dictionary:
	return {
		"move": {"size": 1, "action_type": "continuous"},
		"shoot": {"size": 1, "action_type": "continuous"},
	}
```

## Running inference:

If you’d just like to test the env using the pre-trained onnx model, open `res://scenes/test_scene/test_scene.tscn` in Godot, then press `F6`.

## Training:

There’s an included onnx file that was trained with https://github.com/edbeeching/godot_rl_agents/blob/main/examples/stable_baselines3_example.py

CL arguments used (also onnx export and model saving was used, enable as needed, add `env_path` too to set the exported executable of the platform):

```python
TODO
```

Stats from the training session:
TODO
