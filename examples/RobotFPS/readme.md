# Robot FPS
An arcade-style robot FPS environment.

https://github.com/user-attachments/assets/2086cf9e-ead8-4e6b-88b2-0147e3c2d882

# Goal:

The agent needs to hit other robots while avoiding getting hit.

# Observations:

The agent uses stacked observations from an extended Raycast sensor. The sensor is modified to include information on how much any detected robot is facing toward (or away from) the agent.

Frame-stack is set to 3 by default, meaning that the Raycast data sent to the agent includes data from 2 previous steps as well as the current step.

![Raycast observations screenshot](https://github.com/user-attachments/assets/48899ec6-6f74-4fa2-956f-3c7400840752)

# Action space:

There are 4 discrete actions used by the agent:

```gdscript
func get_action_space() -> Dictionary:
	return {
		"accelerate_forward": {"size": 3, "action_type": "discrete"},
		"accelerate_sideways": {"size": 3, "action_type": "discrete"},
		"turn": {"size": 3, "action_type": "discrete"},
		"shoot": {"size": 2, "action_type": "discrete"},
	}
```

# Rewards and episode end condition:

`+1` For hitting another Robot (unless the Robot is in the protection period after respawning).

Robots have `2` HP each and the episode for a robot ends if HP reaches `0` , at which point the robot gets re-spawned to a random free position on the map.

# Running inference/testing the environment:

1. Open the project in Godot Editor
2. Open either `res://scenes/testing_scene/testing_scene.tscn` (AI vs AI) or `res://scenes/testing_scene/testing_scene_human_vs_ai.tscn` (Human VS AI)
3. Press `F6` to start the scene.

Note: For human VS AI mode, keyboard controls are:

- `WASD` or `UP/DOWN` arrows for movement,
- `LEFT/RIGHT` arrows for rotation,
- `SPACE` for shooting.

# Training:

These are the training settings used to train the included onnx file:

[SB3 example script](https://github.com/edbeeching/godot_rl_agents/blob/main/examples/stable_baselines3_example.py) was used for training, with the following changes:

```python
    model: PPO = PPO(
        "MultiInputPolicy",
        env,
        verbose=2,
        n_steps=256,
        batch_size=1024,
        target_kl=0.02,
        tensorboard_log=args.experiment_dir,
    )
```

SB3 example script cmd arguments:

```python
--speedup=32
--n_parallel=6
--timesteps=4_000_000
--onnx_export_path=model.onnx
```

This environment was made by [Ivan267.](https://github.com/Ivan-267)
