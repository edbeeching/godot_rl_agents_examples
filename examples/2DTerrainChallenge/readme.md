# 2D Terrain Challenge

https://github.com/user-attachments/assets/e083faf7-0afe-41af-9424-96d0d13afe56

# Goal:
The car needs to reach the goal near the end of the procedurally generated terrain
without flipping over or falling off.

# Observations:
```gdscript
func get_obs() -> Dictionary:
	var observations: Array

	var terrain_length: float = terrain_manager.get_terrain_length()
	var velocity_scale_factor: float = 0.000116667

	var car_base: RigidBody2D = car.base
	var goal_position: Vector2 = car_base.to_local(goal_area.global_position) / terrain_length
	var relative_velocity: Vector2 = (
		car_base.global_transform.basis_xform_inv(car_base.linear_velocity) * velocity_scale_factor
	)

	var angular_velocity := clampf(car_base.angular_velocity / 2.0, 0, 1.0)

	var car_orientation := car.base.global_transform.x
	(
		observations
		. append_array(
			[
				car_orientation.x,
				car_orientation.y,
				clampf(goal_position.x, -1.0, 1.0),
				clampf(goal_position.y, -1.0, 1.0),
				clampf(relative_velocity.x, -1.0, 1.0),
				clampf(relative_velocity.y, -1.0, 1.0),
				angular_velocity,
			]
		)
	)

	for sensor in raycast_sensors:
		observations.append_array(sensor.get_observation())

	return {"obs": observations}
```

# Action space:

There are 2 continuous actions used by the agent, for moving and turning:

```gdscript
func get_action_space() -> Dictionary:
	return {
		"wheel_torque": {"size": 1, "action_type": "continuous"},
	}
```


# Rewards and episode end condition:
A reward is given when:
- The car approaches the goal (best distance based)
- The car reaches the goal (ends episode)
- The car falls down (negative reward, ends episode)
- The car flips over (negative reward, ends episode)

# Training:

These are the training settings used to train the included onnx file:

[SB3 example script](https://github.com/edbeeching/godot_rl_agents/blob/main/examples/stable_baselines3_example.py) was used for training, with the following changes:

```python
    learning_rate = 0.0003 if not args.linear_lr_schedule else linear_schedule(0.0003)
    model: PPO = PPO(
        "MlpPolicy",
        env,
        n_steps=512,
        batch_size=512 * env.num_envs,
        vf_coef=0.9,
        gae_lambda=0.995,
        gamma=0.995,
        learning_rate=learning_rate,
        n_epochs=100,
        tensorboard_log=args.experiment_dir,
        verbose=2,
    )
```

Note: Additional changes not detailed above are needed to use the MlpPolicy (`SBGSingleObsEnv` should be used), but you should be able to use the `MultiInput` policy instead.

SB3 example script cmd arguments:

```python
--n_parallel=4
--onnx_export_path=model.onnx
--timesteps=10_000_000
--save_model_path=model.zip
--speedup=20
--linear_lr_schedule
--viz
```

![training session success rate](https://github.com/user-attachments/assets/037b685d-81d2-45a0-917f-9688053a92c8)

Notes: 
- If you don't need to observe the behavior during training, you can remove viz to decrease resource usage (mostly GPU).
- `--env_path` also needs to be set to the exported executable.

This environment was made by [Ivan267.](https://github.com/Ivan-267)


# Testing the trained onnx:
A trained onnx file is included. To test it, open the environment, then open the `res://scenes/test_scene.tscn` scene, then press `F6`.
