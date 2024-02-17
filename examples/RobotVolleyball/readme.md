## Robot Volleyball

A simple minigame arcade-style Volleyball example with AI vs AI and Human VS AI modes. 

### Observations:
- Position of the ball in robot's local reference,
- Position of the ball in the robot's goal's local reference (to tell on what side of the field the ball is in),
- Velocity of the robot in robot's local reference,
- Velocity of the ball in robot's local reference,
- Whether the jump sensor is colliding (which means that the robot can jump),
- Whether the robot is serving,
- Whether the ball has been served,
- Hit count of the ball in a row (hitting the ball more than 2 times in a row by the same robot causes a fault),
- How many steps has passed without hitting the ball (only counted if serving, there is a time limit in that case).

### Action space:
```gdscript
func get_action_space() -> Dictionary:
	return {
		"jump": {"size": 1, "action_type": "continuous"},
		"movement": {"size": 1, "action_type": "continuous"}
	}
```

### Rewards:
- Positive reward for hitting the ball once when serving,
- Negative reward if the same robot hits the ball more than 2 times in a row,
- Negative reward if the ball hits the robots own goal

### Game over / episode end conditions:
In infinite game mode or training mode, there are no specified end conditions.
It's possible to disable these modes in the GameScene node in which case a winner will be announced,
and the scores will be restarted, after a certain amount of points is reached.

### Running inference:
#### AI vs AI
Open the scene `res://scenes/testing_scenes/ai_vs_ai.tscn` in Godot Editor, and press `F6` or click on `Run Current Scene`.

#### Human vs AI
To play VS the AI, open the scene `res://scenes/testing_scenes/human_vs_ai.tscn` in Godot Editor, and press `F6` or click on `Run Current Scene`.

Controls (you can adjust them in Project Settings in Godot Editor):

![Volleyball Controls](https://github.com/edbeeching/godot_rl_agents_examples/assets/61947090/26809560-815d-4d8e-b3ea-2f539a9e1fa3)

### Training:
The default scene `res://scenes/training_scene/training_scene.tscn` can be used for training.

These were the parameters used to train the included onnx file (they can be applied by modifying [stable_baselines3_example.py](https://github.com/edbeeching/godot_rl_agents/blob/main/examples/stable_baselines3_example.py)):
```python
    policy_kwargs = dict(log_std_init=log(1.0))
    model: PPO = PPO("MultiInputPolicy", env, verbose=1, n_epochs=10, learning_rate=0.0003, clip_range=0.2, ent_coef=0.0085, n_steps=128, batch_size=160, policy_kwargs=policy_kwargs, tensorboard_log=args.experiment_dir)
```

The arguments provided to the example for training were (feel free to adjust these):
```bash
--timesteps=6_500_000
--n_parallel=5
--speedup=15
--env_path=[write the path to exported exe file here or remove this and n_parallel above for in-editor training]
--onnx_export_path=volleyball.onnx
```

