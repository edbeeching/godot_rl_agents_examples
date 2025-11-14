# Defend the goal environment

This env was based on the Score the goal env:
https://github.com/edbeeching/godot_rl_agents_examples/tree/main/examples/ScoreTheGoal

## Task:

Defend the goal.

## Observations:

- Raycast sensor that tracks walls and also invisible walls (only the robot collides with them),
- Position sensor that tracks the goal and ball,
- Velocity sensor that tracks the robot and ball,
- Jump timer,
- Turret orientation


## Actions:

```python
func get_action_space() -> Dictionary:
	return {
		"move": {"size": 3, "action_type": "discrete"},
		"jump": {"size": 2, "action_type": "discrete"},
	}
```

## Running inference:

If you’d just like to test the env using the pre-trained onnx model, 
you can open the `res://scenes/test_scene/test_scene.tscn` scene and press `F6` to run the scene.

## Training:

There’s an included onnx file that was trained with https://github.com/edbeeching/godot_rl_agents/blob/main/examples/stable_baselines3_example.py, modified to use hyperparameters as below:

```python
	learning_rate = 0.0004 if not args.linear_lr_schedule else linear_schedule(0.0003)
	model: PPO = PPO(
		"MlpPolicy",
		env,
		verbose=2,
		n_steps=512,
		n_epochs=30,
		batch_size=512 * env.num_envs,
		target_kl=0.006,
		ent_coef=0.008,
		learning_rate=learning_rate,
		tensorboard_log=args.experiment_dir,
	)
```

CL arguments used (checkpointing was also used, you can enable as needed):

```python
--timesteps=700_000
--save_model_path=model.zip
--onnx_export_path=model.onnx
```

The env was started from the Godot editor, but you can also export the env from Godot and set `env_path`.
