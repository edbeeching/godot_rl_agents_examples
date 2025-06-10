## Item Sorting Cart Environment

The agent controls the cart (left/right movement only) and needs to catch the falling items.
Falling items are randomly assigned one of two categories, each item must be brought to the correct destination.

### Observations:
```gdscript
func get_obs() -> Dictionary:
	_player = _player as Cart

	var observations: Array = [
		n_steps / float(reset_after),
		_player.item_collected,
		_player.position.z / _playing_area_half_z_size,
		_player.get_normalized_velocity().z,
		_player.engine_force / _player.acceleration,
		(_player.item.global_position.z - _player.global_position.z) / playing_area_z_size,
		(_player.item.global_position.y - _player.global_position.y) / 15.0,
		_player.item.linear_velocity.y / 10.0,
		_player.item.linear_velocity.z / 10.0,
		(_player.destination.global_position.z - _player.global_position.z) / playing_area_z_size,
		(_player.destination2.global_position.z - _player.global_position.z) / playing_area_z_size,
		_player.item.item_category,
	]
	
	# Clamp obs to -1 to 1 range
	for obs_idx in observations.size():
		observations[obs_idx] = clampf(observations[obs_idx], -1.0, 1.0)
	
	return {"obs": observations}
```

### Action space:
```gdscript
func get_action_space() -> Dictionary:
	return {
		"acceleration" : {
			"size": 1,
			"action_type": "continuous"
		}
	}
```

### Rewards:
- Positive reward for catching a falling item,
- Positive reward for moving the cart with the item to the correct destination,
- Negative reward if an item falls to the ground,
- Negative reward if the cart goes outside the boundaries

### Running inference with the pretrained onnx model:
After opening the project in Godot, open the `res://scenes/testing_scene.tscn` and click on `Run Current Scene` or press `F6`


### Training:
The default scene (training_scene) can be used for training.
Training was done using the [SB3 Example](https://github.com/edbeeching/godot_rl_agents/blob/main/examples/stable_baselines3_example.py),
with the following modifications:

```python
if args.resume_model_path is None:
    learning_rate = 0.0001 if not args.linear_lr_schedule else linear_schedule(0.0001)
    model: PPO = PPO(
        "MultiInputPolicy",
        env,
        ent_coef=0.001,
        verbose=2,
        n_steps=512,
        batch_size=512 * env.num_envs,
        n_epochs=40,
        target_kl=0.0065,
        tensorboard_log=args.experiment_dir,
        learning_rate=learning_rate,
    )
```

Add the following command line arguments when running the script (you can adjust them as you like):
```shell
--onnx_export_path=model.onnx
--timesteps=30_000_000
--n_parallel=4
--speedup=64
```
(also add `--env_path` with the exported env path - which needs to be exported from the Godot Editor first).

Note: For the attached onnx file, training was manually stopped after `~17.7 million steps` when the `ep_mean_reward` reached around `291`.

Training stats:
![training_stats](https://github.com/user-attachments/assets/6fc3ab48-701b-4fa8-b1dd-35e3e23b3b9d)


