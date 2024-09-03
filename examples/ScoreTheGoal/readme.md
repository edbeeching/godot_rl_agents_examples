# Score the goal environment

https://github.com/user-attachments/assets/c2763df6-5338-4eec-9e5b-4c89e3e65f51

## Goal:

The robot must push the ball into the correct goal. Only a single collision with the ball is allowed, after which the robot’s movement is disabled until the end of the episode.

## Observations:

- Position of the ball relative to the player,
- position of the each goal relative to the player,
- for each goal, whether the goal is the "correct goal" as 0 or 1,
- whether the ball was already hit in episode (movement is disabled after hitting the ball),
- observations from the wall raycast sensor (it's not allowed to hit a wall)

## Actions:

```python
func get_action_space() -> Dictionary:
	return {
		"accelerate": {"size": 1, "action_type": "continuous"},
		"steer": {"size": 1, "action_type": "continuous"},
	}
```

## Running inference:

If you’d just like to test the env using the pre-trained onnx model, you can click on the `sync` node in the training scene, then switch to `Control Mode: Onnx Inference` in the inspector on the right and start the game.

## Training:

There’s an included onnx file that was trained with https://github.com/edbeeching/godot_rl_agents/blob/main/examples/stable_baselines3_example.py, modified to use SAC with hyperparameters set as below (for instructions on using SAC, also check https://github.com/edbeeching/godot_rl_agents/pull/198):

```python
    model: SAC = SAC(
        "MlpPolicy",
        env,
        gradient_steps=8,
        verbose=2,
        tensorboard_log=args.experiment_dir,
    )
```

CL arguments used (also onnx export and model saving was used, enable as needed):

```python
--speedup=8
--n_parallel=8
```

Training was done for ~3.1 million steps with manual stopping.
