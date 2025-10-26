# Ship2D example environment

### Boss scene:
https://github.com/user-attachments/assets/72856bb0-a935-44a5-b2a5-9ef524d56a8a

### Asteroid scene:
https://github.com/user-attachments/assets/22d36378-885b-4d4c-848e-f7fd90970bbe

For both scenes, the agent is trained with two variations, player ship shooting enabled and disabled (in which case avoidance is the main goal).

## Observations:
```gdscript
func get_raycast_obs() -> Array[float]:
	var obs: Array[float]
	for sensor in raycast_sensors:
		obs.append_array(sensor.get_observation())
	return obs


#var previous_raycast_obs: Array
func get_obs() -> Dictionary:
	var obs: Array[float]

	var raycast_obs: Array[float] = get_raycast_obs()

	obs.append_array(raycast_obs)

	var velocity_x = clampf(player.get_real_velocity().x / 3000, -1.0, 1.0)

	obs.append_array(
		[
			float(player.can_shoot),
			clampf(player.time_since_projectile_spawned / 
			player.projectile_fire_interval_seconds, 0, 1.0),
			velocity_x
		]
	)

	return {"obs": obs}
```
Note: In this updated version, there is also a shapecast based sensor for detecting bullets fired by the boss ship among the `raycast_sensors`, even though it's not technically a raycast sensor.

## Actions:
```python
func get_action_space() -> Dictionary:
	return {
		"move": {"size": 3, "action_type": "discrete"},
		"shoot": {"size": 2, "action_type": "discrete"},
	}
```

## Running inference:

If you’d just like to test the env using the pre-trained onnx model, open a test scene found in `res://scenes/test_scene` in Godot, then press `F6`.

You can control the shooting ability of the ship by turning on or off the `override can shoot always enabled` property of `BaseGameScene` in the inspector.

![image](https://github.com/user-attachments/assets/f61b4e1d-108f-4157-9089-ae5345675e22)

## Training:

There’s an included onnx file that was trained using SB3.

The hyperparameters in the example script were adjusted:

```Python
    learning_rate = 0.0002 if not args.linear_lr_schedule else linear_schedule(0.0003)
    model: PPO = PPO(
        "MultiInputPolicy",
        env,
        verbose=2,
        n_steps=2048,
        n_epochs=25,
        batch_size=512 * env.num_envs,
        target_kl=0.006,
        stats_window_size=250,
        learning_rate=learning_rate,
        tensorboard_log=args.experiment_dir,
    )
```

CL arguments used (also onnx export and model saving was used, enable as needed, add `env_path` too to set the exported executable of the platform):

```python
--env_path=path_to_exported_game_executable
--speedup=100
--n_parallel=1
--onnx_export_path=model.onnx
--timesteps=30_000_000
```
Note: training was manually stopped after ~20m steps.
Stats from the training session:

<img width="2876" height="869" alt="training_stats" src="https://github.com/user-attachments/assets/f7b5e6c1-63a8-4658-840c-bb065f94a9aa" />

This environment was made by [Ivan-267](https://github.com/Ivan-267).
