# Ship2D example environment


## Goal:
The ship needs to avoid asteroids for as long as possible.
The agent is trained on two scenarios, one where shooting the asteroids is possible, and one with shooting disabled.

## Observations:
```gdscript
func get_raycast_obs() -> Array[float]:
	var obs: Array[float]
	for sensor in raycast_sensors:
		obs.append_array(sensor.get_observation())
	return obs


func get_obs() -> Dictionary:
	var obs: Array[float]

	var raycast_obs: Array[float] = get_raycast_obs()

	obs.append_array(raycast_obs)

	var velocity_x = clampf(player.get_real_velocity().x / 3000, -1.0, 1.0)
	
	obs.append_array([
		float(player.can_shoot),
		clampf(player.time_since_ball_spawned / player.ball_fire_interval_seconds, 0, 1.0),
		velocity_x
	])

	return {"obs": obs}
```

## Actions:
```python
func get_action_space() -> Dictionary:
	return {
		"move": {"size": 3, "action_type": "discrete"},
		"shoot": {"size": 2, "action_type": "discrete"},
	}
```

## Running inference:

If you’d just like to test the env using the pre-trained onnx model, open `res://scenes/test_scene/test_scene.tscn` in Godot, then press `F6`.

You can control the shooting ability of the ship by turning on or off the `override can shoot always enabled` property of `BaseGameScene` in the inspector.

![image](https://github.com/user-attachments/assets/f61b4e1d-108f-4157-9089-ae5345675e22)

## Training:

There’s an included onnx file that was trained using SB3.

The hyperparameters in the example script were adjusted:

```Python
    learning_rate = 0.0003 if not args.linear_lr_schedule else linear_schedule(0.0003)
    model: PPO = PPO(
        "MultiInputPolicy",
        env,
        verbose=2,
        n_steps=128,
        n_epochs=3,
        tensorboard_log=args.experiment_dir,
        learning_rate=learning_rate,
        target_kl=0.02
    )
```

CL arguments used (also onnx export and model saving was used, enable as needed, add `env_path` too to set the exported executable of the platform):

```python
--env_path=path_to_exported_game_executable
--speedup=16
--n_parallel=4
--onnx_export_path=model.onnx
--timesteps=30_000_000
--linear_lr_schedule
```

Stats from the training session:
![training session rewards](https://github.com/user-attachments/assets/986fac4f-fcf9-470b-8809-c6018228ce43)

This environment was made by [Ivan-267](https://github.com/Ivan-267).