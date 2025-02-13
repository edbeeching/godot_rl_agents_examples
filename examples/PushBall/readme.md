# Push Ball
A ball-pushing robot environment.

https://github.com/user-attachments/assets/71cf8787-db48-4c9f-a6da-dbbbbaa52211

# Goal:
The robot needs to push the ball into the goal.

# Observations:
```gdscript
func get_obs() -> Dictionary:
	var observations: Array[float] = []
	for raycast_sensor in raycast_sensors:
		var obs = raycast_sensor.get_observation()
		observations.append_array(obs)

	var player_to_goal := player.to_local(player.goal.global_position)
	var player_to_goal_dir := player_to_goal.normalized()
	var player_to_goal_dist := clampf(player_to_goal.length() / 5.0, 0, 1.0)

	var player_to_ball := player.to_local(player.ball.global_position)
	var player_to_ball_dir := player_to_ball.normalized()
	var player_to_ball_dist := clampf(player_to_ball.length() / 10.0, 0, 1.0)

	var player_velocity = player.linear_velocity
	player_velocity = player.global_basis.inverse() * player_velocity
	player_velocity = player_velocity.limit_length(4) / 4

	var ball_velocity = player.ball.linear_velocity
	ball_velocity = player.global_basis.inverse() * ball_velocity
	ball_velocity = ball_velocity.limit_length(4) / 4

	(
		observations
		. append_array(
			[
				player_to_goal_dir.x,
				player_to_goal_dir.z,
				player_to_goal_dist,
				player_to_ball_dir.x,
				player_to_ball_dir.z,
				player_to_ball_dist,
				player_velocity.x,
				player_velocity.z,
				ball_velocity.x,
				ball_velocity.z,
				n_steps / float(reset_after),
			]
		)
	)

	return {"obs": observations}
```

# Action space:

There are 2 continuous actions used by the agent, for moving and turning:

```gdscript
func get_action_space() -> Dictionary:
	return {
		"move": {"size": 1, "action_type": "continuous"},
		"turn": {"size": 1, "action_type": "continuous"}
	}

```

To incentivize forward movement, the backward action is clamped in `set_action` (so moving backward is slower):

```gdscript
		player.requested_movement = clampf(action.move[0], -1.0, 0.2)
		player.requested_turn = clampf(action.turn[0], -1.0, 1.0)
```

# Rewards and episode end condition:
Reward is given when:
- The ball approaches the goal (best distance based)
- The robot approaches the ball (best distance based)
- The robot falls down or the episode times out (negative rewards in these cases)

Episode ends when:
- The ball reaches the goal
- Either the player or ball fall down
- Episode times out after a certain amount of steps (adjustable in AIController)


# Training:

These are the training settings used to train the included onnx file:

[SB3 example script](https://github.com/edbeeching/godot_rl_agents/blob/main/examples/stable_baselines3_example.py) was used for training, with the following changes:

```python
    learning_rate = 0.0001 if not args.linear_lr_schedule else linear_schedule(0.0003)
    model: PPO = PPO(
        "MlpPolicy",
        env,
        n_steps=256,
        batch_size=256 * env.num_envs,
        clip_range=0.1,
        target_kl=0.01,
        learning_rate=learning_rate,
        n_epochs=50,
        ent_coef=0.0065,
        tensorboard_log=args.experiment_dir,
        verbose=2,
    )
```

Note: Additional changes not detailed above are needed to use the MlpPolicy (`SBGSingleObsEnv` should be used), but you should be able to use the `MultiInput` policy instead.

SB3 example script cmd arguments:

```python
--n_parallel=4
--onnx_export_path=model.onnx
--timesteps=100_000_000
--save_model_path=model.zip
--speedup=20
```

Notes: 
- Training was manually stopped at around 21m steps.
- `--env_path` also needs to be set to the exported executable.

This environment was made by [Ivan267.](https://github.com/Ivan-267)


# Testing the trained onnx:
A trained onnx file is included. To test it, open the environment, then open the `res://scenes/onnx_test_scene.tscn` scene, then press `F6`.
